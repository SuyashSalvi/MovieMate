from flask_sqlalchemy import SQLAlchemy

# Initialize the SQLAlchemy database object
db = SQLAlchemy()

class Movie(db.Model):
    __tablename__ = 'movies'
    movie_id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String)
    genres = db.Column(db.String)