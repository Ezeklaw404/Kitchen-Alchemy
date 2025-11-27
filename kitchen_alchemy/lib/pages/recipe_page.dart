import 'package:another_flushbar/flushbar.dart';
import 'package:kitchen_alchemy/models/ingredient.dart';
import 'package:kitchen_alchemy/models/recipe.dart';
import 'package:kitchen_alchemy/services/firestore_service.dart';
import 'package:kitchen_alchemy/services/ingredient_service.dart';
import 'package:kitchen_alchemy/widgets/page_template.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';


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
  bool isLoaded = false;
  late final recipe;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      _initialized = true;
      loadData();
    }
  }


  Future<void> loadData() async {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    recipe = args['recipe'] as Recipe;

    final fav = await _service.isFavorite(recipe!.id);

    setState(() {
      isFavorite = fav;
      isLoaded = true;
    });
  }


  void _openCompleteRecipeDialog() async {
    if (recipe == null) return;

    // Get user's inventory
    final userIngredients = await _service.getInventory();

    // Map recipe ingredient -> inventory object (if user has it)
    final Map<String, Ingredient> availableMap = {};
    for (var entry in recipe!.ingredients.entries) {
      final inv = userIngredients.firstWhere(
            (i) => i.name.toLowerCase().trim() == entry.key.toLowerCase().trim(),
        orElse: () => null as Ingredient,
      );
      if (inv != null) {
        availableMap[entry.key] = inv;
      }
    }

    if (availableMap.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have no ingredients for this recipe!')),
      );
      return;
    }

    // Start with all deselected
    final selectedItems = <String>{};

    // Show the dialog
    final selectedNames = await showDialog<List<String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select used ingredients'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: availableMap.keys.map((ingredient) {
                return StatefulBuilder(
                  builder: (context, setState) {
                    final isSelected = selectedItems.contains(ingredient);
                    return CheckboxListTile(
                      title: Text(ingredient),
                      value: isSelected,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            selectedItems.add(ingredient);
                          } else {
                            selectedItems.remove(ingredient);
                          }
                        });
                      },
                    );
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, selectedItems.toList()),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );

    if (selectedNames != null && selectedNames.isNotEmpty) {
      // Only remove the selected ingredients from inventory
      final selectedIngredients = selectedNames.map((n) => availableMap[n]!).toList();

      await _service.removeInventoryIngredients(selectedIngredients);

      Flushbar(
        message: 'Removed ${selectedIngredients.length} ingredients from your inventory',
        duration: const Duration(seconds: 2),
        flushbarPosition: FlushbarPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        backgroundColor: const Color(0xFF7AA6ED),
        messageColor: const Color(0xFF0F3570),
      ).show(context);
    }
  }





  Future<void> addMissingIngredientsToShoppingList() async {
    setState(() => _isLoading = true);

    try {
      List<Ingredient> ingredientList = [];

      for (final entry in recipe!.ingredients.entries) {
        final ingredient = await _ingService.getIngredientByName(entry.key);
        if (ingredient != null) ingredientList.add(ingredient);
      }

      if (ingredientList.isEmpty) {
        Flushbar(
          message: 'No missing ingredients found',
          duration: const Duration(seconds: 2),
          flushbarPosition: FlushbarPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(12),
          backgroundColor: const Color(0xFF7AA6ED),
          messageColor: const Color(0xFF0F3570),
        ).show(context);
        return;
      }

      await _service.addSelectedItems(ingredientList, false);

      Flushbar(
        message: 'Added ${ingredientList.length} ingredients to Shopping List',
        duration: const Duration(seconds: 2),
        flushbarPosition: FlushbarPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        backgroundColor: const Color(0xFF7AA6ED),
        messageColor: const Color(0xFF0F3570),
      ).show(context);

    } catch (e) {
      Flushbar(
        message: 'Error: $e',
        duration: const Duration(seconds: 2),
        flushbarPosition: FlushbarPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        backgroundColor: Colors.red.shade400,
        messageColor: Colors.white,
      ).show(context);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoaded || recipe == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
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
                    onPressed: _isLoading ? null : addMissingIngredientsToShoppingList,
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

                if (recipe.youtubeUrl != null && recipe.youtubeUrl!.isNotEmpty) ...[
                  const SizedBox(height: 16),

                  YoutubePlayer(
                    controller: YoutubePlayerController(
                      initialVideoId: YoutubePlayer.convertUrlToId(recipe.youtubeUrl!)!,
                      flags: const YoutubePlayerFlags(
                        autoPlay: false,
                        mute: false,
                      ),
                    ),
                    showVideoProgressIndicator: true,
                  ),
                ],

                const SizedBox(height: 24),

                const Text(
                  'Instructions:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(recipe.instructions),

                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _openCompleteRecipeDialog(),
                    child: const Text('Complete Recipe'),
                  ),
                ),



                if (recipe.sourceUrl != null && recipe.sourceUrl!.isNotEmpty)
                  TextButton.icon(
                    onPressed: () async {
                      final url = Uri.parse(recipe.sourceUrl!);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                    icon: const Icon(Icons.link),
                    label: const Text('View Recipe Source'),
                  ),
              ],
            ),
          ),
        ),


    );
  }

}







