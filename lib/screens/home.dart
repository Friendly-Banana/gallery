import 'package:flutter/material.dart';
import 'package:gallery/screens/settings.dart';

import 'gallery.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  static const List<Widget> _pages = [Gallery(), Settings()];
  int _selectedIndex = 0;
  bool showNoPin = true;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(child: _pages.elementAt(_selectedIndex)),
        bottomNavigationBar: BottomNavigationBar(
          showUnselectedLabels: false,
          currentIndex: _selectedIndex,
          onTap: (int index) => setState(() => _selectedIndex = index),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.collections), label: "Gallery"),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: "Settings")
          ],
        ),
      );
}
