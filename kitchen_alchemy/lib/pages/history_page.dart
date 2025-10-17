import 'package:flutter/material.dart';
import 'package:kitchen_alchemy/pages/page_template.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'History',
      route: '/history',
      showDrawer: true,
      body: SingleChildScrollView(
        child: Center(child: Text('text'),),
      ),
    );
  }
}
