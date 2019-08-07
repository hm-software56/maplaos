 import 'package:flutter/material.dart';
import 'package:maplaos/home.dart';
import 'package:maplaos/homescreen.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:maplaos/province.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Maplaos',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home:HomeScreen(),
    );
  }
}
