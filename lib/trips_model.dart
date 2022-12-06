import 'package:intl/intl.dart';

class Trips {
  int _id;
  String _time;
  String _path;
  String _type;

  Trips(this._time, this._path, this._type);

  Trips.withId(this._id, this._time, this._path);

  int get id => _id;

  String get time => _time;

  String get path => _path;

  String get type => _type;

  set time(String newtime) {
      this._time = newtime;
  }

  set path(String newpath) {
    this._path = newpath;
  }

  set type(String newtype) {
    this._type = newtype;
  }

  // Convert a Trips object into a Map object
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = _id;
    }
    map['time'] = _time;

    map['path'] = _path;

    map['type'] = _type;

    return map;
  }

  // Extract a Trips object from a Map object
  Trips.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._time = map['time'];
    this._path = map['path'];
    this._type = map['type'];
  }
}
