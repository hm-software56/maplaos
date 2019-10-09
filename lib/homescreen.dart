import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maplaos/home.dart';
import 'package:maplaos/model/about_us.dart';
import 'package:maplaos/model/alert.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:maplaos/setting/setting.dart';
import 'package:geolocator/geolocator.dart';
import 'package:device_id/device_id.dart';
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Setting setting = new Setting();
  bool connected = true;
  var geolocator = Geolocator();
  var locationOptions = LocationOptions(
      accuracy: LocationAccuracy.high, distanceFilter: 10, timeInterval: 1);
  bool trackgps = false;
  void checkGPS() {
    setState(() {
      trackgps = true;
    });
    StreamSubscription<Position> positionStream = geolocator
        .getPositionStream(locationOptions)
        .listen((Position position) async {
      if (position != null) {
        final conn = await mysql.MySqlConnection.connect(mysql.ConnectionSettings(
          host: setting.host,
          port: setting.port,
          user: setting.user,
          password: setting.password,
          db: setting.db,
          timeout: Duration(seconds: 3)));
          var now = new DateTime.now();
          String deviceid = await DeviceId.getID;
          await conn.query(
              'insert into tracking_gps (latitude, logtitude,device_id,date) values (?, ?, ?, ?)',
              [position.latitude.toString(), position.longitude.toString(),deviceid,now.toString()]);
      }
    });
    positionStream.onDone(() => setState(() {
          trackgps = true;
        }));
  }

  void autocomplete() async {
    try {
      final conn = await mysql.MySqlConnection.connect(mysql.ConnectionSettings(
          host: setting.host,
          port: setting.port,
          user: setting.user,
          password: setting.password,
          db: setting.db,
          timeout: Duration(seconds: 3)));
    } on Exception {
      setState(() {
        connected = false;
      });
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return Alert();
          });
    }
  }

  @override
  @override
  void initState() {
    super.initState();
    autocomplete();
    checkGPS();
  }

  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 4,
      navigateAfterSeconds: connected ?Home(): '',
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
