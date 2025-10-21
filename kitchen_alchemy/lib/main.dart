import 'package:flutter/material.dart';
import 'package:kitchen_alchemy/pages/add-ingredient_page.dart';
import 'package:kitchen_alchemy/pages/favorites_page.dart';
import 'package:kitchen_alchemy/pages/history_page.dart';
import 'package:kitchen_alchemy/pages/inventory_page.dart';
import 'package:kitchen_alchemy/pages/recipe_page.dart';
import 'package:kitchen_alchemy/pages/scanner_page.dart';
import 'package:kitchen_alchemy/pages/settings_page.dart';
import 'package:kitchen_alchemy/pages/shopping_list_page.dart';
import 'package:kitchen_alchemy/services/firebase_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FirebaseService.init();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kitchen Alchemy',
      // theme: ThemeData(fontFamily: 'Cutive'),

      initialRoute: '/inventory',
      routes: {
        '/favorites': (context) => FavoritesPage(),
        '/history': (context) => HistoryPage(),
        '/inventory': (context) => InventoryPage(),
        '/add-ingredient': (context) => IngredientPage(),
        '/recipe': (context) => RecipePage(),
        '/scanner': (context) => ScannerPage(),
        '/settings': (context) => SettingsPage(),
        '/shop-list': (context) => ShoppingListPage()
      },
    );
  }
}
