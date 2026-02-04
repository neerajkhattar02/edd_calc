import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'user_entry_model.dart';

class UserDatabase {
  static final UserDatabase instance = UserDatabase._init();
  static Database? _database;

  UserDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('user_data.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
        CREATE TABLE if not exists user_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        stateName TEXT,
        stateID INTEGER,
        district TEXT,
        districtID INTEGER,
        block TEXT,
        blockID INTEGER,
        facility TEXT,
        facilityID INTEGER,
        subFacility TEXT,
        subFacilityID INTEGER,
        rchID INTEGER,
        lmpDate TEXT,
        eddDate TEXT,
        createdOn TEXT,
        createdBy TEXT
      )
  ''');
  }

  Future<int> insertUser(UserData user) async {
    final db = await instance.database;
    return await db.insert('user_data', user.toMap());
  }

  Future<List<UserData>> getAllUsers() async {
    final db = await instance.database;
    final result = await db.query('user_data');
    return result.map((map) => UserData.fromMap(map)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
