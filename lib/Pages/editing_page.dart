import 'dart:io';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';

class EditingImages extends StatefulWidget {
  final String imageUrl; // original image URL passed in

  const EditingImages({Key? key, required this.imageUrl}) : super(key: key);

  @override
  State<EditingImages> createState() => _EditingImagesState();
}

class _EditingImagesState extends State<EditingImages> {
  Uint8List? editedImageBytes; // holds edited image bytes
  String? newFileName;         // holds new image file name
  bool isLoading = false;
  File? _selectedImage;
  
  Future<void> _uploadImage() async {
  if (editedImageBytes == null) return; // Check if the edited image is available

  try {
    // Get the file name from the returned image or your logic here
    final String fileName = newFileName ?? 'edited_image.jpg'; // Use the new file name returned from Lambda or default to 'edited_image.jpg'

    final base64String = base64Encode(editedImageBytes!); // Use edited image bytes

    final url = 'https://s8fac61i71.execute-api.us-east-1.amazonaws.com/default/S3BucketUpload/upload';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'file_name': fileName, // Use the file name from the edited image
        'body': base64String,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image uploaded successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload image")),
      );
    }
  } catch (e) {
    print('Error uploading image: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error uploading image")),
    );
  }
}

  /// Calls AWS Lambda with base64 image and selected operation
  Future<void> callLambda(String operation) async {
  setState(() => isLoading = true);

  // Fetch the image from the provided URL
  final imageResponse = await http.get(Uri.parse(widget.imageUrl));
  if (imageResponse.statusCode != 200) {
    print('Failed to load original image');
    setState(() => isLoading = false);
    return;
  }

  final Uint8List imageBytes = imageResponse.bodyBytes;
  String base64Image = base64Encode(imageBytes);

  // If the base64 string has a "data:image/jpeg;base64," prefix, remove it
  if (base64Image.startsWith('data:image')) {
    base64Image = base64Image.split(',').last;
  }

  String lambdaUrl = 'https://ivi524iedl.execute-api.us-east-1.amazonaws.com/default/GreyScale/greyscale';

  final fileName = widget.imageUrl.split('/').last;

  try {
    print('Sending to Lambda:\nfile_name: $fileName\nbase64 length: ${base64Image.length}');

    final response = await http.post(
      Uri.parse(lambdaUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'operation': operation,
        'file_name': fileName,
        'body': base64Image,
      }),
    );

    // Debug print Lambda response body
    print("Lambda response: ${response.body}");

    if (response.statusCode == 200) {
      final body = json.decode(response.body); // Decode the outer JSON
      final String base64Edited = body['body']; // This is the stringified JSON body from the Lambda response
      final Map<String, dynamic> innerBody = json.decode(base64Edited); // Decode the inner JSON body

      final String base64EditedImage = innerBody['edited_image']; // Get the base64 image
      final String returnedFileName = innerBody['file_name']; // Get the file name

      print('Received new file name: $returnedFileName');
      print('Received base64 image of length: ${base64EditedImage.length}');

      setState(() {
        // Base64 decode the edited image data
        editedImageBytes = base64Decode(base64EditedImage);
        newFileName = returnedFileName;
      });
    }
  } catch (e) {
    print('Error calling Lambda: $e');
  }

  setState(() => isLoading = false);
}


  @override
  Widget build(BuildContext context) {
    final displayImage = editedImageBytes != null
        ? Image.memory(editedImageBytes!)
        : Image.network(widget.imageUrl);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Image')),
      body: Column(
        children: [
          const SizedBox(height: 20),
          isLoading
              ? const CircularProgressIndicator()
              : displayImage,
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => callLambda('grayscale'),
                child: const Text('Grayscale'),
              ),
              ElevatedButton(
                onPressed: () => callLambda('resize'),
                child: const Text('Resize'),
              ),
              ElevatedButton(
                onPressed: () => callLambda('negative'),
                child: const Text('Negative'),
              ),
            ],
          ),
          if (newFileName != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text("New file name: $newFileName"),
            ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: IconButton(
          icon: Icon(Icons.upload_file),
          onPressed: _uploadImage,  // Trigger upload image function on tap
        ),
      ),
    );
  }
}