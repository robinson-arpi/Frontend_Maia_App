import 'package:intl/intl.dart';
import 'package:maia_app/monitoring/interactionMiddelware.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:maia_app/monitoring/storage.dart';
import 'package:maia_app/monitoring/preventiveSecurity.dart';

class InteractionGathering {
  List<InteractionController> _observers = [];
  stt.SpeechToText _speech = stt.SpeechToText();
  PreventiveSecurity _preventiveSecurity = PreventiveSecurity();

  bool _isListening = true;
  List<dynamic> parameters = [];

  void addObserver(InteractionController observer) {
    _observers.add(observer);
  }

  void notifyObservers(String type, String action, double value) {
    for (var observer in _observers) {
      observer.update(type, action, value, parameters);
    }
  }

  //Functions responsible for capturing interactions in the views
  //User
  void handleGUI(String order, double value) {
    notifyObservers("GUI", order, value);
  }

  void handleVoiceCommand(String order, double value) {
    notifyObservers("voice", order, value);
  }

  //Ambient
  void checkLightLevel(String action, int luxValue) {
    notifyObservers("ligth", action, luxValue as double);
  }

  //Aditionals
  void checkVolumeLevel(String order, double volume) {
    notifyObservers("volume", order, volume);
  }

  void changeListening() {
    _isListening = !_isListening;
    if (_isListening) {
      _preventiveSecurity.showRecordingNotification();
    }
  }

  void listen() async {
    if (_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        _speech.listen(
          onResult: (val) {
            print("\n-----------------------");
            print(val.recognizedWords.toLowerCase());
            if (val.recognizedWords.toLowerCase().contains("cómo llegar")) {
              handleVoiceCommand("comoLlegar", 1);
            } else if (val.recognizedWords
                .toLowerCase()
                .contains("detalles de próxima actividad")) {
              handleVoiceCommand("detailsOfNextActivity", 1);
            }
          },
        );
      } else {
        print("no disponible");
      }
    } else {
      print("no se graba");
    }
  }
}
