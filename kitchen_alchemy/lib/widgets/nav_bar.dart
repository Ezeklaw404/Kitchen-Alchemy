import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  final int currentIndex;

  const NavBar({super.key,
    required this.currentIndex});



  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      destinations: [
        NavigationDestination(icon: Icon(Icons.kitchen, color: currentIndex == 0 ? Color(0xFF0F3570) : Color(0xFFE5A43D)), label: 'Inventory'),
        NavigationDestination(icon: Icon(Icons.camera, color: currentIndex == 1 ? Color(0xFF0F3570) : Color(0xFFE5A43D)), label: 'Scanner'),
        NavigationDestination(icon: Icon(Icons.restaurant, color: currentIndex == 2 ? Color(0xFF0F3570) : Color(0xFFE5A43D)), label: 'Search'),
        NavigationDestination(icon: Icon(Icons.list, color: currentIndex == 3 ? Color(0xFF0F3570) : Color(0xFFE5A43D)), label: 'Shopping List'),
      ],
      selectedIndex: currentIndex >= 0 ? currentIndex : 0,

      onDestinationSelected: (index) {
        if (index == currentIndex) return;

        switch (index) {
          case 0: Navigator.pushReplacementNamed(context, '/inventory'); break;
          case 1: Navigator.pushReplacementNamed(context, '/scanner'); break;
          case 2: Navigator.pushReplacementNamed(context, '/search'); break;
          case 3: Navigator.pushReplacementNamed(context, '/shop-list'); break;
        }
      },
      backgroundColor: Colors.amber.shade50,
      indicatorColor: currentIndex < 0 ? Colors.amber.shade50 : Color(0xFF7aa6ed),
    );
  }
}

