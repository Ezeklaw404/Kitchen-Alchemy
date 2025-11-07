import 'dart:convert';
import 'package:kitchen_alchemy/models/recipe.dart';
import 'package:http/http.dart' as http;

class RecipeService {
  final String baseUrl = 'https://kitchenalchemy-backend.onrender.com';

  Future<List<Recipe>> getRecipes(String name) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/recipe/$name'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return data
            .map((recipe) => Recipe.fromJson(recipe as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 404) {
        // No recipes found — not really an error
        return [];
      } else {
        // Something unexpected (server error, etc.)
        throw Exception('Failed to load recipes: ${response.statusCode}');
      }
    } catch (e) {
      // Network or parsing failure — also return empty list to avoid crashing
      print('getRecipes() error: $e');
      return [];
    }
  }
}
