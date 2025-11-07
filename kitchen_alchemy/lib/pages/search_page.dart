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
  final TextEditingController _controller = TextEditingController();
  String query = '';

  @override
  void initState() {
    super.initState();
    getRecipe('chicken');
  }

  void getRecipe(String name) async {
    if (name.trim().isEmpty) return;
    setState(() {
      isLoading = true;
    });

    final tempRecipes = await _service.getRecipes(name);

    setState(() {
      recipes = tempRecipes;
      isLoading = false;
      query = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Recipes',
      route: '/search',
      showDrawer: true,
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
                  ? const CircularProgressIndicator()
                  : recipes.isEmpty
                  ? const Text('No recipes found')
                  : ListView.builder(
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  return RecipeItem(
                    recipe: recipes[index],
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/recipe',
                        arguments: {'recipe': recipes[index]},
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
