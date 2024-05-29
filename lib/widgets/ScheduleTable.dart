import 'package:flutter/material.dart';
import 'package:maia_app/providers/api_provider.dart';
import 'package:maia_app/theme/app_theme.dart';

class ScheduleTable extends StatelessWidget {
  const ScheduleTable({
    Key? key,
    required this.apiProvider,
    required this.isLoading,
  }) : super(key: key);

  final ApiProvider apiProvider;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.softColorB,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Horario de Clases',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          DataTable(
            columns: const [
              DataColumn(label: Text('Clase')),
              DataColumn(label: Text('Aula')),
              DataColumn(label: Text('Hora')),
            ],
            rows: apiProvider.schedule.map((classSchedule) {
              return DataRow(cells: [
                DataCell(Text('${classSchedule.className}')),
                DataCell(Text('${classSchedule.classroomName}')),
                DataCell(Text(
                    '${classSchedule.startTime} - ${classSchedule.endTime}')),
              ]);
            }).toList(),
          ),
        ],
      ),
    );
  }
}
