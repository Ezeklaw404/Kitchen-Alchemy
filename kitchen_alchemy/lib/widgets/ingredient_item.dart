import 'package:flutter/material.dart';
import 'package:kitchen_alchemy/models/ingredient.dart';

class IngredientItem extends StatelessWidget {
  final Ingredient ingredient;
  final VoidCallback? onTap;


  const IngredientItem({super.key,
  required this.ingredient,
  this.onTap
});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(ingredient.name),
      subtitle: Text('${ingredient.id}  ${ingredient.type}'),
      onTap: onTap,

    );
  }
}
