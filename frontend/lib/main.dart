import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'login_signup_page.dart';
import 'collabFiltering.dart';
import 'contentBasedFiltering.dart';


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




