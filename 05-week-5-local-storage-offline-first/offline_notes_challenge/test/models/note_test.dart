import 'package:flutter_test/flutter_test.dart';
import 'package:offline_notes_challenge/models/note.dart';

void main() {
  test('Note round-trips through SQLite and retains its dirty flag', () {
    final note = Note(
      id: 8,
      title: 'Belanja',
      body: 'Beli kopi',
      createdAt: DateTime.utc(2026, 10, 8, 12),
      updatedAt: DateTime.utc(2026, 10, 8, 13),
      isDirty: true,
      isDeleted: true,
    );

    final restored = Note.fromMap(note.toMap());

    expect(restored.id, note.id);
    expect(restored.title, note.title);
    expect(restored.body, note.body);
    expect(restored.createdAt, note.createdAt);
    expect(restored.updatedAt, note.updatedAt);
    expect(restored.isDirty, isTrue);
    expect(restored.isDeleted, isTrue);
  });
}
