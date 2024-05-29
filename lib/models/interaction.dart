class Interaction {
  final int id;
  final String type;
  final String action;
  final double value;
  final int timestamp;

  Interaction({
    required this.id,
    required this.type,
    required this.action,
    required this.value,
    required this.timestamp,
  });

  factory Interaction.fromMap(Map<String, dynamic> map) {
    return Interaction(
      id: map['id'],
      type: map['type'],
      action: map['action'],
      value: map['value'],
      timestamp: map['timestamp'],
    );
  }
}
