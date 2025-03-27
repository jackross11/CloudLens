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
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: handleSignIn,
              child: Text('Login'),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: navigateToSignUpPage,
              child: Text("Don't have an account? Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
