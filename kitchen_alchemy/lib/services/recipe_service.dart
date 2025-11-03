import 'dart:convert';
import 'package:kitchen_alchemy/models/recipe.dart';
import 'package:http/http.dart' as http;

class RecipeService {
  final String baseUrl = 'https://kitchenalchemy-backend.onrender.com';

  Future<List<Recipe>> getRecipes(String name) async{
    final response = await http.get(
      Uri.parse('$baseUrl/recipe/$name'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data.map((recipe) => Recipe.fromJson(recipe as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load Ingredient');
    }
  }
}