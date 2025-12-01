import 'package:flutter/material.dart';
import 'package:kitchen_alchemy/models/ingredient.dart';
import 'package:kitchen_alchemy/models/recipe.dart';
import 'package:kitchen_alchemy/services/firestore_service.dart';
import 'package:kitchen_alchemy/services/local_storage_service.dart';
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
  List<Recipe> allRecipes = [];
  final _dbService = FirestoreService();
  List<String> _userIngredients = [];
  bool isLoading = true;
  final TextEditingController _controller = TextEditingController();
  String query = '';

  @override
  void initState() {
    super.initState();
    getUserIngredients();
    loadAllRecipes();
  }

  void loadAllRecipes() async {
    setState(() => isLoading = true);

    final fetched = await _service.getAllRecipes();
    allRecipes = fetched;

    allRecipes.sort((a, b) {
      final pa = ingredientMatchPercent(a);
      final pb = ingredientMatchPercent(b);
      return pb.compareTo(pa);
    });

    setState(() {
      recipes = List.from(allRecipes);
      isLoading = false;
    });
  }

  void getRecipe(String name) async {
    if (allRecipes.isEmpty) return;

    if (name.trim().isEmpty) {
      setState(() {
        recipes = List.from(allRecipes);
      });
      return;
    }
    setState(() {
      isLoading = true;
    });
    final tempRecipes = await _service.getRecipes(name);

    tempRecipes.sort((a, b) {
      final pa = ingredientMatchPercent(a);
      final pb = ingredientMatchPercent(b);

      return pb.compareTo(pa);
    });
    setState(() {
      recipes = tempRecipes;
      isLoading = false;
      query = name;
      _controller.text = name.trim();
    });
  }

  double ingredientMatchPercent(Recipe recipe) {
    if (_userIngredients.isEmpty) return 0;

    final total = recipe.ingredients.length;
    int matches = 0;

    for (final entry in recipe.ingredients.entries) {
      final ingredientName = entry.key.toLowerCase().trim();
      if (_userIngredients.any((u) => u.toLowerCase() == ingredientName)) {
        matches++;
      }
    }

    return matches / total;
  }


  void getUserIngredients() async {
    final List<Ingredient> ingredients = await _dbService.getInventory();
    setState(() {
      _userIngredients = ingredients.map((i) => i.name).toList();
    });
  }


  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Recipes',
      route: '/search',
      showDrawer: true,
      navIndex: 2,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Search recipes...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    final query = _controller.text.trim();
                    if (query.isNotEmpty) {
                      getRecipe(query);
                    }
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (query) {
                if (query.isNotEmpty) getRecipe(query);
              },
            ),
          ),
          Expanded(
            child: Center(
              child: isLoading
                  ? Image.asset(
                // 'assets/images/loading.gif', //40
                // 'assets/images/rolling-loading.gif', //75
                'assets/images/mixing-bowl.gif', //150
                // 'assets/images/mixing-machine.gif', //150

                width: 150,
                height: 150,
              )
                  : recipes.isEmpty
                  ? const Text('No recipes found')
                  : ListView.builder(
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  return RecipeItem(
                    recipe: recipes[index],
                    userIngredients: _userIngredients,
                    onTap: () async {
                      await LocalStorageService.instance.addToHistory(recipes[index]);
                      Navigator.pushNamed(
                        context,
                        '/recipe',
                        arguments: {
                          'recipe': recipes[index],
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
