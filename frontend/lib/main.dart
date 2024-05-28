import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';


import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Recommender',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MovieRecommenderPage(),
    );
  }
}


class MovieRecommenderPage extends StatefulWidget {
  @override
  _MovieRecommenderPageState createState() => _MovieRecommenderPageState();
}

class _MovieRecommenderPageState extends State<MovieRecommenderPage> {
  List<String> _movieTitles = [];
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
      final response = await http.get(Uri.parse('http://127.0.0.1:5000/movies'));
      if (response.statusCode == 200) {
        List<dynamic> titlesJson = jsonDecode(response.body);
        List<String> titles = titlesJson.map((title) => title.toString()).toList();

        setState(() {
          _movieTitles = titles;
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
      "Selected-Movie": selectedMovie
      };
    // String requestBody = jsonEncode({"title": selectedMovie});

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
    List<List<dynamic>> rows = csvData
        .trim()
        .split('\n')
        .map((row) => row.trim().split(','))
        .toList();
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
        title: Text('Movie Mate', style: TextStyle(color: Color.fromARGB(255, 0, 0, 0),fontWeight: FontWeight.bold,)),
        backgroundColor: Color.fromARGB(255, 193, 193, 21),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 10,
            child: Container(color: Color(0xFFF5F5DC))
          ),
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
                return ListTile(
                  title: Text(movieTitle),
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
                crossAxisAlignment: CrossAxisAlignment.stretch, // Ensure the column stretches to fill the container horizontally
                children: [
                  Container(
                    color: const Color(0xFFF5F5DC),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
        ],
      ),
    );
  }
}