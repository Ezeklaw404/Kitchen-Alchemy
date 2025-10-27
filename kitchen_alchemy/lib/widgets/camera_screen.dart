import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late Future<void> _initializeControllerFuture;
  String _scanResult = 'No scan yet';

  // @override
  // void initState() {
  //   super.initState();
  // }
  //
  // @override
  // void dispose() {
  //   super.dispose();
  // }

  // Future startScan() async {
  //   String scanResult;
  //
  //   try {
  //     scanResult = await FlutterBarcodeScanner.scanBarcode(
  //       '#ff6666',
  //       'cancel',
  //       true,
  //       ScanMode.BARCODE,
  //     );
  //
  //     if (!mounted) return;
  //
  //     if (scanResult != '-1') {
  //       setState(() {
  //         _scanResult = scanResult;
  //       });
  //     }
  //   } catch (e) {
  //     _scanResult = 'Error: $e';
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return
      Column(
        children: [
          SizedBox(
            height: 600,
            child: MobileScanner(
              onDetect: (barcodeCapture) {
                final barcode = barcodeCapture.barcodes.first.rawValue ?? '';
                setState(() {
                  _scanResult = barcode;
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _scanResult == null ? 'Scan a code' : 'Result: $_scanResult',
            style: const TextStyle(fontSize: 18),
          ),
        ],
      );
  }
}
