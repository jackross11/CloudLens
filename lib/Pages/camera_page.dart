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
                      onPressed: onPhotoLibraryPressed,
                      iconSize: 50,
                      icon: Icon(Icons.photo_library),
                      color: Color.fromARGB(255, 51, 51, 51),
                    ),

                    GestureDetector(
                      onTap: onCameraPressed,
                      child: Container(
                        width: 60.0,
                        height: 60.0,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Color.fromARGB(255, 51, 51, 51),
                            width: 3.0,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 50.0,
                            height: 50.0,
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 255, 87, 51),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: _switchCamera,
                      icon: Icon(Icons.cameraswitch),
                      iconSize: 50,
                      color: Color.fromARGB(255, 51, 51, 51),
                    ),
                  ],
                ),
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