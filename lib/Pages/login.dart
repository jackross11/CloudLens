import 'package:cloud_lens/Pages/main_page.dart';
import 'package:cloud_lens/Pages/signup.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {

  const LoginPage({
    super.key,
  });

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Sign in method using Cognito
  Future<void> signIn(String email, String password) async {
    // todo remove api from source !!! but lazy
    const String url = 'https://cognito-idp.us-east-1.amazonaws.com/'; // Make sure the region is correct
    final String userPoolId = "us-east-1_K5efHuCAz";
    final String clientId = "4nbhkl6tj0d8ihr0agq5m054jl";

    final body = json.encode({
      'ClientId': clientId,
      'AuthFlow': 'USER_PASSWORD_AUTH',
      'AuthParameters': {
        'USERNAME': email,
        'PASSWORD': password,
      },
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/x-amz-json-1.1',
          'X-Amz-Target': 'AWSCognitoIdentityProviderService.InitiateAuth',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        // Handle the response, for example, extract tokens
        // Navigate to the Favorites Page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      } else {
        print('Sign-in failed: ${response.body}');
      }
    } catch (e) {
      print('Error signing in: $e');
    }
  }

  // Handle sign-in button click
  void handleSignIn() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    
    if (email.isNotEmpty && password.isNotEmpty) {
      signIn(email, password);
    } else {
      // Show a warning message if email or password is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter both email and password")),
      );
    }
  }

    void navigateToSignUpPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignupPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // page icon
              Container(
                margin: const EdgeInsets.symmetric(vertical: 30.0),
                child:
                  Center(
                    child:
                    Image.asset(
                      'assets/icon.png',
                      height: 175.0,
                      width: 175.0,
                    ),
                  ),
              ),

              // email input
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 2)
                    )
                  ]
                ),
                child:
                  TextField(
                    decoration: InputDecoration(
                      icon: Icon(
                        Icons.email,
                      ),
                      hintText: "Email",
                    ),
                    controller: emailController,
                  ),
              ),
              SizedBox(height: 20.0),

              // password input
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30.0),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 2)
                      )
                    ]
                ),
                child:
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.lock,
                    ),
                    hintText: "Password",
                  ),
                  obscureText: true,
                ),
              ),
              SizedBox(height: 30),

              // login button
              ElevatedButton(
                onPressed: handleSignIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  elevation: 5.0,
                  minimumSize: Size(double.infinity, 45)
                ),
                child: Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              SizedBox(height: 15.0),

              // divider
              Row(
                children: [
                  Expanded(
                    child: Container(
                        margin: const EdgeInsets.only(left: 10.0, right: 20.0),
                        child: Divider(
                          color: Colors.deepPurple,
                          height: 36,
                        )),
                  ),
                  Text(
                    "OR",
                    style: TextStyle(
                      color: Colors.deepPurple,
                    ),
                  ),
                  Expanded(
                    child: Container(
                        margin: const EdgeInsets.only(left: 20.0, right: 10.0),
                        child: Divider(
                          color: Colors.deepPurple,
                          height: 36,
                        )),
                  ),
                ]
              ),
              SizedBox(height: 15.0),

              // sign up button
              ElevatedButton(
                onPressed: navigateToSignUpPage,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    elevation: 5.0,
                    minimumSize: Size(double.infinity, 45)
                ),
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ],
          )
      ),
    );
  }
}
