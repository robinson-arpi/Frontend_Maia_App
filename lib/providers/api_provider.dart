import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maia_app/models/node.dart';
import 'package:maia_app/models/schedule.dart';
import 'package:maia_app/models/path.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiProvider with ChangeNotifier {
  final String apiUrl; // URL base para la API
  int id = -1;
  String name = "NoName";
  List<Schedule> schedule = [];
  List<Node> nodes = [];
  List<Path> path = [];
  String currentDay = getDay();

  //Details about activity
  int? startNodeId;
  int? endNodeId;
  Schedule? nextActivity;

  // Atributo para el estado de autenticación
  bool _isLoggedIn = false;
  // Métodos para obtener el estado de autenticación
  bool get isLoggedIn => _isLoggedIn;
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Constructor que recibe la URL base como parámetro
  ApiProvider(this.apiUrl);

  Future<void> getNodes() async {
    try {
      // Realiza una solicitud HTTP GET a la URL base más la ruta específica del horario de clases
      final result = await http.get(Uri.parse('$apiUrl/graph/nodes'));

      // Verifica si la solicitud fue exitosa (código de estado 200)
      if (result.statusCode == 200) {
        // Parsea la respuesta JSON y la asigna a la lista de horarios de clases
        final response = nodeFromJson(result.body);
        nodes = response.nodes ?? [];
        // Notifica a los oyentes (listeners) que los datos han sido actualizados
        notifyListeners();
      } else {
        throw Exception('Error en la solicitud HTTP: ${result.statusCode}');
      }
    } catch (error) {
      print('Error en la solicitud HTTP: $error');
    }
  }

  // Método para obtener el horario de clases
  Future<void> getClassSchedule() async {
    try {
      // Realiza una solicitud HTTP GET a la URL base más la ruta específica del horario de clases
      final result =
          await http.get(Uri.parse('$apiUrl/schedule/$id/$currentDay'));

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

          // Guardar las credenciales de manera segura
          await _storage.write(key: 'email', value: email);
          await _storage.write(key: 'password', value: password);

          _isLoggedIn = true;
          notifyListeners();

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

  void logout() {
    // Lógica de cierre de sesión aquí
    // Actualiza el estado de autenticación
    _isLoggedIn = false;
    notifyListeners();
  }

  Future<void> getPath(int start, int end) async {
    try {
      // Realiza una solicitud HTTP GET a la URL base más la ruta específica del horario de clases
      final result =
          await http.get(Uri.parse('$apiUrl/graph/shortestPath/$start/$end'));

      // Verifica si la solicitud fue exitosa (código de estado 200)
      if (result.statusCode == 200) {
        // Parsea la respuesta JSON y la asigna a la lista de horarios de clases
        final response = pathFromJson(result.body);
        path = response;
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
}

String getDay() {
  initializeDateFormatting(); // Inicializa la fecha actual
  String day = DateFormat('EEEE', 'es').format(DateTime.now());
  //return day[0].toUpperCase() + day.substring(1);
  return "Martes";
}
