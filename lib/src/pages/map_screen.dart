import 'package:flutter/material.dart';
import 'package:maia_app/providers/api_provider.dart'; // Asegúrate de importar tu ApiProvider
import 'package:maia_app/models/node.dart';
import 'package:provider/provider.dart'; // Asegúrate de importar tu modelo Node

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Node? _selectedNode;

  @override
  void initState() {
    super.initState();
    Provider.of<ApiProvider>(context, listen: false).getNodes();
    Provider.of<ApiProvider>(context, listen: false).getPath(1, 4);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            //Navigator.of(context).popUntil(ModalRoute.withName('/home'));
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: Consumer<ApiProvider>(
          builder: (context, apiProvider, _) {
            // Aquí se construye el ComboBox cuando se obtienen los nodos
            if (apiProvider.nodes.isNotEmpty) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton<Node>(
                    value: _selectedNode,
                    hint: Text('Selecciona un nodo'),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedNode = newValue;
                        // Aquí se llama al método getPath para obtener la ruta entre los nodos 1 y 4
                      });
                    },
                    items: apiProvider.nodes.map((node) {
                      return DropdownMenuItem<Node>(
                        value: node,
                        child: Text(node.name ?? ''),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                  // Muestra los datos de respuesta del método getPath
                  ...[
                    for (var path in apiProvider.path)
                      Text(
                          'Node: ${path.first?.name}, Instruction: ${path.second}'),
                  ],
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
