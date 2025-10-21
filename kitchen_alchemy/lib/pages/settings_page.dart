import 'package:flutter/material.dart';
import 'package:kitchen_alchemy/widgets/page_template.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Settings',
      route: '/settings',
      showDrawer: true,
      body: SingleChildScrollView(
        child: Center(child: Text('text'),),
      ),
    );
  }
}
