import 'package:flutter/material.dart';
import 'package:kitchen_alchemy/models/recipe.dart';

class RecipeItem extends StatefulWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final List<String> userIngredients;

  const RecipeItem({
    super.key,
    required this.recipe,
    required this.onTap,
    required this.userIngredients,
  });

  @override
  State<RecipeItem> createState() => _RecipeItemState();
}

class _RecipeItemState extends State<RecipeItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final ingredients = (widget.recipe.ingredients as Map<String, String>).keys
        .toList();

    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        color: const Color(0xFFfffbf5),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  child: Image.network(
                    widget.recipe.thumbnailUrl ?? '',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[400],
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
                          widget.recipe.name,
                          style: const TextStyle(
                            fontFamily: 'AbrilFatface',
                            fontSize: 16,
                          ),
                        ),
                        if (widget.recipe.category != null)
                          Text(
                            widget.recipe.category!,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        if (widget.recipe.area != null)
                          Text(
                            widget.recipe.area!,
                            style: const TextStyle(color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                ),
                if (ingredients.isNotEmpty)
                  Builder(
                    builder: (_) {
                      final total = ingredients.length;
                      final haveCount = ingredients
                          .where(
                            (ing) => widget.userIngredients
                                .map((e) => e.toLowerCase())
                                .contains(ing.toLowerCase()),
                          )
                          .length;
                      final ratio = haveCount / total;
                      final dotColor = ratio == 1.0
                          ? Colors.green
                          : (ratio > 0.75 ? Colors.orange : Colors.red);

                      return Row(
                        children: [
                          Icon(Icons.circle, size: 10, color: dotColor),
                          const SizedBox(width: 4),
                          Text(
                            '$haveCount/$total',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      );
                    },
                  ),

                IconButton(
                  icon: Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                  onPressed: () {
                    setState(() {
                      _expanded = !_expanded;
                    });
                  },
                ),
              ],
            ),

            if (_expanded)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: ingredients.map((ing) {
                    final hasIt = widget.userIngredients
                        .map((e) => e.toLowerCase())
                        .contains(ing.toLowerCase());
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 10,
                            color: hasIt ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(ing),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
