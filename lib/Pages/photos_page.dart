import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotosPage extends StatefulWidget {
  const PhotosPage({super.key});

  @override
  _PhotosPageState createState() => _PhotosPageState();
}

class _PhotosPageState extends State<PhotosPage> {
  final _picker = ImagePicker();
  File? _selectedImage;

  // pick image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // upload images to bucket
  // todo save images as username_photoid
  // save edited images in seperate bucket
  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    final bytes = await _selectedImage!.readAsBytes();
    final base64String = base64Encode(bytes);


    // should probably hide this from src
    final url = 'https://s8fac61i71.execute-api.us-east-1.amazonaws.com/default/S3BucketUpload/upload';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'file_name': 'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
        'body': base64String,
      }),
    );

    if (response.statusCode == 200) {
      print("✅ File uploaded successfully");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image uploaded successfully")),
      );
    } else {
      print("❌ Error uploading file: ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload image")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Photos")),
      body: Center(
        child: _selectedImage == null
            ? Text("No image selected.")
            : Image.file(_selectedImage!), // Display selected image
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage, // Pick an image from gallery
        tooltip: 'Select Image',
        child: Icon(Icons.add_a_photo),
      ),
      bottomNavigationBar: BottomAppBar(
        child: IconButton(
          icon: Icon(Icons.upload_file),
          onPressed: _uploadImage, // Upload the selected image
        ),
      ),
    );
  }
}
