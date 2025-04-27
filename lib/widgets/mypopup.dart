import 'package:flutter/material.dart';

class MyPopupMenu extends StatelessWidget {
  final Function(String) onSelected;

  const MyPopupMenu({Key? key, required this.onSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
    icon: Icon(Icons.settings, color: Colors.white), // Add the color parameter here
    onSelected: onSelected,
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem(
            value: 'profile',
            child: Text('Profile'),
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          PopupMenuItem(
            value: 'settings',
            child: Text('Settings'),
          ),
          PopupMenuItem(
            value: 'logout',
            child: Text('Logout'),
          ),
          PopupMenuItem(
            value: 'Login',
            child: Text('Login'),
            onTap: () {
              Navigator.pushNamed(context, '/');
            }
          ),
        ];
      },
    );
  }
}