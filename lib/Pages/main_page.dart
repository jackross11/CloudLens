import 'package:camera/camera.dart';
import 'package:cloud_lens/Pages/camera_page.dart';
import 'package:cloud_lens/Pages/favorites_page.dart';
import 'package:cloud_lens/Pages/photos_page.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

class MainPage extends StatefulWidget {
  final Future<void> Function(BuildContext) signOutCallback;

  const MainPage({super.key, required this.signOutCallback});
  
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late List<CameraDescription> cameras = []; // List to store initialized cameras
  int _pageIndex = 0;
  String _userEmail = '';

  // Initialize the cameras
  Future<void> initializeCameras() async {
    try {
      // Get available cameras on the device
      cameras = await availableCameras();
      setState(() {});
    } catch (e) {
      print("Error initializing cameras: $e");
    }
  }

  Future<void> _getCurrentUser() async {
    try {
      final user = await Amplify.Auth.getCurrentUser();
      final userAttributes = await Amplify.Auth.fetchUserAttributes();
      final emailAttribute = userAttributes.firstWhere(
        (attribute) => attribute.userAttributeKey == CognitoUserAttributeKey.email);
      setState(() {
        _userEmail = emailAttribute.value; // Set the user's email
      });
    } catch (e) {
      print("Error getting current user: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    initializeCameras(); // Call initializeCameras when the page loads
    _getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_userEmail.isNotEmpty ? _userEmail : "Loading..."),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              // Use the sign-out callback to sign the user out
              await widget.signOutCallback(context);
            },
          ),
        ],
      ),
      body: cameras.isEmpty
          ? Center(child: CircularProgressIndicator()) // Show loading while initializing cameras
          : [
              const PhotosPage(),
              const FavoritesPage(),
              CameraPage(cameras: cameras), // Pass cameras to the CameraPage
            ][_pageIndex], // Display the selected page based on _pageIndex
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.image), label: "Photos"),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "Favorites"),
          BottomNavigationBarItem(icon: Icon(Icons.camera), label: "Camera"),
        ],
        onTap: (index) {
          setState(() {
            _pageIndex = index; // Switch pages based on the tab clicked
          });
        },
        currentIndex: _pageIndex, // Ensure correct tab is highlighted
        unselectedItemColor: Colors.deepPurple.shade200,
        fixedColor: Colors.deepPurple,
      ),
    );
  }
}