import 'package:cloud_lens/Pages/main_page.dart';
import 'package:cloud_lens/Pages/signup.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  final Future<void> Function(BuildContext) signOutCallback;

  const LoginPage({super.key, required this.signOutCallback});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> signIn(String email, String password, BuildContext context) async {
    try {
      final signInResult = await Amplify.Auth.signIn(
        username: email,
        password: password,
      );

      if (signInResult.isSignedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage(signOutCallback: widget.signOutCallback)),
        );
      } else {
        showErrorSnackBar('Sign-in failed. Please check your credentials and try again.');
      }
    } catch (e) {
      String errorMessage = 'An unexpected error occurred. Please try again later.';

      if (e is AuthException) {
        final authError = e as AuthException;

        if (authError.message.contains('UserNotFoundException')) {
          errorMessage = 'No account found with this email. Please sign up first.';
        } else if (authError.message.contains('Incorrect username or password')) {
          errorMessage = 'Invalid email or password. Please try again.';
        } else if (authError.message.contains('NotAuthorizedException')) {
          errorMessage = 'You are not authorized to access this account.';
        } else if (authError.message.contains('TooManyRequestsException')) {
          errorMessage = 'Too many requests. Please try again later.';
        } else {
          errorMessage = 'Authentication error: ${authError.message}. Please try again later.';
        }
      } else if (e is AmplifyException) {
        errorMessage = 'Amplify error: ${e.message}. Please try again later.';
      } else {
        errorMessage = 'An unexpected error occurred: $e. Please try again later.';
      }

      showErrorSnackBar(errorMessage);
      print('Error signing in: $e');
    }
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void handleSignIn() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isNotEmpty && password.isNotEmpty) {
      signIn(email, password, context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both email and password")),
      );
    }
  }

  void navigateToSignUpPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignupPage(signOutCallback: widget.signOutCallback)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF8EC5FC), // Light blue
                  Color(0xFFE0C3FC), // Soft purple
                ],
              ),
            ),
          ),
          // Foreground content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Page icon
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 30.0),
                    child: Image.asset(
                      'assets/icon.png',
                      height: 175.0,
                      width: 175.0,
                    ),
                  ),
                  // Email input
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.email),
                        hintText: "Email",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  // Password input
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.lock),
                        hintText: "Password",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Login button
                  ElevatedButton(
                    onPressed: handleSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      elevation: 5.0,
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  // Divider
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(left: 10.0, right: 20.0),
                          child: const Divider(color: Colors.deepPurple),
                        ),
                      ),
                      const Text(
                        "OR",
                        style: TextStyle(color: Colors.deepPurple),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(left: 20.0, right: 10.0),
                          child: const Divider(color: Colors.deepPurple),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15.0),
                  // Sign-up button
                  ElevatedButton(
                    onPressed: navigateToSignUpPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      elevation: 5.0,
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
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
