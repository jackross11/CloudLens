import 'package:flutter/material.dart';
import 'package:cloud_lens/database.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Map<String, dynamic>> favorites = [];

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final data = await DBHelper.getFavorites();
    setState(() {
      favorites = data;
    });
  }

  Future<void> removeFavorite(String imageUrl) async {
    await DBHelper.deleteFavorite(imageUrl);
    loadFavorites();
  }

  Future<void> downloadImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      final Uint8List bytes = response.bodyBytes;
      final result = await ImageGallerySaverPlus.saveImage(
        bytes,
        name: 'cloudlens_${DateTime.now().millisecondsSinceEpoch}',
        quality: 100,
      );
      if ((result['isSuccess'] ?? false) == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Successfully saved to gallery")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Failed to save image")),
        );
      }
    } catch (e) {
      print("Download error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorites',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 84, 152, 247),
        foregroundColor: Colors.white,
      ),
      body: favorites.isEmpty
          ? const Center(
              child: Text(
                "No favorites yet",
                style: TextStyle(fontSize: 18),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.8, 
                ),
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final imageUrl = favorites[index]['imageUrl'];
                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.download, color: Colors.green),
                                onPressed: () => downloadImage(imageUrl),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => removeFavorite(imageUrl),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
