import 'package:maia_app/models/interaction.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Storage {
  static Database? _database;
  static const String _tableName = 'monitoring_interaction';

  static Future<void> init() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'monitoring.db'),
      onCreate: (db, version) {
        return db.execute(
          '''
          CREATE TABLE $_tableName(
            id INTEGER PRIMARY KEY,
            type TEXT,
            action TEXT,
            value REAL,
            timestamp INTEGER
          )
          ''',
        );
      },
      version: 1,
    );
  }

  static Future<void> insertInteraction(
      String type, String action, double value, int timestamp) async {
    try {
      await Storage.init();
      String dbPath = join(await getDatabasesPath(), 'monitoring.db');
      print('Ruta de la base de datos: $dbPath');
      await _database!.insert(
        _tableName,
        {
          'type': type,
          'action': action,
          'value': value,
          'timestamp': timestamp,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print("Interacción insertada correctamente.");
    } catch (e) {
      print('Error al insertar interacción en la base de datos: $e');
    }
  }

  static Future<List<Interaction>> getInteractions() async {
    await init(); // Asegúrate de que la base de datos esté inicializada
    final List<Map<String, dynamic>> maps = await _database!.query(_tableName);
    return List.generate(maps.length, (i) {
      return Interaction.fromMap(maps[i]);
    });
  }
}
