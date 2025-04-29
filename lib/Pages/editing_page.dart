import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:cloud_lens/database.dart'; // only if you use _saveToFavorites

class EditingImages extends StatefulWidget {
  final String imageUrl;

  const EditingImages({Key? key, required this.imageUrl}) : super(key: key);

  @override
  State<EditingImages> createState() => _EditingImagesState();
}

class _EditingImagesState extends State<EditingImages> {
  Uint8List? editedImageBytes;
  String? editedImageUrl;
  bool isLoading = false;

  final String lambdaEndpoint = 'https://rxig6sxm4d.execute-api.us-east-1.amazonaws.com/default/photoEdits';

  final List<String> editOptions = [
    'invert',
    'grayscale',
    'blur',
    'edge',
    'flip',
    'brightness',
    'contrast',
    'sharpen',
    'sepia',
    'pencil',
    'threshold',
    'emboss',
  ];

  Future<Uint8List> _compressImage(Uint8List originalBytes) async {
    return await FlutterImageCompress.compressWithList(
      originalBytes,
      quality: 75,
      minWidth: 1024,
      minHeight: 1024,
    );
  }

  Future<void> _applyEdit(String operation) async {
    setState(() => isLoading = true);

    try {
      final originalResponse = await http.get(Uri.parse(widget.imageUrl));
      if (originalResponse.statusCode != 200) {
        print('Failed to load original image');
        setState(() => isLoading = false);
        return;
      }

      final compressedBytes = await _compressImage(originalResponse.bodyBytes);
      final base64Body = base64Encode(compressedBytes);

      final fileName = '${operation}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final payload = {
        'file_name': fileName,
        'body': base64Body,
        'operation': operation,
      };

      final response = await http.post(
        Uri.parse(lambdaEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        setState(() {
          editedImageUrl = body['url'];
          editedImageBytes = null; // Clear memory version when switching to network
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed: ${response.body}")),
        );
      }
    } catch (e) {
      print('Error calling Lambda: $e');
    }

    setState(() => isLoading = false);
  }

  Future<void> _saveImage() async {
    if (editedImageBytes == null && editedImageUrl == null) return;
    try {
      Uint8List bytes;
      if (editedImageBytes != null) {
        bytes = editedImageBytes!;
      } else {
        final response = await http.get(Uri.parse(editedImageUrl!));
        bytes = response.bodyBytes;
      }
      await ImageGallerySaverPlus.saveImage(
        bytes,
        name: 'cloudlens_${DateTime.now().millisecondsSinceEpoch}',
        quality: 100,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Successfully saved to gallery")),
      );
    } catch (e) {
      print('Save error: $e');
    }
  }

  Future<void> _saveToFavorites() async {
    String urlToSave = editedImageUrl ?? widget.imageUrl;  
    print('Attempting to save URL: $urlToSave'); // Debugging line
    if (urlToSave.isNotEmpty) {
      try {
        await DBHelper.insertFavorite(urlToSave);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Added to Favorites")),
        );
      } catch (e) {
        print("Error saving to favorites: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Failed to add to favorites")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ No image to save to favorites")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayImage = editedImageBytes != null
        ? Image.memory(editedImageBytes!)
        : editedImageUrl != null
            ? Image.network(editedImageUrl!)
            : Image.network(widget.imageUrl);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Image'),
        backgroundColor: const Color.fromARGB(255, 84, 152, 247),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: displayImage),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _saveImage,
              icon: const Icon(Icons.download),
              label: const Text("Save to Gallery"),
              style: _buttonStyle(),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _saveToFavorites,
              icon: const Icon(Icons.favorite),
              label: const Text("Add to Favorites"),
              style: _buttonStyle(color: Colors.pinkAccent),
            ),
            const SizedBox(height: 20),
            const Text("Choose a Filter:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: editOptions.map((method) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () => _applyEdit(method),
                        child: Text(
                          method.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: _buttonStyle(),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ButtonStyle _buttonStyle({Color color = const Color.fromARGB(255, 84, 152, 247)}) {
    return ElevatedButton.styleFrom(
      minimumSize: const Size(double.infinity, 50),
      backgroundColor: color,
      foregroundColor: Colors.white,
      elevation: 5,
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
