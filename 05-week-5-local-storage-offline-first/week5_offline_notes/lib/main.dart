import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'data/local/note.dart';
import 'data/models/post.dart';
import 'data/repositories/note_repository.dart';
import 'data/repositories/post_repository.dart';
import 'data/sync.dart';
import 'pages/note_detail_page.dart';
import 'widgets/new_note_dialog.dart';
import 'widgets/note_tile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    this.noteRepository,
    this.postRepository,
    this.syncService,
  });

  final NoteRepository? noteRepository;
  final PostRepository? postRepository;
  final SyncService? syncService;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final NoteRepository _notes;
  late final SyncService _sync;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _notes = widget.noteRepository ?? NoteRepository();
    _sync =
        widget.syncService ??
        SyncService(postRepository: widget.postRepository);
    _router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              HomePage(noteRepository: _notes, syncService: _sync),
        ),
        GoRoute(
          path: '/note/:id',
          builder: (context, state) => NoteDetailPage(
            repository: _notes,
            noteId: state.pathParameters['id']!,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Catatan Offline',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.noteRepository,
    required this.syncService,
  });

  final NoteRepository noteRepository;
  final SyncService syncService;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Catatan Offline'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Catatan', icon: Icon(Icons.note_alt_outlined)),
              Tab(text: 'Posts', icon: Icon(Icons.cloud_download_outlined)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            NotesPage(repository: noteRepository, syncService: syncService),
            PostsPage(syncService: syncService),
          ],
        ),
      ),
    );
  }
}

class NotesPage extends StatefulWidget {
  const NotesPage({
    super.key,
    required this.repository,
    required this.syncService,
  });

  final NoteRepository repository;
  final SyncService syncService;

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Note> _notes = [];
  bool _loading = true;
  bool _syncing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    try {
      final notes = await widget.repository.fetchNotes();
      if (!mounted) return;
      setState(() {
        _notes = notes;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'Catatan gagal dimuat: $error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addNote() async {
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (_) => const NewNoteDialog(),
    );
    if (result == null) return;

    try {
      await widget.repository.addNote(title: result.$1, body: result.$2);
      await _loadNotes();
    } catch (error) {
      if (mounted) _showMessage('Catatan gagal disimpan: $error');
    }
  }

  Future<void> _deleteNote(Note note) async {
    if (note.id == null) return;
    try {
      await widget.repository.deleteNote(note.id!);
      await _loadNotes();
    } catch (error) {
      if (mounted) _showMessage('Catatan gagal dihapus: $error');
    }
  }

  Future<void> _syncNotes() async {
    setState(() => _syncing = true);
    try {
      final count = await widget.syncService.syncNotes();
      await _loadNotes();
      if (mounted) {
        _showMessage(
          count == 0
              ? 'Tidak ada catatan untuk disinkronkan.'
              : '$count catatan tersinkron.',
        );
      }
    } catch (error) {
      if (mounted) _showMessage('Sinkronisasi gagal: $error');
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final dirtyCount = _notes.where((note) => note.dirty).length;

    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : Column(
              children: [
                ListTile(
                  title: Text(
                    dirtyCount == 0
                        ? 'Catatan disimpan di perangkat'
                        : '$dirtyCount catatan belum disinkronkan',
                  ),
                  trailing: TextButton.icon(
                    onPressed: _syncing ? null : _syncNotes,
                    icon: _syncing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.sync),
                    label: const Text('Sync'),
                  ),
                ),
                Expanded(
                  child: _notes.isEmpty
                      ? const Center(
                          child: Text(
                            'Belum ada catatan. Tekan + untuk menambah.',
                          ),
                        )
                      : ListView.builder(
                          itemCount: _notes.length,
                          itemBuilder: (context, index) {
                            final note = _notes[index];
                            return NoteTile(
                              note: note,
                              onTap: note.id == null
                                  ? null
                                  : () => context.push('/note/${note.id}'),
                              onDelete: () => _deleteNote(note),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        tooltip: 'Tambah catatan',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class PostsPage extends StatefulWidget {
  const PostsPage({super.key, required this.syncService});

  final SyncService syncService;

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  List<Post> _posts = [];
  bool _loadingCache = true;
  bool _refreshing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCacheThenRefresh();
  }

  Future<void> _loadCacheThenRefresh() async {
    try {
      final cached = await widget.syncService.readCachedPosts();
      if (!mounted) return;
      setState(() {
        _posts = cached;
        _loadingCache = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'Cache gagal dibaca: $error';
        _loadingCache = false;
      });
    }
    if (mounted) unawaited(_refreshPosts());
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _refreshing = true;
      _error = null;
    });
    try {
      final posts = await widget.syncService.refreshPosts();
      if (mounted) setState(() => _posts = posts);
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = _posts.isEmpty
              ? 'Tidak dapat memuat post. Sambungkan ke internet untuk mencoba lagi.'
              : 'Tidak dapat memperbarui. Menampilkan post yang tersimpan di perangkat.',
        );
      }
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingCache && _posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        ListTile(
          title: Text(
            _error ??
                (_refreshing
                    ? 'Menampilkan cache, memeriksa data terbaru…'
                    : 'Data post tersimpan di perangkat'),
          ),
          trailing: IconButton(
            tooltip: 'Muat ulang',
            onPressed: _refreshing ? null : _refreshPosts,
            icon: _refreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),
        ),
        Expanded(
          child: _posts.isEmpty
              ? Center(
                  child: Text(
                    'Belum ada post tersimpan.',
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  itemCount: _posts.length,
                  itemBuilder: (context, index) {
                    final post = _posts[index];
                    return ListTile(
                      leading: CircleAvatar(child: Text('${post.id}')),
                      title: Text(post.title),
                      subtitle: Text(post.body),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
