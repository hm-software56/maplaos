import 'package:flutter/material.dart';
import 'package:maplaos/home.dart';
import 'package:splashscreen/splashscreen.dart';
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
      seconds: 8,
      navigateAfterSeconds: new Home(),
      title: new Text('ຍີມ​ດີ​ທ່ຽວເມືອງລາວ',
        style: new TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20.0
        ),
      ),
      
      image: new Image.asset('assets/logo.png'),
     // gradientBackground:new LinearGradient(colors: [Colors.white, Colors.blue], begin: Alignment.topCenter, end: Alignment.bottomCenter),
      backgroundColor: Colors.white,
      styleTextUnderTheLoader: new TextStyle(),
      photoSize: 150.0,
      onClick: ()=>print("Flutter Egypt"),
      loaderColor: Colors.red,
    );
  }
}