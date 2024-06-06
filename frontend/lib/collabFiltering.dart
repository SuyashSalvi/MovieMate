import 'package:flutter/material.dart';
import 'main.dart'; 
import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'login_signup_page.dart';

class NewUserPage extends StatefulWidget {
  @override
  _NewUserPageState createState() => _NewUserPageState();
}

class _NewUserPageState extends State<NewUserPage> {
  List<String> _movieTitles = [];
  Map<String, double> _userRatings = {};
  List<String> _recommendedMoviesCF = [];
  bool _fetchingRecommendations = false;

  @override
  void initState() {
    super.initState();
    _loadMovieTitles();
  }

  Future<void> _loadMovieTitles() async {
    try {
      final response =
          await http.get(Uri.parse('http://127.0.0.1:5000/movies'));
      if (response.statusCode == 200) {
        List<dynamic> titlesJson = jsonDecode(response.body);
        List<String> titles =
            titlesJson.map((title) => title.toString()).toList();

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

  Future<void> _getRecommendations() async {
     setState(() {
    _fetchingRecommendations = true;
    });
    String apiUrl = "http://127.0.0.1:5000/recommend_new_user_CF";
    Map<String, dynamic> requestBody = {
      "user_ratings": _userRatings,
      "num_recommendations": 20
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        setState(() {
          _recommendedMoviesCF =
              List<String>.from(jsonDecode(response.body));
        });
      } else {
        print("Error fetching recommendations: ${response.statusCode}");
      }
    } catch (e) {
      print("Network error: $e");
    }
    setState(() {
      _fetchingRecommendations = false; // Set back to false on error
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rate Movies'),
        backgroundColor: Color.fromARGB(255, 193, 193, 21),
      ),
      body: Column(
        children: [
          SizedBox(height: 10, child: Container(color: Color(0xFFF5F5DC))),
          Expanded(
            child: ListView.builder(
              itemCount: _movieTitles.length,
              itemBuilder: (context, index) {
                String movieTitle = _movieTitles[index];
                return ListTile(
                  title: Text(movieTitle),
                  trailing: DropdownButton<double>(
                    value: _userRatings[movieTitle],
                    items: [1, 2, 3, 4, 5]
                        .map((rating) => DropdownMenuItem<double>(
                              value: rating.toDouble(),
                              child: Text(rating.toString()),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _userRatings[movieTitle] = value!;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _fetchingRecommendations ? null : _getRecommendations,
            style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50), // Sets the button to take full width and a height of 50
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // No rounded corners
                  ),
                ),
            child: _fetchingRecommendations
                ? Text('Processing....... Movies will be suggested in a moment, please stay with us!')
                : Text('Get Recommendations'),
          ),
          SizedBox(
            height: 300.0,
            child: Container(
              width: double.infinity,
              color: const Color(0xFFF5F5DC),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      itemCount: _recommendedMoviesCF.length,
                      itemBuilder: (context, index) {
                        String recommendedMovie = _recommendedMoviesCF[index];
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
