import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/app_constants.dart';

class LocalDatabase {
  static Database? _database;
  static const String _databaseName = 'pay_sync_local.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String _queueTable = 'sms_queue';
  static const String _settingsTable = 'app_settings';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // SMS Queue table for offline storage
    await db.execute('''
      CREATE TABLE $_queueTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sender_number TEXT NOT NULL,
        amount REAL NOT NULL,
        trx_id TEXT NOT NULL,
        method TEXT NOT NULL,
        message_body TEXT NOT NULL,
        received_at INTEGER NOT NULL,
        synced INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL
      )
    ''');

    // App settings table
    await db.execute('''
      CREATE TABLE $_settingsTable (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    print('Local database created successfully');
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    if (oldVersion < newVersion) {
      // Add migration logic if needed
    }
  }

  // SMS Queue operations
  static Future<int> insertSmsToQueue(Map<String, dynamic> smsData) async {
    final db = await database;
    smsData['created_at'] = DateTime.now().millisecondsSinceEpoch;
    smsData['synced'] = 0;

    int id = await db.insert(_queueTable, smsData);
    print('SMS inserted to local queue with ID: $id');
    return id;
  }

  static Future<List<Map<String, dynamic>>> getUnsyncedSms() async {
    final db = await database;
    return await db.query(
      _queueTable,
      where: 'synced = ?',
      whereArgs: [0],
      orderBy: 'created_at ASC',
    );
  }

  static Future<void> markSmsAsSynced(int id) async {
    final db = await database;
    await db.update(
      _queueTable,
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
    print('SMS with ID $id marked as synced');
  }

  static Future<void> deleteSyncedSms() async {
    final db = await database;
    int count = await db.delete(
      _queueTable,
      where: 'synced = ?',
      whereArgs: [1],
    );
    print('Deleted $count synced SMS records');
  }

  static Future<int> getQueueCount() async {
    final db = await database;
    var result = await db.rawQuery('SELECT COUNT(*) as count FROM $_queueTable WHERE synced = 0');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // App settings operations
  static Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      _settingsTable,
      {
        'key': key,
        'value': value,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<String?> getSetting(String key) async {
    final db = await database;
    var result = await db.query(
      _settingsTable,
      where: 'key = ?',
      whereArgs: [key],
    );

    if (result.isNotEmpty) {
      return result.first['value'] as String?;
    }
    return null;
  }

  static Future<void> clearAllData() async {
    final db = await database;
    await db.delete(_queueTable);
    await db.delete(_settingsTable);
    print('All local data cleared');
  }

  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
