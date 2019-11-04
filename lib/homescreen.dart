import 'dart:async';

import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:maplaos/home.dart';
import 'package:maplaos/model/about_us.dart';
import 'package:maplaos/model/alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:maplaos/setting/setting.dart';
import 'package:location/location.dart' as location;
import 'package:device_id/device_id.dart';
import 'package:cron/cron.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    new FlutterLocalNotificationsPlugin();

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Setting setting = new Setting();
  bool connected = true;

  // firebase push notifycation
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  void initFirebaseMessaging() {
    firebaseMessaging.subscribeToTopic("all");
    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );

    firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      print("Token : $token");
    });
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => Home()),
    );
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

  int days;
  List locationnear = List();
  Future<void> _showNotification(var conn, var currentLocation) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var locations = await conn.query('select * from location  order by id ASC');
    for (var location in locations) {
      final Distance distance = new Distance();
      // meter = 422591.551
      final double meter = distance(
          LatLng(currentLocation.latitude, currentLocation.longitude),
          LatLng(double.parse(location['latitude'].toString()),
              double.parse(location['longitude'].toString())));
      var now = new DateTime.now();
      days = now.day + now.month + now.year;
      print(now.day + now.month + now.year);
      print('wwwwwwwwwwwwwwww');
      if (meter < 1000) {
        if (locationnear.contains(location['id'].toString()) &&
            prefs.get('daynow') == days) {
          print('wwwwqqqqqqqqq');
          break;
        } else {
          print('xxxxxxxxxxxxxx');
          prefs.setInt('daynow', days);
          locationnear.add(location['id'].toString());
          //break;
        }

        var details = location['loc_name'].toString() +
            " Near you around " +
            meter.toString() +
            " meter" +
            "\t\t" +
            location['loc_name_la'] +
            " ຢູ່​ໃກ້​ທ່ານ​ປະ​ມານ " +
            meter.toString() +
            "  ເມັດ";
        var androidPlatformChannelSpecifics = AndroidNotificationDetails(
            'maplaos', 'Maplaos', 'Detection tourist of laos',
            importance: Importance.Max,
            priority: Priority.High,
            ticker: 'ticker');
        var iOSPlatformChannelSpecifics = IOSNotificationDetails();
        var platformChannelSpecifics = NotificationDetails(
            androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
        await flutterLocalNotificationsPlugin.show(
            0, 'Maplaos', '$details', platformChannelSpecifics,
            payload: 'item x');
        break;
      }
    }
  }

  registerPush() {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  @override
  void initState() {
    super.initState();
    autocomplete();
    registerPush();
    initFirebaseMessaging();

    var cron = new Cron();
    cron.schedule(new Schedule.parse('*/10 * * * *'), () async {
      location.LocationData currentLocation =
          await location.Location().getLocation();
      final conn = await mysql.MySqlConnection.connect(mysql.ConnectionSettings(
          host: setting.host,
          port: setting.port,
          user: setting.user,
          password: setting.password,
          db: setting.db,
          timeout: Duration(seconds: 3)));
      _showNotification(conn, currentLocation);

      var now = new DateTime.now();
      String deviceid = await DeviceId.getID;
      await conn.query(
          'insert into tracking_gps (latitude, logtitude,device_id,date) values (?, ?, ?, ?)',
          [
            currentLocation.latitude.toString(),
            currentLocation.longitude.toString(),
            deviceid,
            now.toString()
          ]);
      conn.close();
      print('every three minutes daxiong');
    });
    //checkGPS();
  }

  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 4,
      navigateAfterSeconds: connected ? Home() : '',
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
