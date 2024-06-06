import pandas as pd
import psycopg2
from psycopg2.extras import execute_values
import chardet

# Database connection details
db_params = {
    'dbname': 'rec_system',
    'user': 'postgres',
    'password': 'root',
    'host': 'localhost',
    'port': '5432'
}

# Connect to the database
conn = psycopg2.connect(**db_params)
cur = conn.cursor()

column_names = ['user_id', 'gender', 'age', 'occupation','zipcode','age_desc','occ_desc']
# Load CSV data into DataFrames
users_df = pd.read_csv('./users.csv', names=column_names,sep='\t', skiprows=1)
# movies_df = pd.read_csv('./movies.csv')
column_names = ['movie_id',	'title','genres']
# Detect encoding of the CSV file
with open('./movies.csv', 'rb') as file:
    result = chardet.detect(file.read())

encoding = result['encoding']

# Read the CSV file, handling bad lines and filling irregular rows with NaN
try:
    movies_df = pd.read_csv('./movies.csv',encoding=encoding,names=column_names,on_bad_lines='skip',engine='python',sep='\t', skiprows=1)
except UnicodeDecodeError:
    print("Failed to read the CSV file with detected encoding.")
    # Try another encoding if necessary
    movies_df = pd.read_csv(
        './movies.csv',
        encoding='ISO-8859-1',
        names=column_names,  # Use this if your CSV does not have headers
        on_bad_lines='skip',  # Skip rows with bad lines
        engine='python',  # Use the Python engine to handle more complex parsing scenarios
        sep=',',  # Specify the separator, adjust if necessary
        error_bad_lines=False  # Skip bad lines (deprecated but sometimes still effective)
    )

column_names = ['user_id', 'movie_id', 'rating', 'timestamp','user_emb_id','movie_emb_id']
ratings_df = pd.read_csv('./ratings.csv',names=column_names,sep='\t', skiprows=1)


# Preprocess users_df to select required columns
users_df = users_df[['user_id', 'gender', 'age', 'occ_desc', 'zipcode']]
ratings_df = ratings_df[['user_id', 'movie_id', 'rating', 'timestamp']]

# Insert data into users table
# users_records = users_df.to_records(index=False)
# users_values = [tuple(row) for row in users_records]

# Convert DataFrame to list of dictionaries
users_records = users_df.to_dict(orient='records')

# Convert numpy.int64 to int
for record in users_records:
    record['user_id'] = int(record['user_id'])
    record['age'] = int(record['age'])

# Insert data into users table
execute_values(cur, "INSERT INTO users (user_id, gender, age, occupation, zipcode) VALUES %s", [tuple(record.values()) for record in users_records])




# execute_values(cur, "INSERT INTO users (user_id, gender, age, occupation, zipcode) VALUES %s", users_records)

# Insert data into movies table
# movies_records = movies_df.to_records(index=False)
# movies_values = [tuple(row) for row in movies_records]
# execute_values(cur, "INSERT INTO movies (movie_id, title, genres) VALUES %s", movies_values)

# Convert DataFrame to list of dictionaries
movies_records = movies_df.to_dict(orient='records')

# Insert data into movies table
execute_values(cur, "INSERT INTO movies (movie_id, title, genres) VALUES %s", [tuple(record.values()) for record in movies_records])


# Insert data into ratings table
# ratings_records = ratings_df.to_records(index=False)
# ratings_values = [tuple(row) for row in ratings_records]
# execute_values(cur, "INSERT INTO ratings (user_id, movie_id, rating, timestamp) VALUES %s", ratings_values)

# Convert DataFrame to list of dictionaries
ratings_records = ratings_df.to_dict(orient='records')

# Convert numpy.int64 to int
for record in ratings_records:
    record['user_id'] = int(record['user_id'])
    record['movie_id'] = int(record['movie_id'])
    record['rating'] = int(record['rating'])
    record['timestamp'] = int(record['timestamp'])  # Assuming timestamp is also integer

# Insert data into ratings table
execute_values(cur, "INSERT INTO ratings (user_id, movie_id, rating, timestamp) VALUES %s", [tuple(record.values()) for record in ratings_records])


# Commit the transaction
conn.commit()

# Close the connection
cur.close()
conn.close()
