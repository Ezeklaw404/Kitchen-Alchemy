import 'package:flutter/material.dart';
import 'package:kitchen_alchemy/models/ingredient.dart';
import 'package:kitchen_alchemy/widgets/ingredient_item.dart';

class IngredientListTemplate extends StatelessWidget {
  final List<Ingredient> ingredients;
  final bool scrollable;
  final bool removable;
  final void Function(Ingredient)? onTap;

  const IngredientListTemplate({
    super.key,
    required this.ingredients,
    this.onTap,
    this.scrollable = true,
    required this.removable,
  });

  @override
  Widget build(BuildContext context) {
    final list = ListView.builder(
      shrinkWrap: true,
      physics: scrollable
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      itemCount: ingredients.length,
      itemBuilder: (context, index) {
        final ingredient = ingredients[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: ingredient.isSelected
              ? Colors.blue[100]
              : Colors.amber.shade50,
          child: Stack(
            children: [
              // Main card tap area (selectable)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: removable
                      ? null
                      : () => onTap?.call(ingredient),
                  borderRadius: BorderRadius.circular(10),

                    child: IngredientItem(ingredient: ingredient),
                ),
              ),

              // Delete button in top-right if removable
              if (removable)
                Positioned(
                  right: 4,
                  top: 4,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.redAccent),
                    onPressed: () => onTap?.call(ingredient),
                  ),
                ),
            ],
          ),
        );
      },
    );
    return list;
  }
}
