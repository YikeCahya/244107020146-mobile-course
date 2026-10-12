import 'package:offline_notes_challenge/models/note.dart';
import 'package:offline_notes_challenge/repositories/note_repository.dart';
import 'package:offline_notes_challenge/repositories/remote_note_repository.dart';

class FakeNoteRepository implements NoteRepository {
  final List<Note> notes = [];
  var _nextId = 1;

  @override
  Future<List<Note>> fetchNotes({
    String query = '',
    NoteSyncFilter filter = NoteSyncFilter.all,
  }) async {
    final normalized = query.toLowerCase();
    return notes.where((note) {
      final matchesQuery =
          normalized.isEmpty ||
          note.title.toLowerCase().contains(normalized) ||
          note.body.toLowerCase().contains(normalized);
      final matchesFilter = switch (filter) {
        NoteSyncFilter.all => true,
        NoteSyncFilter.pending => note.isDirty,
        NoteSyncFilter.synced => !note.isDirty,
      };
      return !note.isDeleted && matchesQuery && matchesFilter;
    }).toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Future<Note> saveNote(Note note) async {
    final saved = note.copyWith(
      id: note.id ?? _nextId++,
      isDirty: true,
      isDeleted: false,
    );
    notes.removeWhere((existing) => existing.id == saved.id);
    notes.add(saved);
    return saved;
  }

  @override
  Future<void> deleteNote(int id) async {
    final index = notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      notes[index] = notes[index].copyWith(
        isDirty: true,
        isDeleted: true,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<List<Note>> fetchDirtyNotes() async =>
      notes.where((note) => note.isDirty).toList();

  @override
  Future<void> markSynced(int id) async {
    final index = notes.indexWhere((note) => note.id == id);
    if (index != -1 && notes[index].isDeleted) {
      notes.removeAt(index);
    } else if (index != -1) {
      notes[index] = notes[index].copyWith(isDirty: false);
    }
  }

  @override
  Future<void> saveRemoteVersion(Note note) async {
    final index = notes.indexWhere((item) => item.id == note.id);
    if (index == -1) {
      notes.add(note.copyWith(isDirty: false, isDeleted: false));
    } else {
      notes[index] = note.copyWith(isDirty: false, isDeleted: false);
    }
  }
}

class FakeRemoteRepository implements RemoteNoteRepository {
  final Map<int, Note> notes = {};

  @override
  Future<Note?> fetchNote(int id) async => notes[id];

  @override
  Future<void> saveNote(Note note) async {
    notes[note.id!] = note.copyWith(isDirty: false, isDeleted: false);
  }

  @override
  Future<void> deleteNote(int id) async {
    notes.remove(id);
  }
}
