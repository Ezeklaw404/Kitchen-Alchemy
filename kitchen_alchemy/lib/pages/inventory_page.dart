import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:kitchen_alchemy/models/ingredient.dart';
import 'package:kitchen_alchemy/widgets/ingredient_list.dart';
import 'package:kitchen_alchemy/widgets/page_template.dart';
import 'package:kitchen_alchemy/services/firestore_service.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final _service = FirestoreService();
  List<Ingredient> _ingredients = [];
  String? _error;
  bool isSearching = false;
  bool _isLoading = true;
  String query = '';
  TextEditingController _searchController = TextEditingController();


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

      _showFlushbar(message: message, color: color);
    }
  }

  Future<void> _loadIngredients() async {
    try {
      final ingredients = await _service.getInventory();
      setState(() {
        _ingredients = ingredients;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _removeIngredient(Ingredient ingredient) async {
    try {
      await _service.deleteInventoryItem(ingredient);
      setState(() {
        _ingredients?.remove(ingredient);
      });
    } catch (e) {
      _showFlushbar(message: 'Error deleting: $e', color: Colors.red.shade400);
    }
  }

  void _showFlushbar({required String message, required Color color}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Flushbar(
        message: message,
        duration: const Duration(seconds: 2),
        flushbarPosition: FlushbarPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        backgroundColor: color,
        messageColor: Color(0xFF0F3570),
      ).show(context);
    });
  }


  @override
  Widget build(BuildContext context) {


    Widget body;
    if (_error != null) {
      body = Center(child: Text('Error: $_error'));
    } else if (_isLoading) {
      body = Center(
        child: Image.asset(
          'assets/images/mixing-bowl.gif',
          width: 150,
          height: 150,
        ),
      );
    } else if (_ingredients.isEmpty) {
      body = Center(child: Text('Your Inventory is Empty'));
    } else {
      final displayed = _ingredients
          .where((i) => i.name.toLowerCase().contains(query))
          .toList();

      body = IngredientListTemplate(
        ingredients: displayed,
        removable: true,
        onRemove: _removeIngredient,
      );
    }

    return PageTemplate(
      title: !isSearching
          ? 'Inventory'
          : '',
      actions: [
        isSearching ?
            Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: 40,
              alignment: Alignment.center,
              child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search...',
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0F3570), width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) => setState(() => query = value.toLowerCase()),
            ),
            )
        : IconButton(
          icon: Icon(Icons.search, color: Color(0xFF0F3570)),
          onPressed: () => setState(() => isSearching = true),
        ),
        if (isSearching)
          IconButton(
            icon: Icon(Icons.close, color: Color(0xFF0F3570)),
            onPressed: () {
              _searchController.clear();
              setState(() {
                query = '';
                isSearching = false;
              });
            },
          ),
      ],
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
