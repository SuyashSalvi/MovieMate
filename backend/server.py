from flask import Flask, request, jsonify
import pandas as pd
import pickle
import numpy as np
from sklearn.metrics.pairwise import pairwise_distances
import requests
import csv
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)

# Configure the database connection string
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://postgres:root@localhost:5432/rec_system'
db = SQLAlchemy(app)

class Movie(db.Model):
    __tablename__ = 'movies'
    movie_id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String)
    genres = db.Column(db.String)

# Replace 'YOUR_API_KEY' with your actual TMDB API key
API_KEY = '5c0c6953531ffa135b20bd515a3926f2'
TMDB_BASE_URL = 'https://api.themoviedb.org/3'

def fetch_movie_poster():
    moviePoster_list = {}
    for title in titles:
        print(title)
        movie_name = title
        if not movie_name:
            # return jsonify({'error': 'Movie name not provided'})
            continue

        # Search for the movie
        search_url = f"{TMDB_BASE_URL}/search/movie"
        params = {'api_key': API_KEY, 'query': movie_name}
        response = requests.get(search_url, params=params)
        data = response.json()
        # print(data)
        if(data['results']==[]):
            continue
        # Extract the movie details
        if data['results']:
            movie_id = data['results'][0]['id']
            poster_path = data['results'][0]['poster_path']
            poster_url = f"https://image.tmdb.org/t/p/w500{poster_path}"
            # return jsonify({'movie_name': movie_name, 'poster_url': poster_url})
            moviePoster_list[title] = poster_url
            print(title, poster_url)
    # print(moviePoster_list)
    # Specify the file path
    file_path = './movie_posters.csv'

    # Save the dictionary to a CSV file
    with open(file_path, 'w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(['movie', 'poster'])  # Write header row
        for movie, poster in moviePoster_list.items():
            writer.writerow([movie, poster])




######################################

# Load the pickle files from Google Drive
cosine_sim_path = 'cosine_sim.pkl'
indices_path = 'indices.pkl'
movies_path = 'movies.csv'
ratings_path = 'ratings.csv'

with open(cosine_sim_path, 'rb') as f:
    cosine_sim = pickle.load(f)

with open(indices_path, 'rb') as f:
    indices = pickle.load(f)

# Load the movies DataFrame to get titles
movies = pd.read_csv(movies_path, sep='\t', encoding='latin-1', usecols=['movie_id', 'title', 'genres'])
ratings = pd.read_csv(ratings_path, sep='\t', encoding='latin-1', usecols=['user_id','movie_id','rating', 'timestamp','user_emb_id','movie_emb_id'])
titles = movies['genres']

# Define the genre_recommendations function
def genre_recommendations(title):
    print(titles)
    print(movies)
    if title not in indices:
        return None
    idx = indices[title]
    sim_scores = list(enumerate(cosine_sim[idx]))
    sim_scores = sorted(sim_scores, key=lambda x: x[1], reverse=True)
    sim_scores = sim_scores[1:21]  # Get the top 20 similar movies
    movie_indices = [i[0] for i in sim_scores]
    return titles.iloc[movie_indices]

# Load pickle files and data for collaborative filtering
user_prediction_path = 'user_prediction.pkl'  # Path to pickle file containing user predictions

with open(user_prediction_path, 'rb') as f:
    user_prediction = pickle.load(f)

# Convert user_prediction to a DataFrame
# Convert user_prediction to a DataFrame and set the index to user_id
user_ids = np.arange(user_prediction.shape[0])
user_prediction_df = pd.DataFrame(user_prediction, index=user_ids)
print(user_prediction_df)
# Define function for collaborative filtering recommendations
# def collaborative_filtering_recommendations(user_id):
#     # Get top recommended movies for the given user_id
#     top_movies_indices = user_prediction[user_id].argsort()[-20:][::-1]
#     return titles.iloc[top_movies_indices]



@app.route('/recommend', methods=['GET'])
def recommend():
    # title = request.args.get('title')
    title = request.headers.get('Selected-Movie')
    print(title)
    if title not in indices:
        return jsonify({'error': 'Movie not found'}), 404

    recommendations = genre_recommendations(title)
    if recommendations is None:
        return jsonify({'error': 'Movie not found'}), 404
    return jsonify(recommendations.tolist())

@app.route('/collaborative_recommend', methods=['GET'])
def collaborative_recommend():
    # user_id = request.args.get('test')
    user_id = request.headers.get('User-Id')
    if(user_id==None):
        return jsonify({'error': 'UserID not found'}), 404
    # user_id = request.headers.get('User-Id')
    user_id = int(user_id)
    
    if user_id not in user_prediction_df.index:
        return jsonify({'error': 'User not found'}), 404
    
    user_data = ratings[ratings.user_id == user_id]
    user_full = (user_data.merge(movies, how='left', left_on='movie_id', right_on='movie_id').
                 sort_values(['rating'], ascending=False))
    recommendations = movies[~movies['movie_id'].isin(user_full['movie_id'])]

    top_recommendations = recommendations.head(20)
    return top_recommendations.to_json(orient='records', lines=True)

@app.route('/recommend_new_user', methods=['POST'])
def recommend_new_user():
    data = request.json
    print(data)
    user_ratings = data.get('user_ratings')
    # Filter out movies already rated by the user
    rated_movie_ids = user_ratings.keys()
    unrated_movies = movies[~movies['movie_id'].isin(rated_movie_ids)]
    
    # Calculate similarity between rated movies and all other movies
    movie_similarity = np.zeros(len(unrated_movies))
    for i, (_, rated_rating) in enumerate(user_ratings.items()):
        rated_movie_id = int(i)
        rated_movie_genres = movies[movies['movie_id'] == rated_movie_id]['genres'].iloc[0]
        for j, (_, unrated_movie) in enumerate(unrated_movies.iterrows()):
            unrated_movie_id = unrated_movie['movie_id']
            unrated_movie_genres = unrated_movie['genres']
            # Calculate similarity (for simplicity, just count number of common genres)
            similarity_score = len(set(rated_movie_genres.split('|')).intersection(unrated_movie_genres.split('|')))
            movie_similarity[j] += similarity_score * rated_rating
    
    # Sort movies based on similarity scores
    unrated_movies['similarity'] = movie_similarity
    recommended_movies = unrated_movies.sort_values(by='similarity', ascending=False).head(20)
    recommended_movies = titles.iloc[recommended_movies]
    # print(recommended_movies)
    return jsonify(recommended_movies.to_dict(orient='records'))


@app.route('/recommend_new_user_CF', methods=['POST'])
def recommend_movies_for_new_user():
    data = request.json
    print(data)
    user_ratings = data.get('user_ratings')
    # Create a unique ID for the new user
    new_user_id = ratings['user_id'].max() + 1
    
    # Create a DataFrame for the new user's ratings
    new_ratings = pd.DataFrame({
        'user_id': [new_user_id] * len(user_ratings),  # Assign new_user_id to all new ratings
        'movie_id': list(user_ratings.keys()),         # List of movie IDs
        'rating': list(user_ratings.values())          # Corresponding list of ratings
    })
    
    # Combine existing ratings with new user's ratings
    updated_ratings = pd.concat([ratings, new_ratings], ignore_index=True)

    # Create a user-item matrix
    user_item_matrix = updated_ratings.pivot(index='user_id', columns='movie_id', values='rating').fillna(0)
    
    # Calculate user similarity using Pearson correlation
    user_similarity = 1 - pairwise_distances(user_item_matrix, metric='correlation')
    user_similarity[np.isnan(user_similarity)] = 0

    # Function to predict ratings
    def predict_ratings(ratings, similarity, type='user'):
        if type == 'user':
            mean_user_rating = ratings.mean(axis=1)
            ratings_diff = (ratings - mean_user_rating[:, np.newaxis])
            pred = mean_user_rating[:, np.newaxis] + similarity.dot(ratings_diff) / np.array([np.abs(similarity).sum(axis=1)]).T
        elif type == 'item':
            pred = ratings.dot(similarity) / np.array([np.abs(similarity).sum(axis=1)])
        return pred
    
    # Predict ratings for the new user
    user_prediction = predict_ratings(user_item_matrix.values, user_similarity, type='user')
    new_user_predicted_ratings = user_prediction[new_user_id - 1]
    
    # Get all movies the new user has not rated
    unrated_movie_ids = user_item_matrix.columns[user_item_matrix.loc[new_user_id] == 0]
    
    # Create a DataFrame for the recommended movies
    recommended_movies = movies[movies['movie_id'].isin(unrated_movie_ids)]
    
    # Assign predicted ratings to the recommended movies
    recommended_movies['predicted_rating'] = recommended_movies['movie_id'].map(lambda x: new_user_predicted_ratings[user_item_matrix.columns.get_loc(x)])

    # Sort and return the top N recommendations
    recommended_movies = recommended_movies.sort_values(by='predicted_rating', ascending=False).head(20)
    # Extract movie titles from recommended_movies DataFrame
    print(recommended_movies)
    recommended_movies = recommended_movies['genres'].tolist()
    # recommended_movies = titles.iloc[recommended_movies]
    # recommended_movies_df = titles[titles['title'].isin(recommended_movies)]
    # print(recommended_movie_titles)
    return recommended_movies

@app.route('/movies', methods=['GET'])
def get_movie_titles():
    movies = Movie.query.all()
    titles = [movie.title for movie in movies]
    return jsonify(titles)

if __name__ == '__main__':
    app.run(debug=True)
