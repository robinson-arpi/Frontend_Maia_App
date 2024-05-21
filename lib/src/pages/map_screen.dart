import 'package:flutter/material.dart';
import 'package:maia_app/models/schedule.dart';
import 'package:maia_app/providers/api_provider.dart';
import 'package:maia_app/models/node.dart';
import 'package:maia_app/theme/app_theme.dart';
import 'package:maia_app/widgets/NextActivityDetailWidget.dart';
import 'package:maia_app/widgets/NextActivityDetailsWidget.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class MapScreen extends StatelessWidget {
  final Schedule nextActivity;

  const MapScreen({Key? key, required this.nextActivity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Obtener los nodos y rutas al construir el widget
    Provider.of<ApiProvider>(context, listen: false).getNodes();
    Provider.of<ApiProvider>(context, listen: false).getPath(1, 4);
    Stream<DateTime> _clockStream =
        Stream<DateTime>.periodic(Duration(seconds: 1), (_) => DateTime.now());
    return Scaffold(
      backgroundColor: AppTheme.softColorA,
      appBar: AppBar(
        title: const Text('Indicaciones'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/home');
          },
        ),
      ),
      body: Column(
        children: [
          Center(
            child: Consumer<ApiProvider>(
              builder: (context, apiProvider, _) {
                if (apiProvider.nodes.isNotEmpty) {
                  List<Widget> instructionWidgets = [];

                  var paths = apiProvider.path.toList();
                  for (var i = 0; i < paths.length; i++) {
                    var path = paths[i];
                    if (i == 0) {
                      instructionWidgets.add(Text('${path.second}'));
                    } else if (i == paths.length - 1) {
                      instructionWidgets.add(Text('${path.first?.name}'));
                    } else {
                      instructionWidgets.add(Text('${path.first?.name}'));
                      instructionWidgets.add(Text('${path.second}'));
                    }
                  }

                  return SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: NextActivityDetailWidget(
                              activity: nextActivity,
                              clockStream: _clockStream),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Container(
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
                                  'Ubicación Actual',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                DropdownButton<Node>(
                                  value: apiProvider.nodes.first,
                                  onChanged: (newValue) {
                                    // No se puede cambiar el estado aquí porque este widget es Stateless
                                  },
                                  items: apiProvider.nodes.map((node) {
                                    return DropdownMenuItem<Node>(
                                      value: node,
                                      child: Text(node.name ?? ''),
                                    );
                                  }).toList(),
                                  underline: Container(
                                    height: 2,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  '\nInstrucciones',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 10),
                                ...instructionWidgets,
                                Row(
                                  children: [
                                    Checkbox(
                                      value: false,
                                      onChanged: (bool? value) {
                                        // No se puede cambiar el estado aquí porque este widget es Stateless
                                      },
                                    ),
                                    Text('Estoy en mi aula'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

String getClassroomInfo(String classroomName) {
  String block;
  int floor;

  if (classroomName.length >= 4 &&
      (classroomName[0] == 'B' || classroomName[0] == 'C')) {
    block = classroomName.substring(0, 1);
    floor = int.tryParse(classroomName.substring(1)) ?? 0;
  } else {
    return "Aula inválida";
  }

  return "Bloque $block - Piso $floor";
}
