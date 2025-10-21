import 'package:flutter/material.dart';
import 'package:kitchen_alchemy/models/ingredient.dart';
import 'package:kitchen_alchemy/widgets/page_template.dart';
import 'package:kitchen_alchemy/services/firestore_service.dart';
import 'package:kitchen_alchemy/widgets/ingredient_item.dart';

class ShoppingListPage extends StatelessWidget {
  const ShoppingListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final _service = FirestoreService();

    return PageTemplate(
      title: 'Shopping List',
      route: '/shop-list',
      showDrawer: true,
      body: FutureBuilder<List<Ingredient>>(
        future: _service.getShoppingList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Shopping list is empty'));
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
    );
  }
}