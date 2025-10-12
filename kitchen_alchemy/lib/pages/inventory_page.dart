import 'package:flutter/material.dart';
import 'package:kitchen_alchemy/pages/page_template.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
        title: 'Inventory',
      route: '/inventory',
        body: SingleChildScrollView(
          child: Center(child: Text('text'),),
        ),
    );
  }
}
