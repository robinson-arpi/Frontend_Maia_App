import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:maia_app/models/schedule.dart';
import 'package:http/http.dart' as http;

class ApiProvider with ChangeNotifier {
  final String apiUrl; // URL base para la API
  int id = -1;
  String name = "NoName";
  List<Schedule> schedule = [];

  // Constructor que recibe la URL base como parámetro
  ApiProvider(this.apiUrl);

  // Método para obtener el horario de clases
  Future<void> getClassSchedule() async {
    try {
      // Realiza una solicitud HTTP GET a la URL base más la ruta específica del horario de clases
      final result = await http.get(Uri.parse('$apiUrl/schedule/$id/Lunes'));

      // Verifica si la solicitud fue exitosa (código de estado 200)
      if (result.statusCode == 200) {
        // Parsea la respuesta JSON y la asigna a la lista de horarios de clases
        final response = classScheduleFromJson(result.body);
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
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/auth/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        String responseBody = response.body;
        // Convertir el JSON a un mapa
        Map<String, dynamic> data = json.decode(responseBody);

        if (data.containsKey('id')) {
          id = data['id'];
          name = data['name'];
          //print("ID encontrado: $id --- $name");
        } else {
          print("No se encontró el campo 'id' en la respuesta.");
        }
        return jsonDecode(response.body);
      } else {
        // Si la solicitud no fue exitosa, lanza una excepción con el mensaje de error recibido del servidor
        throw Exception('Error durante la autenticación: ${response.body}');
      }
    } catch (error) {
      // Maneja cualquier error que pueda ocurrir durante la solicitud HTTP
      throw Exception('Error durante la solicitud HTTP: $error');
    }
  }
}
