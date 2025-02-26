import 'package:camera/camera.dart';
import 'package:cloud_lens/Pages/camera_page.dart';
import 'package:cloud_lens/Pages/favorites_page.dart';
import 'package:cloud_lens/Pages/photos_page.dart';
import 'package:cloud_lens/Pages/upload_page.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  const MainPage({super.key, required this.cameras});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late final List<CameraDescription> cameras = widget.cameras;

  late final List<Widget> pages = [
    const PhotosPage(),
    const FavoritesPage(),
    const UploadPage(),
    CameraPage(cameras: cameras),
  ];

  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_pageIndex],
      bottomNavigationBar: BottomNavigationBar(items:
        [
          BottomNavigationBarItem(icon: Icon(Icons.image), label: "Photos"),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "Favorites"),
          BottomNavigationBarItem(icon: Icon(Icons.upload), label: "Upload"),
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