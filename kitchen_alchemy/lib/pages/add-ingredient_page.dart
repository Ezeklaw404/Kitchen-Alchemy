import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:kitchen_alchemy/main.dart';
import 'package:kitchen_alchemy/models/ingredient.dart';
import 'package:kitchen_alchemy/services/firestore_service.dart';
import 'package:kitchen_alchemy/widgets/ingredient_list.dart';
import 'package:kitchen_alchemy/widgets/page_template.dart';
import 'package:kitchen_alchemy/services/ingredient_service.dart';
import 'package:kitchen_alchemy/widgets/ingredient_item.dart';

class IngredientPage extends StatefulWidget {
  const IngredientPage({super.key});

  @override
  State<IngredientPage> createState() => _IngredientPageState();
}

class _IngredientPageState extends State<IngredientPage> {
  List<Ingredient> _ingredients = [];
  bool _isLoading = true;
  String? _error;
  String query = '';

  final Set<String> _selectedIngredients = {};
  late final List<Ingredient> _userIngredients;
  final IngredientService _service = IngredientService();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments as Map?;
      _userIngredients = args?['ingredients'] as List<Ingredient>? ?? [];
      _loadIngredients();
    });
  }

  Future<void> _loadIngredients() async {
    try {
      final ingredients = await _service.getAllIngredients();

      final filtered = ingredients.where((ingredient) {
        return !_userIngredients.any((existing) =>
        existing.name.toLowerCase() == ingredient.name.toLowerCase());
      }).toList();

      setState(() {
        _ingredients = filtered;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addItems(List<Ingredient> selected, bool boolinven) async {
    final firestore = FirestoreService();
    await firestore.addSelectedItems(selected, boolinven);
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    final bool boolInventory = args?['isInventory'] as bool? ?? false;

    return PageTemplate(
      title: 'Add Ingredient',
      route: '/add-ingredient',
      showDrawer: false,
      navIndex: -2,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) => setState(() => query = value.toLowerCase()),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF1B5E20)),
                ),
                labelText: 'Enter Name or Id',
                labelStyle: TextStyle(
                  color: Colors.black,

                ),
              ),
            ),
          ),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_error != null)
            Expanded(child: Center(child: Text('Error: $_error')))
          else
            // filtered list
            Expanded(child: _buildIngredientList()),
        ],
      ),
      floatingActionBtn: FloatingActionButton(
        onPressed: () {
          final selected = _ingredients.where((i) => i.isSelected).toList();

          if (selected.isNotEmpty) {
            _addItems(selected, boolInventory);
          }
            Navigator.pushReplacementNamed(
              context,
              boolInventory ? '/inventory' : '/shop-list',
              arguments: {
                'showFlushbar': true,
                'message': selected.isEmpty
                    ? 'No ingredients added'
                    : '${selected.length} ingredients added',
                'color': selected.isEmpty
                    ? Color(0xFFFFCDD2) //error
                    : Color(0xFF7AA6ED),
              },
            );

        },
        child: Text('Add'),
      ),
    );
  }

  Widget _buildIngredientList() {
    final filtered = _ingredients
        .where(
          (i) =>
      i.name.toLowerCase().contains(query) ||
          i.id.toLowerCase().contains(query),
    )
        .toList();

    if (filtered.isEmpty) {
      return const Center(child: Text('No Ingredients match your search'));
    }

    return IngredientListTemplate(
      ingredients: filtered,
      removable: false,
      onTap: (ingredient) {
        setState(() {
          ingredient.isSelected = !ingredient.isSelected;
        });
      },
    );
  }
}
