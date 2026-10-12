import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/preferences_service.dart';
import '../models/note.dart';
import '../repositories/note_repository.dart';
import '../repositories/remote_note_repository.dart';
import '../services/note_sync_service.dart';

final noteRepositoryProvider = Provider<NoteRepository>(
  (ref) => SqliteNoteRepository(),
);

final remoteNoteRepositoryProvider = Provider<RemoteNoteRepository>(
  (ref) => FakeRemoteNoteRepository(),
);

final noteSyncServiceProvider = Provider<NoteSyncService>(
  (ref) => NoteSyncService(
    local: ref.watch(noteRepositoryProvider),
    remote: ref.watch(remoteNoteRepositoryProvider),
  ),
);

final previousOpenProvider = Provider<String?>((ref) => null);

final themeProvider = AsyncNotifierProvider<ThemeController, bool>(
  ThemeController.new,
);

final notesProvider = AsyncNotifierProvider<NotesController, List<Note>>(
  NotesController.new,
);

class ThemeController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => PreferencesService().getDarkMode();

  Future<void> toggle() async {
    final next = !(state.asData?.value ?? false);
    await PreferencesService().setDarkMode(next);
    state = AsyncData(next);
  }
}

class NotesController extends AsyncNotifier<List<Note>> {
  String _query = '';
  NoteSyncFilter _filter = NoteSyncFilter.all;
  int _loadVersion = 0;

  NoteRepository get _repository => ref.read(noteRepositoryProvider);

  @override
  Future<List<Note>> build() => _load();

  Future<List<Note>> _load() => _repository.fetchNotes(
    query: _query,
    filter: _filter,
  );

  Future<void> setQuery(String query) async {
    _query = query;
    await _reload();
  }

  Future<void> setFilter(NoteSyncFilter filter) async {
    _filter = filter;
    await _reload();
  }

  Future<Note> saveNote({
    int? id,
    required String title,
    required String body,
    DateTime? createdAt,
  }) async {
    final now = DateTime.now();
    final note = Note(
      id: id,
      title: title.trim(),
      body: body.trim(),
      createdAt: createdAt ?? now,
      updatedAt: now,
      isDirty: true,
    );
    final saved = await _repository.saveNote(note);
    await _reload();
    return saved;
  }

  Future<void> deleteNote(int id) async {
    await _repository.deleteNote(id);
    await _reload();
  }

  Future<int> syncNotes() async {
    final count = await ref.read(noteSyncServiceProvider).syncNotes();
    await _reload();
    return count;
  }

  Future<void> _reload() async {
    final version = ++_loadVersion;
    final nextState = await AsyncValue.guard(_load);
    if (version == _loadVersion) state = nextState;
  }
}
