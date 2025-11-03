import 'package:flutter/material.dart';
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
  // late Future<void> _initializeControllerFuture;
  // final MobileScannerController _controller = MobileScannerController();
  String _scanResult = 'No scan yet';
  bool _isProcessing = false;
  final _barcodeService = BarcodeService();
  final _ingredientService = IngredientService();
  final _dbService = FirestoreService();
  String? _error;

  Future<void> _loadBarcode(String barcode) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final BarcodeProduct? product = await _barcodeService.getProductByBarcode(
        barcode,
      );
      if (product == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No product found for this barcode.')),
        );
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
          onAddToInventory: (selectedName) {
            final selectedIngredient =
            matches.firstWhere((i) => i.name == selectedName);
            Navigator.pop(context);
            _dbService.addInventory(selectedIngredient);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Added to Inventory!')),
            );
          },
          onAddToShoppingList: (selectedName) {
            final selectedIngredient =
            matches.firstWhere((i) => i.name == selectedName);
            Navigator.pop(context);
            _dbService.addShoppingList(selectedIngredient);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Added to Shopping List!')),
            );
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load barcode: $e')));
    } finally {
      setState(() => _isProcessing = false);
      // _controller.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 500,
          child: MobileScanner(
            // controller: _controller,
            onDetect: (barcodeCapture) {
              final barcode = barcodeCapture.barcodes.first;
              final rawValue = barcode.rawValue ?? '';

              // Ignore empty or QR codes
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
