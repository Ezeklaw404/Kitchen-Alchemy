import 'dart:convert';
import 'package:kitchen_alchemy/models/recipe.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const _historyKey = 'recipe_history';

  static final LocalStorageService instance = LocalStorageService._();
  LocalStorageService._();

  Future<List<Recipe>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_historyKey);
    if (jsonString == null) return [];

    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded.map((e) => Recipe.fromJson(e)).toList();
  }


  Future<void> addToHistory(Recipe recipe) async {
    final history = await getHistory();

    history.removeWhere((r) => r.id == recipe.id);
    history.insert(0, recipe);

    // limit history size
    if (history.length > 50) {
      history.removeLast();
    }


    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_historyKey, jsonEncode(history.map((r) => r.toJson()).toList()));
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

}