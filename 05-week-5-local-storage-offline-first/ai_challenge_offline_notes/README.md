# AI Challenge: Flutter Offline Notes

Project Flutter baru untuk challenge minggu ke-5. Aplikasi membuat, membaca,
mengubah, dan menghapus catatan secara lokal dengan SQLite (`sqflite`), serta
menyimpan preferensi tema terang/gelap dengan `SharedPreferences`.

## Menjalankan aplikasi

Jalankan pada target yang didukung `sqflite` (Android, iOS, atau macOS):

```sh
flutter pub get
flutter run
```

## Rekap AI Challenge

### Prompt

> Aplikasi Flutter Offline Notes: CRUD catatan + preferensi tema.
> Bandingkan SharedPreferences, Hive, sqflite (SQLite), dan Drift
> untuk dua kebutuhan ini. Requirements:
> - Kriteria: kompleksitas query, kebutuhan relasi, reaktivitas (stream),
>   type-safety, ukuran boilerplate, dan kemudahan testing.
> - Beri rekomendasi final: mana untuk preferensi, mana untuk catatan,
>   beserta alasannya dalam 1 tabel.
> - Tunjukkan skema tabel/kotak untuk 1000+ catatan.
> Jelaskan trade-off setiap pilihan.

### Respons AI

Untuk aplikasi catatan offline, pilihan penyimpanan sebaiknya mengikuti bentuk
data dan pola aksesnya. Preferensi tema hanya satu nilai sederhana; catatan
adalah kumpulan record yang akan dibaca, diurutkan, dicari, dan berpotensi
berelasi dengan data lain. Tidak perlu memakai satu teknologi untuk keduanya.

#### Perbandingan

| Kriteria | SharedPreferences | Hive | sqflite (SQLite) | Drift |
|---|---|---|---|---|
| Kompleksitas query | Sangat sederhana: baca/tulis nilai berdasarkan key; tidak cocok untuk filter atau pencarian kumpulan catatan. | Rendah untuk baca/tulis berdasarkan key dan filter sederhana; query kompleks biasanya perlu diproses di aplikasi. | SQL memberi filter, sort, agregasi, indeks, dan join; query ditulis manual. | Kemampuan SQL SQLite dengan query builder/type-safe dan dukungan query kompleks. |
| Kebutuhan relasi | Tidak ada relasi antar-record. | Tidak relasional; relasi harus dikelola lewat key atau struktur objek. | Mendukung foreign key, join, dan constraint relasional. | Mendukung relasi SQLite dan menyediakan API Dart untuk mendeklarasikannya. |
| Reaktivitas (stream) | Bukan database record reaktif; perubahan key biasanya ditangani lewat state aplikasi. | Watch pada box/key dapat memberi notifikasi perubahan. | `sqflite` tidak menyediakan stream query bawaan; perlu refresh atau solusi state tambahan. | Stream query menjadi fitur utama; hasil dapat diperbarui saat tabel berubah. |
| Type-safety | API bertipe untuk nilai sederhana, tetapi tidak ada model/skema data terstruktur. | Box dapat diberi tipe, tetapi model kustom membutuhkan adapter/serialisasi. | Hasil query berupa map dinamis; pemetaan model dan SQL perlu dijaga manual. | Tinggi: skema dan API query dikodekan sebagai Dart dan kode terkait dihasilkan. |
| Ukuran boilerplate | Paling kecil untuk preferensi sederhana. | Perlu inisialisasi dan adapter untuk model kustom. | Perlu SQL, konversi map-model, pengelolaan database, dan migrasi manual. | Perlu definisi tabel, konfigurasi generator, dan file hasil generate; investasi awal lebih besar. |
| Kemudahan testing | Mudah untuk preference kecil; tersedia mock untuk plugin. | Box dapat diuji terisolasi/in-memory, tetapi adapter tetap perlu diuji. | Bisa diuji dengan database sementara/in-memory; integrasi plugin perlu diperhatikan. | Mendukung executor sementara/in-memory dan pengujian query yang terisolasi; setup generator menambah persiapan. |

#### Rekomendasi final

| Kebutuhan | Pilihan | Alasan |
|---|---|---|
| Preferensi tema | **SharedPreferences** | Satu boolean sederhana, tidak butuh relasi, query, maupun stream database; implementasi dan pengujiannya ringkas. |
| Catatan | **sqflite (SQLite)** untuk aplikasi ini | CRUD terstruktur, pengurutan, indeks, dan jalur migrasi ke relasi bila fitur berkembang. Untuk skala 1000+ catatan, SQLite memadai dengan indeks dan query terpaginasikan. Jika kebutuhan stream/type-safety menjadi prioritas, pilih **Drift** sebagai lapisan SQLite, dengan menerima boilerplate generator tambahan. |

#### Skema data untuk 1000+ catatan

Seribu catatan tidak memerlukan partisi khusus. Simpan setiap catatan sebagai
satu row; jangan satukan seluruh catatan dalam satu blob preference. Indeks
mendukung daftar terbaru dan foreign key opsional mendukung tag:

```sql
CREATE TABLE notes (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  title      TEXT NOT NULL,
  content    TEXT NOT NULL DEFAULT '',
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
CREATE INDEX idx_notes_updated_at ON notes(updated_at DESC);

CREATE TABLE tags (
  id   INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE
);

CREATE TABLE note_tags (
  note_id INTEGER NOT NULL REFERENCES notes(id) ON DELETE CASCADE,
  tag_id  INTEGER NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
  PRIMARY KEY (note_id, tag_id)
);
CREATE INDEX idx_note_tags_tag_id ON note_tags(tag_id);
```

Relasi: `notes 1---N note_tags N---1 tags` (secara konseptual, `notes` dan
`tags` memiliki relasi many-to-many). Tabel `tags` dan `note_tags` bersifat
opsional untuk versi aplikasi tanpa kategori/tag. Daftar sebaiknya mengambil
data per halaman (misalnya `LIMIT 50 OFFSET ...`) dan memakai indeks
`updated_at`; pencarian teks sederhana bisa memakai `LIKE`, sedangkan
pencarian skala lebih besar dapat mempertimbangkan SQLite FTS.

#### Trade-off pilihan

- **SharedPreferences** paling praktis untuk konfigurasi kecil, tetapi bukan
  database catatan: tidak ada query, relasi, atau skema record. Menyimpan
  banyak catatan sebagai JSON di preference membuat pembaruan dan pencarian
  seluruh koleksi semakin rapuh.
- **Hive** menawarkan penyimpanan key-value/object yang ringan dan akses cepat
  tanpa SQL. Trade-off-nya adalah tidak ada join relasional, query kompleks
  perlu dikelola sendiri, dan model kustom membutuhkan adapter/serialisasi.
- **sqflite** menyediakan SQLite matang dengan SQL, indeks, transaksi, dan
  relasi; dependency ekosistem Flutter ini cocok untuk CRUD lokal. Trade-off:
  kode query dan mapping model manual serta tidak memiliki stream query
  bawaan atau type-safety setara Drift.
- **Drift** memberi tipe, query Dart, migrasi, dan stream reaktif di atas
  SQLite. Trade-off: lebih banyak setup/boilerplate, kode generated perlu
  dikelola, dan terlalu berat bila aplikasi hanya menyimpan beberapa field
  tanpa kebutuhan query reaktif.

Implementasi project ini memakai tabel `notes` beserta indeks urutan perubahan,
dan menyimpan pilihan tema dengan key `dark_mode`. Skema tag di atas merupakan
pengembangan yang disarankan, belum termasuk dalam UI aplikasi saat ini.
