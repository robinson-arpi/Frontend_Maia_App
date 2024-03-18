import 'package:flutter/material.dart';
import 'package:maia_app/models/schedule.dart';
import 'package:http/http.dart' as http;

class ApiProvider with ChangeNotifier {
  final url = 'http://localhost:8080';

  List<Schedule> schedule = [];

  Future<void> getClassSchedule() async {
    final result = await http.get(Uri.parse('$url/schedule/6'));
    final response = classScheduleFromJson(result.body);
    schedule
        .addAll(response.schedule ?? []); // Aquí accedemos a response.schedule
    notifyListeners();
  }
}
