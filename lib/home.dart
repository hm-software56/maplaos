import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maplaos/menu/menu.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';



class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  
  Completer<GoogleMapController> _controller = Completer();
  Menu menu = Menu();

/*================= Get current location  ===============*/
  Location location = Location();
  var latitude = 17.974855;
  var longitude = 102.609986;
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
  Map<MarkerId, Marker> markers =<MarkerId, Marker>{}; 
  void addmultimarker() {
    final MarkerId markerId = MarkerId('1');
    // creating a new MARKER
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(latitude, longitude),
      //infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
      onTap: () {
        showdetail('Village');
      },
    );

    setState(() {
      markers[markerId] = marker;
    });
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
                        style: TextStyle(color: Colors.white),
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
            zoom: 16,
          ),
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          markers: Set<Marker>.of(markers.values),
        ));
  }
}
