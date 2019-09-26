import 'package:carousel_pro/carousel_pro.dart';
import 'package:easy_localization/easy_localization_delegate.dart';
import 'package:flutter/material.dart';
import 'package:maplaos/model/add_location.dart';
import 'package:maplaos/model/alert.dart';
import 'package:maplaos/setting/setting.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:shared_preferences/shared_preferences.dart';

class ModelListLocation extends StatefulWidget {
  @override
  _ModelListLocationState createState() => _ModelListLocationState();
}

class _ModelListLocationState extends State<ModelListLocation> {
  Setting setting = Setting();
  bool isloading = true;
  List listlocation = List();
  void loadlistlocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('userId');
    var conn = await mysql.MySqlConnection.connect(mysql.ConnectionSettings(
        host: setting.host,
        port: setting.port,
        user: setting.user,
        password: setting.password,
        db: setting.db,
        timeout: Duration(seconds: 5)));
    var locations =
        await conn.query('select * from location where user_id=? order by id DESC', [userId]);
    for (var location in locations) {
      listlocation.add(location);
    }

    setState(() {
      isloading = false;
      listlocation = listlocation;
    });
  }
void deletelocation(var id) async{
       var conn = await mysql.MySqlConnection.connect(mysql.ConnectionSettings(
        host: setting.host,
        port: setting.port,
        user: setting.user,
        password: setting.password,
        db: setting.db,
        timeout: Duration(seconds: 5)));
        var locationdele=await conn.query('delete from location where id=?', [id]);
        
    }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadlistlocation();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).tr('List location')),
      ),
      body: isloading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.separated(
              itemCount: listlocation.length,
              itemBuilder: (context, index) {
                final item = listlocation[index]['id'].toString();
                 return Dismissible(
              key: Key(item),
              onDismissed: (direction) {
                setState(() {
                  deletelocation(listlocation[index]['id']);
                  listlocation.removeAt(listlocation[index]);
                });
                // Then show a snackbar.
                Scaffold.of(context)
                    .showSnackBar(SnackBar(content: Text("$item dismissed")));
              },
              // Show a red background as the item is swiped away.
              background: Container(color: Colors.red),
              child: ListTile(
                  leading: Icon(
                Icons.map,
                color: Colors.red,
              ),
                  trailing: Icon(
                    Icons.menu,
                    color: Colors.red,
                  ),
                  title: Localizations.localeOf(context).languageCode == "en"?
                  Text(listlocation[index]['loc_name'].toString()):
                  Text(listlocation[index]['loc_name_la'].toString()),
                  subtitle: Align(
                    alignment:Alignment.centerLeft,
                    child: Column(
                      children: <Widget>[
                        Text(AppLocalizations.of(context).tr('Latitude')+": "+listlocation[index]['latitude'].toString()),
                        Text(AppLocalizations.of(context).tr('Longtitude')+": "+listlocation[index]['longitude'].toString()),
                        Text(AppLocalizations.of(context).tr('Status')+": "+listlocation[index]['status'].toString()=='Open'?AppLocalizations.of(context).tr('Public'):AppLocalizations.of(context).tr('Pedding')),
                      ],
                    ),
                  ),
                ));
              },
              separatorBuilder: (context, index) {
                return Divider();
              },
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddLocation(),
                ));
              },
              child: Icon(Icons.add),
              backgroundColor: Colors.blue,
            ),
    );
  }
}
