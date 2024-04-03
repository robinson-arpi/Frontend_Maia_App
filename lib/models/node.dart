// To parse this JSON data, do
//
//     final node = nodeFromJson(jsonString);

import 'dart:convert';

Nodes nodeFromJson(String str) => Nodes.fromJson(json.decode(str));

String nodeToJson(Nodes data) => json.encode(data.toJson());

class Nodes {
  List<Node>? nodes;

  Nodes({
    this.nodes,
  });

  factory Nodes.fromJson(Map<String, dynamic> json) => Nodes(
        nodes: json["nodes"] == null
            ? []
            : List<Node>.from(
                json["nodes"]!.map((x) => Node.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "nodes": nodes == null
            ? []
            : List<dynamic>.from(nodes!.map((x) => x.toJson())),
      };
}

class Node {
  int? nodeId;
  String? name;

  Node({
    this.nodeId,
    this.name,
  });

  factory Node.fromJson(Map<String, dynamic> json) => Node(
        nodeId: json["nodeId"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "nodeId": nodeId,
        "name": name,
      };
}
