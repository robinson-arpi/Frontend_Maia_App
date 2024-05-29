import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maia_app/monitoring/storage.dart';
import 'package:maia_app/theme/app_theme.dart';
import 'package:maia_app/widgets/InteractionTableWidget.dart';
import 'package:maia_app/widgets/NextActivityWidget.dart';
import 'package:maia_app/widgets/ScheduleTable.dart';
import 'package:provider/provider.dart';
import 'package:maia_app/providers/api_provider.dart';
import 'package:maia_app/models/schedule.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:maia_app/monitoring/informationGathering.dart';
import 'package:maia_app/monitoring/interactionMiddelware.dart';
import 'package:volume_watcher/volume_watcher.dart';
import 'package:light/light.dart';
import 'package:maia_app/monitoring/preventiveSecurity.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final scrollController = ScrollController();

  bool _isListening = true;
  FlutterTts flutterTts = FlutterTts();
  late ApiProvider apiProvider;
  bool isFirstTime = true;
  late Stream<DateTime> _clockStream;

  final InteractionGathering _interactionGathering = InteractionGathering();
  final InteractionController _interactionController = InteractionController();

  //late BuildContext _ancestorContext;
  double currentVolume = 0.0;
  double initVolume = 0.0;
  double maxVolume = 0.0;

  Light? _light;
  StreamSubscription? _lightSubscription;
  int _currentLuxValue = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //_ancestorContext = context;
  }

  @override
  void initState() {
    super.initState();
    _interactionGathering.addObserver(_interactionController);
    _interactionGathering.listen();
    // Inicializa la base de datos
    Storage.init();

    _clockStream =
        Stream<DateTime>.periodic(Duration(seconds: 1), (_) => DateTime.now());
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        apiProvider = Provider.of<ApiProvider>(context, listen: false);
        updateNextActivity();
        Timer.periodic(const Duration(minutes: 1), (_) {
          try {
            updateNextActivity();
          } catch (e) {
            print('Error en la actualización de la próxima actividad: $e');
          }
        });
        _clockStream = Stream<DateTime>.periodic(
            Duration(seconds: 1), (_) => DateTime.now());
        apiProvider.getClassSchedule().then((_) {
          updateNextActivity();
        });
      } catch (e) {
        print('Error al obtener el horario de clase: $e');
      }
    });

    try {
      //VolumeWatcher.addListener(onVolumeChange);
      //initPlatformState();
      //startLightListening();
    } catch (e) {
      print('verga: $e');
    }
  }

  Future<void> initPlatformState() async {
    try {
      VolumeWatcher.hideVolumeView = true;
      initVolume = await VolumeWatcher.getCurrentVolume;
      maxVolume = await VolumeWatcher.getMaxVolume;
    } catch (e) {
      print('Failed to get volume.');
    }

    if (!mounted) return;

    setState(() {
      this.initVolume = initVolume;
      this.maxVolume = maxVolume;
    });
  }

  @override
  void dispose() {
    //VolumeWatcher.removeListener(onVolumeChange as int?);
    stopLightListening();
    super.dispose();
  }

  void onVolumeChange(double volume) {
    setState(() {
      String direction;
      if (volume > currentVolume) {
        direction = "subir";
      } else if (volume < currentVolume) {
        direction = "bajar";
      } else {
        direction = "se mantuvo";
      }
      currentVolume = volume; // Actualizar el volumen actual
      _interactionGathering.checkVolumeLevel(direction, volume);
    });
  }

  void onLightData(int luxValue) {
    setState(() {
      String lightChange;
      if (luxValue > _currentLuxValue) {
        lightChange = "subir";
      } else if (luxValue < _currentLuxValue) {
        lightChange = "bajar";
      } else {
        lightChange = "se mantuvo";
      }
      _currentLuxValue = luxValue; // Actualizar el valor actual de lux
      _interactionGathering.checkLightLevel(lightChange, luxValue);
      print("Lux value: $luxValue, Light change: $lightChange");
    });
  }

  void startLightListening() {
    _light = Light();
    try {
      _lightSubscription = _light?.lightSensorStream.listen(onLightData);
    } on LightException catch (exception) {
      print(exception);
    }
  }

  void stopLightListening() {
    _lightSubscription?.cancel();
  }

  Future<void> updateNextActivity() async {
    if (!mounted) return;
    print("Cargando...");
    final apiProvider = Provider.of<ApiProvider>(context, listen: false);
    final List<Schedule> schedule = apiProvider.schedule;
    final TimeOfDay now = TimeOfDay(hour: 2, minute: 58);
    print(now);
    Schedule? next;

    for (final activity in schedule) {
      final activityTime = TimeOfDay.fromDateTime(
          DateFormat('HH:mm:ss').parse(activity.startTime!));
      print(activityTime);

      if (activityTime.hour > now.hour ||
          (activityTime.hour == now.hour && activityTime.minute > now.minute)) {
        next = activity;
        break;
      }
      print("For");
    }

    setState(() {
      apiProvider.nextActivity = next;
      print(next?.className);
      print("-----");
      _interactionGathering.parameters = [context, apiProvider.nextActivity];
    });
  }

  @override
  Widget build(BuildContext context) {
    final apiProvider = Provider.of<ApiProvider>(context);
    try {
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
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: NextActivityWidget(
                  activity: apiProvider.nextActivity ??
                      Schedule(className: "Cargando..."),
                  currentDay: apiProvider.currentDay,
                  clockStream: _clockStream,
                  interactionGathering: _interactionGathering,
                ),
              ),
              if (apiProvider.schedule.isNotEmpty)
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ScheduleTable(
                    apiProvider: apiProvider,
                    isLoading: false,
                  ),
                ),
              if (apiProvider.nextActivity == null &&
                  apiProvider.schedule.isEmpty)
                const Center(
                  child: CircularProgressIndicator(),
                ),
              // SizedBox(

              //   width: MediaQuery.of(context).size.width,
              //   child: InteractionTable(),
              // ),
              Text("Current Volume: $currentVolume"),
              Text("Current Lux Value: $_currentLuxValue"),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _interactionGathering.changeListening(),
          child: Icon(_isListening ? Icons.mic : Icons.mic_none),
        ),
      );
    } catch (e) {
      print('Error en build: $e');
      return Scaffold(
        body: Center(
          child: Text('Error en la construcción de la pantalla: $e'),
        ),
      );
    }
  }
}
