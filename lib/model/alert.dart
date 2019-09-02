import 'package:flutter/material.dart';
import 'package:rich_alert/rich_alert.dart';

import '../main.dart';
class Alert extends StatefulWidget {
  @override
  _AlertState createState() => _AlertState();
}

class _AlertState extends State<Alert> {
   
  @override
  Widget build(BuildContext context) {
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
  }
}