import 'package:flutter/material.dart';
import 'package:kitchen_alchemy/models/ingredient.dart';
import 'package:kitchen_alchemy/pages/page_template.dart';
import 'package:kitchen_alchemy/services/firestore_service.dart';
import 'package:kitchen_alchemy/widgets/ingredient_item.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final _service = FirestoreService();

    return PageTemplate(
      title: 'Inventory',
      route: '/inventory',
      showDrawer: true,
      body: FutureBuilder<List<Ingredient>>(
        future: _service.getInventory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Inventory is empty'));
          }

          final ingredients = snapshot.data!;
          return ListView.builder(
            itemCount: ingredients.length,
            itemBuilder: (context, index) {
              return IngredientItem(
                ingredient: ingredients[index],
                onTap: () {},
              );
            },
          );
        },
      ),
      floatingActionBtn: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-ingredient');
        },
      ),
    );
  }
}
