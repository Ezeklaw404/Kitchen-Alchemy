import 'package:kitchen_alchemy/models/recipe.dart';
import 'package:kitchen_alchemy/widgets/page_template.dart';
import 'package:flutter/material.dart';

class RecipePage extends StatelessWidget {
  const RecipePage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final recipe = args['recipe'] as Recipe;
    return PageTemplate(
        title: recipe.name,
        route: '/recipe',
        showDrawer: false,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (recipe.thumbnailUrl != null && recipe.thumbnailUrl!.isNotEmpty)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(blurRadius: 8)],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        recipe.thumbnailUrl!,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else
                  const Icon(Icons.image_not_supported, size: 120),

                const SizedBox(height: 16),

                Text(
                  'Category: ${recipe.category ?? "Unknown"}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Area: ${recipe.area ?? "Unknown"}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),

                if (recipe.tags != null && recipe.tags!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('Tags: ${recipe.tags!}'),
                ],

                const SizedBox(height: 24),

                const Text(
                  'Ingredients:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                for (final entry in recipe.ingredients.entries)
                  Text('${entry.key}: ${entry.value}'),

                const SizedBox(height: 24),

                const Text(
                  'Instructions:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(recipe.instructions),

                const SizedBox(height: 24),

                if (recipe.youtubeUrl != null && recipe.youtubeUrl!.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.video_library),
                    label: const Text('Watch on YouTube'),
                  ),

                if (recipe.sourceUrl != null && recipe.sourceUrl!.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.link),
                    label: const Text('View Source'),
                  ),
              ],
            ),
          ),
        ),
    );
  }

}
