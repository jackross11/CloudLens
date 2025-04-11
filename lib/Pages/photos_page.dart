import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_lens/Pages/editing_page.dart';

class PhotosPage extends StatefulWidget {
  const PhotosPage({super.key});

  @override
  _PhotosPageState createState() => _PhotosPageState();
}

class _PhotosPageState extends State<PhotosPage> with SingleTickerProviderStateMixin{
  final _picker = ImagePicker();
  File? _selectedImage;
  List<String> _cloudImageURLs = [];
  List<File> _localImages = [];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize TabController with length 2 (Local, Cloud)
    _tabController = TabController(length: 2, vsync: this);
    _fetchCloudImages(); // Fetch cloud images when the page loads
  }

  // Pick image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _localImages.add(_selectedImage!);
      });
    }
  }

  // Upload images to S3 bucket
  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    try {
      final user = await Amplify.Auth.getCurrentUser();
      final userID = user.userId;
      final photoID = Uuid().v4();
      final fileName = '$userID' + '_' + photoID + '.jpg';

      final bytes = await _selectedImage!.readAsBytes();
      final base64String = base64Encode(bytes);

      final url = 'https://s8fac61i71.execute-api.us-east-1.amazonaws.com/default/S3BucketUpload/upload';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'file_name': fileName, // Use the formatted file name
          'body': base64String,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Image uploaded successfully")),
        );
        _fetchCloudImages(); // Reload cloud images after uploading
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

  // Fetch cloud images from S3
  Future<void> _fetchCloudImages() async {
    try {
      final user = await Amplify.Auth.getCurrentUser();
      final userID = user.userId;

      // get all files under the path 'userID'
      final operation = Amplify.Storage.list(path: StoragePath.fromString(userID));
      final result = await operation.result;
      // Filter files by userID
      final filteredFiles = result.items
          .where((item) => item.path.startsWith(userID))
        .toList();

      // Get URLs for the filtered files
      final List<String> imageUrls = [];
      for (var file in filteredFiles) {
        final urlOperation = await Amplify.Storage.getUrl(path: StoragePath.fromString(file.path));
        final urlResult = await urlOperation.result;
        imageUrls.add(urlResult.url.toString()); // Add the file URL to the list
      }

      setState(() {
        _cloudImageURLs = imageUrls;
      });
    } catch (e) {
      print("Error fetching cloud images: $e");
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Photos"),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Local"),
            Tab(text: "Cloud"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Local Images Tab
          Center(
            child: _localImages.isEmpty
                ? Text("No local images available.")
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, 
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: _localImages.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          // Navigate to EditingImages page when tapped
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditingImages(imageUrl: _localImages[index].path),
                            ),
                          );
                        },
                        child: Image.file(_localImages[index]),
                      );
                    },
                  ),
          ),
          // Cloud Images Tab
          Center(
            child: _cloudImageURLs.isEmpty
                ? Text("No cloud images available.")
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, 
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: _cloudImageURLs.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          // Navigate to EditingImages page when tapped
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditingImages(imageUrl: _cloudImageURLs[index]),
                            ),
                          );
                        },
                        child: Image.network(_cloudImageURLs[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        tooltip: 'Select Image',
        child: Icon(Icons.add_a_photo),
      ),
      bottomNavigationBar: BottomAppBar(
        child: IconButton(
          icon: Icon(Icons.upload_file),
          onPressed: _uploadImage,
        ),
      ),
    );
  }
}