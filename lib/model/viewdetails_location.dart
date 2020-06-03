import 'package:flutter/material.dart';
import 'package:maplaos/model/loadimg.dart';
import 'package:maplaos/setting/setting.dart';
import 'package:mysql1/mysql1.dart' as mysql;

class ViewDetailsLocation extends StatefulWidget {
  var location_id;
  ViewDetailsLocation(this.location_id);
  @override
  _ViewDetailsLocationState createState() =>
      _ViewDetailsLocationState(this.location_id);
}

class _ViewDetailsLocationState extends State<ViewDetailsLocation> {
  var location_id;
  _ViewDetailsLocationState(this.location_id);
  Setting setting = new Setting();
  bool isloading = true;
  var locationlist;
  void loadinglocation(location_id) async {
    final conn = await mysql.MySqlConnection.connect(mysql.ConnectionSettings(
        host: setting.host,
        port: setting.port,
        user: setting.user,
        password: setting.password,
        db: setting.db));
    var locations = await conn.query(
        "select location.*, pro_name,pro_name_la,dis_name,dis_name_la, location_details.details, location_details.details_la from location left join provinces on provinces.id=location.provinces_id left join districts on districts.id=location.districts_id left join location_details on location_details.location_id=location.id where location.id=?",
        [location_id]);
    for (var location in locations) {
      setState(() {
        locationlist = location;
        isloading = false;
      });
    }
    await conn.close();
  }

  @override
  void initState() {
    super.initState();
    loadinglocation(this.location_id);
  }

  Widget build(BuildContext context) {
    var details;
    if (!isloading) {
      details = Localizations.localeOf(context).languageCode == "en"
          ? locationlist['details'].toString()
          : locationlist['details_la'].toString();
    }
    return Scaffold(
      appBar: AppBar(
        title: isloading
            ? Text('')
            : Localizations.localeOf(context).languageCode == "en"
                ? Text(locationlist['loc_name'].toString())
                : Text(locationlist['loc_name_la'].toString()),
      ),
      body: isloading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : details == 'null'
              ? Center(
                  child: Text('No Details'),
                )
              : Container(
                  padding: EdgeInsets.all(5.0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Flexible(child: new Text("${details}")),
                        ],
                      ),
                      Loadimg(locationlist['id']),
                    ],
                  )),
    );
  }
}
