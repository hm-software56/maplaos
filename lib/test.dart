import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DragMarkerMap1 extends StatefulWidget {
  @override
  _DragMarkerMap1State createState() => _DragMarkerMap1State();
}

class _DragMarkerMap1State extends State<DragMarkerMap1> {
  Completer<GoogleMapController> _controller = Completer();

  static const LatLng _center = const LatLng(45.521563, -122.677433);

  Set<Marker> _markers = {};

  LatLng _lastMapPosition = _center;

  MapType _currentMapType = MapType.normal;

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  void _onAddMarkerButtonPressed() {
    setState(() {
      _markers.add(Marker(
        // This marker id can be anything that uniquely identifies each marker.
        markerId: MarkerId('marker_id'),
        draggable: true,
        position: _lastMapPosition,
        infoWindow: InfoWindow(
          title: 'Custom Marker',
          snippet: 'Inducesmile.com',
        ),
        icon: BitmapDescriptor.defaultMarker,
      ));
    });
  }

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
    CameraPosition newPos = CameraPosition(target: position.target);
    Marker marker = _markers.first;

    setState(() {
      _markers.first.copyWith(positionParam: newPos.target);
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Select location'),
          backgroundColor: Colors.red,
        ),
        body: Stack(
          children: <Widget>[
            GoogleMap(
              onMapCreated: _onMapCreated,
              myLocationEnabled: true,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 11.0,
              ),
              mapType: _currentMapType,
              markers: _markers,
              onCameraMove: _onCameraMove,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topRight,
                child: Column(
                  children: <Widget>[
                    FloatingActionButton(
                      onPressed: _onMapTypeButtonPressed,
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      backgroundColor: Colors.green,
                      child: const Icon(Icons.map, size: 36.0),
                    ),
                    SizedBox(height: 16.0),
                    FloatingActionButton(
                      onPressed: _onAddMarkerButtonPressed,
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      backgroundColor: Colors.green,
                      child: const Icon(Icons.add_location, size: 36.0),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
