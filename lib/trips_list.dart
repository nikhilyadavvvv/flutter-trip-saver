import 'package:flutter/material.dart';
import 'package:map_app/db.dart';
import 'package:map_app/list_location.dart';
import 'package:map_app/tax_cal.dart';
import 'package:map_app/trips_model.dart';
import 'package:sqflite/sqflite.dart';

class Trips_List extends StatefulWidget {
  @override
  _Trips_ListState createState() => _Trips_ListState();
}

class _Trips_ListState extends State<Trips_List> {
  int _currentIndex = 1;
  PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Trips> trip_list;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    updateListView();
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        child: getTripsListView(),
      ),
      /*bottomNavigationBar: FFNavigationBar(
        theme: FFNavigationBarTheme(
          barBackgroundColor: Colors.black,
          selectedItemBorderColor: Colors.black,
          selectedItemBackgroundColor: Colors.black,
          selectedItemIconColor: Colors.blueAccent,
          selectedItemLabelColor: Colors.white54,
          unselectedItemLabelColor: Colors.white38,
        ),
        selectedIndex: selectedIndex,
        onSelectTab: (index) {
          setState(() {
            selectedIndex = index;
          });
          if (index == 0) {
            Navigator.pop(context);
          }
        },
        items: [
          FFNavigationBarItem(
            iconData: Icons.home,
            label: 'Home',
          ),
          FFNavigationBarItem(
            iconData: Icons.linear_scale,
            label: 'MyTrips',
          ),
        ],
      ),*/
    );
  }

  ListView getTripsListView() {
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        String string = this.trip_list[position].time;
        return Card(
          color: Color(0xFF212224),
          elevation: 2.0,
          child: ListTile(
            title: Text(
              string.split(",")[1],
              style: TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              string.split(",")[0],
              style: TextStyle(color: Colors.white60),
            ),
            onTap: () {
              /*Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TrackRecord(
                    ll: jsonDecode(this.trip_list[position].path),
                  ),
                ),
              );*/
              //print(jsonDecode(this.trip_list[position].path));
              final listLocation =
                  listLocationFromJson(this.trip_list[position].path);
              createLatLongMap(listLocation,position);
              /*Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Tracemap(
                    ll: listLocation,
                  ),
                ),
              );*/

              /*List<dynamic> l = new List();
              List<List_Location> ll = new List();
              l = jsonDecode(this.trip_list[position].path);
              for (var i = 0; i < l.length; i++) {
                ll.add(new List_Location(l[i].lng, l[i].lng));
              }
              print(ll);*/
            },
          ),
        );
      },
    );
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

  createLatLongMap(List<List_Location> ll,int position) {
    var i;
    //List<List_Location> ll = widget.ll;
    List<dynamic> data = new List();
    for (i = 0; i < ll.length; i++) {
      var myMap = Map();
      myMap["lat"] = ll[i].lat;
      myMap["lng"] = ll[i].lat;
      data.add(myMap);
    }
    //print(data);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaxCal(
          data: data,
          ll: ll,
          trip: this.trip_list[position],
        ),
      ),
    );
  }
}

//[{lat: 37.4219983, lng: 37.4219983}, {lat: 37.4219983, lng: 37.4219983}]
