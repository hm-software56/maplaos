import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:easy_localization/easy_localization_delegate.dart';
import 'package:flutter/material.dart';
import 'package:maplaos/model/add_location.dart';
import 'package:maplaos/model/alert.dart';
import 'package:maplaos/model/model_location_view.dart';
import 'package:maplaos/setting/setting.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loadmore/loadmore.dart';

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
    String userType = prefs.getString('userType');
    var conn = await mysql.MySqlConnection.connect(mysql.ConnectionSettings(
        host: setting.host,
        port: setting.port,
        user: setting.user,
        password: setting.password,
        db: setting.db,
        timeout: Duration(minutes: 1)));
    var locations;
    if (userType == "admin") {
      locations = await conn.query(
          'select location.*, provinces.pro_name,provinces.pro_name_la,districts.dis_name,districts.dis_name_la from location LEFT JOIN provinces ON location.provinces_id=provinces.id LEFT JOIN districts ON location.districts_id=districts.id order by id DESC');
    } else {
      locations = await conn.query(
          'select location.*, provinces.pro_name,provinces.pro_name_la,districts.dis_name,districts.dis_name_la from location LEFT JOIN provinces ON location.provinces_id=provinces.id LEFT JOIN districts ON location.districts_id=districts.id where user_id=? order by id DESC',
          [userId]);
    }
    for (var location in locations) {
      list_autocomplete.add(location['loc_name_la'].toString());
      list_autocomplete.add(location['loc_name'].toString());
      list_autocomplete.add(location['pro_name'].toString() + " Province");
      list_autocomplete.add("ແຂວງ " + location['pro_name_la'].toString());
      list_autocomplete.add(location['dis_name'].toString() + " District");
      list_autocomplete.add("ເມືອງ " + location['dis_name_la'].toString());

      listlocation.add(location);
    }
    conn.close();
    setState(() {
      isloading = false;
      listlocation = listlocation;
    });
  }

  void deletelocation(var id) async {
    var conn = await mysql.MySqlConnection.connect(mysql.ConnectionSettings(
        host: setting.host,
        port: setting.port,
        user: setting.user,
        password: setting.password,
        db: setting.db,
        timeout: Duration(seconds: 5)));
    var locationdele =
        await conn.query('delete from location where id=?', [id]);
    conn.close();
  }

  Future<void> refresh() {
    listlocation = List();
    loadlistlocation();
    return Future.value();
  }

  /* ======================= Searching filtter location    ====================*/
  static final GlobalKey<AutoCompleteTextFieldState<String>> key = GlobalKey();
  List<String> list_autocomplete = [];
  bool is_searching = false;
  var keyword = "";
  void Searching(var keywordvalue) async {
    if (keywordvalue != "") {
      setState(() {
        isloading = true;
        listlocation.clear();
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt('userId');
      String userType = prefs.getString('userType');
      var conn = await mysql.MySqlConnection.connect(mysql.ConnectionSettings(
          host: setting.host,
          port: setting.port,
          user: setting.user,
          password: setting.password,
          db: setting.db,
          timeout: Duration(minutes: 1)));
      var locations;
      if (userType == "admin") {
        locations = await conn.query(
            'select location.*, provinces.pro_name,provinces.pro_name_la,districts.dis_name,districts.dis_name_la from location LEFT JOIN provinces ON location.provinces_id=provinces.id LEFT JOIN districts ON location.districts_id=districts.id where pro_name=? or pro_name_la=? or dis_name=? or dis_name_la=? or loc_name=? or loc_name_la=?  order by id DESC',
            [
              keywordvalue.replaceAll(' Province', ''),
              keywordvalue.replaceAll('ແຂວງ ', ''),
              keywordvalue.replaceAll(' District', ''),
              keywordvalue.replaceAll('ເມືອງ ', ''),
              keywordvalue,
              keywordvalue
            ]);
      } else {
        locations = await conn.query(
            'select location.*, provinces.pro_name,provinces.pro_name_la,districts.dis_name,districts.dis_name_la from location LEFT JOIN provinces ON location.provinces_id=provinces.id LEFT JOIN districts ON location.districts_id=districts.id where (pro_name=? or pro_name_la=? or dis_name=? or dis_name_la=? or loc_name=? or loc_name_la=?) and user_id=? order by id DESC',
            [
              keywordvalue.replaceAll(' Province', ''),
              keywordvalue.replaceAll('ແຂວງ ', ''),
              keywordvalue.replaceAll(' District', ''),
              keywordvalue.replaceAll('ເມືອງ ', ''),
              keywordvalue,
              keywordvalue,
              userId
            ]);
      }
      for (var location in locations) {
        listlocation.add(location);
      }
      setState(() {
        keyword = keywordvalue;
        is_searching = false;
        isloading = false;
        listlocation = listlocation;
      });
      conn.close();
    } else {
      setState(() {
        is_searching = true;
      });
    }
  }

  Widget buildSearchField(context) {
    return SimpleAutoCompleteTextField(
        textChanged: (text) {
          // Searching(text);
        },
        textSubmitted: (text) {
          Searching(text);
        },
        clearOnSubmit: true,
        key: key,
        suggestions: list_autocomplete.toSet().toList(),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: 'Search....',
          contentPadding: EdgeInsets.all(10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white, width: 0.0),
          ),
          hintStyle: const TextStyle(color: Colors.white),
        ));
  }
/* ======================= End searching filtter location    ====================*/

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadlistlocation();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: is_searching
            ? buildSearchField(context)
            : keyword != ""
                ? Text(keyword)
                : Text(AppLocalizations.of(context).tr('List location')),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.search),
            onPressed: () {
              Searching('');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: isloading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView.separated(
                itemCount: listlocation.length,
                itemBuilder: (context, index) {
                  String statusname =
                      listlocation[index]['status'].toString() == 'Open'
                          ? AppLocalizations.of(context).tr('Public')
                          : AppLocalizations.of(context).tr('Pedding');
                  final item = listlocation[index]['id'].toString();

                  String provincename =
                      Localizations.localeOf(context).languageCode == "en"
                          ? listlocation[index]['pro_name'].toString()
                          : listlocation[index]['pro_name_la'].toString();
                  String districtname =
                      Localizations.localeOf(context).languageCode == "en"
                          ? listlocation[index]['dis_name'].toString()
                          : listlocation[index]['dis_name_la'].toString();

                  return Dismissible(
                      key: Key(item),
                      onDismissed: (direction) {
                        setState(() {
                          deletelocation(listlocation[index]['id']);
                          listlocation.removeAt(listlocation[index]);
                        });
                        // Then show a snackbar.
                        Scaffold.of(context).showSnackBar(
                            SnackBar(content: Text("$item dismissed")));
                      },
                      // Show a red background as the item is swiped away.
                      background: Container(color: Colors.red),
                      child: ListTile(
                        leading: CircleAvatar(
                            backgroundImage: AssetImage('assets/map.png')),
                        trailing: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ModelLocationView(
                                      listlocation[index]['id']),
                                ));
                          },
                          child: Icon(
                            Icons.visibility,
                            color: Colors.red,
                          ),
                        ),
                        title: Localizations.localeOf(context).languageCode ==
                                "en"
                            ? Text(listlocation[index]['loc_name'].toString())
                            : Text(
                                listlocation[index]['loc_name_la'].toString()),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              AppLocalizations.of(context).tr('Province') +
                                  ": " +
                                  "$provincename",
                              style: TextStyle(fontSize: 11.0),
                            ),
                            Text(
                              AppLocalizations.of(context).tr('District') +
                                  ": " +
                                  "$districtname",
                              style: TextStyle(fontSize: 11.0),
                            ),
                            Text(
                              AppLocalizations.of(context).tr('Latitude') +
                                  ": " +
                                  listlocation[index]['latitude'].toString(),
                              style: TextStyle(fontSize: 11.0),
                            ),
                            Text(
                              AppLocalizations.of(context).tr('Longtitude') +
                                  ": " +
                                  listlocation[index]['longitude'].toString(),
                              style: TextStyle(fontSize: 11.0),
                            ),
                            Text(
                              AppLocalizations.of(context).tr('Status') +
                                  ": $statusname",
                              style: TextStyle(
                                  fontSize: 11.0,
                                  color: listlocation[index]['status']
                                              .toString() ==
                                          'Open'
                                      ? Colors.green
                                      : Colors.red),
                            ),
                          ],
                        ),
                      ));
                },
                separatorBuilder: (context, index) {
                  return Divider();
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddLocation(null),
              ));
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
