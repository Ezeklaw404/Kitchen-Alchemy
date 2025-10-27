import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraButton extends StatefulWidget {
  const CameraButton({super.key, required this.camera});

  final CameraDescription camera;

  @override
  State<CameraButton> createState() => _CameraButtonState();
}

class _CameraButtonState extends State<CameraButton> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium);

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        try {
          await _initializeControllerFuture;
          final image = await _controller.takePicture();
        } catch (e) {
          print(e);
        }
      },
      child: const Icon(Icons.camera_alt_outlined),
    );
  }
}
