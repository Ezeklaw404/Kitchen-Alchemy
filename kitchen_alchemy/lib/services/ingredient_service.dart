import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kitchen_alchemy/models/ingredient.dart';

class IngredientService {
  final String baseUrl = 'https://kitchenalchemy-backend.onrender.com';

  Future<List<Ingredient>> getAllIngredients() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/ingredients'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // If backend returns a JSON array
        if (data is List) {
          return data.map((json) => Ingredient.fromJson(json)).toList();
        }

        // If backend wraps it like { "ingredients": [...] }
        if (data is Map && data['ingredients'] is List) {
          return (data['ingredients'] as List)
              .map((json) => Ingredient.fromJson(json))
              .toList();
        }

        throw Exception('Unexpected JSON structure');
      } else {
        throw Exception('Failed to load ingredients: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching ingredients: $e');
      return [];
    }
  }


  Future<Ingredient> getIngredient(int id) async{
    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
    );
    if (response.statusCode == 200) {
      return Ingredient.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to load Creature');
    }
  }

}
