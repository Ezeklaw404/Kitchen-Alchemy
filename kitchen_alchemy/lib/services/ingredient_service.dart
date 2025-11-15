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
        if (data is List) {
          return data.map((json) => Ingredient.fromJson(json)).toList();
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
      Uri.parse('$baseUrl/ingredients/id=$id'),
    );
    if (response.statusCode == 200) {
      return Ingredient.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to load Ingredient');
    }
  }

  Future<Ingredient?> getIngredientByName(String name) async{
    if (name.contains(' ')) {
      name = name.replaceAll(' ', '_');
    }
    final response = await http.get(
      Uri.parse('$baseUrl/ingredients/$name'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data == null || (data is List && data.isEmpty)) {
        return null; // nothing found
      }
      return Ingredient.fromJson(data);
    } else if (response.statusCode == 404) {
      // Not found ->
      return null;
    } else {
      throw Exception('Failed to load Ingredient: ${response.statusCode}');
    }
  }

  Future<void> addIngredient(String name) async{
    final response = await http.post(
      Uri.parse('$baseUrl/ingredients'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "name": name.trim(),
        "description": null, // optional
        "type": null,        // optional
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add ingredient');
    }
  }

}
