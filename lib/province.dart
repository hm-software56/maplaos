
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maplaos/setting/setting.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'model/db.dart';

class Province extends StatefulWidget {
  @override
  _ProvinceState createState() => _ProvinceState();
}

class _ProvinceState extends State<Province> {
  /*================= Get current location  ===============*/
  Db db = Db();
  Future dbcc() async {
    print(
        'daxiong1111111111111111111111111111111111111111111111111111111111111111111111111111111111111');
    // Open a connection (testdb should already exist)
    final conn = await mysql.MySqlConnection.connect(mysql.ConnectionSettings(
        host: 'remotemysql.com',
        port: 3306,
        user: '2CEvh1t8JM',
        password: '5N1nJoJJTN',
        db: '2CEvh1t8JM'));
    // Query the database using a parameterized query
    var results = await conn.query('select * from provinces');
    print(results);
    for (var row in results) {
      print(row['id']);
      var polygons = await conn.query('select * from polygon where provinces_id=?',[row['id']]);
      for(var pl in polygons)
      {
        print(pl[0]);
      }
    }

    // Finally, close the connection
    await conn.close();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GoogleMapController mapController;
  Location location = Location();
  Setting setting = Setting();
  var currentLocation;
  void getCurrentLocation() {
    location.onLocationChanged().listen((value) {
      currentLocation = value;
      setState(() {
        setting.latitude = currentLocation['latitude'];
        setting.longitude = currentLocation['longitude'];
      });
    });
  }

  @override
  void initState() {
    super.initState();
    dbcc();
    getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('dddddd'),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Row()
          ],
        ),
      )
    );
  }
}
