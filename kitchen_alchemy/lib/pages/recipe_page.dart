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

  void _showFlushbar({required String message, required Color color}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Flushbar(
        message: message,
        duration: const Duration(seconds: 2),
        flushbarPosition: FlushbarPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        backgroundColor: color,
        messageColor: Color(0xFF0F3570),
      ).show(context);
    });
  }

  void _openCompleteRecipeDialog() async {
    if (recipe == null) return;

    final userIngredients = await _service.getInventory();

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

    // if (availableMap.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('You have no ingredients for this recipe!')),
    //   );
    //   return;
    // } TODO can still complete when missing ingredients, userSetting

    final selectedItems = <String>{};

    final selectedNames = await showDialog<List<String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Mark used items as gone'),
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
      final selectedIngredients = selectedNames.map((n) => availableMap[n]!).toList();

      await _service.removeInventoryIngredients(selectedIngredients);

      _showFlushbar(message: 'Removed ${selectedIngredients.length} ingredients from your inventory',
          color: Color(0xFF7AA6ED));
    }
  }


  Future<void> addMissingIngredientsToShoppingList() async {
    setState(() => _isLoading = true);

    try {
      final inventory = await _service.getInventory();
      List<Ingredient> ingredientList = [];

      for (final entry in recipe!.ingredients.entries) {
        final ingredient = await _ingService.getIngredientByName(entry.key);
        if (ingredient == null) continue;

        final alreadyOwned = inventory.any((inv) =>
        inv.name.toLowerCase().trim() ==
            ingredient.name.toLowerCase().trim());

        if (!alreadyOwned) {
          ingredientList.add(ingredient);
        }
      }

      if (ingredientList.isEmpty) {
        _showFlushbar(message: 'No missing ingredients found', color: Color(0xFF7AA6ED));
        return;
      }

      await _service.addSelectedItems(ingredientList, false);

      _showFlushbar(message: 'ingredients to Shopping List', color: Color(0xFF7AA6ED));


    } catch (e) {
      _showFlushbar(message: 'Error: $e', color: Colors.red.shade400);
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
                // Thumbnail
                if (recipe.thumbnailUrl != null && recipe.thumbnailUrl!.isNotEmpty)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black26)],
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
                  const Icon(Icons.image_not_supported, size: 120, color: Colors.grey),

                const SizedBox(height: 16),

                // Category & Area
                Center(
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      Chip(
                        label: Text(
                          'Category: ${recipe.category ?? "Unknown"}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: Colors.orange.shade100,
                      ),
                      Chip(
                        label: Text(
                          '${recipe.area ?? "Unknown"}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: Colors.blue.shade100,
                      ),
                    ],
                  ),
                ),

                if (recipe.tags != null && recipe.tags!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Tags: ${recipe.tags!}',
                      style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Ingredients heading
                Center(
                  child: Text(
                    'Ingredients',
                    style: const TextStyle(fontFamily: 'AbrilFatface', fontSize: 24),
                  ),
                ),
                const SizedBox(height: 8),

                // Ingredients list
                ...recipe.ingredients.entries.map(
                      (entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                    child: Text(
                      '${entry.value} ${entry.key}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                Center(
                  child: SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
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
                ),

                const SizedBox(height: 24),

                // YouTube video
                if (recipe.youtubeUrl != null && recipe.youtubeUrl!.isNotEmpty) ...[
                  YoutubePlayer(
                    controller: YoutubePlayerController(
                      initialVideoId: YoutubePlayer.convertUrlToId(recipe.youtubeUrl!)!,
                      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
                    ),
                    showVideoProgressIndicator: true,
                  ),
                  const SizedBox(height: 24),
                ],

                // Instructions heading
                Center(
                  child: Text(
                    'Instructions',
                    style: const TextStyle(fontFamily: 'AbrilFatface', fontSize: 24),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  recipe.instructions,
                  style: const TextStyle(fontSize: 16, height: 1.4),
                ),

                const SizedBox(height: 16),
                Center(
                  child: SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => _openCompleteRecipeDialog(),
                      child: const Text('Complete Recipe'),
                    ),
                  ),
                ),

                if (recipe.sourceUrl != null && recipe.sourceUrl!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton.icon(
                      onPressed: () async {
                        final url = Uri.parse(recipe.sourceUrl!);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        }
                      },
                      icon: const Icon(Icons.link),
                      label: const Text('View Recipe Source'),
                    ),
                  ),
                ],
              ],
            ),

          ),
        ),


    );
  }

}







