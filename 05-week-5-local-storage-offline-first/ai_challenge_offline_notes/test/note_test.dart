import 'package:ai_challenge_offline_notes/data/note.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Note round-trips through its SQLite map representation', () {
    final note = Note(
      id: 42,
      title: 'Belanja',
      content: 'Beli kopi',
      createdAt: DateTime.utc(2026, 10, 8, 12),
      updatedAt: DateTime.utc(2026, 10, 8, 13),
    );

    final restored = Note.fromMap(note.toMap());

    expect(restored.id, note.id);
    expect(restored.title, note.title);
    expect(restored.content, note.content);
    expect(restored.createdAt, note.createdAt);
    expect(restored.updatedAt, note.updatedAt);
  });
}
