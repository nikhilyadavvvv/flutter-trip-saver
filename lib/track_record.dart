import 'package:flutter/material.dart';
import 'package:map_app/list_location.dart';
import 'package:map_app/trace_map.dart';

class TrackRecord extends StatefulWidget {
  List<List_Location> ll;
  TrackRecord({Key key, this.ll}) : super(key: key);
  @override
  _TrackRecordState createState() => _TrackRecordState();
}

class _TrackRecordState extends State<TrackRecord> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: listbuild(context),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Tracemap(
                ll: widget.ll,
              ),
            ),
          );
        },
        child: Icon(Icons.linear_scale),
      )
    );
  }

  Widget listbuild(BuildContext context) {
    List<List_Location> ll = widget.ll;
    return ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: ll.length,
      shrinkWrap: true,
      //primary: false,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          leading: new Text(ll[index].lat.toString()),
          trailing: new Text(ll[index].long.toString()),
          onTap: () => {},
        );
      },
    );
  }
}
/*
 points.add(_createLatLng(50.546399 + offset, 9.673536));
    points.add(_createLatLng(50.543991 + offset, 9.675844));
    points.add(_createLatLng(50.544093 + offset, 9.674594));
    */