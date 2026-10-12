import '../repositories/note_repository.dart';
import '../repositories/remote_note_repository.dart';

class NoteSyncService {
  const NoteSyncService({required this.local, required this.remote});

  final NoteRepository local;
  final RemoteNoteRepository remote;

  Future<int> syncNotes() async {
    final dirtyNotes = await local.fetchDirtyNotes();
    var syncedCount = 0;
    for (final localNote in dirtyNotes) {
      final id = localNote.id;
      if (id == null) {
        throw StateError('Catatan lokal yang disimpan harus memiliki ID.');
      }
      final remoteNote = await remote.fetchNote(id);
      if (remoteNote != null &&
          remoteNote.updatedAt.isAfter(localNote.updatedAt)) {
        await local.saveRemoteVersion(remoteNote);
      } else if (localNote.isDeleted) {
        await remote.deleteNote(id);
        await local.markSynced(id);
      } else {
        await remote.saveNote(localNote);
        await local.markSynced(id);
      }
      syncedCount++;
    }
    return syncedCount;
  }
}
