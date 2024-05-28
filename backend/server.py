from flask import Flask, request, jsonify
import pandas as pd
import pickle

# Load the pickle files from Google Drive
cosine_sim_path = 'cosine_sim.pkl'
indices_path = 'indices.pkl'
movies_path = 'movies.csv'

with open(cosine_sim_path, 'rb') as f:
    cosine_sim = pickle.load(f)

with open(indices_path, 'rb') as f:
    indices = pickle.load(f)

# Load the movies DataFrame to get titles
movies = pd.read_csv(movies_path, sep='\t', encoding='latin-1', usecols=['movie_id', 'title', 'genres'])
titles = movies['title']

# Define the genre_recommendations function
def genre_recommendations(title):
    if title not in indices:
        return None
    idx = indices[title]
    sim_scores = list(enumerate(cosine_sim[idx]))
    sim_scores = sorted(sim_scores, key=lambda x: x[1], reverse=True)
    sim_scores = sim_scores[1:21]  # Get the top 20 similar movies
    movie_indices = [i[0] for i in sim_scores]
    return titles.iloc[movie_indices]

# Create the Flask app
app = Flask(__name__)

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

@app.route('/movies', methods=['GET'])
def get_movie_titles():
    return jsonify(titles.tolist())

if __name__ == '__main__':
    app.run(debug=True)
