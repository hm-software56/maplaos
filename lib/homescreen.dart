import 'package:flutter/material.dart';
import 'package:maplaos/home.dart';
import 'package:maplaos/main.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:maplaos/setting/setting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rich_alert/rich_alert.dart';

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
          timeout:Duration(seconds: 8)
          ));
      var results = await conn.query('select * from location_search');
      for (var re in results) {
        list_autocomplete.add(re['name']);
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setStringList('list_autocomplete', list_autocomplete);
    } on Exception {
      setState(() {
       connected=false; 
      });
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return RichAlertDialog(
              //uses the custom alert dialog
              alertTitle: richTitle("Warning/ແຈ້ງ​ເຕືອນ"),
              alertSubtitle: richSubtitle(
                  "Please check connection/ກວດ​ການ​ເຊື່ອມ​ຕໍ່​ເນັດ"),
              alertType: RichAlertType.WARNING,
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.refresh,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) => MyApp()));
                  },
                )
              ],
            );
          });
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
            seconds: 15,
            navigateAfterSeconds: connected?Home():'',
            title: new Text(
              'ຍີມ​ດີ​ທ່ຽວເມືອງລາວ',
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
