import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maia_app/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:maia_app/providers/api_provider.dart';
import 'package:maia_app/models/schedule.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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

    // Actualiza la próxima actividad cada minuto
    Timer.periodic(const Duration(minutes: 1), (timer) {
      updateNextActivity();
    });

    initializeDateFormatting(); // Inicializa la fecha actual
    currentDate = DateFormat('EEEE', 'es').format(DateTime.now());
  }

  void updateNextActivity() {
    if (!mounted) return; // Comprueba si el widget está montado

    final apiProvider = Provider.of<ApiProvider>(context, listen: false);
    final List<Schedule> schedule = apiProvider.schedule;
    final TimeOfDay now = TimeOfDay.now(); // Obtén la hora actual
    Schedule? next;

    for (final activity in schedule) {
      final activityTime = TimeOfDay.fromDateTime(DateFormat('HH:mm:ss')
          .parse(activity.startTime!)); // Parsea la cadena de hora

      print("Control");

      if (activityTime.hour > now.hour ||
          (activityTime.hour == now.hour && activityTime.minute > now.minute)) {
        next = activity;
        print("Nueva actividad");
        break;
      }
      print("Sin nueva actividad");
    }
    print(next?.className);

    setState(() {
      nextActivity = next;
    });
  }

  @override
  Widget build(BuildContext context) {
    final apiProvider = Provider.of<ApiProvider>(context);
    return Scaffold(
      backgroundColor: AppTheme.softColorA,
      appBar: AppBar(
        title: Text(
          "Hola, ${apiProvider.name}",
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: AppTheme.softColorB,
      ),
      body: Column(
        children: [
          // Siempre muestra el widget NextActivityWidget
          SizedBox(
            width: MediaQuery.of(context).size.width, // Ancho de la pantalla
            child: NextActivityWidget(
              nextActivity: nextActivity ??
                  Schedule(className: "Sin próximas actividades"),
              currentDay: currentDate,
            ),
          ),
          if (apiProvider.schedule.isNotEmpty)
            ScheduleTable(
              apiProvider: apiProvider,
              isLoading: isLoading,
            ),
          if (nextActivity == null && apiProvider.schedule.isEmpty)
            const Center(
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
        columns: const [
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
    required this.currentDay,
  }) : super(key: key);

  final Schedule nextActivity;
  final String currentDay;

  void _map(BuildContext context) async {
    try {
      context.go('/map');
    } catch (error) {
      // Manejar cualquier error que pueda ocurrir durante la autenticación
      print('Error durante la autenticación: $error');
      // Mostrar un mensaje de error al usuario, por ejemplo:
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error map')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Color de fondo blanco
        borderRadius: BorderRadius.circular(10), // Esquinas redondeadas
      ),
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
            "${nextActivity.className} - ${nextActivity.startTime} - ${nextActivity.endTime}",
            style: const TextStyle(fontSize: 18),
          ),
          ElevatedButton(
            onPressed: () => _map(context),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                  AppTheme.strongColorA), // Fondo del botón azul
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10), // Bordes menos redondeados
                ),
              ),
              overlayColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.pressed)) {
                    return AppTheme.strongColorA
                        .withOpacity(0.5); // Color de sombreado al presionar
                  }
                  return null; // No hay sombreado en otros estados
                },
              ),
            ),
            child: const Text(
              'Guía',
              style: TextStyle(
                  color: AppTheme.softColorB), // Color de texto blanco
            ),
          ),
        ],
      ),
    );
  }
}
