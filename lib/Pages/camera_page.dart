import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

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
          SnackBar(content: Text('Saved to gallery!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save photo')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: _initControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Column(
                children: [
                  Expanded(
                      child: CameraPreview(_controller)
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF8EC5FC), Color(0xFFE0C3FC)],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: GestureDetector(
                              onTap: onCameraPressed,
                              child: Container(
                                width: 60.0,
                                height: 60.0,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.deepPurple,
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
                          ),
                          Positioned(
                            right: 50,
                            child: IconButton(
                              onPressed: _switchCamera,
                              icon: Icon(Icons.flip_camera_android),
                              iconSize: 50,
                              color: Colors.deepPurple
                            )
                          ),

                        ],
                      ),
                    )
                  )
                ],
              );

            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
