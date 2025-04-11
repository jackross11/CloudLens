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

  // Sign in method using Amplify Auth
  Future<void> signIn(String email, String password, BuildContext context) async {
    try {
      // Attempt to sign in with Amplify Auth
      final signInResult = await Amplify.Auth.signIn(
        username: email,
        password: password,
      );

      if (signInResult.isSignedIn) {
        // Sign-in successful, navigate to MainPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage(signOutCallback: widget.signOutCallback)),
        );
      } else {
        // Sign-in failed
        print('Sign-in failed: ${signInResult.toString()}');
      }
    } catch (e) {
      // Handle any errors that occurred during sign-in
      print('Error signing in: $e');
    }
  }

  // Handle sign-in button click
  void handleSignIn() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isNotEmpty && password.isNotEmpty) {
      signIn(email, password, context);  // Pass context here
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
      MaterialPageRoute(builder: (context) => SignupPage(signOutCallback: widget.signOutCallback)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // page icon
            Container(
              margin: const EdgeInsets.symmetric(vertical: 30.0),
              child: Center(
                child: Image.asset(
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
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.email),
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
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  icon: Icon(Icons.lock),
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
                minimumSize: Size(double.infinity, 45),
              ),
              child: Text(
                'Login',
                style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
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
                    ),
                  ),
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
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15.0),
            // sign up button
            ElevatedButton(
              onPressed: navigateToSignUpPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                elevation: 5.0,
                minimumSize: Size(double.infinity, 45),
              ),
              child: Text(
                'Sign Up',
                style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
