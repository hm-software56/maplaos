import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maplaos/home.dart';
import 'package:maplaos/model/about_us.dart';
import 'package:maplaos/model/alert.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:maplaos/setting/setting.dart';
import 'package:location/location.dart' as location;
import 'package:device_id/device_id.dart';
import 'package:cron/cron.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Setting setting = new Setting();
  bool connected = true;

  void sendNotification() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails('10000',
        'FLUTTER_NOTIFICATION_CHANNEL', 'FLUTTER_NOTIFICATION_CHANNEL_DETAIL',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(111, 'Hello, benznest.',
        'This is a your notifications. ', platformChannelSpecifics,
        payload: 'I just haven\'t Met You Yet');
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

  double meter = 0;
  double lat;
  double long;

  String message;
  String channelId = "1000";
  String channelName = "FLUTTER_NOTIFICATION_CHANNEL";
  String channelDescription = "FLUTTER_NOTIFICATION_CHANNEL_DETAIL";

  @override
  void initState() {
    message = "No message.";

    var initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');

    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: (id, title, body, payload) {
      print("onDidReceiveLocalNotification called.");
    });
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (payload) {
      // when user tap on notification.
      print("onSelectNotification called.");
      setState(() {
        message = payload;
      });
    });

    super.initState();
    autocomplete();
    var cron = new Cron();
    cron.schedule(new Schedule.parse('*/1 * * * *'), () async {
      sendNotification();
      location.LocationData currentLocation =
          await location.Location().getLocation();
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
