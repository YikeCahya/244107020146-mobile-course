# Week 5: Local Storage & Offline First

Aplikasi Flutter sederhana untuk mempelajari penyimpanan lokal dan konsep
offline-first.

Fitur utama:
- Membuat dan menyimpan catatan di perangkat menggunakan SQLite.
- Menampilkan daftar post dari API dengan cache lokal, sehingga post yang
  pernah dimuat tetap dapat dibuka saat offline.
- Menyimulasikan sinkronisasi catatan yang belum tersinkron.

Sinkronisasi catatan pada proyek ini masih berupa simulasi dan belum mengirim
data ke server.

## Refactoring

- Baris catatan menggunakan widget `NoteTile`; catatan yang masih dirty
  menampilkan badge **Belum tersinkron**.
- `SyncService` di `lib/data/sync.dart` menangani cache post dan simulasi
  sinkronisasi. `PostRepository` hanya mengambil post dari API.
- Detail catatan tersedia di `/note/:id` dan dimuat berdasarkan ID dari
  `NoteRepository`, jadi halaman detail tidak bergantung pada state daftar.
