import 'dart:async';
import 'dart:math';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'package:map_app/background_tracking.dart';
import 'package:map_app/list_location.dart';
import 'package:map_app/track_record.dart';

void main() => runApp(MyApp());
//void main() => runApp(Back());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      //home: MapSample(),
      home: Back(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> with AfterLayoutMixin<MapSample> {
  GoogleMapController mapController;
  Position _currentPosition;
  String _currentAddress;
  List<List_Location> ll = new List<List_Location>();
  final Set<Marker> _markers = {};
  final Set<Polyline> _polyline = {};
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  MarkerId selectedMarker;
  double _markerIdCounter = 0;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            mapController = controller;
          },
          initialCameraPosition: CameraPosition(
            target: LatLng(37.42796133580664, -122.085749655962),
            zoom: 14.4746,
          ),
          markers: Set<Marker>.of(markers.values),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Back(),
            ),
          );
        },
        child: Icon(Icons.scatter_plot),
      ),
    );
  }

  _getCurrentLocation() {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        print(position);
        mapController.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(position.latitude, position.longitude),
                zoom: 17.0),
          ),
        );
        ll.add(new List_Location(lat: position.latitude, long :position.longitude));
        _add(position.latitude, position.longitude);
        _getAddressFromLatLng(geolocator);
      });
    }).catchError((e) {
      print(e);
    });
  }

  void _add(double lat, double long) {
    final int markerCount = markers.length;

    if (markerCount == 12) {
      return;
    }

    final String markerIdVal = 'marker_id_$_markerIdCounter';
    double rem = _markerIdCounter--;
    String markrem = 'marker_id_$rem';
    _markerIdCounter++;
    final MarkerId markerId = MarkerId(markerIdVal);

    final Marker marker = Marker(
        markerId: markerId,
        position: LatLng(lat, long),
        infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
        onTap: () {
          _onMarkerTapped(markerId);
        });

    setState(() {
      markers.remove(markrem);
      markers[markerId] = marker;
    });
  }

  void _onMarkerTapped(MarkerId markerId) {
    final Marker tappedMarker = markers[markerId];
    if (tappedMarker != null) {
      setState(() {
        if (markers.containsKey(selectedMarker)) {
          final Marker resetOld = markers[selectedMarker]
              .copyWith(iconParam: BitmapDescriptor.defaultMarker);
          markers[selectedMarker] = resetOld;
        }
        selectedMarker = markerId;
        final Marker newMarker = tappedMarker.copyWith(
          iconParam: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        );
        markers[markerId] = newMarker;
      });
    }
  }

  void _remove() {
    setState(() {
      if (markers.containsKey(selectedMarker)) {
        markers.remove(selectedMarker);
      }
    });
  }

  _getAddressFromLatLng(Geolocator geolocator) async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
            "${place.locality}, ${place.postalCode}, ${place.country}";
        /*Fluttertoast.showToast(
            msg: _currentAddress,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIos: 1,
            backgroundColor: Colors.red[300],
            textColor: Colors.white,
            fontSize: 16.0);*/

        Timer(Duration(milliseconds: 500), () {
          setState(() {
            _getCurrentLocationNext();
          });
        });
      });
    } catch (e) {
      print(e);
    }
  }

  _getCurrentLocationNext() {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        print(position);
        ll.add(new List_Location(lat:position.latitude, long:position.longitude));
        _add(position.latitude, position.longitude);
        _getAddressFromLatLng(geolocator);
      });
    }).catchError((e) {
      print(e);
    });
  }

  @override
  void afterFirstLayout(BuildContext context) {
    // TODO: implement afterFirstLayout

    Timer(Duration(milliseconds: 1500), () {
      setState(() {
        _getCurrentLocation();
      });
    });
  }
}
