import 'dart:convert';

import "package:flutter/material.dart";

import 'package:mysql1/mysql1.dart' as mysql;
import 'package:maplaos/setting/setting.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

class Locationimg extends StatefulWidget {
  var location_id;
  Locationimg(this.location_id);
  @override
  _LocationimgState createState() => _LocationimgState(this.location_id);
}

class _LocationimgState extends State<Locationimg> {
  var location_id;
  _LocationimgState(this.location_id);
  Setting setting = Setting();
  var locationimg;
  List img = [];
  bool isloading = true;
  void loadimg() async {
    final conn = await mysql.MySqlConnection.connect(mysql.ConnectionSettings(
        host: setting.host,
        port: setting.port,
        user: setting.user,
        password: setting.password,
        db: setting.db,
        timeout: Duration(seconds: 8)));
    var locations_img = await conn.query(
        'select l.loc_name_la, l.loc_name, ld.id as detail_id from location as l left join location_details as ld on ld.location_id=l.id where l.id=? and latitude!=0',
        [this.location_id]);
    for (var location_img in locations_img) {
      var images = await conn.query(
          'select * from photo where location_details_id=?',
          [location_img['detail_id']]);
      for (var image in images) {
        img.add(image['photo']);
      }
      setState(() {
        locationimg = location_img;
        isloading = false;
      });
    }
    await conn.close();
  }

  @override
  void initState() {
    super.initState();
    loadimg();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isloading
            ? Text('')
            : Text(locationimg['loc_name_la'].toString() +
                '/' +
                locationimg['loc_name'].toString()),
      ),
      body: isloading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Swiper(
              itemBuilder: (BuildContext context, int index) {
                return Image.network('${setting.apiUrl}/showimg/${img[index]}',
                  fit: BoxFit.fill,
                );
              },
              itemCount: img.length,
              pagination: SwiperPagination(),
              control: SwiperControl(),
            ),
    );
  }
}
