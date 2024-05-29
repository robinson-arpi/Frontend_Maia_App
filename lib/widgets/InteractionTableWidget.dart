import 'package:flutter/material.dart';
import 'package:maia_app/models/interaction.dart';
import 'package:maia_app/monitoring/storage.dart';
import 'package:maia_app/providers/api_provider.dart';
import 'package:maia_app/theme/app_theme.dart';

class InteractionTable extends StatefulWidget {
  const InteractionTable({Key? key}) : super(key: key);

  @override
  _InteractionTableState createState() => _InteractionTableState();
}

class _InteractionTableState extends State<InteractionTable> {
  late Future<List<Interaction>> _interactionsFuture;

  @override
  void initState() {
    super.initState();
    _interactionsFuture = Storage.getInteractions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Datos de Interacciones'),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: AppTheme.softColorB,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.all(10),
        child: FutureBuilder<List<Interaction>>(
          future: _interactionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No hay datos disponibles'));
            } else {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Tipo')),
                    DataColumn(label: Text('Acción')),
                    DataColumn(label: Text('Valor')),
                    DataColumn(label: Text('Timestamp')),
                  ],
                  rows: snapshot.data!.map((interaction) {
                    return DataRow(cells: [
                      DataCell(Text('${interaction.id}')),
                      DataCell(Text(interaction.type)),
                      DataCell(Text(interaction.action)),
                      DataCell(Text('${interaction.value}')),
                      DataCell(Text('${interaction.timestamp}')),
                    ]);
                  }).toList(),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
