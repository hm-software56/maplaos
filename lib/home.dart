import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maplaos/menu/menu.dart';
import 'package:location/location.dart';
import 'package:maplaos/setting/setting.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:async_loader/async_loader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_cache_store/flutter_cache_store.dart';
import 'package:mysql1/mysql1.dart' as mysql;
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Completer<GoogleMapController> _controller = Completer();
  Menu menu = Menu();
  Setting setting = new Setting();
  final GlobalKey<AsyncLoaderState> _asyncLoaderState =
      GlobalKey<AsyncLoaderState>();

/*================= Get current location  ===============*/
  Location location = Location();
  var latitude = 17.974855;
  var longitude = 102.609986;
  double zoom = 5;
  bool isloading=true;

  var currentLocation;
  void getCurrentLocation() {
    location.onLocationChanged().listen((value) {
      currentLocation = value;
      setState(() {
        latitude = currentLocation['latitude'];
        longitude = currentLocation['longitude'];
      });
    });
  }

  /*================ foreach multil maker ==============*/
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Map<PolylineId, Polyline> polylines = <PolylineId, Polyline>{};
  Dio dio = Dio();
  
  Future addmultimarker() async {
    var url = setting.apiUrl;
   // dio.options.connectTimeout = 5000; //5s
    //dio.options.receiveTimeout = 3000;

    try {
      Response response = await dio.get(
        "$url/api/getallprovince",
        options: buildCacheOptions(Duration(days: 7)),
      );
      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        await prefs.setString('provinces', response.toString());
        print(response.data);
        print('33333333333333333333333');
        foreachlisprovinnces();
        
      } else {
        print('getgggggggggggggggggggggggggggggggggggggggggg');
      }
    } on DioError catch (e) {
      print('Nonnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn');
    }
  }
  void foreachlisprovinnces() async
  {
    for (final provinces in List()) {
          /*======== Marker =======*/
          final MarkerId markerId = MarkerId('$provinces["id"]');
          // creating a new MARKER
          final Marker marker = Marker(
            markerId: markerId,
            position: LatLng(double.parse(provinces['latitute']),
                double.parse(provinces['longtitute'])),
            onTap: () {
              /** zoom curent location on click */
              mapController.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                      target: LatLng(double.parse(provinces['latitute']),
                          double.parse(provinces['longtitute'])),
                      zoom: 8.0),
                ),
              );

              /** Show modal details  */
              showdetail(
                  provinces["pro_name"] + '/' + provinces["pro_name_la"],
                  double.parse(provinces['latitute']),
                  double.parse(provinces['longtitute']),
                  int.parse(provinces['id']));
            },
          );

          /*================ Polyline ===============*/
          final PolylineId polygonId = PolylineId('$provinces["id"]');
          final List<LatLng> polylinelist = <LatLng>[];
          for (final polylinelatlong in provinces['polygons']) {
            polylinelist.add(LatLng(double.parse(polylinelatlong['latitude']),
                double.parse(polylinelatlong['longitude'])));
          }
          final Polyline polyline = Polyline(
              polylineId: polygonId,
              color: Colors.red[300],
              points: polylinelist);

          markers[markerId] = marker;
          polylines[polygonId] = polyline;
        }
        setState(() {
            markers=markers;
            polylines=polylines;
            zoom = 10;
          });
  }

  void testdb() async
  {
    final conn = await mysql.MySqlConnection.connect(mysql.ConnectionSettings(
        host:setting.host,
        port:setting.port,
        user:setting.user,
        password:setting.password,
        db:setting.db));
    // Query the database using a parameterized query
    var results = await conn.query('select * from provinces where id=2');
    for (var provinces in results) {
          /*======== Marker =======*/
          final MarkerId markerId = MarkerId('$provinces["id"]');
          // creating a new MARKER
          final Marker marker = Marker(
            markerId: markerId,
            position: LatLng(provinces['latitute'],provinces['longtitute']),
            onTap: () {
              /** zoom curent location on click */
              mapController.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                      target: LatLng(provinces['latitute'],provinces['longtitute']),
                      zoom: 8.0),
                ),
              );

              /** Show modal details  */
              showdetail(
                  provinces["pro_name"] + '/' + provinces["pro_name_la"],provinces['latitute'],provinces['longtitute'],provinces['id']);
            },
          );

          /*================ Polyline ===============*/
          final PolylineId polygonId = PolylineId('$provinces["id"]');
          final List<LatLng> polylinelist = <LatLng>[];
          var polygons = await conn.query('select * from polygon where provinces_id=?',[provinces['id']]);
          for (final polylinelatlong in polygons) {
            polylinelist.add(LatLng(polylinelatlong['latitude'],polylinelatlong['longitude']));
          }
          final Polyline polyline = Polyline(
              polylineId: polygonId,
              color: Colors.red[300],
              points: polylinelist);
           markers[markerId] = marker;
           polylines[polygonId] = polyline;
        }
        setState(() {
            isloading=false;
            markers=markers;
            polylines=polylines;
            zoom = 10;
          });
  }
  /*================= Get list district by provinces ===========*/
  List listdistricts = [];

  void getlistDistrictsByProvince(int province_id) async {
    var url = setting.apiUrl;
    try {
      Response response = await dio.get(
        "$url/api/getlistdistrict&province_id=$province_id",
        options: buildCacheOptions(Duration(days: 7)),
      );
      if (response.statusCode == 200) {
        setState(() {
          listdistricts = response.data;
        });
      }
    } on DioError catch (e) {
      print('NoNoNoNoNoNoNoNoNoNoNoNoNoNo');
    }
  }

  /*=============== get detail onlick marker  ===============*/
  GoogleMapController mapController;
  void showdetail(
      var title, double latitude1, double longitude1, int province_id) {
    getlistDistrictsByProvince(province_id);
    showModalBottomSheet(
        context: context,
        builder: (Builder) {
          return Container(
            color: Colors.white,
            child: Center(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(10),
                    color: Colors.red,
                    child: Center(
                      child: Text(
                        '$title',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: FlatButton(
                            onPressed: () => {
                              launch("tel://21213123123"),
                            },
                            color: Colors.white,
                            padding: EdgeInsets.all(10.0),
                            child: Column(
                              // Replace with a Row for horizontal icon + text
                              children: <Widget>[
                                Icon(
                                  Icons.call,
                                  color: Colors.red,
                                ),
                                Text("CALL")
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: FlatButton(
                            onPressed: () => {
                              launch("http://gooogle.com"),
                            },
                            color: Colors.white,
                            padding: EdgeInsets.all(10.0),
                            child: Column(
                              // Replace with a Row for horizontal icon + text
                              children: <Widget>[
                                Icon(
                                  Icons.important_devices,
                                  color: Colors.red,
                                ),
                                Text("WEBSITE")
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: FlatButton(
                            onPressed: () => {
                              // openGoogleMap(latitude, longitude)
                            },
                            color: Colors.white,
                            padding: EdgeInsets.all(10.0),
                            child: Column(
                              // Replace with a Row for horizontal icon + text
                              children: <Widget>[
                                Icon(
                                  Icons.directions,
                                  color: Colors.red,
                                ),
                                Text("GO")
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                      child: Column(
                        children: <Widget>[
                          ListView.builder(
                          itemCount: listdistricts.length,
                          itemBuilder: (BuildContext ctxt, int index) {
                            return new Text(listdistricts[index]['dis_name']);
                          })
                        ],
                      ))
                ],
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    testdb();
    //addmultimarker();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      drawer: menu.drawer,
      appBar: AppBar(
        title: Text("HOME"),
      ),
      body: isloading?Center( child: CircularProgressIndicator(),):GoogleMap(
        mapType: MapType.normal,
        myLocationEnabled: true,
        compassEnabled: true,
        initialCameraPosition: CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: zoom,
        ),
        onMapCreated: (GoogleMapController controller) {
          //_controller.complete(controller);
          mapController = controller;
        },
        markers: Set<Marker>.of(markers.values),
        polylines: Set<Polyline>.of(polylines.values),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(new MaterialPageRoute(builder: (context) => Home()));
        },
        child: new Icon(Icons.refresh),
      ),
    );
  }
}
