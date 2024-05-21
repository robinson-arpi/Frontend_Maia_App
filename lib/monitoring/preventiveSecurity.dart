import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PreventiveSecurity {
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
