import 'dart:async';
import 'package:easy_localization/easy_localization_delegate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maplaos/locationimg.dart';
import 'package:maplaos/menu/menu.dart';
import 'package:maplaos/model/direction_place.dart';
import 'package:maplaos/model/loadimg.dart';
import 'package:maplaos/model/viewdetails_location.dart';
import 'package:maplaos/setting/setting.dart';
import 'package:flutter_cache_store/flutter_cache_store.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart' as location;
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:easy_localization/easy_localization.dart';
import 'model/direction_caculate.dart';
import 'package:device_id/device_id.dart';

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
  var locations;
  Map locationlistdetails = Map();
  bool isnolocation = true;
  /*================ foreach multil maker ==============*/
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Map<PolylineId, Polyline> polylines = <PolylineId, Polyline>{};
  void addmultiMaker(var keysearch) async {
    locationlistdetails.clear();
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
        isnolocation = false;
        /*========= get data province by location ======*/
        var provinces = await conn.query(
            'select pro_name, pro_name_la from provinces  where id=?',
            [location['provinces_id']]);
        var pro_name;
        var pro_name_la;
        for (var province in provinces) {
          pro_name = province['pro_name'].toString();
          pro_name_la = province['pro_name_la'].toString();
        }

        /*========= get data district by location ======*/
        var districts = await conn.query(
            'select dis_name, dis_name_la from districts  where id=?',
            [location['districts_id']]);
        var dis_name;
        var dis_name_la;
        for (var district in districts) {
          dis_name = district['dis_name'].toString();
          dis_name_la = district['dis_name_la'].toString();
        }

        /*========= get photo by location ======*/
        var photos = await conn.query(
            'select photo from photo where location_id=? limit 1',
            [location['id']]);
        var photo_name = 'location_img.png';
        for (var photo in photos) {
          photo_name = photo['photo'].toString();
        }

        /*========= get photo by location ======*/
        var countvisits = await conn.query(
            'SELECT COUNT(id) as count FROM tracking_visitor WHERE location_id=?',
            [location['id']]);
        var count_location = 0;
        for (var countvisit in countvisits) {
          count_location = countvisit['count'];
        }

        locationlistdetails[location["id"]] = {
          "location_id": location["id"].toString(),
          'location_name': location['loc_name'].toString(),
          'location_name_la': location['loc_name_la'].toString(),
          'latitude': location['latitude'],
          'longitude': location['longitude'],
          "pro_name": pro_name + ' Province',
          "pro_name_la": "ແຂວງ " + pro_name_la,
          "dis_name": dis_name + " District",
          "dis_name_la": "ເມື່ອງ " + dis_name_la,
          'photo_name': photo_name,
          'count_location': count_location
        };
        // locationlistdetails.add(location["id"]);
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
      isnolocation = isnolocation;
      locationlistdetails = locationlistdetails;
      setting.latitude = setting.latitude;
      setting.longitude = setting.longitude;
      markers = markers;
      polylines = polylines;
      setting.zoom = 8;
    });
  }

  void savetracingvisitor(var data) async {
    String deviceid = await DeviceId.getID;
    var now = new DateTime.now();
    final conn = await mysql.MySqlConnection.connect(mysql.ConnectionSettings(
        host: setting.host,
        port: setting.port,
        user: setting.user,
        password: setting.password,
        db: setting.db));
    var save = await conn.query(
        'insert into tracking_visitor (date, location_id,device_id) values (?, ?,?)',
        [now.toString(), data['id'], deviceid]);
  }

  /*=============== get detail onclick marker  ===============*/
  GoogleMapController mapController;

  void showdetail(var data, var currentLocation_latitude,
      var currentLocation_longitude) async {
    savetracingvisitor(data);
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
                          Localizations.localeOf(context).languageCode == "en"
                              ? data['loc_name'].toString()
                              : data['loc_name_la'].toString(),
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
                                                ViewDetailsLocation(
                                                    data['id'])))
                                  },
                                  //color: Colors.white,
                                  padding: EdgeInsets.all(10.0),
                                  child: Column(
                                    // Replace with a Row for horizontal icon + text
                                    children: <Widget>[
                                      Icon(
                                        Icons.list,
                                        color: Colors.red,
                                      ),
                                      Text(AppLocalizations.of(context)
                                          .tr("Details"))
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(''),
                              ),
                              Expanded(
                                child: FlatButton(
                                  onPressed: () => {
                                    // openGoogleMap(latitude, longitude)
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          fullscreenDialog: true,
                                          builder: (context) => DirectionPlace(
                                              currentLocation_latitude,
                                              currentLocation_longitude,
                                              data["latitude"],
                                              data["longitude"]),
                                        ))
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
                                      Text(AppLocalizations.of(context)
                                          .tr("Direction"))
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
                          Image.network(
                              '${setting.apiUrl}/showimg/${data['id']}.png',
                              fit: BoxFit.cover),
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
  static final GlobalKey<AutoCompleteTextFieldState<String>> key = GlobalKey();
  TextEditingController _searchQuery;
  bool _isSearching = false;
  String searchQuery = "";
  List<String> list_autocomplete = [];
  void autocomplete() async {
    final conn = await mysql.MySqlConnection.connect(mysql.ConnectionSettings(
        host: setting.host,
        port: setting.port,
        user: setting.user,
        password: setting.password,
        db: setting.db,
        timeout: Duration(seconds: 8)));
    var results = await conn.query('select * from location_searchs');
    for (var re in results) {
      String name = re['search_text']
          .toString()
          .replaceAll("', ", ';')
          .replaceAll("['", '')
          .replaceAll("]'", '')
          .replaceAll("'", '');
      setState(() {
        list_autocomplete = name.split(";");
      });
    }
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

  Widget slideFooter(Map locationdata) {
    return Container(
      padding: EdgeInsets.only(bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SizedBox(
            width: 8.0,
          ),
          Container(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  bottomLeft: Radius.circular(10.0)),
              child: InkWell(
                  onTap: () {
                    mapController.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                            target: LatLng(locationdata['latitude'],
                                locationdata['longitude']),
                            zoom: 18.0),
                        //target: LatLng(17.976794, 102.636504), zoom: 15.0),
                      ),
                    );
                  },
                  child: Image.network(
                    '${setting.apiUrl}/showimg/${locationdata['photo_name']}',
                  )),
            ),
          ),
          Container(
              color: Colors.blueGrey,
              width: 150,
              alignment: Alignment.topLeft,
              child: ListTile(
                  title: Text(
                    Localizations.localeOf(context).languageCode == "en"
                        ? locationdata['location_name']
                        : locationdata['location_name_la'],
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        Localizations.localeOf(context).languageCode == "en"
                            ? locationdata['pro_name']
                            : locationdata['pro_name_la'],
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.0,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        Localizations.localeOf(context).languageCode == "en"
                            ? locationdata['dis_name']
                            : locationdata['dis_name_la'],
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.0,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          for (var i = 1; i <= 5; i++)
                            Icon(
                              Icons.star,
                              color: i == 1 &&
                                      (locationdata['count_location'] > 1)
                                  ? Colors.amber
                                  : i == 2 &&
                                          locationdata['count_location'] > 20
                                      ? Colors.amber
                                      : i == 3 &&
                                              locationdata['count_location'] >
                                                  40
                                          ? Colors.amber
                                          : i == 4 &&
                                                  locationdata[
                                                          'count_location'] >
                                                      60
                                              ? Colors.amber
                                              : i == 5 &&
                                                      locationdata[
                                                              'count_location'] >
                                                          80
                                                  ? Colors.amber
                                                  : Colors.white70,
                              size: 16.0,
                            ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Icon(
                            Icons.visibility,
                            color: Colors.green,
                            size: 14.0,
                          ),
                          Text(
                            " " +
                                locationdata['count_location'].toString() +
                                ' views',
                            style: TextStyle(
                              fontSize: 10.0,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  onTap: () {
                    mapController.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                            target: LatLng(locationdata['latitude'],
                                locationdata['longitude']),
                            zoom: 18.0),
                        //target: LatLng(17.976794, 102.636504), zoom: 15.0),
                      ),
                    );
                  }))
        ],
      ),
    );
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
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: FloatingActionButton(
                          onPressed: _onMapTypeButtonPressed,
                          child: new Icon(
                            Icons.map,
                            color: Colors.white,
                          ),
                        ),
                      )),
                ),
                isnolocation
                    ? Text('')
                    : Align(
                        alignment: Alignment.bottomLeft,
                        child: Container(
                          alignment: Alignment.topLeft,
                          margin: EdgeInsets.symmetric(vertical: 2.0),
                          height: 90.0,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: <Widget>[
                              for (var keyvalue in locationlistdetails.keys)
                                slideFooter(locationlistdetails[keyvalue]),
                            ],
                          ),
                        ),
                      )
              ]));
  }
}
