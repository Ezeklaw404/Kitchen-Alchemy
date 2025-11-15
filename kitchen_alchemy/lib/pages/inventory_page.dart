import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:kitchen_alchemy/models/ingredient.dart';
import 'package:kitchen_alchemy/widgets/ingredient_list.dart';
import 'package:kitchen_alchemy/widgets/page_template.dart';
import 'package:kitchen_alchemy/services/firestore_service.dart';
import 'package:kitchen_alchemy/widgets/ingredient_item.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final _service = FirestoreService();
  List<Ingredient> _ingredients = [];
  String? _error;
  String output = '';

  @override
  void initState() {
    super.initState();
    _loadIngredients();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showFlushbarFromArgs();
    });
  }

  void _showFlushbarFromArgs() {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null && args['showFlushbar'] == true) {
      final message = args['message'] ?? '';
      final color = args['color'] ?? Theme.of(context).colorScheme.primary;

      Flushbar(
        message: message,
        duration: const Duration(seconds: 2),
        flushbarPosition: FlushbarPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        backgroundColor: color,
        messageColor: Color(0xFF0F3570),
      ).show(context);
    }
  }

  Future<void> _loadIngredients() async {
    try {
      final ingredients = await _service.getInventory();
      setState(() {
        _ingredients = ingredients;
        output = 'Your Inventory is Empty';
      });
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  void _removeIngredient(Ingredient ingredient) async {
    try {
      await _service.deleteInventoryItem(ingredient);
      setState(() {
        _ingredients?.remove(ingredient);
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {


    Widget body;
    if (_error != null) {
      body = Center(child: Text('Error: $_error'));
    } else if (_ingredients.isEmpty) {
      body = Center(child: Text(output));
    } else {
      body = IngredientListTemplate(
        ingredients: _ingredients,
        removable: true,
        onRemove: _removeIngredient,
      );
    }

    return PageTemplate(
      title: 'Inventory',
      route: '/inventory',
      showDrawer: true,
      navIndex: 0,
      body: body,

      floatingActionBtn: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/add-ingredient',
            arguments: {'isInventory': true, 'ingredients': _ingredients},
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
