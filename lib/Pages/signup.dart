import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cloud_lens/Pages/main_page.dart';  // Assuming you're navigating here on successful signup
import 'package:cloud_lens/Pages/login.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({
    super.key,
  });

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> signUp(String email, String password) async {
    try {
      // Call Amplify Auth to sign up the user
      final result = await Amplify.Auth.signUp(
        username: email,
        password: password,
        options: SignUpOptions(
          userAttributes: {
            CognitoUserAttributeKey.email: email, // Directly passing the email
          },
        ),
      );

      // Check if sign-up is complete
      if (result.isSignUpComplete) {
        print("Signup successful!");
        // Navigate to the next page, for example, FavoritesPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
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
      MaterialPageRoute(builder: (context) => LoginPage()), // Assuming you have a SignInPage
    );
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text('Signup')),
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

              // sign up button
              ElevatedButton(
                onPressed: () {
                  String email = emailController.text.trim();
                  String password = passwordController.text.trim();

                  if (email.isEmpty || password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please fill in both fields')),
                    );
                    return;
                  }

                  signUp(email, password);
                },
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

              // login button
              ElevatedButton(
                onPressed: navigateToSignInPage,
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
            ],
        ),
      ),
    );
  }
}