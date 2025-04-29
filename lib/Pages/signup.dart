import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cloud_lens/Pages/main_page.dart'; // Assuming you're navigating here on successful signup
import 'package:cloud_lens/Pages/login.dart';

class SignupPage extends StatefulWidget {
  final Future<void> Function(BuildContext) signOutCallback;

  const SignupPage({super.key, required this.signOutCallback});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> signUp(String email, String password) async {
    try {
      final result = await Amplify.Auth.signUp(
        username: email,
        password: password,
        options: SignUpOptions(
          userAttributes: {
            CognitoUserAttributeKey.email: email,
          },
        ),
      );

      if (result.isSignUpComplete) {
        print("Signup successful!");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage(signOutCallback: widget.signOutCallback)),
        );
      } else {
        print('Signup not complete');
      }
    } catch (e) {
      print('Signup failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed: $e')),
      );
    }
  }

  void navigateToSignInPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage(signOutCallback: widget.signOutCallback)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Signup'),
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
                  // Sign Up button
                  ElevatedButton(
                    onPressed: () {
                      String email = emailController.text.trim();
                      String password = passwordController.text.trim();

                      if (email.isEmpty || password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill in both fields')),
                        );
                        return;
                      }

                      signUp(email, password);
                    },
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
                  // Login button
                  ElevatedButton(
                    onPressed: navigateToSignInPage,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
