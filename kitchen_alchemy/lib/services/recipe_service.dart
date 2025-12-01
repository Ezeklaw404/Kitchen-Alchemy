import 'dart:convert';
import 'package:kitchen_alchemy/models/recipe.dart';
import 'package:http/http.dart' as http;

class RecipeService {
  final String baseUrl = 'https://kitchenalchemy-backend.onrender.com';

  Future<List<Recipe>> getAllRecipes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/recipes'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Recipe.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load all recipes');
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<List<Recipe>> getRecipes(String name) async {
    try {
      name = name.trim().replaceAll(' ', '_');
      final response = await http.get(Uri.parse('$baseUrl/recipes/$name'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return data
            .map((recipe) => Recipe.fromJson(recipe as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to load recipes: ${response.statusCode}');
      }
    } catch (e) {
      print('getRecipes() error: $e');
      return [];
    }
  }

  Future<Recipe?> getRecipeById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/recipes/id=$id'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
        return Recipe.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load recipe: ${response.statusCode}');
      }
    } catch (e) {
      print('getRecipeById() error: $e');
      return null;
    }
  }


}
