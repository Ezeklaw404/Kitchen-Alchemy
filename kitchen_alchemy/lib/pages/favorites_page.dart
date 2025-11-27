import 'package:flutter/material.dart';
import 'package:kitchen_alchemy/models/recipe.dart';
import 'package:kitchen_alchemy/services/firestore_service.dart';
import 'package:kitchen_alchemy/services/recipe_service.dart';
import 'package:kitchen_alchemy/widgets/page_template.dart';
import 'package:kitchen_alchemy/widgets/recipe_item.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final _service = RecipeService();
  List<Recipe> favoriteRecipes = [];
  List<String> userIngredients = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserIngredients();
    loadFavorites();
  }

  void loadUserIngredients() async {
    final ing = await FirestoreService().getInventory();
    userIngredients = ing.map((i) => i.name).toList();
    setState(() {});
  }

  void loadFavorites() async {
    setState(() => isLoading = true);

    final service = FirestoreService();

    try {
      final favoriteIds = await service.getFavoriteRecipes();

      final List<Recipe?> recipes = await Future.wait(
        favoriteIds.map((id) => _service.getRecipeById(id)),
      );

      final List<Recipe> tempFavorites = recipes.whereType<Recipe>().toList();

      setState(() {
        favoriteRecipes = tempFavorites;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print('Error loading favorites: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Favorites',
      route: '/favorites',
      showDrawer: true,
      navIndex: -1,
        body: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : favoriteRecipes.isEmpty
              ? const Text('No favorites yet')
              : ListView.builder(
            itemCount: favoriteRecipes.length,
            itemBuilder: (context, index) {
              return RecipeItem(
                recipe: favoriteRecipes[index],
                userIngredients: userIngredients,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/recipe',
                    arguments: {'recipe': favoriteRecipes[index]},
                  );
                },
              );
            },
          ),
        ),
    );
  }

}
