import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DBHelper {
  static const String _databaseName = "wintrack.db";
  static const int _databaseVersion = 2;
  static const String tableActivities = 'activities';

  // Make this a singleton class
  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = await getDatabaseFilePath();
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<String> getDatabaseFilePath() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    return join(documentsDirectory.path, _databaseName);
  }


  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableActivities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        date TEXT NOT NULL,
        isCompleted INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'Sedang'
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE $tableActivities ADD COLUMN status TEXT NOT NULL DEFAULT "Sedang"');
    }
  }

  Future<int> insertActivity(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(tableActivities, row);
  }

  Future<List<Map<String, dynamic>>> getActivitiesByDate(String date) async {
    Database db = await instance.database;
    return await db.query(
      tableActivities,
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'createdAt DESC',
    );
  }

  Future<int> updateActivity(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row['id'];
    return await db.update(
      tableActivities,
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteActivity(int id) async {
    Database db = await instance.database;
    return await db.delete(
      tableActivities,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
