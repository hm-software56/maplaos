import 'package:flutter/material.dart';
import 'package:maplaos/home.dart';
import 'package:maplaos/model/alert.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:maplaos/setting/setting.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Setting setting = new Setting();
  List<String> list_autocomplete = [];
  bool connected=true;
  void autocomplete() async {
    try {
      final conn = await mysql.MySqlConnection.connect(mysql.ConnectionSettings(
          host: setting.host,
          port: setting.port,
          user: setting.user,
          password: setting.password,
          db: setting.db,
          timeout:Duration(seconds: 3)
          ));
     /* var results = await conn.query('select * from location_search');
      for (var re in results) {
        list_autocomplete.add(re['name']);
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('list_autocomplete');
     prefs.setStringList('list_autocomplete', list_autocomplete);*/
    } on Exception {
      setState(() {
       connected=false; 
      });
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return Alert();
          }
      );
    }
  }

  @override
  @override
  void initState() {
    super.initState();
    autocomplete();
  }

  Widget build(BuildContext context) {
    return SplashScreen(
            seconds: 8,
            navigateAfterSeconds: connected?Home():'',
            title: new Text(
              'ຍີ​ນດີ​ທ່ຽວເມືອງລາວ',
              style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
            ),

            image: new Image.asset('assets/logo.png'),
            // gradientBackground:new LinearGradient(colors: [Colors.white, Colors.blue], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            backgroundColor: Colors.white,
            styleTextUnderTheLoader: new TextStyle(),
            photoSize: 150.0,
            onClick: () => print("Flutter Egypt"),
            loaderColor: Colors.red,
          );
  }
}
