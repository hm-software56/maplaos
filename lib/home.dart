import 'dart:async';
import 'package:flutter/cupertino.dart';
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
import 'model/formsearch.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> _controller = Completer();
  Menu menu = Menu();
  Setting setting = new Setting();
  Formsearch search = Formsearch();
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
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    print("${first.adminArea} : ${first.addressLine}");
    var name;
    if (keysearch == null) {
      try {
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
    var results = await conn.query(
        'select * from provinces where MATCH(pro_name, pro_name_la) AGAINST("$name" IN NATURAL LANGUAGE MODE)');
    //var results = await conn .query('select * from provinces where pro_name Like "%${name[0]}%"');
    for (var provinces in results) {
      /*======== Marker =======*/
      final MarkerId markerId = MarkerId('$provinces["id"]');
      // creating a new MARKER
      final Marker marker = Marker(
        markerId: markerId,
        position: LatLng(provinces['latitute'], provinces['longtitute']),
        onTap: () {
          /** zoom curent location on click */
          mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                  target:
                      LatLng(provinces['latitute'], provinces['longtitute']),
                  zoom: 8.0),
            ),
          );

          /** Show modal details  */
          showdetail(provinces["pro_name"] + '/' + provinces["pro_name_la"],
              provinces['latitute'], provinces['longtitute'], provinces['id']);
        },
      );
      markers[markerId] = marker;

      /*========== add location in to maker ========*/
      var locations = await conn.query(
          'select * from location_tour where province_code=? and latitude!=0',
          [provinces['pro_code']]);
      for (var location in locations) {
        final MarkerId markerId = MarkerId('$location["province_code"]');
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
            showdetail(location["name"] + '/' + location["name_la"],
                location['latitude'], location['longitude'], location['id']);
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
      setting.latitude = provinces['latitute'];
      setting.longitude = provinces['longtitute'];
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

/*===================== Search =======================*/
  static final GlobalKey<ScaffoldState> scaffoldKey =
      new GlobalKey<ScaffoldState>();

  TextEditingController _searchQuery;
  bool _isSearching = false;
  String searchQuery = "Search query";
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
    return new TextField(
      controller: _searchQuery,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Search...',
        border: InputBorder.none,
        hintStyle: const TextStyle(color: Colors.white30),
      ),
      style: const TextStyle(color: Colors.white, fontSize: 16.0),
      onChanged: updateSearchQuery,
    );
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
    });
    print("search query " + newQuery);
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
    // getCurrentLocation();
    addmultiMaker(null);
  }

  Widget build(BuildContext context) {
    return Scaffold(
        //key: _scaffoldKey,
        drawer: menu.drawer,
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
