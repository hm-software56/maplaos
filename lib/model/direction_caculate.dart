import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class DirectionCaculate extends StatefulWidget {
  var plat;
  var plong;
  var clong;
  var clat;
  DirectionCaculate(this.plong, this.plat, this.clong, this.clat);
  @override
  _DirectionCaculateState createState() =>
      _DirectionCaculateState(this.plong, this.plat, this.clong, this.clat);
}

class _DirectionCaculateState extends State<DirectionCaculate> {
  var plat;
  var plong;
  var clong;
  var clat;
  _DirectionCaculateState(this.plong, this.plat, this.clong, this.clat);
  var du_km;
  var du_m;
  var di_minuts;
  var dis_hours;
  var sumary_m_km = "unkown";
  var sumary_minuts_hour = "​​unkown";
  bool isloading = true;
  void direction() async {
    var clong=102.610895; //use for test
    var clat=17.966028; //use for test
    try {
      Response response = await Dio(BaseOptions(
        connectTimeout: 3000,
        receiveTimeout: 3000,
      )).get("https://api.mapbox.com/directions/v5/mapbox/driving/${clong},${clat};${plong},${plat}?access_token=pk.eyJ1IjoiZGF4aW9uZ2luZm8iLCJhIjoiY2prdXVucWZ3MGIzYzNrcnJwMWw0eTRueSJ9.4Ow9sGdMnMG3cVPkHuDphA");
      
      du_km = response.data['routes'][0]['legs'][0]['distance'] / 1000;
      du_m = response.data['routes'][0]['legs'][0]['distance'];
      di_minuts = response.data['routes'][0]['legs'][0]['duration'] / 60;
      dis_hours = response.data['routes'][0]['legs'][0]['duration'] / 3600;
      if (du_km >= 1) {
        setState(() {
          sumary_m_km = du_km.toStringAsFixed(2) + ' KM';
        });
      } else {
        setState(() {
          sumary_m_km = du_m.toStringAsFixed(2) + " M";
        });
      }
      if (dis_hours >= 1) {
        setState(() {
          sumary_minuts_hour =
              dis_hours.toStringAsFixed(2) + ' ​ຊົ່ວ​ໂມງ/hours​';
        });
      } else {
        setState(() {
          sumary_minuts_hour = di_minuts.toStringAsFixed(2) + "​ ນາ​ທີ/minuts";
        });
      }
      setState(() {
       isloading=false; 
      });
    } catch (e) {
       setState(() {
       isloading=false; 
      });
    }
  }

  @override
  void initState() {
    super.initState();
    direction();
  }

  @override
  Widget build(BuildContext context) {
    return isloading
        ? Text('')
        : Column(
            children: <Widget>[
              ListTile(
                leading: Icon(
                  Icons.timeline,
                  color: Colors.red,
                ),
                title: Text('​ໄລ​ຍະ​ທາງ​/distance'),
                subtitle: Text(sumary_m_km),
                trailing: Icon(Icons.more_vert),
              ),
              ListTile(
                leading: Icon(
                  Icons.alarm,
                  color: Colors.red,
                ),
                title: Text('ເວ​ລາ​ເດີນ​ທາງ/duration'),
                subtitle: Text(sumary_minuts_hour),
                trailing: Icon(Icons.more_vert),
              ),
            ],
          );
  }
}
