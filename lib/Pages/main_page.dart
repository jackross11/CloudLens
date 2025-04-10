import 'package:camera/camera.dart';
import 'package:cloud_lens/Pages/camera_page.dart';
import 'package:cloud_lens/Pages/favorites_page.dart';
import 'package:cloud_lens/Pages/photos_page.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({
    super.key,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late List<CameraDescription> cameras = []; // List to store initialized cameras
  int _pageIndex = 0;

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

  @override
  void initState() {
    super.initState();
    initializeCameras(); // Call initializeCameras when the page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: cameras.isEmpty ? Center(child: CircularProgressIndicator())
          : [
              const PhotosPage(),
              const FavoritesPage(),
              CameraPage(cameras: cameras), // Pass initialized cameras to CameraPage
            ][_pageIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.image), label: "Photos"),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "Favorites"),
          BottomNavigationBarItem(icon: Icon(Icons.camera), label: "Camera"),
        ],
        onTap: (index) {
          setState(() {
            _pageIndex = index;
          });
        },
        currentIndex: _pageIndex,
        unselectedItemColor: Colors.deepPurple.shade200,
        fixedColor: Colors.deepPurple,
      ),
    );
  }
}
