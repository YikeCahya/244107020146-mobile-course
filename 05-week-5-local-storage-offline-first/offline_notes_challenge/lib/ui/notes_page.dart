import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/note.dart';
import '../providers/app_providers.dart';

class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({super.key});

  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showNoteEditor([Note? note]) async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: note?.title ?? '');
    final bodyController = TextEditingController(text: note?.body ?? '');
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(note == null ? 'Catatan baru' : 'Edit catatan'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Judul'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Judul tidak boleh kosong.'
                    : null,
              ),
              TextFormField(
                controller: bodyController,
                decoration: const InputDecoration(labelText: 'Isi catatan'),
                minLines: 2,
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (saved == true && mounted) {
      await _runAction(() async {
        await ref
            .read(notesProvider.notifier)
            .saveNote(
              id: note?.id,
              title: titleController.text,
              body: bodyController.text,
              createdAt: note?.createdAt,
            );
      });
    }
    titleController.dispose();
    bodyController.dispose();
  }

  Future<void> _confirmDelete(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus catatan?'),
        content: Text('Catatan "${note.title}" akan dihapus dari perangkat.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true && note.id != null) {
      await _runAction(
        () => ref.read(notesProvider.notifier).deleteNote(note.id!),
      );
    }
  }

  Future<void> _runAction(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $error')));
      }
    }
  }

  Future<void> _sync() async {
    try {
      final count = await ref.read(notesProvider.notifier).syncNotes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              count == 0
                  ? 'Semua catatan sudah tersinkron.'
                  : '$count catatan berhasil disinkronkan (simulasi).',
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sinkronisasi gagal: $error')));
      }
    }
  }

  String _formatPreviousOpen(String? value) {
    if (value == null) return 'Pertama kali dibuka';
    final date = DateTime.tryParse(value)?.toLocal();
    return date == null
        ? 'Waktu buka sebelumnya tidak valid'
        : 'Terakhir dibuka: ${date.toString().substring(0, 16)}';
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(notesProvider);
    final theme = ref.watch(themeProvider);
    final previousOpen = ref.watch(previousOpenProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Offline'),
        actions: [
          IconButton(
            tooltip: 'Sinkronkan catatan',
            onPressed: _sync,
            icon: const Icon(Icons.sync),
          ),
          IconButton(
            tooltip: 'Ganti tema',
            onPressed: theme.isLoading
                ? null
                : () => _runAction(
                    () => ref.read(themeProvider.notifier).toggle(),
                  ),
            icon: Icon(
              theme.asData?.value == true ? Icons.light_mode : Icons.dark_mode,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNoteEditor(),
        icon: const Icon(Icons.add),
        label: const Text('Catatan'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              _formatPreviousOpen(previousOpen),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          if (theme.hasError)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Gagal memuat preferensi tema: ${theme.error}',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) =>
                  ref.read(notesProvider.notifier).setQuery(value),
              decoration: InputDecoration(
                labelText: 'Cari catatan',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: 'Hapus pencarian',
                  onPressed: () {
                    _searchController.clear();
                    ref.read(notesProvider.notifier).setQuery('');
                  },
                  icon: const Icon(Icons.clear),
                ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<NoteSyncFilter>(
              initialValue: NoteSyncFilter.all,
              decoration: const InputDecoration(
                labelText: 'Tampilkan',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: NoteSyncFilter.all,
                  child: Text('Semua catatan'),
                ),
                DropdownMenuItem(
                  value: NoteSyncFilter.pending,
                  child: Text('Belum tersinkron'),
                ),
                DropdownMenuItem(
                  value: NoteSyncFilter.synced,
                  child: Text('Sudah tersinkron'),
                ),
              ],
              onChanged: (filter) {
                if (filter != null) {
                  ref.read(notesProvider.notifier).setFilter(filter);
                }
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: notes.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Gagal memuat catatan: $error'),
                ),
              ),
              data: (items) => items.isEmpty
                  ? const Center(
                      child: Text('Belum ada catatan. Tambahkan catatan baru.'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
                      itemCount: items.length,
                      itemBuilder: (context, index) => _NoteCard(
                        note: items[index],
                        onEdit: () => _showNoteEditor(items[index]),
                        onDelete: () => _confirmDelete(items[index]),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.note,
    required this.onEdit,
    required this.onDelete,
  });

  final Note note;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onEdit,
        title: Text(note.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note.body.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  note.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: 6),
            Text(
              note.isDirty ? 'Belum tersinkron' : 'Sudah tersinkron',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
        leading: Icon(
          note.isDirty
              ? Icons.cloud_upload_outlined
              : Icons.cloud_done_outlined,
          color: note.isDirty
              ? Theme.of(context).colorScheme.tertiary
              : Theme.of(context).colorScheme.primary,
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Hapus')),
          ],
        ),
      ),
    );
  }
}
