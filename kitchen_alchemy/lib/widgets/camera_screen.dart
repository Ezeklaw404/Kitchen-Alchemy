import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kitchen_alchemy/models/barcode_product.dart';
import 'package:kitchen_alchemy/models/ingredient.dart';
import 'package:kitchen_alchemy/services/barcode_service.dart';
import 'package:kitchen_alchemy/services/firestore_service.dart';
import 'package:kitchen_alchemy/services/fuzzy_match_service.dart';
import 'package:kitchen_alchemy/services/ingredient_service.dart';
import 'package:kitchen_alchemy/widgets/barcode_result.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with SingleTickerProviderStateMixin{
  String _scanResult = '';
  bool _isProcessing = false;
  final _barcodeService = BarcodeService();
  final _ingredientService = IngredientService();
  final _dbService = FirestoreService();
  late AnimationController _controller;
  late Animation<double> _animation;
  String? _error;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);

    _scanResult = 'No scan yet';
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    _controller.dispose();
    super.dispose();
  }

  void _showFlushbar({required String message, bool isError = false,}) {
    final color = isError
        ? const Color(0xFFFFCDD2) // error
        : const Color(0xFF7AA6ED); // success

    Flushbar(
      message: message,
      duration: const Duration(seconds: 2),
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(12),
      backgroundColor: color,
      messageColor: const Color(0xFF0F3570),
    ).show(context);
  }

  Future<void> _loadBarcode(String barcode) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final BarcodeProduct? product = await _barcodeService.getProductByBarcode(
        barcode,
      );
      if (product == null) {
        _showFlushbar(message: 'No product found for this barcode',
            isError: true);
        return;
      }

      final List<Ingredient> allIngredients = await _ingredientService
          .getAllIngredients();

      final matches = FuzzyMatchService.findMatches(
        product.productName,
        allIngredients,
      );

      // https://pub.dev/packages/string_similarity

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => BarcodeResult(
          productName: product.productName,
          matchedIngredients: matches.map((i) => i.name).toList(),
          onAddToInventory: (selectedName) async {
            final selectedIngredient = matches.firstWhere(
              (i) => i.name == selectedName,
            );
            Navigator.pop(context);

            if ( await _dbService.hasInventory(selectedIngredient.id, inventory: true)) {
              _showFlushbar(message: 'Already in Inventory',
                  isError: false);

            } else {
              _dbService.addInventory(selectedIngredient);
              _showFlushbar(message: 'Added to Inventory!',
                  isError: false);

            }
          },
          onAddToShoppingList: (selectedName) async {
            final selectedIngredient = matches.firstWhere(
              (i) => i.name == selectedName,
            );
            Navigator.pop(context);

            if (await _dbService.hasInventory(selectedIngredient.id, inventory: false)) {
              _showFlushbar(message: 'Already in Shopping List',
                  isError: false);
            } else {
              _dbService.addShoppingList(selectedIngredient);
              _showFlushbar(message: 'Added to Shopping List!',
                  isError: false);
            }
          },
          onCancel: () {
            Navigator.pop(context);
          },
        ),
      );

      setState(() {
        _scanResult = product.productName;
      });
    } catch (e, stack) {
      debugPrint('Error loading barcode: $e\n$stack');
      _showFlushbar(message: 'No product found for this barcode',
          isError: true);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cameraHeight = MediaQuery.of(context).size.height * 0.55;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [

        Container(
          width: screenWidth,
          height: cameraHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              MobileScanner(
                onDetect: (barcodeCapture) {
                  final barcode = barcodeCapture.barcodes.first;
                  final rawValue = barcode.rawValue ?? '';

                  if (barcode.format == BarcodeFormat.qrCode || rawValue.isEmpty) return;
                  _loadBarcode(rawValue);
                },
              ),

              const ScannerOverlay(),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_isProcessing)
          Center(
            child: Image.asset(
              'assets/images/mixing-bowl.gif',
              width: 120,
              height: 120,
            ),
          ),

        const SizedBox(height: 6),
        Text(
          _isProcessing
              ? ''
              : _scanResult == null
              ? 'Scan a code'
              : 'last scan: $_scanResult',
          style: const TextStyle(fontSize: 18),
        ),
      ],
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final double linePosition; // 0 = top, 1 = bottom
  ScannerOverlayPainter({this.linePosition = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()..color = Colors.black.withOpacity(0.55);

    const double boxWidth = 260;
    const double boxHeight = 175;
    const double cornerRadius = 12;

    final left = (size.width - boxWidth) / 2;
    final top = (size.height - boxHeight) / 2;
    final rect = RRect.fromLTRBR(
      left,
      top,
      left + boxWidth,
      top + boxHeight,
      Radius.circular(cornerRadius),
    );

    // Draw dark overlay with cutout
    final full = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final hole = Path()..addRRect(rect);
    final path = Path.combine(PathOperation.difference, full, hole);
    canvas.drawPath(path, overlayPaint);

    // Draw border
    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(rect, borderPaint);

    // Draw moving red laser line
    final linePaint = Paint()
      ..color = Colors.redAccent.withOpacity(0.7)
      ..strokeWidth = 2;

    final double laserPadding = 6;
    final lineY = top + laserPadding + (boxHeight - laserPadding * 2) * linePosition;

    canvas.drawLine(
      Offset(left + 4, lineY),
      Offset(left + boxWidth - 4, lineY),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant ScannerOverlayPainter oldDelegate) => true;
}

class ScannerOverlay extends StatefulWidget {
  const ScannerOverlay({super.key});

  @override
  State<ScannerOverlay> createState() => _ScannerOverlayState();
}

class _ScannerOverlayState extends State<ScannerOverlay>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (_, __) {
          return CustomPaint(
            size: size,
            painter: ScannerOverlayPainter(
              linePosition: _animation.value,
            ),
          );
        },
      ),
    );
  }
}


