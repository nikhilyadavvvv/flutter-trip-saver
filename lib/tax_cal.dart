

import 'package:flutter/material.dart';
import 'dart:math' show cos, sqrt, asin;
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:map_app/analysis.dart';
import 'package:map_app/trace_map.dart';
import 'package:sqflite/sqflite.dart';
import 'package:map_app/list_location.dart';

import 'db.dart';
import 'trips_model.dart';

class TaxCal extends StatefulWidget {
  List<dynamic> data;
  List<List_Location> ll;
  Trips trip;
  TaxCal({Key key, this.data, this.ll, this.trip}) : super(key: key);
  @override
  _TaxCalState createState() => _TaxCalState();
}

class _TaxCalState extends State<TaxCal> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Trips> trip_list;
  int count = 0;
  Trips trip;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    trip = widget.trip;
  }

  @override
  Widget build(BuildContext context) {
    updateListView();
    return Scaffold(
      appBar: AppBar(
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
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Container(
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            //crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: detailEle(context, Icons.alternate_email,
                        Colors.yellow, "  Rate", "0.1€/KM"),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: detailEle(
                          context,
                          Icons.swap_calls,
                          Colors.blue,
                          "  Total Distance",
                          distance(tax()).toString() + " KM")),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: InkWell(
                      child: detailEle(context, Icons.style, Colors.green,
                          "  Total Tax", cost(tax()).toString() + " €"),
                      onTap: () {
                        /* Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TimeSeriesBar(_createSampleData()),
                          ),
                        );*/
                      },
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: InkWell(
                      child: detailEle(context, Icons.map, Colors.pink,
                          "  Show Route", "Open Map"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Tracemap(
                              ll: widget.ll,
                              showBack: true,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: InkWell(
                      child: detailEle(
                          context,
                          Icons.category,
                          Colors.deepPurple,
                          "  Trip Type (tap to change)",
                          widget.trip.type),
                      onTap: () {
                        /* Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TimeSeriesBar(_createSampleData()),
                          ),
                        );*/
                        updateType();
                      },
                    ),
                  ),
                ],
              ),
            ],
          )),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          delete();
        },
        label: Text(
          "Delete Trip",
          style: TextStyle(color: Colors.white54),
        ),
        icon: Icon(
          Icons.delete_forever,
          color: Colors.red,
        ),
        backgroundColor: Color(0xFF212224),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  double tax() {
    List<dynamic> data = widget.data;
    double totalDistance = 0;
    for (var i = 0; i < data.length - 1; i++) {
      totalDistance += calculateDistance(data[i]["lat"], data[i]["lng"],
          data[i + 1]["lat"], data[i + 1]["lng"]);
    }
    return totalDistance;
  }

  double taxEach(List<dynamic> data) {
    double totalDistance = 0;
    for (var i = 0; i < data.length - 1; i++) {
      totalDistance += calculateDistance(data[i]["lat"], data[i]["lng"],
          data[i + 1]["lat"], data[i + 1]["lng"]);
    }
    return totalDistance;
  }

  distance(double dist) {
    return double.parse((dist).toStringAsFixed(2));
  }

  cost(double dist) {
    var cost = 0.1 * dist;
    return double.parse((cost).toStringAsFixed(2));
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  Widget detailEle(BuildContext context, IconData iconData, Color color,
      String heading, String cal) {
    bool rotate = false;
    if (heading == "  Total Tax") {
      rotate = true;
    }

    return Container(
      height: 150.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        color: Color(0xFF212224),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    rotate
                        ? RotatedBox(
                            quarterTurns: 2,
                            child: Icon(
                              iconData,
                              size: 25.0,
                              color: color,
                            ),
                          )
                        : Icon(
                            iconData,
                            size: 25.0,
                            color: color,
                          ),
                    Text(
                      heading,
                      style: TextStyle(color: Colors.white38),
                    ),
                  ],
                ),
              ),
              flex: 8,
            ),
            Expanded(
              flex: 2,
              child: Text(
                cal,
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  updateType() {
    switch (widget.trip.type) {
      case "SELF":
        updateT("COLLEAGUE");
        setState(() {
          widget.trip.type = "COLLEAGUE";
        });
        break;
      case "COLLEAGUE":
        updateT("COMPANY");
        setState(() {
          widget.trip.type = "COMPANY";
        });
        break;
      case "COMPANY":
        updateT("SELF");
        setState(() {
          widget.trip.type = "SELF";
        });
        break;
    }
  }

  updateT(String newtype) async {
    DatabaseHelper helper = DatabaseHelper();
    trip.type = newtype;
    if (trip.id != null) {
      // Update operation
      int result = await helper.updateTrips(trip);
      print("updated");
      print(result);
      print(trip.id);
    }
  }

  void delete() async {
    DatabaseHelper helper = DatabaseHelper();
    int result = await helper.deleteTrips(trip.id);
    print("deleted");
    Navigator.pop(context);
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Trips>> tripListFuture = databaseHelper.getTripsList();
      tripListFuture.then((tripList) {
        setState(() {
          this.trip_list = tripList;
          this.count = trip_list.length;
        });
      });
    });
  }
}
