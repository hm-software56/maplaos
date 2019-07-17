import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maplaos/menu/menu.dart';
import 'package:location/location.dart';
import 'package:maplaos/setting/setting.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio_http_cache/dio_http_cache.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Completer<GoogleMapController> _controller = Completer();
  Menu menu = Menu();
  Setting setting = new Setting();

/*================= Get current location  ===============*/
  Location location = Location();
  var latitude = 17.974855;
  var longitude = 102.609986;
  double zoom = 5;

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
    dio.options.connectTimeout = 380000; //5s
    dio.options.receiveTimeout = 380000;
    try {
      Response response = await dio.get("$url/api/getallprovince",options: buildCacheOptions(Duration(days: 7)),);
      if (response.statusCode == 200) {
        for (final provinces in response.data) {
          /*======== Marker =======*/
          final MarkerId markerId = MarkerId('$provinces["id"]');
          // creating a new MARKER
          final Marker marker = Marker(
            markerId: markerId,
            position: LatLng(double.parse(provinces['latitute']), double.parse(provinces['longtitute'])),
            //infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
            onTap: () {
              showdetail(provinces["pro_name"]+'/'+provinces["pro_name_la"]);
            },
          );

          /*================ Polyline ===============*/
          final PolylineId polygonId = PolylineId('$provinces["id"]');
          final List<LatLng> polylinelist = [];
          for (final polylinelatlong in provinces['polygons']) {
            polylinelist.add(LatLng(double.parse(polylinelatlong['latitude']),
                double.parse(polylinelatlong['longitude'])));
          }
          final Polyline polyline = Polyline(
              polylineId: polygonId,
              color: Colors.red[300],
              points: polylinelist);

          setState(() {
            markers[markerId] = marker;
            polylines[polygonId] = polyline;
            zoom = 5;
          });
        }
      } else {
        print('getgggggggggggggggggggggggggggggggggggggggggg');
      }
    } on DioError catch (e) {
      print('Nonnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn');
    }
  }

  /*=============== get detail onlick marker  ===============*/
  void showdetail(var title) {
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
                        style: TextStyle(color: Colors.white,fontWeight:FontWeight.bold),
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
                  )
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
    addmultimarker();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        drawer: menu.drawer,
        appBar: AppBar(
          title: Text("HOME"),
        ),
        body: GoogleMap(
          mapType: MapType.normal,
          myLocationEnabled: true,
          compassEnabled: true,
          initialCameraPosition: CameraPosition(
            target: LatLng(latitude, longitude),
            zoom: zoom,
          ),
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          markers: Set<Marker>.of(markers.values),
          polylines: Set<Polyline>.of(polylines.values),
          /*polylines: {
            Polyline(
                polylineId: PolylineId("p1"),
                color: Colors.red[300],
                points: [
                  LatLng(13.7123167, 100.728104),
                  LatLng(13.655067, 100.722697),
                  LatLng(13.648389, 100.753335),
                  LatLng(13.705761, 100.779158),
                  LatLng(13.7123167, 100.728104),
                ])
          },*/
        ));
  }
}
