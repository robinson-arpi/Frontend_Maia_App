import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:maia_app/models/schedule.dart';
import 'package:maia_app/monitoring/preventiveSecurity.dart';
import 'package:maia_app/monitoring/storage.dart';
//import 'package:speech_to_text/speech_to_text.dart' as stt;

abstract class Observer {
  void update(
      String type, String action, double value, List<dynamic> parameters);
}

class InteractionMiddelware implements Observer {
  //stt.SpeechToText _speech = stt.SpeechToText();
  FlutterTts flutterTts = FlutterTts();
  PreventiveSecurity _preventiveSecurity = PreventiveSecurity();

  @override
  void update(
      String type, String action, double value, List<dynamic> parameters) {
    _logInteraction(type, action, value);

    switch (type) {
      case 'GUI':
        GUIController(action, parameters);
        break;
      case 'voice':
        VoiceController(action, parameters);
        break;
      case 'volume':
        SensorController(parameters[0]);
        break;
      case 'light':
        _handleLightChange(parameters[0]);
        break;
      default:
        break;
    }
  }

  void GUIController(String action, List<dynamic> parameters) {
    switch (action) {
      case 'goMap':
        BuildContext context = parameters[0];
        Schedule activity = parameters[1];
        _goMap(context, activity);
        break;
      case 'backHome':
        BuildContext context = parameters[0];
        Schedule activity = parameters[1];
        _goHome(context, activity);
        break;
      default:
        break;
    }
  }

  void VoiceController(String action, List<dynamic> parameters) {
    switch (action) {
      case 'comoLlegar':
        BuildContext context = parameters[0];
        Schedule activity = parameters[1];
        _goMap(context, activity);
        break;
      case 'detallesDeActividad':
        Schedule activity = parameters[0];
        _speakActivity(activity);
        break;
      default:
        break;
    }
  }

  void SensorController(double volume) {
    _preventiveSecurity.volumeSecurity(volume, 0.8);

    // print("El volumen ha cambiado: $volume");
  }

  void _handleLightChange(int luxValue) {
    print("Lux value: $luxValue");
  }

  void _goHome(BuildContext context, Schedule activity) async {
    try {
      context.go('/home');
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error navigating')),
      );
    }
  }

  void _goMap(BuildContext context, Schedule activity) async {
    try {
      context.go('/map', extra: activity);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error navigating')),
      );
    }
  }

  void _speakActivity(Schedule activity) {
    String message =
        "La próxima actividad es ${activity.className} en el aula ${activity.classroomName} y empieza a las ${activity.startTime}";
    speak(message);
  }

  void speak(String message) {
    flutterTts.speak(message);
  }

  void _logInteraction(String type, String action, double valor) async {
    final int timestamp = DateTime.now().millisecondsSinceEpoch;
    await Storage.insertInteraction(type, action, valor, timestamp);
  }
}
