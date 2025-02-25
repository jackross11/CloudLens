import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CloudLens',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      home: const HomeScreen(),
    );
  }
}

/// HomeScreen 
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final Dio _dio = Dio();

  /// select images
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  /// take photos
  Future<void> _takePhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  /// upload images
  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    String fileName = _selectedImage!.path.split('/').last;
    FormData formData = FormData.fromMap({
      
      "photo": await MultipartFile.fromFile(_selectedImage!.path, filename: fileName),
    });

    try {
      Response response = await _dio.post(
        "http://127.0.0.1:5000/upload", // use 10.0.2.2 to replace 127.0.0.1 in Android device
        data: formData,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("successfully upload: ${response.data['filePath']}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("failed to upload：$e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CloudLens"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _selectedImage != null
                  ? Image.file(_selectedImage!, width: 200, height: 200, fit: BoxFit.cover)
                  : const Text("no image selected"),
            ),
          ),
          // buttons
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _pickImage,
                   style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: const Text("Select an Image"),
                ),
                ElevatedButton(
                  onPressed: _takePhoto,
                   style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: const Text("Take a Photo"),
                ),
                ElevatedButton(
                  onPressed: _uploadImage,
                   style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: const Text("Upload an Image"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
