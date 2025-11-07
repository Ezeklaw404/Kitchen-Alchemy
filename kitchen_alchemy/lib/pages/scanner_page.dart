import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:kitchen_alchemy/widgets/camera_button.dart';
import 'package:kitchen_alchemy/widgets/camera_screen.dart';
import 'package:kitchen_alchemy/widgets/page_template.dart';

class ScannerPage extends StatelessWidget {

  const ScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Scanner',
      route: '/scanner',
      showDrawer: true,
      body: SingleChildScrollView(
        child: Center(
          child: CameraScreen()
        ),
      ),
    );
  }
}
