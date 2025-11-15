import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kitchen_alchemy/pages/add-ingredient_page.dart';
import 'package:kitchen_alchemy/pages/favorites_page.dart';
import 'package:kitchen_alchemy/pages/history_page.dart';
import 'package:kitchen_alchemy/pages/inventory_page.dart';
import 'package:kitchen_alchemy/pages/recipe_page.dart';
import 'package:kitchen_alchemy/pages/search_page.dart';
import 'package:kitchen_alchemy/pages/scanner_page.dart';
import 'package:kitchen_alchemy/pages/settings_page.dart';
import 'package:kitchen_alchemy/pages/shopping_list_page.dart';
import 'package:kitchen_alchemy/services/firebase_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FirebaseService.init();

  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryBlueDark = Color(0xFF0F3570);
    final Color primaryBlueLight = Color(0xFF7AA6ED);

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Kitchen Alchemy',
       theme: ThemeData(
      // fontFamily: 'Cutive'
         elevatedButtonTheme: ElevatedButtonThemeData(
           style: ElevatedButton.styleFrom(
             backgroundColor: primaryBlueLight,
             foregroundColor: primaryBlueDark,
           ),
         ),
         textButtonTheme: TextButtonThemeData(
           style: TextButton.styleFrom(
             foregroundColor: primaryBlueLight,
           ),
         ),
         floatingActionButtonTheme: FloatingActionButtonThemeData(
           backgroundColor: primaryBlueLight,
           foregroundColor: primaryBlueDark,
         ),

       ),

      initialRoute: '/inventory',
      routes: {
        '/favorites': (context) => FavoritesPage(),
        '/history': (context) => HistoryPage(),
        '/inventory': (context) => InventoryPage(),
        '/add-ingredient': (context) => IngredientPage(),
        '/search': (context) => SearchPage(),
        '/recipe': (context) => RecipePage(),
        '/scanner': (context) => ScannerPage(),
        '/settings': (context) => SettingsPage(),
        '/shop-list': (context) => ShoppingListPage()
      },
    );
  }
}
