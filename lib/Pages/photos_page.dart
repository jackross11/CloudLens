import 'dart:typed_data';
import 'package:cloud_lens/Pages/edit_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotosPage extends StatefulWidget {
  const PhotosPage({super.key});

  @override
  _PhotosPageState createState() => _PhotosPageState();
}

class _PhotosPageState extends State<PhotosPage> {
  Future<void> _pickImage() async {
    try {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (file != null) {
        final bytes = await file.readAsBytes();
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditPage(imageBytes: bytes),
          ),
        );
      } else {
        print("❌ No image selected");
      }
    } catch (e) {
      print("❌ Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Photos",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 84, 152, 247),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: const Text(
            "No image selected",
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: ElevatedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.image),
            label: const Text("Select Image"),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: const Color.fromARGB(255, 84, 152, 247),
              foregroundColor: Colors.white,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 5,
            ),
          ),
        ),
      ),
    );
  }
}
