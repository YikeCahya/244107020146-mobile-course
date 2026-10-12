import 'package:flutter_test/flutter_test.dart';
import 'package:offline_notes_challenge/data/notes_database.dart';
import 'package:offline_notes_challenge/models/note.dart';
import 'package:offline_notes_challenge/repositories/note_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Database database;
  late SqliteNoteRepository repository;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    database = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await database.execute('''
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
    repository = SqliteNoteRepository(
      database: NotesDatabase(openDatabase: () async => database),
    );
  });

  tearDown(() => database.close());

  test('SQLite repository orders newest updates first', () async {
    final older = DateTime.utc(2026, 10, 1);
    final newer = DateTime.utc(2026, 10, 2);
    await repository.saveNote(
      Note(title: 'Lama', body: 'Isi lama', createdAt: older, updatedAt: older),
    );
    await repository.saveNote(
      Note(title: 'Baru', body: 'Isi baru', createdAt: newer, updatedAt: newer),
    );

    final notes = await repository.fetchNotes();

    expect(notes.map((note) => note.title), ['Baru', 'Lama']);
  });

  test('search and pending filter are applied by SQLite', () async {
    final now = DateTime.utc(2026, 10, 1);
    final saved = await repository.saveNote(
      Note(title: 'Rapat', body: 'Review', createdAt: now, updatedAt: now),
    );
    await repository.markSynced(saved.id!);
    await repository.saveNote(
      Note(
        title: 'Belanja',
        body: 'Kopi',
        createdAt: now,
        updatedAt: now.add(const Duration(minutes: 1)),
      ),
    );

    final notes = await repository.fetchNotes(
      query: 'kopi',
      filter: NoteSyncFilter.pending,
    );

    expect(notes.map((note) => note.title), ['Belanja']);
  });

  test('deleted notes stay as dirty tombstones until synced', () async {
    final now = DateTime.utc(2026, 10, 1);
    final saved = await repository.saveNote(
      Note(title: 'Hapus nanti', body: '', createdAt: now, updatedAt: now),
    );

    await repository.deleteNote(saved.id!);

    expect(await repository.fetchNotes(), isEmpty);
    final dirty = await repository.fetchDirtyNotes();
    expect(dirty.single.isDeleted, isTrue);

    await repository.markSynced(saved.id!);
    expect(await repository.fetchDirtyNotes(), isEmpty);
  });
}
