import 'package:flutter/material.dart';
import 'package:cloud_lens/amplifyconfiguration.dart';
import 'package:cloud_lens/Pages/login.dart';
import 'package:cloud_lens/Pages/main_page.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Amplify.addPlugins([AmplifyAuthCognito(), AmplifyStorageS3()]);
  await Amplify.configure(amplifyconfig);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cloud Lens',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: Color.fromARGB(255, 226, 232, 236), 
        useMaterial3: true,
      ),
      home: LoginPage(),
      // home: MainPage(), 
    );
  }
}
