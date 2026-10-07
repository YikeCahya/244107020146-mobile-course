# Mini Project: Daftar Post REST API

Aplikasi Flutter sederhana untuk menampilkan daftar post dari JSONPlaceholder.
Request HTTP dikelola oleh Dio dan `PostRepository`, sedangkan state daftar dan
pagination dikelola dengan Riverpod.

## Fitur

- Memusatkan base URL, timeout, dan logging request di Dio.
- Memetakan respons JSON ke model `Post` dengan parsing yang aman terhadap
  field null atau tipe data yang tidak sesuai.
- Menampilkan state loading, error dengan tombol coba lagi, empty, dan daftar
  post.
- Memuat 10 post per halaman dengan infinite scroll dan guard request ganda.
- Menguji model, pemetaan error, provider dengan repository palsu, dan guard
  pagination tanpa request internet.

## Menjalankan

Jalankan dari folder `mini_project`:

```sh
flutter pub get
flutter run
```

## Validasi

```sh
flutter analyze
flutter test
```
