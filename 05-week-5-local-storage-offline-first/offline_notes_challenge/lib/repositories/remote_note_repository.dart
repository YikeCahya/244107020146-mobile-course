import '../models/note.dart';

abstract interface class RemoteNoteRepository {
  Future<Note?> fetchNote(int id);
  Future<void> saveNote(Note note);
  Future<void> deleteNote(int id);
}

class FakeRemoteNoteRepository implements RemoteNoteRepository {
  final Map<int, Note> _notes = {};

  @override
  Future<Note?> fetchNote(int id) async => _notes[id];

  @override
  Future<void> saveNote(Note note) async {
    final id = note.id;
    if (id == null) {
      throw ArgumentError.value(id, 'note.id', 'Remote notes need an ID.');
    }
    _notes[id] = note.copyWith(isDirty: false);
  }

  @override
  Future<void> deleteNote(int id) async {
    _notes.remove(id);
  }
}
