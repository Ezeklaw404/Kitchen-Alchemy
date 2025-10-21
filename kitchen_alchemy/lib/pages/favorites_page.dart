import 'package:flutter/material.dart';
import 'package:kitchen_alchemy/widgets/page_template.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Favorites',
      route: '/favorites',
      showDrawer: true,
      body: SingleChildScrollView(
        child: Center(child: Text('text'),),
      ),
    );
  }
}
