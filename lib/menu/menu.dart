import 'package:flutter/material.dart';

class Menu{
Widget drawer=Drawer(
  child: ListView(
    padding: EdgeInsets.zero,
    children: <Widget>[
      DrawerHeader(
        child: Text('Drawer Header'),
        decoration: BoxDecoration(
          color: Colors.red,
        ),
      ),
      ListTile(
        title: Text('Item 1'),
        onTap: () {
          // ...
        },
      ),
      ListTile(
        title: Text('Item 2'),
        onTap: () {
          // ...
        },
      ),
    ],
  ),
);
}