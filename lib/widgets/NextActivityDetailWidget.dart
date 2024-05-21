import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maia_app/models/schedule.dart';

class NextActivityDetailWidget extends StatelessWidget {
  const NextActivityDetailWidget({
    Key? key,
    required this.activity,
    required this.clockStream,
  }) : super(key: key);

  final Schedule activity;
  final Stream<DateTime> clockStream;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Próxima actividad",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            "${activity.className} - ${activity.startTime} - ${activity.endTime}",
            style: const TextStyle(fontSize: 18),
          ),
          Text(
            "Profesor(a): ${activity.professorFirstName} ${activity.professorLastName}",
            style: const TextStyle(fontSize: 18),
          ),
          Text(
            "Aula: ${activity.classroomName}",
            style: const TextStyle(fontSize: 18),
          ),
          StreamBuilder<DateTime>(
            stream: clockStream,
            builder: (context, snapshot) {
              try {
                if (snapshot.hasData) {
                  final now = snapshot.data!;
                  final currentDateTime = DateTime(now.year, now.month, now.day,
                      now.hour, now.minute, now.second);
                  final activityTime =
                      DateFormat('HH:mm:ss').parse(activity.startTime!);

                  final activityStartTime = DateTime(
                      currentDateTime.year,
                      currentDateTime.month,
                      currentDateTime.day,
                      activityTime.hour,
                      activityTime.minute,
                      activityTime.second);

                  final difference =
                      activityStartTime.difference(currentDateTime).abs();

                  final hours = difference.inHours;
                  final minutes = difference.inMinutes.remainder(60);
                  final seconds = difference.inSeconds.remainder(60);
                  return Text(
                    "Tiempo restante: $hours horas $minutes minutos $seconds segundos",
                    style: const TextStyle(fontSize: 18),
                  );
                } else if (snapshot.hasError) {
                  return Text(
                    "Error: ${snapshot.error}",
                    style: const TextStyle(fontSize: 18),
                  );
                } else {
                  return const Text(
                    "No se han cargado datos aún",
                    style: const TextStyle(fontSize: 18),
                  );
                }
              } catch (e) {
                // Capturar cualquier excepción que ocurra al acceder a snapshot.data
                print("Error al acceder a snapshot.data: $e");
                return const Text(
                  "Error al acceder a los datos",
                  style: const TextStyle(fontSize: 18),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
