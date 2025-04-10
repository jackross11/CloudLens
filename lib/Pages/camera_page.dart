import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:flutter/services.dart'; // for ByteData

class CameraPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraPage({super.key, required this.cameras});

  @override
  State<StatefulWidget> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  late Future<void> _initControllerFuture;
  int _currentCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeCamera(_currentCameraIndex);
  }

  Future<void> _initializeCamera(int cameraIndex) async {
    try {
      final camera = widget.cameras[cameraIndex];
      _controller = CameraController(
        camera,
        ResolutionPreset.medium,
      );
      _initControllerFuture = _controller.initialize();
      await _initControllerFuture;
      setState(() {});
    } catch (e) {
      print('initialization failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('initialization failed: $e')),
      );
    }
  }

  void _switchCamera() async {
    _currentCameraIndex = (_currentCameraIndex + 1) % widget.cameras.length;
    await _controller.dispose();
    _initializeCamera(_currentCameraIndex);
  }

  void onCameraPressed() async {
  try {
    if (!_controller.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera not initialized')),
      );
      return;
    }

    await _initControllerFuture;
    final image = await _controller.takePicture();

    final bytes = await File(image.path).readAsBytes();
    final result = await ImageGallerySaverPlus.saveImage(
      Uint8List.fromList(bytes),
      name: "cloudlens_${DateTime.now().millisecondsSinceEpoch}",
    );

    if (result['isSuccess'] == true || result['isSuccess'] == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Saved to gallery!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Failed to save photo')),
      );
    }

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}

  void onPhotoLibraryPressed() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) {
        print('select images from gallery: ${image.path}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('image selected: ${image.path}')),
        );
      }
    } catch (e) {
      print('unable to select an image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _initControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CameraPreview(_controller),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {
                        print('clicked');
                        onCameraPressed();
                      },
                      iconSize: 50,
                      icon: Icon(Icons.camera),
                    ),
                    IconButton(
                      onPressed: onPhotoLibraryPressed,
                      iconSize: 50,
                      icon: Icon(Icons.photo_album),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: _switchCamera,
                  icon: Icon(Icons.refresh),
                  iconSize: 50,
                  color: Colors.blue,
                ),
                Text(
                  _currentCameraIndex == 0 ? 'back' : 'front',
                  style: TextStyle(fontSize: 16),
                )
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
