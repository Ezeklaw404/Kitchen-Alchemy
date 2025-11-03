import 'package:flutter/material.dart';
import 'package:kitchen_alchemy/models/recipe.dart';
import 'package:kitchen_alchemy/services/recipe_service.dart';
import 'package:kitchen_alchemy/widgets/page_template.dart';
import 'package:kitchen_alchemy/widgets/recipe_item.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _service = RecipeService();
  List<Recipe> recipes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRecipe();
  }

  void fetchRecipe() async {
    final tempRecipes = await _service.getRecipes('chicken');

    setState(() {
      recipes = tempRecipes;
      isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Recipes',
      route: '/search',
      showDrawer: true,
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator() // show spinner while loading
            : recipes.isEmpty
            ? const Text('No recipes found')
            : ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          return RecipeItem(
            recipe: recipes[index],
            onTap: () {
              // TODO: show recipe details
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Clicked: ${recipes[index].name}'),
                ),
              );
            },
          );
        },
      ),
      ),
    );
  }



}







