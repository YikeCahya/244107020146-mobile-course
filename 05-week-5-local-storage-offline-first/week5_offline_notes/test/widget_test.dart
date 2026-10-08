import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/data/local/note.dart';
import 'package:week5_offline_notes/data/models/post.dart';
import 'package:week5_offline_notes/data/repositories/note_repository.dart';
import 'package:week5_offline_notes/data/sync.dart';
import 'package:week5_offline_notes/main.dart';

void main() {
  testWidgets('keeps cached posts visible when refresh fails', (tester) async {
    await tester.pumpWidget(
      MyApp(
        noteRepository: _FakeNoteRepository(),
        syncService: _OfflineSyncService(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Posts'));
    await tester.pumpAndSettle();

    expect(find.text('Post tersimpan offline'), findsOneWidget);
    expect(
      find.text(
        'Tidak dapat memperbarui. Menampilkan post yang tersimpan di perangkat.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('DioException'), findsNothing);
  });

  testWidgets('shows a simple notes page', (tester) async {
    final repository = _FakeNoteRepository();
    await tester.pumpWidget(
      MyApp(noteRepository: repository, syncService: _FakeSyncService()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Catatan'), findsOneWidget);
    expect(find.text('Posts'), findsOneWidget);
    expect(
      find.text('Belum ada catatan. Tekan + untuk menambah.'),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Tambah catatan'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Belajar Flutter');
    await tester.enterText(find.byType(TextField).last, 'Catatan offline');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('Belajar Flutter'), findsOneWidget);
    expect(find.text('Catatan offline'), findsOneWidget);
    expect(find.text('Belum tersinkron'), findsOneWidget);
    expect(repository.savedTitle, 'Belajar Flutter');

    await tester.tap(find.text('Posts'));
    await tester.pumpAndSettle();
    expect(find.text('Post tersimpan offline'), findsOneWidget);
  });

  testWidgets('opens note detail using its local repository ID', (
    tester,
  ) async {
    final repository = _FakeNoteRepository()
      ..notes = [
        Note(
          id: 12,
          title: 'Catatan lokal',
          body: 'Isi dari repository',
          updatedAt: DateTime.now(),
          dirty: false,
        ),
      ];
    await tester.pumpWidget(
      MyApp(noteRepository: repository, syncService: _FakeSyncService()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Catatan lokal'));
    await tester.pumpAndSettle();

    expect(repository.requestedNoteId, 12);
    expect(find.text('Detail catatan'), findsOneWidget);
    expect(find.text('Isi dari repository'), findsOneWidget);
  });
}

class _FakeSyncService extends SyncService {
  @override
  Future<List<Post>> readCachedPosts() async => [
    const Post(id: 1, title: 'Post tersimpan offline', body: 'Isi post'),
  ];

  @override
  Future<List<Post>> refreshPosts() async => [
    const Post(id: 1, title: 'Post tersimpan offline', body: 'Isi post'),
  ];

  @override
  Future<int> syncNotes() async => 0;
}

class _OfflineSyncService extends _FakeSyncService {
  @override
  Future<List<Post>> readCachedPosts() async => [
    const Post(id: 1, title: 'Post tersimpan offline', body: 'Isi post'),
  ];

  @override
  Future<List<Post>> refreshPosts() async {
    throw Exception('DioException [connection error]');
  }
}

class _FakeNoteRepository extends NoteRepository {
  List<Note> notes = [];
  String? savedTitle;
  int? requestedNoteId;

  @override
  Future<List<Note>> fetchNotes() async => notes;

  @override
  Future<Note?> fetchNoteById(int id) async {
    requestedNoteId = id;
    for (final note in notes) {
      if (note.id == id) return note;
    }
    return null;
  }

  @override
  Future<Note> addNote({required String title, String body = ''}) async {
    savedTitle = title;
    final note = Note(
      id: 1,
      title: title,
      body: body,
      updatedAt: DateTime.now(),
      dirty: true,
    );
    notes = [note];
    return note;
  }
}
