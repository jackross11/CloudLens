import 'package:flutter/material.dart' show BuildContext, ColorScheme, Colors, MaterialApp, StatelessWidget, ThemeData, Widget, WidgetsFlutterBinding, runApp;
import 'package:cloud_lens/amplifyconfiguration.dart';
import 'package:cloud_lens/Pages/login.dart'; // bypass login
import 'package:cloud_lens/Pages/main_page.dart'; // skip to main page
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Amplify.addPlugins([AmplifyAuthCognito(), AmplifyStorageS3()]);
  await Amplify.configure(amplifyconfig);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cloud Lens',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LoginPage(),
      //home: MainPage(), // skip to main page
    );
  }
}