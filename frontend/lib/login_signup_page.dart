import 'package:flutter/material.dart';
import 'main.dart';  
import 'collabFiltering.dart';

class LoginSignupPage extends StatefulWidget {
  @override
  _LoginSignupPageState createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> {
  final TextEditingController _loginUsernameController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();
  final TextEditingController _signupUsernameController = TextEditingController();
  final TextEditingController _signupPasswordController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _zipcodeController = TextEditingController();
  String? _selectedGender;

  Future<void> _login() async {
    // Implement your login logic here
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => NewUserPage()),
    );
  }

  Future<void> _signup() async {
    // Implement your signup logic here
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => NewUserPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login/SignUp'),
        backgroundColor: Color.fromARGB(255, 193, 193, 21),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Login',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              TextField(
                controller: _loginUsernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: _loginPasswordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: Text('Login'),
              ),
              SizedBox(height: 10), // Add this line
              Divider(), // Add this line
              SizedBox(height: 10),
              Text(
                'Sign Up',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              TextField(
                controller: _signupUsernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: _signupPasswordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                hint: Text('Select Gender'),
                items: ['Male', 'Female', 'Other']
                    .map((gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value!;
                  });
                },
                decoration: InputDecoration(labelText: 'Gender'),
              ),
              TextField(
                controller: _ageController,
                decoration: InputDecoration(labelText: 'Age'),
              ),
              TextField(
                controller: _occupationController,
                decoration: InputDecoration(labelText: 'Occupation'),
              ),
              TextField(
                controller: _zipcodeController,
                decoration: InputDecoration(labelText: 'Zipcode'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signup,
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
