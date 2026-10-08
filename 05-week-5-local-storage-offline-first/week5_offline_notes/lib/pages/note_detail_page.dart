import 'package:flutter/material.dart';

import '../data/local/note.dart';
import '../data/repositories/note_repository.dart';

class NoteDetailPage extends StatefulWidget {
  const NoteDetailPage({
    super.key,
    required this.repository,
    required this.noteId,
  });

  final NoteRepository repository;
  final String noteId;

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late final Future<Note?> _note;
  late final int? _id;

  @override
  void initState() {
    super.initState();
    _id = int.tryParse(widget.noteId);
    _note = _id == null
        ? Future<Note?>.value(null)
        : widget.repository.fetchNoteById(_id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail catatan')),
      body: FutureBuilder<Note?>(
        future: _note,
        builder: (context, snapshot) {
          if (_id == null) {
            return const Center(child: Text('ID catatan tidak valid.'));
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Catatan gagal dimuat: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData && snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final note = snapshot.data;
          if (note == null) {
            return const Center(child: Text('Catatan tidak ditemukan.'));
          }

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(note.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                if (note.dirty)
                  const Chip(
                    avatar: Icon(Icons.cloud_upload_outlined, size: 16),
                    label: Text('Belum tersinkron'),
                  ),
                const SizedBox(height: 12),
                Text(note.body.isEmpty ? 'Tanpa isi' : note.body),
              ],
            ),
          );
        },
      ),
    );
  }
}
