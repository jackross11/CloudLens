import 'dart:convert';
import 'dart:io';
import 'package:cloud_lens/Pages/edit_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class PhotosPage extends StatefulWidget {
  const PhotosPage({super.key});

  @override
  _PhotosPageState createState() => _PhotosPageState();
}

class _PhotosPageState extends State<PhotosPage> {
  File? _selectedImage;

  // select an image 
  Future<void> _pickImage() async {
    try {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (file != null) {
        final bytes = await File(file.path).readAsBytes();
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditPage(imageBytes: bytes),
          ),
        );
      } else {
        print("❌ no image selected");
      }
    } catch (e) {
      print("❌ Error: $e");
    }
  }

  // upload images
  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    try {
      final bytes = await _selectedImage!.readAsBytes();

      final url = 'https://s8fac61i71.execute-api.us-east-1.amazonaws.com/default/S3BucketUpload/upload';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'file_name': 'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
          'body': base64Encode(bytes),
        }),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.statusCode == 200
              ? "✅ successfully uploaded"
              : "❌ failed to upload: ${response.body}"),
        ),
      );
    } catch (e) {
      print("❌ Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Photos")),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.add_a_photo),
          label: const Text("Select Image"),
          onPressed: _pickImage,
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: IconButton(
          icon: const Icon(Icons.upload_file),
          onPressed: _uploadImage,
        ),
      ),
    );
  }
}
