import 'dart:convert';

List<List_Location> listLocationFromJson(String str) => List<List_Location>.from(json.decode(str).map((x) => List_Location.fromJson(x)));

String listLocationToJson(List<List_Location> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class List_Location {
    double lat;
    double long;

    List_Location({
        this.lat,
        this.long,
    });

    factory List_Location.fromJson(Map<String, dynamic> json) => List_Location(
        lat: json["lat"].toDouble(),
        long: json["long"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "lat": lat,
        "long": long,
    };
}
