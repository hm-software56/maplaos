import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maplaos/menu/menu.dart';
import 'package:maplaos/setting/setting.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_cache_store/flutter_cache_store.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as location;
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
 // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> _controller = Completer();
  Menu menu = Menu();
  Setting setting = new Setting();
  bool isloading=true;
 
  /*================ foreach multil maker ==============*/
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Map<PolylineId, Polyline> polylines = <PolylineId, Polyline>{};
  void addmultiMaker() async
  {
    /*========= get curent position and coordinate ==========*/
  //Position position  = await Geolocator().getCurrentPosition(desiredAccuracy:LocationAccuracy.best);
   location.LocationData currentLocation = await location.Location().getLocation();
   print(currentLocation.latitude);
   print(currentLocation.longitude);

    final coordinates = new Coordinates(currentLocation.latitude,currentLocation.longitude);
          var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
          var first = addresses.first;
           print("${first.featureName} : ${first.addressLine}");
           var name;
           try{
              name=first.featureName.split(" ",);
              print('dddddddddddddddddddddddd');
           }catch (c){
              name=['Vientaine'];
           }
          
          print(name);
          print("${first.adminArea} : ${first.coordinates}");
          print('wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww');
    
    /*========== Connct mysql and query data =============*/
    final conn = await mysql.MySqlConnection.connect(mysql.ConnectionSettings(
        host:setting.host,
        port:setting.port,
        user:setting.user,
        password:setting.password,
        db:setting.db));
    var results = await conn.query('select * from provinces where pro_name Like "%${name[0]}%"');
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
           setting.latitude=provinces['latitute'];
           setting.longitude=provinces['longtitute'];
        }
        
        setState(() {
            isloading=false;
            setting.latitude=setting.latitude;
            setting.longitude=setting.longitude;
            markers=markers;
            polylines=polylines;
            setting.zoom =8;
          });
  }
  /*=============== get detail onlick marker  ===============*/
  GoogleMapController mapController;
  void showdetail(
      var title, double latitude1, double longitude1, int province_id) {
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
                ],
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
   // getCurrentLocation();
    addmultiMaker();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      //key: _scaffoldKey,
      drawer: menu.drawer,
      appBar: AppBar(
        title: Text("HOME"),
      ),
      body: isloading?Center( child: CircularProgressIndicator(),):GoogleMap(
        mapType: MapType.normal,
        myLocationEnabled: true,
        compassEnabled: true,
        initialCameraPosition: CameraPosition(
          target: LatLng(17.9755039,102.6099928),
          zoom: setting.zoom,
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
