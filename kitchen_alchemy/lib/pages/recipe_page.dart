import 'package:another_flushbar/flushbar.dart';
import 'package:kitchen_alchemy/models/ingredient.dart';
import 'package:kitchen_alchemy/models/recipe.dart';
import 'package:kitchen_alchemy/services/firestore_service.dart';
import 'package:kitchen_alchemy/services/ingredient_service.dart';
import 'package:kitchen_alchemy/widgets/page_template.dart';
import 'package:flutter/material.dart';


class RecipePage extends StatefulWidget {
  const RecipePage({super.key});

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  final _service = FirestoreService();
  final _ingService = IngredientService();
  bool _isLoading = false;
  late bool isFavorite;
  bool favSet = false;
  late final recipe;


  @override
  void initState() {
    super.initState();
    checkFavoriteStatus();
  }

  Future<void> checkFavoriteStatus() async {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    recipe = args['recipe'] as Recipe;

    final fav = await FirestoreService().isFavorite(recipe.id);
    setState(() {
      isFavorite = fav;
      favSet = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!favSet) {
      checkFavoriteStatus();
    }



    return PageTemplate(
        title: recipe.name,
        route: '/recipe',
        showDrawer: false,
        navIndex: -2,
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red.shade600 : Color(0xFF0F3570),
            ),
            onPressed: () async {
              setState(() {
                isFavorite = !isFavorite;
              });
              if (isFavorite) {
                await _service.addFavorite(recipe.id);
              } else {
                await _service.removeFavorite(recipe.id);
              }
            },
          ),
        ],
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
                  Text('${entry.value}: ${entry.key}'),

                const SizedBox(height: 12),
                SizedBox(
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                      setState(() => _isLoading = true);

                      try {
                        List<Ingredient> ingredientList = [];

                        for (final entry in recipe.ingredients.entries) {
                          final ingredient = await _ingService.getIngredientByName(entry.key);
                          if (ingredient != null) ingredientList.add(ingredient);
                        }

                        await _service.addRecipeToShoppingList(ingredientList);


                        Flushbar(
                          message: 'Added missing ingredients to Shopping List',
                          duration: const Duration(seconds: 2),
                          flushbarPosition: FlushbarPosition.TOP,
                          margin: const EdgeInsets.all(16),
                          borderRadius: BorderRadius.circular(12),
                          backgroundColor: Color(0xFF7AA6ED),
                          messageColor: Color(0xFF0F3570),
                        ).show(context);

                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      } finally {
                        setState(() => _isLoading = false);
                      }
                    },

                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text('Add to Shopping List'),
                  ),
                ),
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
                    onPressed: () {},  //TODO imbed the video link here or just the link idk
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







