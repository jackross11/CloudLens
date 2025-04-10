import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

class EditPage extends StatefulWidget {
  final Uint8List imageBytes;
  const EditPage({super.key, required this.imageBytes});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  String? _editedImageUrl;
  bool _isProcessing = false;

  // API end points
  final Map<String, String> apiMap = {
    'Invert Colors': 'https://zh50419t6e.execute-api.us-east-1.amazonaws.com/default/invertImage',
    'Greyscale': 'https://k8pat6qwxi.execute-api.us-east-1.amazonaws.com/default/greyscaleImage',
  
  };

  // processing methods
  Future<void> _applyEdit(String methodName) async {
  setState(() => _isProcessing = true);

  final fileName = '${methodName.toLowerCase().replaceAll(" ", "_")}_${DateTime.now().millisecondsSinceEpoch}.jpg';
  final base64Body = base64Encode(widget.imageBytes);
  final url = apiMap[methodName]!;

  final payload = {
    'file_name': fileName,
    'body': base64Body,
  };

  print("📤 POST to $url");
  print("📄 Payload: $payload");

  final response = await http.post(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(payload),
  );

  setState(() => _isProcessing = false);

  if (response.statusCode == 200) {
    final body = jsonDecode(response.body);
    setState(() => _editedImageUrl = body['url']);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ Failed: ${response.body}")),
    );
  }
}

  //save images
  Future<void> _saveImage() async {
    if (_editedImageUrl == null) return;
    try {
      final response = await http.get(Uri.parse(_editedImageUrl!));
      final Uint8List bytes = response.bodyBytes;
      final result = await ImageGallerySaverPlus.saveImage(
        bytes,
        name: 'cloudlens_${DateTime.now().millisecondsSinceEpoch}',
        quality: 100,
      );
      if ((result['isSuccess'] ?? false) == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Successfully saved")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Failed to save")),
        );
      }
    } catch (e) {
      print("save error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Image')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _editedImageUrl != null
            ? Column(
                children: [
                  Image.network(_editedImageUrl!),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _saveImage,
                    icon: const Icon(Icons.download),
                    label: const Text("Save to Gallery"),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text("Choose an edit method:"),
                  const SizedBox(height: 16),
                  ...apiMap.keys.map(
                    (methodName) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : () => _applyEdit(methodName),
                        child: Text(methodName),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
