import 'package:flutter/material.dart';
import 'package:kitchen_alchemy/widgets/nav_drawer.dart';

class PageTemplate extends StatelessWidget {
  final String title;
  final Widget body;
  final String route;
  final bool showDrawer;
  final Widget? floatingActionBtn;

  const PageTemplate({
    super.key,
    required this.title,
    required this.body,
    required this.route,
    required this.showDrawer,
    this.floatingActionBtn
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber.shade50,
    appBar: AppBar(title: Text(title,
      // style: TextStyle(color: Colors.amber, fontFamily: 'Cutive'),
    ),
      centerTitle: true,
      backgroundColor: Colors.amber.shade400,

      // actions: [
      //   ClipRect(
      //     borderRadius: BorderRadius.circular(100),
      //     child: Image.asset('assets/images/kitchen-logo.jpg',
      //     height: 40,
      //     fit: BoxFit.fitHeight,)
      //   )
      // ],

      leading: showDrawer
          ? null // when drawer is shown, Flutter adds hamburger automatically
          : IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),

   ),
      drawer: showDrawer ? NavDrawer(currentPage:  route) : null,

      // bottomNavigationBar: NavMenu(currentIndex: currentIndex),

      body: Padding(
        padding: EdgeInsets.all(16),
        child: body,
      ),

      floatingActionButton: floatingActionBtn,
    );
  }
}
