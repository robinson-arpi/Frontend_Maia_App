import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maia_app/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:maia_app/providers/api_provider.dart';
import 'package:maia_app/models/schedule.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final scrollController = ScrollController();
  bool isLoading = false;
  Schedule? nextActivity;
  String currentDate = "";
  late stt.SpeechToText _speech;
  bool _isListening = false;
  FlutterTts flutterTts = FlutterTts();
  late ApiProvider apiProvider;
  bool isFirstTime = true;

  // Stream para la hora actual
  late Stream<DateTime> _clockStream;

  @override
  void initState() {
    super.initState();
    apiProvider = Provider.of<ApiProvider>(context, listen: false);
    _speech = stt.SpeechToText();
    apiProvider.getClassSchedule().then((_) {
      updateNextActivity();
    });
    // Actualiza la próxima actividad cada minuto
    Timer.periodic(const Duration(minutes: 1), (_) {
      updateNextActivity();
    });

    // Crear el Stream para la hora actual una vez
    _clockStream =
        Stream<DateTime>.periodic(Duration(seconds: 1), (_) => DateTime.now());
  }

  @override
  void dispose() {
    if (_isListening) {
      _speech.stop();
    }
    super.dispose();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            if (val.recognizedWords.toLowerCase().contains("cómo llegar")) {
              _speech.stop();
              setState(() => _isListening = false);
              context.go('/map');
            } else if (val.recognizedWords
                .toLowerCase()
                .contains("próxima actividad")) {
              _speech.stop();
              setState(() => _isListening = false);
              _speakNextActivityDetails();
            }
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _speakNextActivityDetails() {
    if (mounted) {
      if (nextActivity != null) {
        String message =
            "La próxima actividad es ${nextActivity!.className} en el aula ${nextActivity!.classroomName} y empieza a las ${nextActivity!.startTime}";
        _speak(message);
      } else {
        _speak("No hay próxima actividad.");
      }
    }
  }

  void _speak(String message) {
    flutterTts.speak(message);
  }

  Future<void> updateNextActivity() async {
    if (!mounted) return; // Verificar si el widget aún está montado

    final apiProvider = Provider.of<ApiProvider>(context, listen: false);
    final List<Schedule> schedule = apiProvider.schedule;

    if (isFirstTime) {
      print("Waiting...");
      await Future.delayed(const Duration(milliseconds: 500));
      isFirstTime = false;
    }

    final TimeOfDay now = TimeOfDay(hour: 6, minute: 30);

    Schedule? next;

    for (final activity in schedule) {
      final activityTime = TimeOfDay.fromDateTime(
          DateFormat('HH:mm:ss').parse(activity.startTime!));

      if (activityTime.hour > now.hour ||
          (activityTime.hour == now.hour && activityTime.minute > now.minute)) {
        next = activity;
        break;
      }
      print("No new activity");
    }
    print(next?.className);

    setState(() {
      nextActivity = next;
      print("-------------------\nSetting new activity");
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
          style: Theme.of(context).textTheme.headline6,
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: AppTheme.softColorB,
      ),
      body: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: NextActivityWidget(
              nextActivity: nextActivity ??
                  Schedule(className: "Sin próximas actividades"),
              currentDay: apiProvider.currentDay,
              clockStream: _clockStream, // Pasar el Stream al widget
            ),
          ),
          if (apiProvider.schedule.isNotEmpty)
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: ScheduleTable(
                apiProvider: apiProvider,
                isLoading: isLoading,
              ),
            ),
          if (nextActivity == null && apiProvider.schedule.isEmpty)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _listen,
        child: Icon(_isListening ? Icons.mic : Icons.mic_none),
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
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.softColorB,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(10),
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
    required this.clockStream,
  }) : super(key: key);

  final Schedule nextActivity;
  final String currentDay;
  final Stream<DateTime> clockStream;

  void _map(BuildContext context) async {
    try {
      context.go('/map');
    } catch (error) {
      print('Error during navigation: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error navigating')),
      );
    }
  }

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
            "${nextActivity.className} - ${nextActivity.startTime} - ${nextActivity.endTime}",
            style: const TextStyle(fontSize: 18),
          ),
          Text(
            "Profesor(a): ${nextActivity.professorFirstName} ${nextActivity.professorLastName}",
            style: const TextStyle(fontSize: 18),
          ),
          Text(
            "Aula: ${nextActivity.classroomName}",
            style: const TextStyle(fontSize: 18),
          ),
          // Widget para mostrar la hora actual
          // Widget para mostrar el tiempo restante antes de que comience la próxima actividad
          StreamBuilder<DateTime>(
            stream: clockStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final now = snapshot.data!;
                final currentDateTime = DateTime(now.year, now.month, now.day,
                    now.hour, now.minute, now.second);
                final activityTime =
                    DateFormat('HH:mm:ss').parse(nextActivity.startTime!);

                final activityStartTime = DateTime(
                    currentDateTime.year,
                    currentDateTime.month,
                    currentDateTime.day,
                    activityTime.hour,
                    activityTime.minute,
                    activityTime.second);

                final difference =
                    activityStartTime.difference(currentDateTime).abs();

                final hours = 23 - difference.inHours;
                final minutes = 59 - difference.inMinutes.remainder(60);
                final seconds = 59 - difference.inSeconds.remainder(60);

                return Text(
                  "Tiempo restante: $hours horas $minutes minutos $seconds segundos",
                  style: const TextStyle(fontSize: 18),
                );
              } else {
                return const Text(
                  "No se han cargado datos aún",
                  style: const TextStyle(fontSize: 18),
                );
              }
            },
          ),
          ElevatedButton(
            onPressed: () => _map(context),
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
              'Guía',
              style: TextStyle(color: AppTheme.softColorB),
            ),
          ),
        ],
      ),
    );
  }
}
