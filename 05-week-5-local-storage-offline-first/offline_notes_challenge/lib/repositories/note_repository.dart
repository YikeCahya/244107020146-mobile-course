import '../data/notes_database.dart';
import '../models/note.dart';

abstract interface class NoteRepository {
  Future<List<Note>> fetchNotes({
    String query = '',
    NoteSyncFilter filter = NoteSyncFilter.all,
  });
  Future<Note> saveNote(Note note);
  Future<void> deleteNote(int id);
  Future<List<Note>> fetchDirtyNotes();
  Future<void> markSynced(int id);
  Future<void> saveRemoteVersion(Note note);
}

class SqliteNoteRepository implements NoteRepository {
  SqliteNoteRepository({NotesDatabase? database})
    : _database = database ?? NotesDatabase();

  final NotesDatabase _database;

  @override
  Future<List<Note>> fetchNotes({
    String query = '',
    NoteSyncFilter filter = NoteSyncFilter.all,
  }) async {
    final db = await _database.database;
    final conditions = <String>[];
    final arguments = <Object?>[];
    conditions.add('is_deleted = 0');
    final trimmedQuery = query.trim();
    if (trimmedQuery.isNotEmpty) {
      conditions.add('(title LIKE ? OR body LIKE ?)');
      final pattern = '%$trimmedQuery%';
      arguments
        ..add(pattern)
        ..add(pattern);
    }
    if (filter == NoteSyncFilter.pending) {
      conditions.add('is_dirty = ?');
      arguments.add(1);
    } else if (filter == NoteSyncFilter.synced) {
      conditions.add('is_dirty = ?');
      arguments.add(0);
    }

    final rows = await db.query(
      'notes',
      where: conditions.isEmpty ? null : conditions.join(' AND '),
      whereArgs: arguments.isEmpty ? null : arguments,
      orderBy: 'updated_at DESC',
    );
    return rows.map(Note.fromMap).toList();
  }

  @override
  Future<Note> saveNote(Note note) async {
    final db = await _database.database;
    final local = note.copyWith(isDirty: true, isDeleted: false);
    final values = local.toMap()..remove('id');
    if (local.id == null) {
      final id = await db.insert('notes', values);
      return local.copyWith(id: id);
    }
    await db.update('notes', values, where: 'id = ?', whereArgs: [local.id]);
    return local;
  }

  @override
  Future<void> deleteNote(int id) async {
    final db = await _database.database;
    await db.update(
      'notes',
      {
        'is_dirty': 1,
        'is_deleted': 1,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<Note>> fetchDirtyNotes() async {
    final db = await _database.database;
    final rows = await db.query(
      'notes',
      where: 'is_dirty = ?',
      whereArgs: [1],
      orderBy: 'updated_at ASC',
    );
    return rows.map(Note.fromMap).toList();
  }

  @override
  Future<void> markSynced(int id) async {
    final db = await _database.database;
    final deleted = await db.delete(
      'notes',
      where: 'id = ? AND is_deleted = 1',
      whereArgs: [id],
    );
    if (deleted > 0) return;
    await db.update(
      'notes',
      {'is_dirty': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> saveRemoteVersion(Note note) async {
    final db = await _database.database;
    final values = note
        .copyWith(isDirty: false, isDeleted: false)
        .toMap()
      ..remove('id');
    await db.update('notes', values, where: 'id = ?', whereArgs: [note.id]);
  }
}
