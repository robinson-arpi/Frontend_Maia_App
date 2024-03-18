import 'package:flutter/material.dart';
import 'package:maia_app/models/schedule.dart';
import 'package:http/http.dart' as http;

class ApiProvider with ChangeNotifier {
  final url = 'localhost:8080';

  List<Schedule> schedule = [];

  Future<void> getClassSchedule(int page) async {
    final result = await http.get(Uri.https(url, "/schedule/6"));
    final response = classScheduleFromJson(result.body);
    schedule.addAll(response.results!);
    notifyListeners();
  }
}
