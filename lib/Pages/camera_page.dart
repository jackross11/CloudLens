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

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
        widget.cameras[0], ResolutionPreset.medium
    );
    _initControllerFuture = _controller.initialize();
  }

  void onCameraPressed() async {
    XFile picture = await _controller.takePicture();

    // TODO: send picture to server
  }

  void onPhotoLibraryPressed() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    // TODO: send picture to server
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: _initControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done){
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
                          icon: Icon(Icons.photo_album)
                      )
                    ],
                  )
                ],
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          })
    );
  }
}