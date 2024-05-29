import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PreventiveSecurity {
  void volumeSecurity(double volume, double limit) {
    if (volume > limit) {
      showVolumeWarningToast();
    }
  }

  void brightnessSecurity(double brightness, double limit) {
    if (brightness > limit) {
      showBrightnessWarningToast();
    }
  }

  void showVolumeWarningToast() {
    Fluttertoast.showToast(
      msg:
          '¡Cuidado con el volumen!\nEl volumen está demasiado alto y puede dañar tu capacidad auditiva.',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  void showBrightnessWarningToast() {
    Fluttertoast.showToast(
      msg:
          '¡Cuidado con el nivel d e brillo!\nEl brillo está demasiado alto y puede ocasioanr fatiga visual.',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  void showRecordingNotification() {
    Fluttertoast.showToast(
      msg: 'Aunque se  está grabando. No se almacenna tus comentarios.',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
    );
  }
}
