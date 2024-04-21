import 'package:flutter/material.dart';
import 'package:maia_app/providers/api_provider.dart'; // Asegúrate de importar tu ApiProvider
import 'package:maia_app/models/node.dart';
import 'package:maia_app/theme/app_theme.dart';
import 'package:provider/provider.dart'; // Asegúrate de importar tu modelo Node
import 'package:go_router/go_router.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Node? _selectedNode;
  bool _isChecked = false;

  @override
  void initState() {
    super.initState();
    Provider.of<ApiProvider>(context, listen: false).getNodes();
    Provider.of<ApiProvider>(context, listen: false).getPath(1, 4);
  }

  @override
  Widget build(BuildContext context) {
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
      body: Center(
        child: Consumer<ApiProvider>(
          builder: (context, apiProvider, _) {
            // Aquí se construye el ComboBox cuando se obtienen los nodos
            if (apiProvider.nodes.isNotEmpty) {
              //_selectedNode ??= apiProvider.nodes.first; // Inicializa _selectedNode si es null
              List<Widget> instructionWidgets = [];

              var paths = apiProvider.path.toList();
              for (var i = 0; i < paths.length; i++) {
                var path = paths[i];
                if (i == 0) {
                  // Si es el primer elemento, imprimir solo path.second
                  instructionWidgets.add(Text('${path.second}'));
                } else if (i == paths.length - 1) {
                  // Si es el último elemento, imprimir solo path.first?.name
                  instructionWidgets.add(Text('${path.first?.name}'));
                } else {
                  // Para cualquier otro elemento, imprimir ambas cosas
                  instructionWidgets.add(Text('${path.first?.name}'));
                  instructionWidgets.add(Text('${path.second}'));
                }
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment
                    .start, // Alinea los elementos a la izquierda
                children: [
                  // Sección 1: Ubicación actual y ComboBox de nodos
                  SizedBox(
                    width: MediaQuery.of(context)
                        .size
                        .width, // Ancho de la pantalla
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white, // Color de fondo blanco
                        borderRadius:
                            BorderRadius.circular(10), // Esquinas redondeadas
                      ),
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Alinea los elementos a la izquierda
                        children: [
                          const Text('Ubicación Actual'),
                          const SizedBox(height: 10),
                          DropdownButton<Node>(
                            value: _selectedNode ?? apiProvider.nodes.first,
                            onChanged: (newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedNode = newValue;
                                  // Aquí se llama al método getPath para obtener la ruta entre los nodos 1 y 4
                                });
                              }
                            },
                            items: apiProvider.nodes.map((node) {
                              return DropdownMenuItem<Node>(
                                value: node,
                                child: Text(node.name ?? ''),
                              );
                            }).toList(),
                            underline: Container(
                              // Estilo de la línea debajo del ComboBox
                              height: 2,
                              color: Colors.black, // Color de la línea
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Sección 2: Instrucciones obtenidas del provider
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white, // Color de fondo blanco
                        borderRadius:
                            BorderRadius.circular(10), // Esquinas redondeadas
                      ),
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Alinea los elementos a la izquierda
                        children: [
                          Text('Instrucciones'),
                          SizedBox(height: 10),
                          ...instructionWidgets,
                        ],
                      ),
                    ),
                  ),

                  // Sección 3: Checkbox para indicar llegada al aula
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white, // Color de fondo blanco
                        borderRadius:
                            BorderRadius.circular(10), // Esquinas redondeadas
                      ),
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Alinea los elementos a la izquierda
                        children: [
                          Text('Llegada'),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Checkbox(
                                value: _isChecked,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _isChecked = value!;
                                  });
                                },
                              ),
                              Text('Estoy en mi aula'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              );
            } else {
              // Muestra un indicador de carga mientras se obtienen los nodos
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}

String getClassroomInfo(String classroomName) {
  String block;
  int floor;

  // Suponiendo que el nombre del aula tiene el formato "BXYY" o "CXYY" donde X es el bloque y YY es el piso
  if (classroomName.length >= 4 &&
      (classroomName[0] == 'B' || classroomName[0] == 'C')) {
    block = classroomName.substring(0, 1);
    floor = int.tryParse(classroomName.substring(1)) ?? 0;
  } else {
    return "Aula inválida";
  }

  return "Bloque $block - Piso $floor";
}
