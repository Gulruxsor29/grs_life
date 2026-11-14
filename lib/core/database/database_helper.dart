import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

const List<String> _tables = [
  'tasks',
  'money_entries',
  'budgets',
  'financial_goals',
  'lesson_progress',
  'study_sessions',
  'goals',
  'journal',
];

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final dir = await getDatabasesPath();
    final path = p.join(dir, 'grs_life.db');
    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        note TEXT NOT NULL DEFAULT '',
        category TEXT NOT NULL,
        priority INTEGER NOT NULL DEFAULT 1,
        due_date TEXT NOT NULL,
        reminder_minutes INTEGER,
        is_done INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE money_entries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        amount INTEGER NOT NULL,
        category TEXT NOT NULL,
        note TEXT NOT NULL DEFAULT '',
        date TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE budgets(
        month TEXT PRIMARY KEY,
        amount INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE financial_goals(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        target_amount INTEGER NOT NULL,
        saved_amount INTEGER NOT NULL DEFAULT 0,
        deadline TEXT,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE lesson_progress(
        course_key TEXT NOT NULL,
        lesson_index INTEGER NOT NULL,
        is_done INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY(course_key, lesson_index)
      )
    ''');
    await db.execute('''
      CREATE TABLE study_sessions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        course_key TEXT NOT NULL,
        minutes INTEGER NOT NULL,
        date TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE goals(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        target_date TEXT,
        progress INTEGER NOT NULL DEFAULT 0,
        is_done INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE journal(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        mood TEXT NOT NULL DEFAULT 'neutral',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future<Map<String, List<Map<String, Object?>>>> exportAll() async {
    final db = await database;
    final result = <String, List<Map<String, Object?>>>{};
    for (final table in _tables) {
      result[table] = await db.query(table);
    }
    return result;
  }

  Future<void> restore(Map<String, List<Map<String, Object?>>> data) async {
    final db = await database;
    await db.transaction((txn) async {
      for (final table in _tables) {
        await txn.delete(table);
      }
      for (final entry in data.entries) {
        if (!_tables.contains(entry.key)) continue;
        for (final row in entry.value) {
          await txn.insert(entry.key, row, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
    });
  }
}
