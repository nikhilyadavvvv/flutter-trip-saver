import 'dart:math';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_app/list_location.dart';
import 'package:map_app/tax_cal.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

class Tracemap extends StatefulWidget {
  List<List_Location> ll;
  bool showBack;
  Tracemap({Key key, this.ll, this.showBack}) : super(key: key);
  @override
  _TracemapState createState() => _TracemapState();
}

class _TracemapState extends State<Tracemap> with AfterLayoutMixin<Tracemap> {
  int _currentIndex = 2;
  PageController _pageController;
  bool isloading = true;
  GoogleMapController controller;
  Map<PolylineId, Polyline> polylines = <PolylineId, Polyline>{};
  BitmapDescriptor initIcon;
  BitmapDescriptor finalIcon;
  BitmapDescriptor pinLocationIcon;

  int _polylineIdCounter = 1;
  PolylineId selectedPolyline;

  Position _currentPosition;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  double _markerIdCounter = 0;
  void _onMapCreated(GoogleMapController controller) {
    this.controller = controller;
  }

  @override
  void initState() {
    super.initState();
    setCustomMapPin();
    _pageController = PageController();
  }

  void setCustomMapPin() async {
    initIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(108, 108)), 'assets/init_marker.png');
    finalIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(108, 108)), 'assets/end_marker.png');
  }

  @override
  Widget build(BuildContext context) {
    int len = widget.ll.length;
    bool showback = widget.showBack;
    if (len > 0) {
      setState(() {
        isloading = false;
      });
      _add();
      _addMarker(
        widget.ll[0].lat,
        widget.ll[0].long,
        true,
      );
      _addMarker(
        widget.ll[widget.ll.length - 1].lat,
        widget.ll[widget.ll.length - 1].long,
        false,
      );
    }
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: showback
          ? AppBar(
              backgroundColor: Colors.black,
              leading: Padding(
                padding: EdgeInsets.only(left: 12),
                child: IconButton(
                  icon: Icon(Icons.keyboard_arrow_left),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            )
          : AppBar(
              backgroundColor: Colors.black,
              elevation: 0,
            ),
      body: Container(
        child: Center(
          child: isloading
              ? Text(
                  "No trip in progress",
                  style: TextStyle(color: Colors.white54),
                )
              : GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(50.5441217, 9.673536),
                    zoom: 7.0,
                  ),
                  markers: Set<Marker>.of(markers.values),
                  polylines: Set<Polyline>.of(polylines.values),
                  onMapCreated: _onMapCreated,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                ),
        ),
      ),
      /*floatingActionButton: FloatingActionButton(
        onPressed: () {
          createLatLongMap();
        },
        child: Icon(Icons.monetization_on),
      ),*/
    );
  }

  void _add() {
    final int polylineCount = polylines.length;

    if (polylineCount == 12) {
      return;
    }
    print("add called");
    final String polylineIdVal = 'polyline_id_$_polylineIdCounter';
    _polylineIdCounter++;
    final PolylineId polylineId = PolylineId(polylineIdVal);

    final Polyline polyline = Polyline(
      polylineId: polylineId,
      consumeTapEvents: true,
      color: Colors.orange,
      width: 3,
      points: _createPoints(),
      onTap: () {
        //_onPolylineTapped(polylineId);
      },
    );
    print(polyline);

    setState(() {
      polylines[polylineId] = polyline;
      print(polylines[polylineId]);
    });
  }

  void _addMarker(double lat, double long, bool init) {
    print("in add marker");
    var markerIdVal = lat.toString() + " , " + long.toString();
    if (init) {
      markerIdVal = "Start: " + lat.toString() + " , " + long.toString();
    } else {
      markerIdVal = "End: " + lat.toString() + " , " + long.toString();
    }
    final MarkerId markerId = MarkerId(markerIdVal);

    // creating a new MARKER
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(lat, long),
      infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
      onTap: () {},
      icon: init ? initIcon : finalIcon,
    );

    setState(() {
      // adding a new marker to map
      markers[markerId] = marker;
    });
  }

  List<LatLng> _createPoints() {
    final List<LatLng> points = <LatLng>[];
    //List<List_Location> ll = widget.ll;
    //print(ll);

    for (var i = 0; i < widget.ll.length; i++) {
      points.add(_createLatLng(widget.ll[i].lat, widget.ll[i].long));
    }

    //points.add(_createLatLng(50.546399 + offset, 9.673536));
    //points.add(_createLatLng(50.543991 + offset, 9.675844));
    //points.add(_createLatLng(50.544093 + offset, 9.674594));
    return points;
  }

  LatLng _createLatLng(double lat, double lng) {
    return LatLng(lat, lng);
  }

  createLatLongMap() {
    var i;
    //List<List_Location> ll = widget.ll;
    List<dynamic> data = new List();
    for (i = 0; i < widget.ll.length; i++) {
      var myMap = Map();
      myMap["lat"] = widget.ll[i].lat;
      myMap["lng"] = widget.ll[i].lat;
      data.add(myMap);
    }
    //print(data);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaxCal(
          data: data,
        ),
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
        controller.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
                //target: LatLng(position.latitude, position.longitude),
                target: LatLng(widget.ll[0].lat, widget.ll[0].long),
                zoom: 17.0),
          ),
        );
      });
    }).catchError((e) {
      //print(e);
    });
  }

  initLocation() {
    setState(() {
      controller.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
              //target: LatLng(position.latitude, position.longitude),
              target: LatLng(widget.ll[0].lat, widget.ll[0].long),
              zoom: 17.0),
        ),
      );
    });
  }

  @override
  afterFirstLayout(BuildContext context) async {
    _getCurrentLocation();
    initLocation();
  }
}
