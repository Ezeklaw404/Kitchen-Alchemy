import 'package:flutter/material.dart';
import 'package:kitchen_alchemy/models/recipe.dart';

class RecipeItem extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;

  const RecipeItem({
    super.key,
    required this.recipe,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Image.network(
                recipe.thumbnailUrl ?? '',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (recipe.category != null)
                      Text(
                        recipe.category!,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    if (recipe.area != null)
                      Text(
                        recipe.area!,
                        style: const TextStyle(color: Colors.grey),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
