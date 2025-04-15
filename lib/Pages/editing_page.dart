import 'dart:io';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

class EditingImages extends StatefulWidget {
  final String imageUrl;

  const EditingImages({Key? key, required this.imageUrl}) : super(key: key);

  @override
  State<EditingImages> createState() => _EditingImagesState();
}

class _EditingImagesState extends State<EditingImages> {
  Uint8List? editedImageBytes;
  String? newFileName;
  bool isLoading = false;

  /// Call AWS Lambda with image and operation
  Future<void> callLambda(String operation) async {
    setState(() => isLoading = true);

    final imageResponse = await http.get(Uri.parse(widget.imageUrl));
    if (imageResponse.statusCode != 200) {
      print('Failed to load original image');
      setState(() => isLoading = false);
      return;
    }

    final Uint8List imageBytes = imageResponse.bodyBytes;
    String base64Image = base64Encode(imageBytes);

    if (base64Image.startsWith('data:image')) {
      base64Image = base64Image.split(',').last;
    }

    String lambdaUrl = 'https://ivi524iedl.execute-api.us-east-1.amazonaws.com/default/GreyScale/greyscale';
    final fileName = widget.imageUrl.split('/').last;

    try {
      print('Sending to Lambda:\nfile_name: $fileName\nbase64 length: ${base64Image.length}');

      final response = await http.post(
        Uri.parse(lambdaUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'operation': operation,
          'file_name': fileName,
          'body': base64Image,
        }),
      );

      print("Lambda response: ${response.body}");

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final String base64Edited = body['body'];
        final Map<String, dynamic> innerBody = json.decode(base64Edited);

        final String base64EditedImage = innerBody['edited_image'];
        final String returnedFileName = innerBody['file_name'];

        print('Received new file name: $returnedFileName');
        print('Received base64 image of length: ${base64EditedImage.length}');

        setState(() {
          editedImageBytes = base64Decode(base64EditedImage);
          newFileName = returnedFileName;
        });
      }
    } catch (e) {
      print('Error calling Lambda: $e');
    }

    setState(() => isLoading = false);
  }

  /// Save image to gallery
  Future<void> _saveImage() async {
    if (editedImageBytes == null) return;
    try {
      final result = await ImageGallerySaverPlus.saveImage(
        editedImageBytes!,
        name: 'cloudlens_${DateTime.now().millisecondsSinceEpoch}',
        quality: 100,
      );
      if ((result['isSuccess'] ?? false) == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Successfully saved")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to save")),
        );
      }
    } catch (e) {
      print("save error: $e");
    }
  }

  @override
Widget build(BuildContext context) {
  final bool hasEditedImage = editedImageBytes != null;
  final displayImage = hasEditedImage
      ? Image.memory(editedImageBytes!)
      : Image.network(widget.imageUrl);

  return Scaffold(
    appBar: AppBar(title: const Text('Edit Image')),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          displayImage,
          const SizedBox(height: 20),
          if (hasEditedImage)
            ElevatedButton.icon(
              onPressed: _saveImage,
              icon: const Icon(Icons.download),
              label: const Text("Save to Gallery"),
            ),
          const SizedBox(height: 20),
          const Text("Choose an edit method:", style: TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: isLoading ? null : () => callLambda('grayscale'),
            child: const Text('Grayscale'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: isLoading ? null : () => callLambda('resize'),
            child: const Text('Resize'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: isLoading ? null : () => callLambda('negative'),
            child: const Text('Negative'),
          ),
          if (newFileName != null)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Center(
                child: Text("New file name: $newFileName",
                    style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
              ),
            ),
        ],
      ),
    ),
  );
}
}
