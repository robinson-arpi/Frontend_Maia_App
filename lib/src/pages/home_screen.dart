import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maia_app/providers/api_provider.dart';
import 'package:maia_app/models/schedule.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final scrollController = ScrollController();
  bool isLoading = false;
  Schedule? nextActivity;

  @override
  void initState() {
    super.initState();
    final apiProvider = Provider.of<ApiProvider>(context, listen: false);
    apiProvider.getClassSchedule();
    scrollController.addListener(() async {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        setState(() {
          isLoading = true;
        });

        await apiProvider.getClassSchedule();
        setState(() {
          isLoading = false;
        });
      }
    });

    // Actualiza la próxima actividad cada minuto
    Timer.periodic(Duration(minutes: 1), (timer) {
      updateNextActivity();
    });
    // Actualiza la próxima actividad al inicio
    updateNextActivity();
  }

  void updateNextActivity() {
    final apiProvider = Provider.of<ApiProvider>(context, listen: false);
    final List<Schedule> schedule = apiProvider.schedule;
    final TimeOfDay now = TimeOfDay.now(); // Obtén la hora actual
    Schedule? next;
    for (final activity in schedule) {
      final activityTime = TimeOfDay.fromDateTime(DateFormat('HH:mm:ss')
          .parse(activity.startTime!)); // Parsea la cadena de hora
      if (activityTime.hour > now.hour ||
          (activityTime.hour == now.hour && activityTime.minute > now.minute)) {
        next = activity;
        break;
      }
    }
    setState(() {
      nextActivity = next;
    });
  }

  @override
  Widget build(BuildContext context) {
    final apiProvider = Provider.of<ApiProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Horario de clases",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          if (nextActivity != null)
            NextActivityWidget(nextActivity: nextActivity!),
          if (apiProvider.schedule.isNotEmpty)
            ScheduleTable(
              apiProvider: apiProvider,
              isLoading: isLoading,
            ),
          if (nextActivity == null && apiProvider.schedule.isEmpty)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

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
    return Expanded(
      child: DataTable(
        columns: [
          DataColumn(label: Text('Clase')),
          DataColumn(label: Text('Aula')),
          DataColumn(label: Text('Hora')),
        ],
        rows: apiProvider.schedule.map((classSchedule) {
          return DataRow(cells: [
            DataCell(Text('${classSchedule.className}')),
            DataCell(Text('${classSchedule.classroomName}')),
            DataCell(
                Text('${classSchedule.startTime} - ${classSchedule.endTime}')),
          ]);
        }).toList(),
      ),
    );
  }
}

class NextActivityWidget extends StatelessWidget {
  const NextActivityWidget({
    Key? key,
    required this.nextActivity,
  }) : super(key: key);

  final Schedule nextActivity;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Próxima actividad:",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          "${nextActivity.className} - ${nextActivity.startTime} - ${nextActivity.endTime}",
          style: TextStyle(fontSize: 18),
        ),
      ],
    );
  }
}
