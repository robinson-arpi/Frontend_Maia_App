import 'dart:io';
import 'package:xml/xml.dart' as xml;

class DescriptiveModel {
  SystemState systemState = SystemState();
  EnvironmentState environmentState = EnvironmentState();
  List<UserStatus> userInteractions = [];
  AppState appState = AppState();

  DescriptiveModel() {
    loadFromXml();
  }

  void loadFromXml() {
    try {
      // Ruta al archivo XML del modelo descriptivo
      File file = File('lib/model/descriptiveModel.xml');
      String xmlString = file.readAsStringSync();

      // Analizar el XML
      final document = xml.XmlDocument.parse(xmlString);
      final descriptiveModel =
          document.findAllElements('DescriptiveModel').first;

      // Obtener los elementos y atributos del XML
      for (var child in descriptiveModel.children) {
        if (child is xml.XmlElement) {
          switch (child.name.local) {
            case 'SystemState':
              systemState.loadFromXml(child);
              break;
            case 'EnvironmentState':
              environmentState.loadFromXml(child);
              break;
            case 'UserInteractions':
              for (var userStatusElement in child.children) {
                if (userStatusElement is xml.XmlElement) {
                  UserStatus userStatus = UserStatus();
                  userStatus.loadFromXml(userStatusElement);
                  userInteractions.add(userStatus);
                }
              }
              break;
            case 'AppState':
              appState.loadFromXml(child);
              break;
            default:
              break;
          }
        }
      }
    } catch (e) {
      print('Error al cargar el modelo descriptivo: $e');
    }
  }
}

class SystemState {
  double responseTimeMax = 0.0;
  double responseTimeCurrent = 0.0;

  void loadFromXml(xml.XmlElement element) {
    responseTimeMax = double.parse(
        element.findElements('ResponseTime').first.getAttribute('max') ??
            '0.0');
    responseTimeCurrent = double.parse(
        element.findElements('ResponseTime').first.getAttribute('current') ??
            '0.0');
  }
}

class EnvironmentState {
  double lightIntensityMin = 0.0;
  double lightIntensityMax = 0.0;
  double lightIntensityCurrent = 0.0;

  void loadFromXml(xml.XmlElement element) {
    lightIntensityMin = double.parse(
        element.findElements('LightIntensity').first.getAttribute('min') ??
            '0.0');
    lightIntensityMax = double.parse(
        element.findElements('LightIntensity').first.getAttribute('max') ??
            '0.0');
    lightIntensityCurrent = double.parse(
        element.findElements('LightIntensity').first.getAttribute('current') ??
            '0.0');
  }
}

class UserStatus {
  String interactionType = '';
  int priority = 0;

  void loadFromXml(xml.XmlElement element) {
    interactionType = element.getAttribute('interactionType') ?? '';
    priority = int.parse(element.getAttribute('priority') ?? '0');
  }
}

class AppState {
  double brightnessIntensityMin = 0.0;
  double brightnessIntensityMax = 0.0;
  double brightnessIntensityCurrent = 0.0;
  String themeValue = '';
  double volumeIntensityMin = 0.0;
  double volumeIntensityMax = 0.0;
  double volumeIntensityCurrent = 0.0;

  void loadFromXml(xml.XmlElement element) {
    brightnessIntensityMin = double.parse(
        element.findElements('BrightnessIntensity').first.getAttribute('min') ??
            '0.0');
    brightnessIntensityMax = double.parse(
        element.findElements('BrightnessIntensity').first.getAttribute('max') ??
            '0.0');
    brightnessIntensityCurrent = double.parse(element
            .findElements('BrightnessIntensity')
            .first
            .getAttribute('current') ??
        '0.0');
    themeValue =
        element.findElements('Theme').first.getAttribute('value') ?? '';
    volumeIntensityMin = double.parse(
        element.findElements('VolumeIntensity').first.getAttribute('min') ??
            '0.0');
    volumeIntensityMax = double.parse(
        element.findElements('VolumeIntensity').first.getAttribute('max') ??
            '0.0');
    volumeIntensityCurrent = double.parse(
        element.findElements('VolumeIntensity').first.getAttribute('current') ??
            '0.0');
  }
}
