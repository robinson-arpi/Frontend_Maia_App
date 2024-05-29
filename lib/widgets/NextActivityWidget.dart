import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maia_app/models/schedule.dart';
import 'package:maia_app/monitoring/informationGathering.dart';
import 'package:maia_app/theme/app_theme.dart';

class NextActivityWidget extends StatelessWidget {
  const NextActivityWidget({
    Key? key,
    required this.activity,
    required this.currentDay,
    required this.clockStream,
    required this.interactionGathering,
  }) : super(key: key);

  final Schedule activity;
  final String currentDay;
  final Stream<DateTime> clockStream;
  final InteractionGathering interactionGathering;

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
            "Día: $currentDay",
            style: const TextStyle(fontSize: 18),
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
          ElevatedButton(
            onPressed: () => interactionGathering.handleGUI("goMap", 1),
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(AppTheme.strongColorA),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              overlayColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.pressed)) {
                    return AppTheme.strongColorA.withOpacity(0.5);
                  }
                  return null;
                },
              ),
            ),
            child: const Text(
              'Cómo llegar?',
              style: TextStyle(color: AppTheme.softColorB),
            ),
          ),
        ],
      ),
    );
  }
}
