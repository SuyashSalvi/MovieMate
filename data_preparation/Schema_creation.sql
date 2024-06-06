CREATE TABLE users (
    user_id INT PRIMARY KEY,
    username VARCHAR(50),
    password VARCHAR(50),
    gender CHAR(1),
    age INT,
    occupation VARCHAR(50),
    zipcode VARCHAR(10)
);

CREATE TABLE movies (
    movie_id SERIAL PRIMARY KEY,
    title VARCHAR(255),
    genres VARCHAR(255)
);

CREATE TABLE ratings (
    user_id INT,
    movie_id INT,
    rating FLOAT,
    timestamp BIGINT,
    user_emb_id INT,
    movie_emb_id INT,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id)
);

SELECT * FROM users;
SELECT * FROM movies;
SELECT * FROM ratings;
