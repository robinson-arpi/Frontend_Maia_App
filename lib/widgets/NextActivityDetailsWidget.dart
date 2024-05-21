import 'package:flutter/material.dart';
import 'package:maia_app/models/schedule.dart'; // Importa el modelo Schedule si no lo has importado aún

class NextActivityDetailsWidget extends StatelessWidget {
  final Schedule? activity;
  const NextActivityDetailsWidget({Key? key, required this.activity})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (activity != null) {
      // Si nextActivity no es nulo, muestra los detalles de la próxima actividad
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Próxima actividad:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text('Inicio: ${activity!.startTime}'),
            Text('Fin: ${activity!.endTime}'),
            Text('Lugar: ${activity!.classroomName}'),
          ],
        ),
      );
    } else {
      // Si nextActivity es nulo, muestra un mensaje indicando que no hay próxima actividad
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          'No hay próxima actividad.',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      );
    }
  }
}
