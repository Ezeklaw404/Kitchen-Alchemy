import 'package:flutter/material.dart';
import 'package:kitchen_alchemy/widgets/page_template.dart';

class RecipePage extends StatelessWidget {
  const RecipePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Recipes',
      route: '/recipe',
      showDrawer: true,
      body: SingleChildScrollView(
        child: Center(child: Text('text'),),
      ),
    );
  }
}
