import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_cache_store/flutter_cache_store.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maplaos/setting/setting.dart';
import 'package:mysql1/mysql1.dart' as mysql;

class HomeSlide extends StatefulWidget {
  @override
  Map locationdata;
  HomeSlide(this.locationdata);
  _HomeSlideState createState() => _HomeSlideState(this.locationdata);
}

class _HomeSlideState extends State<HomeSlide> {
  Map locationdata;
  _HomeSlideState(this.locationdata);
  Setting setting = new Setting();
  Completer<GoogleMapController> _controller = Completer();
  Future<void> aaaa() async {
    final GoogleMapController mapController = await _controller.future;
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(17.976794, 102.636504), zoom: 15.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SizedBox(
            width: 8.0,
          ),
          Container(
            color: Colors.white,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.network(
                  '${setting.apiUrl}/showimg/${locationdata['photo_name']}'),
            ),
          ),
          Container(
              color: Colors.white,
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
                      color: Colors.blue,
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
                        ),
                      ),
                      Text(
                        Localizations.localeOf(context).languageCode == "en"
                            ? locationdata['dis_name']
                            : locationdata['dis_name_la'],
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.0,
                        ),
                      )
                    ],
                  ),
                  onTap: () {
                    print('wwwwwww');
                    aaaa();
                  }))
        ],
      ),
    );
  }
}
