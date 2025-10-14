
import 'dart:convert';

import 'package:http/http.dart' as http;


Future<List<Ingredient>> getAllIngredients() async {
  final response =  await http.get(
  Uri.parse('https://www.themealdb.com/api/json/v1/1/list.php?i=list'),
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Ingredient.fromJson(json as Map<String, dynamic>)).toList();
  } else {
    throw Exception('Failed to load ingredients');
  }



}


class Ingredient {
  final String id;
  final String name;
  final String? description;
  final String? type;

  const Ingredient({required this.id, required this.name, required this.description, required this.type});

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['idIngredient'] as String? ?? '',
      name: json['strIngredient'] as String? ?? '',
      description: json['strDescription'] as String? ?? '',
      type: json['strType'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idIngredient': id,
      'strIngredient': name,
      'strDescription': description,
      'strType': type,
    };
  }

}
