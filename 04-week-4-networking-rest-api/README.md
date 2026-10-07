# Week 4

## Gambaran Projek
Projek ini merupakan latihan integrasi aplikasi Flutter dengan REST API. Aplikasi mengambil data post dan komentar dari JSONPlaceholder, mengubah respons JSON menjadi model Dart, serta menampilkan data dengan dukungan pemuatan bertahap (pagination). Latihan ini juga menerapkan pemisahan akses API melalui repository, pengelolaan state, dan penanganan error agar pesan kegagalan lebih mudah dipahami.

## Teknologi yang Digunakan
- **Flutter** dan **Dart** untuk membangun aplikasi.
- **Dio** untuk mengirim request HTTP ke REST API.
- **Riverpod** (`flutter_riverpod`) untuk mengelola state dan menyediakan dependency.
- **JSONPlaceholder** sebagai sumber data REST API.

## Praktikum 1: Dio dan model data
![Hasil P1](docs/P1.jpeg)

## Praktikum 2: Provider dan error handling
![Code P2 Ganti home](docs/Ganti%20home.png)
![Hasil P2](docs/P2.jpeg)
![Hasil P2 Mode Pesawat](docs/P2%20Mode%20Pesawat.jpeg)
![Code P2 Ganti baseURL](docs/Ganti%20baseURL.png)
![Hasil P2 Ganti baseURL A](docs/P2%20Ganti%20baseURL.jpeg)
![Hasil P2 Ganti baseURL B](docs/P2%20Ganti%20baseURL%20B.jpeg)

## Praktikum 3: Pagination dasar
![Hasil P3 Awal](docs/P3%20Pagination%20awal.jpeg)
![Hasil P3 Akhir](docs/P3%20Pagination%20akhir.jpeg)


## AI Challenge

## Verifikasi
| Pertanyaan | Temuan | Perbaikan |
|---|---|---|
| UI memanggil Dio langsung? | Tidak ada UI di tugas ini; Dio hanya diakses lewat CommentRepository via dioProvider | - |
| fromJson aman null? | Pola `as num?` / `as String?` aman untuk null/hilang, tetapi crash jika tipe berubah (mis. `'abc' as num?` melempar TypeError) | Diganti helper `_asInt` / `_asString` berbasis `is` |
| Semua DioExceptionType dipetakan? | Timeout, connectionError, badResponse terpetakan; tipe lain lewat `default` | Memakai friendlyErrorMessage terpusat |
| baseUrl/timeout terpusat? | Ya, di createDio() | - |
| Test benar menguji field hilang? | (isi: apakah test AI hanya happy path?) | Tambah edge case: null + tipe salah + map kosong |
| flutter analyze / test | (isi hasil dan screenshot) | |

## Hasil testing
![Test](docs/AI%20Challenge.png)


## Refactoring dan testing
Baris post kini menggunakan widget `PostTile` yang dapat dipakai ulang, pesan error jaringan dipusatkan di `network_errors.dart`, dan detail post tersedia melalui GoRouter pada `/post/:id`. Saat dibuka dari daftar, halaman menggunakan data post yang sudah dimuat; jika URL dibuka langsung, detail diambil melalui repository.

![Test Refactoring](docs/Refactoring%20Test.png)

## Mini project / Industry Challenge