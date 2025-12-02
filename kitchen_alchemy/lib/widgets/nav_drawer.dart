import 'package:flutter/material.dart';

class NavDrawer extends StatelessWidget {
  final String currentPage;

  const NavDrawer({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.amber.shade50,

      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF110E0B)),
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,

              child: Image.asset(
                'assets/images/kitchen_alchemy_logo.png',
                fit: BoxFit.fitHeight,
              ),
          ),


          // _buildDrawerItem(context, Icons.inventory, 'Inventory', '/inventory'),
          // _buildDrawerItem(context, Icons.backpack, 'Inventory', '/inventory'),
          // _buildDrawerItem(context, Icons.kitchen, 'Inventory', '/inventory'),

          // _buildDrawerItem(context, Icons.find_in_page_sharp, 'Recipes', '/search',),
          // _buildDrawerItem(context, Icons.restaurant, 'Recipes', '/search',),

          // _buildDrawerItem(context, Icons.camera, 'Scanner', '/scanner'),

          // _buildDrawerItem(context, Icons.settings, 'Settings', '/settings'),

          // _buildDrawerItem(context, Icons.shopping_cart, 'Shopping List', '/shop-list'),
          // _buildDrawerItem(context, Icons.list, 'Shopping List', '/shop-list'),

          _buildDrawerItem(context, Icons.favorite, 'Favorites', '/favorites'),

          _buildDrawerItem(context, Icons.history, 'History', '/history'),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    String route,
  ) {
    bool selected = currentPage == route;

    return ListTile(
      leading: Icon(icon, color: selected ? Color(0xFFE5A43D) : null),
      title: Text(
        title,
        style: TextStyle(
          color: selected ? Color(0xFFE5A43D) : null,
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
