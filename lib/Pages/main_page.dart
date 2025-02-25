import 'package:cloud_lens/Pages/favorites_page.dart';
import 'package:cloud_lens/Pages/photos_page.dart';
import 'package:cloud_lens/Pages/upload_page.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final List<Widget> pages = [
    const PhotosPage(),
    const FavoritesPage(),
    const UploadPage(),
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
          BottomNavigationBarItem(icon: Icon(Icons.upload), label: "Upload")
        ],
        onTap: (index) {
          setState(() {
            _pageIndex = index;
          });
        },
        currentIndex: _pageIndex,
      ),
    );
  }
}