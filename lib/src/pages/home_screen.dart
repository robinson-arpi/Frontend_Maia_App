import 'package:flutter/material.dart';
import 'package:maia_app/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:maia_app/providers/api_provider.dart';
import 'package:maia_app/models/schedule.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final scrollController = ScrollController();
  bool isLoading = false;
  Schedule? nextActivity;
  String currentDate = "";

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

    // Actualiza la próxima actividad al inicio
    updateNextActivity();
    print("Luego de priemr vez");
    // Actualiza la próxima actividad cada minuto
    Timer.periodic(Duration(minutes: 1), (timer) {
      updateNextActivity();
    });

    // Inicializa la fecha actual
    initializeDateFormatting();

    currentDate = DateFormat('EEEE', 'es').format(DateTime.now());
  }

  void updateNextActivity() {
    print("Ejecuta nex activity");
    final apiProvider = Provider.of<ApiProvider>(context, listen: false);
    final List<Schedule> schedule = apiProvider.schedule;
    final TimeOfDay now = TimeOfDay.now(); // Obtén la hora actual
    Schedule? next;
    print(next);
    for (final activity in schedule) {
      final activityTime = TimeOfDay.fromDateTime(DateFormat('HH:mm:ss')
          .parse(activity.startTime!)); // Parsea la cadena de hora
      if (activityTime.hour > now.hour ||
          (activityTime.hour == now.hour && activityTime.minute > now.minute)) {
        next = activity;
        print("Nueva actividad");
        break;
      }
      print("Sin nueva actividad");
    }
    print("Acabo");
    setState(() {
      nextActivity = next;
    });
  }

  @override
  Widget build(BuildContext context) {
    final apiProvider = Provider.of<ApiProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("HORARIO DE CLASES",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: AppTheme.softColorA,
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

  get currentDate => null;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Próxima actividad: ${currentDate}",
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
