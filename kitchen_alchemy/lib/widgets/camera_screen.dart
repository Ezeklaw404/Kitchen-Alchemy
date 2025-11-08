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

  Future<void> _loadBarcode(String barcode) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final BarcodeProduct? product = await _barcodeService.getProductByBarcode(
        barcode,
      );
      if (product == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No product found for this barcode.'),
          ), //TODO ive never seen this, usually just says scan error instead
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
          onAddToInventory: (selectedName) async {
            final selectedIngredient = matches.firstWhere(
              (i) => i.name == selectedName,
            );
            Navigator.pop(context);

            if ( await _dbService.hasInventory(selectedIngredient.id, inventory: true)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Already in Inventory')),
              );
            } else {
              _dbService.addInventory(selectedIngredient);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to Inventory!')),
              );
            }
          },
          onAddToShoppingList: (selectedName) async {
            final selectedIngredient = matches.firstWhere(
              (i) => i.name == selectedName,
            );
            Navigator.pop(context);

            if (await _dbService.hasInventory(selectedIngredient.id, inventory: false)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Already in Shopping List')),
              );
            } else {
              _dbService.addShoppingList(selectedIngredient);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to Shopping List!')),
              );
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load barcode: $e')));
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
