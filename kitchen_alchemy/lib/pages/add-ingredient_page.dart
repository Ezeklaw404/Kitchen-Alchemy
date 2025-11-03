import 'package:flutter/material.dart';
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

  final IngredientService _service = IngredientService();

  @override
  void initState() {
    super.initState();
    _loadIngredients();
  }

  Future<void> _loadIngredients() async {
    try {
      final ingredients = await _service.getAllIngredients();
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

  Future<void> _addItems(List<Ingredient> selected, bool boolinven) async {
    final firestore = FirestoreService();
    await firestore.addSelectedItems(selected, boolinven);
  }

  @override
  Widget build(BuildContext context) {
    final boolInventory = ModalRoute.of(context)!.settings.arguments as bool? ?? false;

    return PageTemplate(
      title: 'Add Ingredient',
      route: '/add-ingredient',
      showDrawer: false,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) => setState(() => query = value.toLowerCase()),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'CutiveMono',
              ),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF1B5E20)),
                ),
                labelText: 'Enter Name or Id',
                labelStyle: TextStyle(
                  color: Colors.black,

                  //fontFamily: 'Cutive',
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
          if (selected.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No ingredients added')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${selected.length} ingredients added')),
            );
            _addItems(selected, boolInventory);
          }
          Navigator.pushReplacementNamed(context, boolInventory ? '/inventory' : '/shop-list');
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
    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final ingredient = filtered[index];
        final isSelected = _selectedIngredients.contains(ingredient.id);
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: ingredient.isSelected
              ? Colors.blue[100]
              : Colors.amber.shade50,
          child: IngredientItem(
            ingredient: ingredient,
            onTap: () {
              setState(() {
                ingredient.isSelected = !ingredient.isSelected;
              });
            },
          ),
        );
      },
    );
  }
}

// @override
// Widget build(BuildContext context) {
//   return PageTemplate(
//     title: 'Add Ingredient',
//     route: '/add-ingredient',
//     showDrawer: false,
//
//     body: IngredientListTemplate(
//       ingredients: _service.getAllIngredients(),
//       onTap: (ingredient) {
//         setState(() {
//           ingredient.isSelected = !ingredient.isSelected;
//         });
//       },
//     ),
//
//     floatingActionBtn: FloatingActionButton(
//       onPressed: () {
//         final selected = _ingredients.where((i) => i.isSelected).toList();
//
//         if (selected.isEmpty) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('No ingredients selected!')),
//           );
//           return;
//         }
//         _addItems(selected);
//         Navigator.pushReplacementNamed(context, '/inventory');
//       },
//       child: Text('Add'),
//     ),
//   );
// }
// // Column(
// //   children: [
// //     Padding(
// //       padding: const EdgeInsets.all(8.0),
// //       child: TextField(
// //         onChanged: (value) => setState(() => query = value.toLowerCase()),
// //         style: const TextStyle(
// //           fontSize: 18,
// //           fontWeight: FontWeight.bold,
// //           fontFamily: 'CutiveMono',
// //         ),
// //         decoration: const InputDecoration(
// //           border: OutlineInputBorder(),
// //           focusedBorder: OutlineInputBorder(
// //             borderSide: BorderSide(color: Color(0xFF1B5E20)),
// //           ),
// //           labelText: 'Enter Name or Id',
// //           labelStyle: TextStyle(
// //             color: Colors.black,
// //             // fontFamily: 'Cutive',
// //           ),
// //         ),
// //       ),
// //     ),
// //
// //     if (_isLoading)
// //       const Expanded(child: Center(child: CircularProgressIndicator()))
// //     else if (_error != null)
// //       Expanded(child: Center(child: Text('Error: $_error')))
// //     else
// //       // filtered list
// //       Expanded(child: _buildIngredientList()),
// //   ],
// // ),
//
// //
// // Widget _buildIngredientList() {
// //   final filtered = _ingredients
// //       .where(
// //         (i) =>
// //             i.name.toLowerCase().contains(query) ||
// //             i.id.toLowerCase().contains(query),
// //       )
// //       .toList();
// //
// //   if (filtered.isEmpty) {
// //     return const Center(child: Text('No Ingredients match your search'));
// //   }
// //
// //   return ListView.builder(
// //     itemCount: filtered.length,
// //     itemBuilder: (context, index) {
// //       final ingredient = filtered[index];
// //       final isSelected = _selectedIngredients.contains(ingredient.id);
// //       return Card(
// //         margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// //         elevation: 2,
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(10),
// //         ),
// //         color: ingredient.isSelected
// //             ? Colors.blue[100]
// //             : Colors.amber.shade50,
// //         child: IngredientItem(
// //           ingredient: ingredient,
// //           onTap: () {
// //             setState(() {
// //               ingredient.isSelected = !ingredient.isSelected;
// //             });
// //           },
// //         ),
// //       );
// //     },
// //   );
