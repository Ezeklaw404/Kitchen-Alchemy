import 'package:flutter/material.dart';
import 'package:kitchen_alchemy/models/ingredient.dart';
import 'package:kitchen_alchemy/widgets/ingredient_list.dart';
import 'package:kitchen_alchemy/widgets/page_template.dart';
import 'package:kitchen_alchemy/services/firestore_service.dart';
import 'package:kitchen_alchemy/widgets/ingredient_item.dart';

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

  @override
  void initState() {
    super.initState();
    _loadIngredients();
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

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_ingredients == null) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      body = Center(child: Text('Error: $_error'));
    } else {
      body = IngredientListTemplate(
        ingredients: _ingredients!,
        removable: true,
        onTap: _removeIngredient,
      );
    }

    return PageTemplate(
      title: 'Shopping List',
      route: '/shop-list',
      showDrawer: true,
      body: body,

      floatingActionBtn: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-ingredient',
            arguments: {'isInventory': false, 'ingredients': _ingredients},);
        },
        child: const Icon(Icons.add_shopping_cart),
      ),
    );
  }
}



