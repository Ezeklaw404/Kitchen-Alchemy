import 'package:flutter/material.dart';
import 'package:kitchen_alchemy/widgets/nav_menu.dart';
import 'package:kitchen_alchemy/pages/nav_menu.dart';

class PageTemplate extends StatelessWidget {
  final String title;
  final Widget body;
  final String route;
  final Widget? floatingActionBtn;

  const PageTemplate({
    super.key,
    required this.title,
    required this.body,
    required this.route,
    this.floatingActionBtn
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.amber,
    appBar: AppBar(title: Text(title,
      // style: TextStyle(color: Colors.amber, fontFamily: 'Cutive'),
    ),
      centerTitle: true,
      backgroundColor: Colors.green,

      // actions: [
      //   ClipRect(
      //     borderRadius: BorderRadius.circular(100),
      //     child: Image.asset('assets/images/kitchen-logo.jpg',
      //     height: 40,
      //     fit: BoxFit.fitHeight,)
      //   )
      // ],
    ),
      drawer: NavMenu(currentPage:  route),

      // bottomNavigationBar: NavMenu(currentIndex: currentIndex),

      body: Padding(
        padding: EdgeInsets.all(16),
        child: body,
      ),

      floatingActionButton: floatingActionBtn,
    );
  }
}
