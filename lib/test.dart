import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class Test extends StatefulWidget {
  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
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

  @override
  initState() {
    initFirebaseMessaging();
    super.initState();
  }

  Widget build(BuildContext context) {
    return Container(
      child: Text('ddddddddddd'),
    );
  }
}
