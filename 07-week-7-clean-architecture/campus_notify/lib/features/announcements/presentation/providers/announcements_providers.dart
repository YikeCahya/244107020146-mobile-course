import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/announcement_local_source.dart';
import '../../data/repositories/announcement_repository_impl.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../../domain/usecases/get_announcements.dart';
import '../../../../core/failures.dart';

// Data layer: sumber data disuntikkan, mudah diganti fake saat test
final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  return AnnouncementRepositoryImpl(loadRows: loadAnnouncementRows);
});

// Domain layer: use case menerima abstraksi, bukan implementasi
final getAnnouncementsProvider = Provider<GetAnnouncements>((ref) {
  return GetAnnouncements(ref.watch(announcementRepositoryProvider));
});

// Presentation: state daftar untuk UI
final announcementsProvider = FutureProvider<List<Announcement>>((ref) async {
  final result = await ref.watch(getAnnouncementsProvider).call();
  if (result.failure != null) throw FailureException(result.failure!);
  return result.items;
});

// Detail: repository langsung, tanpa use case (operasi satu baris)
final announcementByIdProvider =
    FutureProvider.family<Announcement?, String>((ref, id) async {
  final result = await ref.watch(announcementRepositoryProvider).getById(id);
  if (result.failure != null) throw FailureException(result.failure!);
  return result.item;
});