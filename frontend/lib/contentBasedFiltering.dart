
import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'login_signup_page.dart';
import 'collabFiltering.dart';


class MovieRecommenderPage extends StatefulWidget {
  @override
  _MovieRecommenderPageState createState() => _MovieRecommenderPageState();
}

class _MovieRecommenderPageState extends State<MovieRecommenderPage> {
  List<String> _movieTitles = [];
  Map<String, String> _moviePosters = {};
  List<String> _recommendedMovies = [];
  late String _selectedMovie;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadMovieTitles();
  }

  Future<void> _loadMovieTitles() async {
    // Fetch movie titles from the API
    try {
      final response =
          await http.get(Uri.parse('http://127.0.0.1:5000/movies'));
      if (response.statusCode == 200) {
        List<dynamic> titlesJson = jsonDecode(response.body);
        List<String> titles =
            titlesJson.map((title) => title.toString()).toList();
        // Load and parse the CSV file
        final csvString = await rootBundle.loadString('assets/movie_posters.csv');
        List<List<dynamic>> csvData = CsvToListConverter().convert(csvString);

        // Convert CSV data to a map
        Map<String, String> moviePosters = {};
        for (var row in csvData.skip(1)) { // Skip the header row
          String movie = row[0];
          String poster = row[1];
          moviePosters[movie] = poster;
        }

        setState(() {
          _movieTitles = titles;
          _moviePosters = moviePosters;
          // _moviePosters = {'Casino (1995)':'https://image.tmdb.org/t/p/w500/4TS5O1IP42bY2BvgMxL156EENy.jpg'};
        });
      } else {
        print('Failed to load movie titles: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading movie titles: $e');
    }
  }

  Future<void> _getRecommendedMovies(String selectedMovie) async {
    // Call the Flask API to get recommended movies
    String apiUrl = "http://127.0.0.1:5000/recommend";
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Selected-Movie": selectedMovie.toString()
    };
    // String requestBody = jsonEncode({"title": selectedMovie});
    print(headers);
    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);

      if (response.statusCode == 200) {
        setState(() {
          _recommendedMovies = List<String>.from(jsonDecode(response.body));
        });
      } else {
        // Handle error
        print("Error fetching recommended movies: ${response.statusCode}");
      }
    } catch (e) {
      // Handle network error
      print("Network error: $e");
    }
  }

  // Define csvToList method
  List<List<dynamic>> csvToList(String csvData) {
    List<List<dynamic>> rows =
        csvData.trim().split('\n').map((row) => row.trim().split(',')).toList();
    return rows;
  }

  void _searchMovies(String query) {
    List<String> filteredMovies = [];
    if (query.isEmpty) {
      _loadMovieTitles();
    } else {
      filteredMovies = _movieTitles
          .where((title) => title.toLowerCase().contains(query.toLowerCase()))
          .toList();
      setState(() {
        _movieTitles = filteredMovies;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movie Mate',
            style: TextStyle(
              color: Color.fromARGB(255, 0, 0, 0),
              fontWeight: FontWeight.bold,
            )),
        backgroundColor: Color.fromARGB(255, 193, 193, 21),
      ),
      body: Column(
        children: [
          SizedBox(height: 10, child: Container(color: Color(0xFFF5F5DC))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0),
            child: TextField(
              controller: _searchController,
              onChanged: _searchMovies,
              decoration: InputDecoration(
                hintText: 'Search for a movie...',
                filled: true,
                fillColor: Color(0xFFF5F5DC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: _movieTitles.length,
              itemBuilder: (context, index) {
                String movieTitle = _movieTitles[index];
                String moviePoster = _moviePosters[movieTitle] ?? 'assets/static.jpg';
                return ListTile(
                  title: Text(movieTitle),
                  //  leading: Image.network(
                  //   moviePoster,
                  //   width: 50,
                  //   height: 50,
                  // ),
                  leading: _buildMoviePoster(moviePoster),
                  trailing: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedMovie = movieTitle;
                      });
                      _getRecommendedMovies(movieTitle);
                    },
                    child: Text('Like'),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            height: 300.0, // Specify the desired height
            child: Container(
              width: double.infinity,
              color: const Color(0xFFF5F5DC),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment
                    .stretch, // Ensure the column stretches to fill the container horizontally
                children: [
                  Container(
                    color: const Color(0xFFF5F5DC),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: const Text(
                      'Recommended Movies',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _recommendedMovies.length,
                      itemBuilder: (context, index) {
                        String recommendedMovie = _recommendedMovies[index];
                        return ListTile(
                          title: Text(recommendedMovie),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
     ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginSignupPage()),
              );
            },
            child: Text('Login/ SignUp', style: TextStyle(fontSize: 18),),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50), // Sets the button to take full width and a height of 50
            ),
            ),
        ],
      ),
    );
  }
}
Widget _buildMoviePoster(String posterPath) {
  if (posterPath.startsWith('http')) {
    // If poster path is a URL, use Image.network
    return Image.network(
      posterPath,
      width: 50,
      height: 100,
    );
  } else {
    // If poster path is a local file path, use Image.asset
    return Image.asset(
      posterPath,
      width: 50,
      height: 50,
    );
  }
}
