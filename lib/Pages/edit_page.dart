import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:cloud_lens/database.dart'; 

class EditPage extends StatefulWidget {
  final Uint8List imageBytes;
  const EditPage({super.key, required this.imageBytes});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  String? _editedImageUrl;
  bool _isProcessing = false;

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
    setState(() => _isProcessing = true);

    final fileName = '${operation}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final compressedBytes = await _compressImage(widget.imageBytes);
    final base64Body = base64Encode(compressedBytes);

    final payload = {
      'file_name': fileName,
      'body': base64Body,
      'operation': operation,
    };

    try {
      final response = await http.post(
        Uri.parse(lambdaEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        setState(() => _editedImageUrl = body['url']);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed: ${response.body}")),
        );
      }
    } catch (e) {
      print('❌ Error: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _saveImage() async {
    if (_editedImageUrl == null) return;
    try {
      final response = await http.get(Uri.parse(_editedImageUrl!));
      final Uint8List bytes = response.bodyBytes;
      await ImageGallerySaverPlus.saveImage(
        bytes,
        name: 'cloudlens_${DateTime.now().millisecondsSinceEpoch}',
        quality: 100,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Successfully saved to gallery")),
      );
    } catch (e) {
      print('save error: $e');
    }
  }

  Future<void> _saveToFavorites() async {
    if (_editedImageUrl != null) {
      await DBHelper.insertFavorite(_editedImageUrl!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Added to Favorites")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Image',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 84, 152, 247),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _editedImageUrl != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Image.network(_editedImageUrl!, fit: BoxFit.contain),
                  ),
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
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Choose a Filter:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: editOptions.map((method) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ElevatedButton(
                              onPressed: _isProcessing ? null : () => _applyEdit(method),
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
