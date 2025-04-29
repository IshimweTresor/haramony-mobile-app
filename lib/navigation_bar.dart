import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Color(0xFF0A2647),
      unselectedItemColor: Colors.grey,
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Ahabanza",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.wifi_off),
          label: "itumanaho",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.language),
          label: "abajyanama",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.article),
          label: "ibibazo",
        ),
      ],
    );
  }
}
