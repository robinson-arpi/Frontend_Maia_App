// To parse this JSON data, do
//
//     final path = pathFromJson(jsonString);

import 'dart:convert';

List<Path> pathFromJson(String str) =>
    List<Path>.from(json.decode(str).map((x) => Path.fromJson(x)));

String pathToJson(List<Path> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Path {
  First? first;
  String? second;

  Path({
    this.first,
    this.second,
  });

  factory Path.fromJson(Map<String, dynamic> json) => Path(
        first: json["first"] == null ? null : First.fromJson(json["first"]),
        second: json["second"],
      );

  Map<String, dynamic> toJson() => {
        "first": first?.toJson(),
        "second": second,
      };
}

class First {
  int? nodeId;
  String? name;

  First({
    this.nodeId,
    this.name,
  });

  factory First.fromJson(Map<String, dynamic> json) => First(
        nodeId: json["nodeId"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "nodeId": nodeId,
        "name": name,
      };
}
