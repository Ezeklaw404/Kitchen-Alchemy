import 'package:flutter/material.dart';
import 'package:kitchen_alchemy/models/recipe.dart';
import 'package:kitchen_alchemy/services/local_storage_service.dart';
import 'package:kitchen_alchemy/widgets/page_template.dart';
import 'package:kitchen_alchemy/widgets/recipe_item.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Recipe> historyRecipes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  void loadHistory() async {
    setState(() {
      isLoading = true;
    });

    final List<Recipe> tempHistory = await LocalStorageService.instance.getHistory();

    setState(() {
      historyRecipes = tempHistory;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'History',
      route: '/history',
      showDrawer: true,
      navIndex: -1,
      body: Expanded(
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : historyRecipes.isEmpty
              ? const Text('No history yet')
              : ListView.builder(
            itemCount: historyRecipes.length,
            itemBuilder: (context, index) {
              return RecipeItem(
                recipe: historyRecipes[index],
                userIngredients: [],
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/recipe',
                    arguments: {'recipe': historyRecipes[index]},
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}