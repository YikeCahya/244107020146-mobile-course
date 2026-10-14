Future<List<Map<String, Object?>>> loadAnnouncementRows() async {
  return const <Map<String, Object?>>[
    {
      'id': '1',
      'title': 'Pendaftaran UKM dibuka',
      'body': 'Pendaftaran UKM semester ganjil dibuka sampai Jumat.',
      'date': '10 Okt 2026',
    },
    {
      'id': '2',
      'title': 'Libur nasional',
      'body': 'Perkuliahan ditiadakan pada hari libur nasional.',
      'date': '11 Okt 2026',
    },
    {
      'id': '3',
      'title': 'Jadwal kuliah berubah',
      'body': 'Kelas Mobile pindah ke Ruang A2 jam 13.00.',
      'date': '13 Okt 2026',
    },
  ];
}