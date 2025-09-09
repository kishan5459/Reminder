import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static late Database _db;

  static Future<void> initDb() async {
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      join(dbPath, "reminders.db"),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE reminders(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            isActive INTEGER,
            reminderTime TEXT,
            category TEXT
          )
        ''');
      },
      version: 1,
    );
  }

  static Future<List<Map<String, dynamic>>> getReminders() async {
    return await _db.query('reminders');
  }

  static Future<Map<String, dynamic>?> getRemindersById(int id) async {
    final List<Map<String, dynamic>> results = await _db.query(
      "reminders",
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  static Future<int> addReminder(Map<String, dynamic> reminder) async {
    return await _db.insert("reminders", reminder);
  }

  static Future<void> updateReminder(
    int id,
    Map<String, dynamic> reminder,
  ) async {
    await _db.update("reminders", reminder, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteReminder(int id) async {
    await _db.delete("reminders", where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> toggleReminder(int id, bool isActive) async {
    await _db.update(
      "reminders",
      {'isActive': isActive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
