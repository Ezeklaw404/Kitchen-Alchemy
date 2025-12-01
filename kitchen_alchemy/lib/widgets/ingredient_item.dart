import 'package:flutter/material.dart';
import 'package:kitchen_alchemy/models/ingredient.dart';

class IngredientItem extends StatelessWidget {
  final Ingredient ingredient;
  final VoidCallback? onTap;


  const IngredientItem({super.key,
  required this.ingredient, this.onTap
});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(ingredient.name),
      subtitle: ingredient.dateAdded == null ? null
      : Text('Added: ${ingredient.dateAdded!.month}/${ingredient.dateAdded!.day}/${ingredient.dateAdded!.year}'),
      dense: true,

      trailing: ingredient.isSelected ? Icon(Icons.check) : null,
      onTap: onTap,
    );
  }
}
