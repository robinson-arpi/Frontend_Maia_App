import 'package:flutter/material.dart';
import 'package:maia_app/models/schedule.dart';
import 'package:http/http.dart' as http;

class ApiProvider with ChangeNotifier {
  final String apiUrl; // URL base para la API

  List<Schedule> schedule = [];

  // Constructor que recibe la URL base como parámetro
  ApiProvider(this.apiUrl);

  // Método para obtener el horario de clases
  Future<void> getClassSchedule() async {
    try {
      // Realiza una solicitud HTTP GET a la URL base más la ruta específica del horario de clases
      final result = await http.get(Uri.parse('$apiUrl/schedule/6/Lunes'));

      // Verifica si la solicitud fue exitosa (código de estado 200)
      if (result.statusCode == 200) {
        // Parsea la respuesta JSON y la asigna a la lista de horarios de clases
        final response = classScheduleFromJson(result.body);
        print(response);
        schedule = response.schedule ?? [];
        // Notifica a los oyentes (listeners) que los datos han sido actualizados
        notifyListeners();
      } else {
        // Si la solicitud no fue exitosa, lanza una excepción con el código de estado
        throw Exception('Error en la solicitud HTTP: ${result.statusCode}');
      }
    } catch (error) {
      // Captura cualquier error que ocurra durante la solicitud HTTP
      print('Error en la solicitud HTTP: $error');
      // Maneja el error según sea necesario
    }
  }
}
