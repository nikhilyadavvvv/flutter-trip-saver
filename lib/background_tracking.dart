import 'dart:convert';

import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:background_location/background_location.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:map_app/list_location.dart';
import 'package:map_app/trace_map.dart';
import 'package:map_app/trips_list.dart';
import 'package:map_app/trips_model.dart';

import 'db.dart';

class Back extends StatefulWidget {
  @override
  _BackState createState() => _BackState();
}

class _BackState extends State<Back> {
  int _currentIndex = 0;
  int selectedIndex = 0;
  PageController _pageController;

  List<List_Location> ll = [];
  String latitude = "waiting...";
  String longitude = "waiting...";
  String altitude = "waiting...";
  String accuracy = "waiting...";
  String bearing = "waiting...";
  String speed = "waiting...";
  int thowAwayArea = 0;
  @override
  Future<void> initState() {
    super.initState();
    _pageController = PageController();
    //BackgroundLocation.startLocationService();
    BackgroundLocation.getLocationUpdates((location) {
       print('BackgroundLocation.getLocationUpdates');
      setState(() {
        this.latitude = location.latitude.toString();
        this.longitude = location.longitude.toString();
        this.accuracy = location.accuracy.toString();
        this.altitude = location.altitude.toString();
        this.bearing = location.bearing.toString();
        this.speed = location.speed.toString();
        ll.add(new List_Location(
            lat: location.latitude, long: location.longitude));
        thowAwayArea++;
        if (thowAwayArea > 5) {
          ll.add(new List_Location(
              lat: location.latitude, long: location.longitude));
        }
      });

      print("""\n
      Latitude:  $latitude
      Longitude: $longitude
      Altitude: $altitude
      Accuracy: $accuracy
      Bearing:  $bearing
      Speed: $speed
      """);
    });
    initDB();
  }

  initDB() async {}

  bool started = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          children: <Widget>[
            thisPage(context),
            Trips_List(),
            Tracemap(
              ll: ll,
              showBack: false,
            )
          ],
        ),
      ),
      bottomNavigationBar: bottomNavigationBar(),
    );
  }

  Widget thisPage(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: InkWell(
                  child: started
                      ? roundedButtons(context, Icons.play_arrow,
                          Colors.white38, "Start Trip")
                      : roundedButtons(context, Icons.play_arrow, Colors.green,
                          "Start Trip"),
                  onTap: () {
                    if (!started) {
                      BackgroundLocation.startLocationService();
                      print("Start Location Service");
                      toaster("New Trip Started, Happy Journey");
                      setState(() {
                        started = true;
                      });
                    }
                    //Start Location Service
                  },
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: InkWell(
                  child: started
                      ? roundedButtons(
                          context, Icons.stop, Colors.red, "Stop Trip")
                      : roundedButtons(
                          context, Icons.stop, Colors.white38, "Stop Trip"),
                  onTap: () {
                    if (started) {
                      BackgroundLocation.stopLocationService();
                      toaster("Trip Ended and Saved");
                      print("Stop Location Service");
                      _save();
                      setState(() {
                        started = false;
                      });
                    }
                    //Stop Location Service
                  },
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget currentTrip(BuildContext context) {
    if (started) {
      return Tracemap(
        ll: ll,
      );
    } else {
      return Scaffold(
        body: Center(
          child: Text("No Trip In Progress"),
        ),
      );
    }
  }

  Widget locationData(String data) {
    return Text(
      data,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget roundedButtons(
      BuildContext context, IconData iconData, Color color, String buttonText) {
    return Container(
      height: 200.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        color: Color(0xFF212224),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 8,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 25, 0, 0),
                child: Icon(
                  iconData,
                  size: 25.0,
                  color: color,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                buttonText,
                style: TextStyle(color: Colors.white38),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // BackgroundLocation.stopLocationService();
    // super.dispose();
  }

  void _save() async {
    print("saved");
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('kk:mm:ss , EEE d MMM').format(now);
    Trips item = new Trips(formattedDate, returnLatLongMap(), "SELF");
    DatabaseHelper helper = DatabaseHelper();
    helper.insertTrips(item);
    ll.clear();
  }

  returnLatLongMap() {
    var i;
    List<dynamic> data = new List();
    for (i = 0; i < ll.length; i++) {
      var myMap = Map();
      myMap["lat"] = ll[i].lat;
      myMap["long"] = ll[i].long;
      data.add(myMap);
    }
    return jsonEncode(data);
  }

  toaster(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Widget bottomNavigationBar() {
    return BottomNavyBar(
      backgroundColor: Colors.black,
      selectedIndex: _currentIndex,
      onItemSelected: (index) {
        setState(() => _currentIndex = index);
        _pageController.animateToPage(index,
            duration: Duration(milliseconds: 300), curve: Curves.linear);
      },
      items: <BottomNavyBarItem>[
        BottomNavyBarItem(
            title: Text('Home'),
            icon: Icon(Icons.apps),
            activeColor: Colors.pink),
        BottomNavyBarItem(
            title: Text('Trips'),
            icon: Icon(Icons.linear_scale),
            activeColor: Colors.indigo),
        BottomNavyBarItem(
            title: Text('Current Trip'),
            icon: Icon(Icons.trending_up),
            activeColor: Colors.green),
      ],
    );
  }

  Widget detailedCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
        color: Color(0xFF212224),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(flex: 4, child: Text("Latitude")),
                Expanded(flex: 6, child: Text(latitude)),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(flex: 4, child: Text("Longitude")),
                Expanded(flex: 6, child: Text(longitude)),
              ],
            ),
            //locationData("Latitude: " + latitude),
            //locationData("Longitude: " + longitude),
            //locationData("Altitude: " + altitude),
            //locationData("Accuracy: " + accuracy),
            //locationData("Bearing: " + bearing),
            //locationData("Speed: " + speed),
          ],
        ),
      ),
    );
  }
}

//spherical images on mobile
