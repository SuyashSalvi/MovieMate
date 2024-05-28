# Movie Mate - Movie Recommendation System with Content-Based and Collaborative Filtering

## Overview

**Movie Recommendation System** aims to answer the frequently asked question: "What movie should I watch this evening?" Using two widely used recommendation techniques, Content-Based Filtering and Collaborative Filtering, this project builds a robust system to suggest movies based on user preferences and behaviors.

From Netflix to Hulu, recommendation systems are crucial for providing personalized content to modern consumers. These systems are not limited to movies but also extend to various products and services like Amazon (Books, Items), Pandora/Spotify (Music), Google (News, Search), and YouTube (Videos).

This project implements both Content-Based and Collaborative Filtering recommendation systems to suggest movies and evaluates their performance to determine which one is more effective.

## Key Objectives

After exploring this project, you will understand:

- The MovieLens dataset problem for recommender systems.
- How to load and process the data.
- How to perform exploratory data analysis.
- The two main types of recommendation engines.
- How to develop a content-based recommendation model based on movie genres.
- How to develop a collaborative filtering model based on user ratings.
- Alternative approaches to improve existing models.

## The MovieLens Dataset

The MovieLens Dataset is a commonly used dataset for building Recommender Systems. The version used in this project (1M) contains 1,000,209 anonymous ratings of approximately 3,900 movies by 6,040 users. The data was collected by GroupLens researchers and released in February 2003. Each user has rated at least 20 movies.

The dataset includes three files: `movies.dat`, `ratings.dat`, and `users.dat`. These files have been converted into CSV format for easier handling, as detailed in the Data Processing Notebook.

## Types of Recommendation Engines

### 1. Content-Based Filtering

Content-Based Filtering recommends items based on the similarity between items. If a user likes a particular item, they are likely to enjoy similar items. This approach relies on the attributes of items to make recommendations.

- **User Profile**: Generated based on user-provided data (e.g., movie ratings).
- **Recommendation**: Items similar to those the user has liked are suggested.
- **Accuracy**: Improves as the user provides more inputs or actions on recommendations.

### 2. Collaborative Filtering

Collaborative Filtering recommends items based on past behavior and user similarities, rather than item attributes.

- **User Behavior**: Analyzes past preferences and choices to find similarities between users.
- **Recommendation**: Items liked by similar users are suggested.
- **Types**:
  - **Memory-Based**: Focuses on similarities between users or items using statistical techniques.
  - **Model-Based**: Utilizes machine learning models to predict user preferences.

In this project, we focus on Memory-Based Collaborative Filtering.

## Project Structure

- **Data Processing Notebook**: Steps to convert original data files into CSV format.
- **Content-Based Model**: Implementation of a content-based recommendation system using movie genres.
- **Collaborative Filtering Model**: Implementation of a memory-based collaborative filtering system using user ratings.
- **Evaluation**: Comparison of the two systems to determine which performs better.

## Getting Started

To run this project, follow these steps:

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/yourusername/movie-recommendation-system.git
   cd movie-recommendation-system
   ```

2. **Install Dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

3. **Run the Notebooks**:
   - Open the Jupyter notebooks in your preferred environment.
   - Follow the instructions in each notebook to process data, build models, and evaluate results.

## Conclusion

This project demonstrates how to build and evaluate movie recommendation systems using Content-Based and Collaborative Filtering techniques. By leveraging the MovieLens dataset, we can develop models that provide personalized movie suggestions, enhancing user experience.

Feel free to explore the notebooks, experiment with different models, and adapt the system to your specific needs. Happy recommending!

---

For any questions or contributions, please open an issue or submit a pull request on GitHub.

![Netflix](https://upload.wikimedia.org/wikipedia/commons/0/08/Netflix_2015_logo.svg)
