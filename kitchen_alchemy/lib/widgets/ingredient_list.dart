import 'package:flutter/material.dart';
import 'package:kitchen_alchemy/models/ingredient.dart';
import 'package:kitchen_alchemy/widgets/ingredient_item.dart';

class IngredientListTemplate extends StatelessWidget {
  final List<Ingredient> ingredients;
  final bool scrollable;
  final bool removable;
  final void Function(Ingredient)? onTap;
  final void Function(Ingredient)? onRemove;

  const IngredientListTemplate({
    super.key,
    required this.ingredients,
    this.onTap,
    this.onRemove,
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
              ? Colors.orangeAccent
              : Color(0xFFfffbf5),
          child: Stack(
            children: [
              Material(
                color: Colors.transparent,
                child:  onTap != null
                    ? InkWell(
                  onTap: () => onTap?.call(ingredient),
                  borderRadius: BorderRadius.circular(10),

                    child: IngredientItem(ingredient: ingredient),
                ) : IngredientItem(ingredient: ingredient),
              ),

              if (removable)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.redAccent),
                    onPressed: () => onRemove?.call(ingredient),
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
