import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:kitchen_alchemy/models/ingredient.dart';
import 'package:kitchen_alchemy/widgets/ingredient_list.dart';
import 'package:kitchen_alchemy/widgets/page_template.dart';
import 'package:kitchen_alchemy/services/firestore_service.dart';

class ShoppingListPage extends StatefulWidget {
  final bool boolInventory;
  const ShoppingListPage({super.key, this.boolInventory = true});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}


class _ShoppingListPageState extends State<ShoppingListPage> {
  final _service = FirestoreService();
  List<Ingredient> _ingredients = [];
  String? _error;

  bool _selectMode = false;
  Set<String> _selectedIds = {};

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
      final ingredients = await _service.getShoppingList();
      setState(() => _ingredients = ingredients);
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  void _removeIngredient(Ingredient ingredient) async {
    try {
      await _service.deleteShoppingListItem(ingredient);
      setState(() {
        _ingredients?.remove(ingredient);
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error deleting: $e')));
    }
  }


  Future<void> _moveToInventory() async {
    if (_ingredients.isEmpty) {
      _showFlushbar(
        message: 'Shopping list is empty',
        color: Theme.of(context).colorScheme.error,
      );
      return;
    }

    if (!_selectMode) {
      setState(() {
        _selectMode = true;
        _selectedIds = _ingredients.map((i) => i.id).toSet(); // select all
        for (var i in _ingredients) {
          i.isSelected = true;
        }
      });
      _showFlushbar(
        message: 'Tap ingredients to unselect items you didn’t get',
        color: Color(0xFF7AA6ED),
      );
      return;
    }

    final selectedIngredients =
    _ingredients.where((i) => _selectedIds.contains(i.id)).toList();

    for (final ingredient in selectedIngredients) {
      final alreadyInInventory =
      await _service.hasInventory(ingredient.id, inventory: true);

      if (!alreadyInInventory) {
        await _service.addSelectedItems([ingredient], true);
      }

      await _service.deleteShoppingListItem(ingredient);
    }

    setState(() {
      _ingredients.removeWhere((i) => _selectedIds.contains(i.id));
      _selectMode = false;
      _selectedIds.clear();
    });


    _showFlushbar(
      message: 'All ingredients moved to inventory',
      color: Color(0xFF7AA6ED),
    );
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
    if (_ingredients == null) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      body = Center(child: Text('Error: $_error'));
    } else {
      body = IngredientListTemplate(
        ingredients: _ingredients,
        removable: !_selectMode,
        onRemove: _removeIngredient,
        onTap: _selectMode
            ? (ingredient) {
          if (!_selectMode) return;
          setState(() {
            ingredient.isSelected = !ingredient.isSelected;
            if (ingredient.isSelected) {
              _selectedIds.add(ingredient.id);
            } else {
              _selectedIds.remove(ingredient.id);
            }
          });
        } : null,
      );
    }

    return PageTemplate(
      title: 'Shopping List',
      route: '/shop-list',
      showDrawer: true,
      navIndex: 3,
      body: body,

      floatingActionBtn: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(

            heroTag: 'addIngredient',
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/add-ingredient',
                arguments: {'isInventory': false, 'ingredients': _ingredients},
              );
            },
            child: const Icon(Icons.add),
            // child: const Icon(Icons.playlist_add),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(

            heroTag: 'moveToInventory',
            onPressed: _moveToInventory,
            child: const Icon(Icons.shopping_cart),
          ),
        ],
      ),
    );
  }
}



