import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class NotesDatabase {
  NotesDatabase({Future<Database> Function()? openDatabase})
    : _openDatabase = openDatabase ?? _openDefault;

  final Future<Database> Function() _openDatabase;
  Future<Database>? _database;

  Future<Database> get database => _database ??= _openDatabase();

  static Future<Database> _openDefault() async {
    final directory = await getDatabasesPath();
    return openDatabase(
      p.join(directory, 'offline_notes_challenge.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            body TEXT NOT NULL DEFAULT '',
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            is_dirty INTEGER NOT NULL DEFAULT 1,
            is_deleted INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute(
          'CREATE INDEX idx_notes_updated_at ON notes(updated_at DESC)',
        );
      },
    );
  }
}
