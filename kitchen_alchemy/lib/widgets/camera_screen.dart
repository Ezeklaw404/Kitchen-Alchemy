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

class _CameraScreenState extends State<CameraScreen> {
  String _scanResult = '';
  bool _isProcessing = false;
  final _barcodeService = BarcodeService();
  final _ingredientService = IngredientService();
  final _dbService = FirestoreService();
  String? _error;

  @override
  void initState() {
    super.initState();

    _scanResult = 'No scan yet';
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
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
            isError: true); //TODO ive never seen this, usually just says scan error instead
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
      _showFlushbar(message: 'Failed to load barcode: $e',
          isError: true);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: screenWidth,
          height: screenWidth * 4 / 3,
          // 4:3 aspect ratio, adjust as needed
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            // border: Border.all(color: Color(0xFF110E0B), width: 3),
          ),
          clipBehavior: Clip.hardEdge,
          child: MobileScanner(
            onDetect: (barcodeCapture) {
              final barcode = barcodeCapture.barcodes.first;
              final rawValue = barcode.rawValue ?? '';

              if (barcode.format == BarcodeFormat.qrCode || rawValue.isEmpty) {
                return;
              }

              _loadBarcode(rawValue);
            },
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _isProcessing
              ? 'Processing...'
              : _scanResult == null
              ? 'Scan a code'
              : 'last scan: $_scanResult',
          style: const TextStyle(fontSize: 18),
        ),
      ],
    );
  }
}


// ? Image.asset( TODO fix loading in scanner
// // 'assets/images/loading.gif', //40
// // 'assets/images/rolling-loading.gif', //75
// 'assets/images/mixing-bowl.gif', //150
// // 'assets/images/mixing-machine.gif', //150
//
// width: 150,
// height: 150,
// )
// :