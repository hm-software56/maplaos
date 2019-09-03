import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maplaos/locationimg.dart';
import 'package:maplaos/menu/menu.dart';
import 'package:maplaos/model/loadimg.dart';
import 'package:maplaos/setting/setting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_cache_store/flutter_cache_store.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as location;
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:dio/dio.dart';

import 'model/direction_caculate.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> _controller = Completer();
  Menu menu = Menu();
  Setting setting = new Setting();
  bool isloading = true;
  String title = "Home";

  /*================ foreach multil maker ==============*/
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Map<PolylineId, Polyline> polylines = <PolylineId, Polyline>{};
  void addmultiMaker(var keysearch) async {
    /*========= get curent position and coordinate ==========*/
    //Position position  = await Geolocator().getCurrentPosition(desiredAccuracy:LocationAccuracy.best);
    location.LocationData currentLocation =
        await location.Location().getLocation();
    final coordinates =
        new Coordinates(currentLocation.latitude, currentLocation.longitude);

    //print("${first.adminArea} : ${first.addressLine}");
    var name;
    if (keysearch == null) {
      try {
        var addresses =
            await Geocoder.local.findAddressesFromCoordinates(coordinates);
        var first = addresses.first;
        name = first.adminArea;
      } catch (c) {
        name = 'Vientiane';
      }
    } else {
      name = keysearch;
    }

    /*========== Connct mysql and query data =============*/
    final conn = await mysql.MySqlConnection.connect(mysql.ConnectionSettings(
        host: setting.host,
        port: setting.port,
        user: setting.user,
        password: setting.password,
        db: setting.db));
    var find_search_step = 1;
    var results = await conn.query(
        'select * from provinces where MATCH(pro_name, pro_name_la) AGAINST("$name" IN NATURAL LANGUAGE MODE)');
    if (results.length == 0) {
      find_search_step = 2;
      results = await conn.query(
          'select * from districts where MATCH(dis_name, dis_name_la) AGAINST("$name" IN NATURAL LANGUAGE MODE)');
      if (results.length == 0) {
        find_search_step = 3;
        results = await conn.query(
            'select * from location where MATCH(loc_name, loc_name_la) AGAINST("$name" IN NATURAL LANGUAGE MODE)');
      }
    }
    for (var result in results) {
      /*
      /*======== Marker =======*/
      final MarkerId markerId = MarkerId('$result["id"]');
      // creating a new MARKER
      final Marker marker = Marker(
        markerId: markerId,
        position: LatLng(result['latitude'], result['longitude']),
        onTap: () {
          /** zoom curent location on click */
          mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                  target: LatLng(result['latitude'], result['longitude']),
                  zoom: 8.0),
            ),
          );

          /** Show modal details  */
          showdetail(result);
        },
      );
      markers[markerId] = marker;
      */
      /*========== add location in to maker ========*/
      var locations;
      if (find_search_step == 1) {
        locations = await conn.query(
            'select l.*,ld.id as detail_id,ld.details,ld.details_la from location as l left join location_details as ld on ld.location_id=l.id where l.provinces_id=? and latitude!=0',
            [result['id']]);
      } else if (find_search_step == 2) {
        locations = await conn.query(
            'select l.*,ld.id as detail_id,ld.details,ld.details_la from location as l left join location_details as ld on ld.location_id=l.id where l.districts_id=? and latitude!=0',
            [result['id']]);
      } else {
        locations = await conn.query(
            'select l.*,ld.id as detail_id,ld.details,ld.details_la from location as l left join location_details as ld on ld.location_id=l.id where l.id=? and latitude!=0',
            [result['id']]);
      }
      for (var location in locations) {
        final MarkerId markerId = MarkerId('$location["id"]_1');
        // creating a new MARKER
        final Marker marker = Marker(
          markerId: markerId,
          position: LatLng(location['latitude'], location['longitude']),
          onTap: () {
            /** zoom curent location on click */
            mapController.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                    target: LatLng(location['latitude'], location['longitude']),
                    zoom: 15.0),
              ),
            );

            /** Show modal details  */
            showdetail(
                location, currentLocation.latitude, currentLocation.longitude);
          },
        );
        markers[markerId] = marker;
      }

      /*================ Polyline ===============*/
      /* final PolylineId polygonId = PolylineId('$provinces["id"]');
      final List<LatLng> polylinelist = <LatLng>[];
      var polygons = await conn.query(
          'select * from polygon where provinces_id=?', [provinces['id']]);
      for (final polylinelatlong in polygons) {
        polylinelist.add(
            LatLng(polylinelatlong['latitude'], polylinelatlong['longitude']));
      }
      final Polyline polyline = Polyline(
          polylineId: polygonId, color: Colors.red[300], points: polylinelist);

      polylines[polygonId] = polyline;*/
      setting.latitude = result['latitude'];
      setting.longitude = result['longitude'];
    }

    setState(() {
      isloading = false;
      setting.latitude = setting.latitude;
      setting.longitude = setting.longitude;
      markers = markers;
      polylines = polylines;
      setting.zoom = 8;
    });
  }

  /*=============== get detail onclick marker  ===============*/
  GoogleMapController mapController;

  void showdetail(var data, var currentLocation_latitude,
      var currentLocation_longitude) async {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20.0),
                topRight: const Radius.circular(20.0))),
        backgroundColor: Colors.white,
        context: context,
        builder: (Builder) {
          return SingleChildScrollView(
            child: Container(
              color: Colors.transparent,
              child: Center(
                child: Column(
                  children: <Widget>[
                    Container(
                      decoration: new BoxDecoration(
                          color: Colors.red,
                          borderRadius: new BorderRadius.only(
                              topLeft: const Radius.circular(20.0),
                              topRight: const Radius.circular(20.0))),
                      padding: EdgeInsets.all(10),
                      //color: Colors.red,
                      child: Center(
                        child: Text(
                          data['loc_name'] + '/' + data['loc_name_la'],
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: FlatButton(
                                  onPressed: () => {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            fullscreenDialog: true,
                                            builder: (context) =>
                                                Locationimg(data['id'])))
                                  },
                                  //color: Colors.white,
                                  padding: EdgeInsets.all(10.0),
                                  child: Column(
                                    // Replace with a Row for horizontal icon + text
                                    children: <Widget>[
                                      Icon(
                                        Icons.image,
                                        color: Colors.red,
                                      ),
                                      Text("Image​")
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: FlatButton(
                                  onPressed: () => {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                Locationimg(data['id'])))
                                  },
                                  //color: Colors.white,
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
                                  // color: Colors.white,
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
                          Divider(),
                          DirectionCaculate(
                              data["longitude"],
                              data["latitude"],
                              currentLocation_longitude,
                              currentLocation_latitude),
                          Loadimg(data['id']),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

/*===================== Search =======================*/
  static final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>();
  GlobalKey<AutoCompleteTextFieldState<String>> key = GlobalKey();
  TextEditingController _searchQuery;
  bool _isSearching = false;
  String searchQuery = "";
  List<String> list_autocomplete = [];
  void autocomplete() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    list_autocomplete = prefs.getStringList('list_autocomplete');
  }

  void _startSearch() {
    ModalRoute.of(context)
        .addLocalHistoryEntry(new LocalHistoryEntry(onRemove: _stopSearching));
    setState(() {
      markers.clear();
      polylines.clear();
      _isSearching = true;
    });
  }

  void _stopSearching() {
    setState(() {
      _isSearching = false;
    });
  }

  Widget _buildSearchField() {
    return SimpleAutoCompleteTextField(
      controller: TextEditingController(text: searchQuery),
      textChanged: (text) {
        updateSearchQuery(text);
      },
      textSubmitted: (text) {
        updateSearchQueryByClicklist(text);
      },
      clearOnSubmit: true,
      key: key,
      suggestions: list_autocomplete,
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
      ),
    );
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
    });
    print("search query " + newQuery);
  }

  void updateSearchQueryByClicklist(String newQuery) {
    setState(() {
      searchQuery = newQuery;
      isloading = true;
      title = searchQuery;
    });
    markers.clear();
    polylines.clear();
    addmultiMaker(searchQuery);
    Navigator.pop(context);
  }

  List<Widget> _buildActions() {
    if (_isSearching) {
      return <Widget>[
        new IconButton(
          icon: const Icon(Icons.send),
          onPressed: () {
            if (_searchQuery == null || _searchQuery.text.isEmpty) {
              print(searchQuery);
              setState(() {
                isloading = true;
                title = searchQuery;
              });
              markers.clear();
              polylines.clear();
              addmultiMaker(searchQuery);
              Navigator.pop(context);
            }
          },
        ),
      ];
    }
    return <Widget>[
      new IconButton(
        icon: const Icon(Icons.search),
        onPressed: _startSearch,
      ),
    ];
  }

/*=================== switch map type ===========*/
  MapType _currentMapType = MapType.normal;
  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  @override
  void initState() {
    super.initState();
    autocomplete();
    addmultiMaker(null);
  }

  Widget build(BuildContext context) {
    return Scaffold(
        //key: _scaffoldKey,
        drawer: menu,
        key: scaffoldKey,
        appBar: new AppBar(
          centerTitle: true,
          title: _isSearching ? _buildSearchField() : Text(title),
          actions: _buildActions(),
        ),
        body: isloading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Stack(children: <Widget>[
                GoogleMap(
                  mapType: _currentMapType,
                  myLocationEnabled: true,
                  compassEnabled: true,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(setting.latitude, setting.longitude),
                    zoom: setting.zoom,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    //_controller.complete(controller);
                    mapController = controller;
                  },
                  markers: Set<Marker>.of(markers.values),
                  polylines: Set<Polyline>.of(polylines.values),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: new FloatingActionButton(
                      onPressed: _onMapTypeButtonPressed,
                      child: new Icon(
                        Icons.map,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ]));
  }
}
