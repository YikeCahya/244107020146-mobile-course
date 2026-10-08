import 'package:flutter/material.dart';

import '../data/local/note.dart';

class NoteTile extends StatelessWidget {
  const NoteTile({
    super.key,
    required this.note,
    this.onTap,
    required this.onDelete,
  });

  final Note note;
  final VoidCallback? onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(note.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(note.body.isEmpty ? 'Tanpa isi' : note.body),
          if (note.dirty)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Chip(
                avatar: Icon(Icons.cloud_upload_outlined, size: 16),
                label: Text('Belum tersinkron'),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
        ],
      ),
      leading: Icon(
        note.dirty ? Icons.cloud_upload_outlined : Icons.cloud_done_outlined,
      ),
      trailing: IconButton(
        tooltip: 'Hapus catatan',
        onPressed: onDelete,
        icon: const Icon(Icons.delete_outline),
      ),
    );
  }
}
