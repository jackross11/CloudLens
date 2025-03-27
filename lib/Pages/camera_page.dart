import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
    // initialize camera (back facing camera by default)
    _initializeCamera(_currentCameraIndex);
  }

  // initialize the camera based on index
  Future<void> _initializeCamera(int cameraIndex) async {
    final camera = widget.cameras[cameraIndex];
    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
    );
    _initControllerFuture = _controller.initialize();
    setState(() {});
  }

  // switch between the front and back camera
  void _switchCamera() async {
    _currentCameraIndex = (_currentCameraIndex + 1) % widget.cameras.length;
    await _controller.dispose();
    _initializeCamera(_currentCameraIndex);
  }

  void onCameraPressed() async {
    //XFile picture = await _controller.takePicture();

    // TODO: send picture to server
  }

  void onPhotoLibraryPressed() async {
    //final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    // TODO: send picture to server
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: onCameraPressed,
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
                  _currentCameraIndex == 0 ? 'Back Camera' : 'Front Camera',
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