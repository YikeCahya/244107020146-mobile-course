# Offline Notes Challenge

Aplikasi catatan Flutter sederhana yang dirancang untuk tetap berguna tanpa
koneksi internet. Catatan disimpan di SQLite pada perangkat; sinkronisasi
ditunjukkan memakai repository remote palsu di memori, bukan server sungguhan.

## Menjalankan

Gunakan target Android, iOS, atau macOS untuk menjalankan aplikasi dengan
`sqflite`:

```sh
flutter pub get
flutter run
```

Jalankan seluruh test (termasuk SQLite in-memory):

```sh
flutter test
```

## Fitur

- Tambah, baca, edit, dan hapus catatan secara lokal.
- Catatan terbaru tampil paling atas; pencarian judul/isi dan filter status
  dijalankan melalui query repository SQLite.
- Catatan yang dibuat atau diedit ditandai **Belum tersinkron**.
- Penghapusan offline disimpan sebagai tombstone dirty sampai penghapusan
  berhasil dikirim saat sync.
- Tombol Sync memproses catatan dirty satu per satu. Catatan lokal baru menjadi
  bersih setelah penulisan remote berhasil; kegagalan membiarkan catatan lokal
  dirty sehingga dapat dicoba lagi.
- Preferensi tema gelap/terang dan waktu pembukaan terakhir dikelola dengan
  SharedPreferences.
- Judul wajib diisi dan penghapusan membutuhkan konfirmasi.

## Penyimpanan dan struktur

- `models/note.dart`: model dan pemetaan SQLite.
- `data/notes_database.dart`: pembuatan database serta indeks `updated_at`.
- `repositories/note_repository.dart`: kontrak repository dan implementasi
  SQLite, termasuk CRUD, pencarian, filter, dan status dirty.
- `repositories/remote_note_repository.dart`: kontrak remote dan fake remote
  untuk demonstrasi.
- `services/note_sync_service.dart`: aturan sinkronisasi dan resolusi konflik.
- `providers/app_providers.dart`: integrasi repository, sinkronisasi, tema,
  dan state catatan dengan Riverpod.
- `data/preferences_service.dart`: penyimpanan preferensi.

## Offline-first dan konflik

SQLite adalah sumber data utama aplikasi. Daftar dibaca langsung dari database
lokal sehingga tidak memerlukan jaringan. Pada saat sync, aplikasi memeriksa
versi remote untuk setiap catatan lokal dirty:

1. Jika tidak ada versi remote, kirim versi lokal.
2. Jika `updated_at` remote lebih baru, simpan versi remote ke SQLite sebagai
   versi bersih.
3. Jika `updated_at` lokal lebih baru **atau waktunya sama**, versi lokal
   menang dan dikirim ke remote.
4. Penghapusan lokal menggunakan tombstone; penghapusan remote dijalankan saat
   sync dan tombstone lokal dibersihkan hanya setelah berhasil.
5. Catatan lokal ditandai bersih hanya setelah versi remote berhasil disimpan
   atau versi remote yang menang berhasil diterapkan. Error ditampilkan dan
   catatan yang belum berhasil tetap dirty.

Fake remote hanya hidup selama proses aplikasi dan tidak membutuhkan koneksi
internet. Implementasi produksi perlu menggantinya dengan API nyata, identitas
catatan yang stabil lintas perangkat, serta strategi konflik yang disepakati
server. Tombol Sync pada challenge ini tidak mendeteksi konektivitas.

## Test

- `test/models/note_test.dart`: round-trip model termasuk dirty flag.
- `test/providers/note_provider_test.dart`: provider dengan repository palsu
  dan resolusi konflik versi remote yang lebih baru.
- `test/repositories/note_repository_test.dart`: urutan terbaru, pencarian,
  dan filter status menggunakan SQLite in-memory.
