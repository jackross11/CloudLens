import 'package:camera/camera.dart';
import 'package:cloud_lens/Pages/camera_page.dart';
import 'package:cloud_lens/Pages/favorites_page.dart';
import 'package:cloud_lens/Pages/photos_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      cameras = await availableCameras();
      setState(() {});
    } catch (e) {
      print("Error initializing cameras: $e");
    }
  }

  // Get current user's email
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
    initializeCameras();
    _getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7FA), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: cameras.isEmpty
            ? Center(child: CircularProgressIndicator()) // Show loading while initializing cameras
            : [
                const PhotosPage(),
                const FavoritesPage(),
                CameraPage(cameras: cameras), // Pass cameras to the CameraPage
              ][_pageIndex], // Display the selected page based on _pageIndex
      ),
      appBar: AppBar(
        title: Text(_userEmail.isNotEmpty ? _userEmail : "Loading..."),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await widget.signOutCallback(context); // Sign out logic
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 8),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.deepPurple.shade200,
          selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w400),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.image), label: "Photos"),
            BottomNavigationBarItem(icon: Icon(Icons.star), label: "Favorites"),
            BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: "Camera"),
          ],
          onTap: (index) {
            setState(() {
              _pageIndex = index; // Switch pages based on the tab clicked
            });
          },
          currentIndex: _pageIndex, // Ensure the correct tab is highlighted
        ),
      ),
    );
  }
}
