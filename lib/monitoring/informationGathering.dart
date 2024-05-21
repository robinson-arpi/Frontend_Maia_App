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

  void notifyObservers(String type, String action) {
    for (var observer in _observers) {
      observer.update(type, action, parameters);
    }
  }

  void handleGUIClick(String order) {
    notifyObservers("GUI", order);
    _logInteraction("GUI", order, 1);
  }

  void handleVoiceCommand(String order) {
    notifyObservers("voice", order);
    _logInteraction("voice", order, 1);
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
              handleVoiceCommand("comoLlegar");
            } else if (val.recognizedWords
                .toLowerCase()
                .contains("detalles de próxima actividad")) {
              handleVoiceCommand("detailsOfNextActivity");
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

  void checkVolumeLevel(double volume) {
    _logInteraction("volume", "change", volume);
    if (volume > 0.8) {
      _preventiveSecurity.showVolumeWarningToast();
    }
  }

  void checkLightLevel(int luxValue) {
    _logInteraction("ligth", "change", luxValue as double);
  }

  void _logInteraction(String type, String action, double valor) async {
    final String timestamp =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    await Storage.insertInteraction(type, action, valor, timestamp);
  }
}
