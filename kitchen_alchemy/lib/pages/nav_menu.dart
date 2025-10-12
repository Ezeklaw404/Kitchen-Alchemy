import 'package:flutter/material.dart';

class NavMenu extends StatelessWidget {
  final String currentPage;

  const NavMenu({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text('Pages'),
          ),
          _buildDrawerItem(context, Icons.home, 'Inventory', '/inventory'),
          _buildDrawerItem(context, Icons.find_in_page_sharp, 'Recipes', '/recipe'),
          _buildDrawerItem(context, Icons.camera, 'Scanner', '/scanner'),
          _buildDrawerItem(context, Icons.settings, 'Settings', '/settings'),
          _buildDrawerItem(context, Icons.list, 'Shopping List', '/shop-list'),
          _buildDrawerItem(context, Icons.heart_broken, 'Favorites', '/favorites'),
          _buildDrawerItem(context, Icons.history, 'History', '/history'),
        ],
      ),

      // backgroundColor: Colors.amber,
      // indicatorColor: Colors.red,
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, String route,) {
    bool selected = currentPage == route;

    return ListTile(
      leading: Icon(icon, color: selected ? Colors.orange : null),
      title: Text(
        title,
        style: TextStyle(
          color: selected ? Colors.orange : null,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: selected,
      onTap: () {
        Navigator.pop(context); // close drawer first
        if (!selected) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
    );
  }
}
