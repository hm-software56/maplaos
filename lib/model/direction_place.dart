import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:maplaos/setting/setting.dart';

class DirectionPlace extends StatefulWidget {
  var originlat;
  var originlong;
  var destinationlat;
  var destinationlong;
   DirectionPlace(this.originlat,this.originlong,this.destinationlat,this.destinationlong);
  @override
  _DirectionPlaceState createState() => _DirectionPlaceState(this.originlat,this.originlong,this.destinationlat,this.destinationlong);
}

class _DirectionPlaceState extends State<DirectionPlace> {
  var originlat;
  var originlong;
  var destinationlat;
  var destinationlong;
  _DirectionPlaceState(this.originlat,this.originlong,this.destinationlat,this.destinationlong);
  Setting setting = new Setting();
  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
          url: "https://www.google.com/maps/dir/?api=1&origin=$originlat,$originlong&destination=$destinationlat,$destinationlong&travelmode=driving&dir_action=navigate",
          appBar: new AppBar(
            title: new Text("ນຳ​ທາງ"),
          ),
        );
  }
}