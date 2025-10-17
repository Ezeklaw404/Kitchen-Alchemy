import 'package:flutter/material.dart';
import 'package:kitchen_alchemy/models/ingredient.dart';
import 'package:kitchen_alchemy/pages/page_template.dart';
import 'package:kitchen_alchemy/services/ingredient_service.dart';
import 'package:kitchen_alchemy/widgets/ingredient_item.dart';

class IngredientPage extends StatefulWidget {
  const IngredientPage({super.key});


  @override
  State<IngredientPage> createState() => _IngredientPageState();
}

class _IngredientPageState extends State<IngredientPage> {
  String query = '';

  final IngredientService _service = IngredientService();


  @override
  Widget build(BuildContext context) {
    return PageTemplate(
        title: 'Add Ingredient',
      route: '/add-ingredient',
          showDrawer: false,
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: (value) => setState(() => query = value.toLowerCase()),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'CutiveMono'),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF1B5E20)),
                    ),
                    labelText: 'Enter Name or Id',
                    labelStyle: TextStyle(color: Colors.black, fontFamily: 'Cutive'),
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Ingredient>>(
                  future: _service.getAllIngredients(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No Ingredients Found'));
                    }

                    final ingredients = snapshot.data!
                        .where((i) =>
                    i.name.toLowerCase().contains(query) ||
                        i.id.toLowerCase().contains(query))
                        .toList();

                    if (ingredients.isEmpty) {
                      return const Center(child: Text('No Ingredients match your search'));
                    }

                    return ListView.builder(
                      itemCount: ingredients.length,
                      itemBuilder: (context, index) {
                        return IngredientItem(
                          ingredient: ingredients[index],
                          onTap: () {
                            // Navigate to ingredient details page if you have one
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
    }
}