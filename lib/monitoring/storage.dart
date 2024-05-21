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
      String type, String action, double value, String timestamp) async {
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
  }
}
