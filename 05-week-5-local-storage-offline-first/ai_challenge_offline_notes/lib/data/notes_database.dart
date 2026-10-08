import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import 'note.dart';

class NotesDatabase {
  NotesDatabase._();

  static final NotesDatabase instance = NotesDatabase._();
  static const _databaseName = 'offline_notes.db';
  static const _databaseVersion = 1;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    final databasePath = await getDatabasesPath();
    _database = await openDatabase(
      path.join(databasePath, _databaseName),
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            content TEXT NOT NULL DEFAULT '',
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
        await db.execute(
          'CREATE INDEX idx_notes_updated_at ON notes(updated_at DESC)',
        );
      },
    );
    return _database!;
  }

  Future<List<Note>> getAllNotes() async {
    final db = await database;
    final rows = await db.query('notes', orderBy: 'updated_at DESC');
    return rows.map(Note.fromMap).toList();
  }

  Future<void> saveNote(Note note) async {
    final db = await database;
    final values = note.toMap()..remove('id');
    if (note.id == null) {
      await db.insert('notes', values);
    } else {
      await db.update(
        'notes',
        values,
        where: 'id = ?',
        whereArgs: [note.id],
      );
    }
  }

  Future<void> deleteNote(int id) async {
    final db = await database;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}
