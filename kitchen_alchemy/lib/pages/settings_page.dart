import 'package:flutter/material.dart';
import 'package:kitchen_alchemy/pages/page_template.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Settings',
      route: '/settings',
      body: SingleChildScrollView(
        child: Center(child: Text('text'),),
      ),
    );
  }
}
