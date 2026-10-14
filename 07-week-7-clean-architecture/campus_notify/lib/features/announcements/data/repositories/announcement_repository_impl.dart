import '../../../../core/failures.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../models/announcement_model.dart';
  // ignore: prefer_initializing_formals
class AnnouncementRepositoryImpl implements AnnouncementRepository {
  AnnouncementRepositoryImpl({required this._loadRows});

  final Future<List<Map<String, Object?>>> Function() _loadRows;

  Future<List<Announcement>> _all() async {
    final rows = await _loadRows();
    return rows.map((r) => AnnouncementModel.fromMap(r).toEntity()).toList();
  }

  @override
  Future<({List<Announcement> items, Failure? failure})>
      fetchAnnouncements() async {
    try {
      return (items: await _all(), failure: null);
    } catch (e) {
      return (
        items: const <Announcement>[],
        failure: LocalFailure('Gagal membaca pengumuman. Coba lagi.'),
      );
    }
  }

  @override
  Future<({Announcement? item, Failure? failure})> getById(String id) async {
    try {
      final all = await _all();
      for (final a in all) {
        if (a.id == id) return (item: a, failure: null);
      }
      return (item: null, failure: null); // tidak ditemukan, bukan error
    } catch (e) {
      return (
        item: null,
        failure: LocalFailure('Gagal membaca pengumuman. Coba lagi.'),
      );
    }
  }
}