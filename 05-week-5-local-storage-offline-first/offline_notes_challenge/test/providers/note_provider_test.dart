import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_notes_challenge/models/note.dart';
import 'package:offline_notes_challenge/providers/app_providers.dart';

import '../support/fake_repositories.dart';

void main() {
  test('provider loads from and writes through the fake repository', () async {
    final repository = FakeNoteRepository();
    final container = ProviderContainer(
      overrides: [noteRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    expect(await container.read(notesProvider.future), isEmpty);
    await container
        .read(notesProvider.notifier)
        .saveNote(title: 'Rencana', body: 'Selesaikan challenge');

    final notes = await container.read(notesProvider.future);
    expect(notes, hasLength(1));
    expect(notes.single.title, 'Rencana');
    expect(notes.single.isDirty, isTrue);
  });

  test('sync replaces a dirty local copy only when remote is newer', () async {
    final repository = FakeNoteRepository();
    final remote = FakeRemoteRepository();
    final container = ProviderContainer(
      overrides: [
        noteRepositoryProvider.overrideWithValue(repository),
        remoteNoteRepositoryProvider.overrideWithValue(remote),
      ],
    );
    addTearDown(container.dispose);

    final localVersion = Note(
      id: 1,
      title: 'Lokal',
      body: '',
      createdAt: DateTime.utc(2026, 10, 1),
      updatedAt: DateTime.utc(2026, 10, 2),
      isDirty: true,
    );
    await repository.saveNote(localVersion);
    remote.notes[1] = localVersion.copyWith(
      title: 'Remote terbaru',
      updatedAt: DateTime.utc(2026, 10, 3),
      isDirty: false,
    );

    final count = await container.read(notesProvider.notifier).syncNotes();

    expect(count, 1);
    expect(repository.notes.single.title, 'Remote terbaru');
    expect(repository.notes.single.isDirty, isFalse);
  });

  test('sync sends local deletion tombstones to the remote repository', () async {
    final repository = FakeNoteRepository();
    final remote = FakeRemoteRepository();
    final container = ProviderContainer(
      overrides: [
        noteRepositoryProvider.overrideWithValue(repository),
        remoteNoteRepositoryProvider.overrideWithValue(remote),
      ],
    );
    addTearDown(container.dispose);

    final saved = await repository.saveNote(
      Note(
        title: 'Hapus nanti',
        body: '',
        createdAt: DateTime.utc(2026, 10, 1),
        updatedAt: DateTime.utc(2026, 10, 1),
      ),
    );
    remote.notes[saved.id!] = saved.copyWith(isDirty: false);
    await repository.deleteNote(saved.id!);

    await container.read(notesProvider.notifier).syncNotes();

    expect(remote.notes, isEmpty);
    expect(repository.notes, isEmpty);
  });
}
