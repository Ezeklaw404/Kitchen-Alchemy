import 'package:flutter/material.dart';
import 'package:kitchen_alchemy/pages/page_template.dart';

class ShoppingListPage extends StatelessWidget {
  const ShoppingListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Shopping List',
      route: '/shop-list',
      body: SingleChildScrollView(
        child: Center(child: Text('text'),),
      ),
    );
  }
}
