class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
  });
  final String id;
  final String title;
  final String body;
  final String date;
}

const announcements = [
  Announcement(
    id: '1',
    title: 'Pendaftaran UKM dibuka',
    body: 'Pendaftaran UKM semester ganjil dibuka sampai Jumat.',
    date: '10 Okt 2026',
  ),
  Announcement(
    id: '2',
    title: 'Libur nasional',
    body: 'Perkuliahan ditiadakan pada hari libur nasional.',
    date: '11 Okt 2026',
  ),
  Announcement(
    id: '3',
    title: 'Jadwal kuliah berubah',
    body: 'Kelas Mobile pindah ke Ruang A2 jam 13.00.',
    date: '13 Okt 2026',
  ),
];

Announcement? findAnnouncement(String id) {
  for (final a in announcements) {
    if (a.id == id) return a;
  }
  return null;
}