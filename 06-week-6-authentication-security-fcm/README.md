# WEEK 6 -  Authentication, Security & FCM
## Tujuan
Aplikasi pengumuman kampus dengan login, penyimpanan token aman, dan push notification FCM.

## Fitur utama
- Login mock dengan guard route (GoRouter + Riverpod)
- Token di flutter_secure_storage, Dio refresh otomatis saat 401
- FCM: permission, token + onTokenRefresh, topik pengumuman-kampus
- Klik notifikasi membuka /pengumuman/:id

## Stack
Flutter, Riverpod, GoRouter, Dio, flutter_secure_storage, Firebase Messaging, flutter_local_notifications

## Cara menjalankan
flutter pub get
(letakkan google-services.json di android/app/)
flutter run

## Praktikum 1: Login + secure storage + token refresh
### Hasil
<table>
  <tr>
    <td><img src="Docs/Hasil Praktikum 1 A.jpeg" width="180"></td>
    <td><img src="Docs/Hasil Praktikum 1 B.jpeg" width="180"></td>
    <td><img src="Docs/Hasil Praktikum 1 C.jpeg" width="180"></td>
  </tr>
</table>

### Test
![Test Praktikum 1](Docs/Test%20Praktikum%201.png)


## Praktikum 2: FCM, permission, dan token lifecycle
### Hasil
![Hasil Praktikum Notifikasi](Docs/fcm-console-test.jpeg)
Saat notifikasi di klik, maka akan mengarah ke aplikasi.
![Hasil Praktikum 2](Docs/Hasil%20Praktikum%202.jpeg)

### Test
![Test Praktikum 2](Docs/Test%20Praktikum%202.png)

## Praktikum 3: Payload, tiga app state, klik dan topik

### Matriks pengujian wajib

| State      | Diharapkan                               | Hasil | Bukti |
|------------|------------------------------------------|-------|-------|
| Foreground | Banner lokal muncul, klik ke /pengumuman/3 | Lolos   |![Uji Foreground](Docs/Foreground.jpeg)|
| Background | Banner sistem muncul, klik ke rute benar    | Lolos   |![Uji Background](Docs/Background.jpeg)|
| Terminated | Terbuka ke rute benar via getInitialMessage | Lolos   |![Uji Terminated](Docs/Terminated.jpeg)|

### Topic messaging
<table>
  <tr>
    <td><img src="Docs/Topic messaging aktif.jpeg" width="180"></td>
    <td><img src="Docs/Topic messaging non aktif.jpeg" width="180"></td>
    <td><img src="Docs/Topic messaging aktif lagi.jpeg" width="180"></td>
  </tr>
</table>

## AI Challenge

## Refactoring, testing, dan error umum
### Test

<table>
  <tr>
    <td><img src="Docs/Analyze Refactoring.png" width="180"></td>
    <td><img src="Docs/Test Refactoring.png" width="180"></td>
  </tr>
</table>


## Tugas, refleksi, dan referensi
### Mini Project
| State      | Diharapkan                               | Hasil | Bukti |
|------------|------------------------------------------|-------|-------|
| Foreground | Banner lokal muncul, klik ke /pengumuman/2 | Lolos   |![Uji Foreground](Docs/mini%20project%20foreground.jpeg)|
| Background | Banner sistem muncul, klik ke rute benar    | Lolos   |![Uji Background](Docs//mini%20project%20background.jpeg)|
| Terminated | Terbuka ke rute benar via getInitialMessage | Lolos   |![Uji Terminated](Docs/mini%20project%20terminated.jpeg)|

### Hasil
<table>
  <tr>
    <td><img src="Docs/data mini project.jpeg" width="180"></td>
  </tr>
</table>

### Test
<table>
  <tr>
    <td><img src="Docs/Mini project analyze.png" width="180"></td>
    <td><img src="Docs/Mini project test.png" width="180"></td>
  </tr>
</table>


### Refleksi

1. Mengapa refresh token tidak boleh disimpan di SharedPreferences?
SharedPreferences menyimpan data tanpa enkripsi, jadi bisa dibaca di perangkat yang di-root atau lewat backup. Refresh token berumur panjang, jadi kalau bocor, penyerang bisa terus meminta access token baru dan menyamar sebagai pengguna tanpa tahu kata sandinya. Karena itu token disimpan di flutter_secure_storage (Keystore/Keychain).

2. Apa yang rusak bila onTokenRefresh diabaikan?
Backend terus menyimpan token FCM lama yang sudah basi, sehingga notifikasi tidak sampai ke perangkat tanpa ada error yang terlihat. Mahasiswa melewatkan pengumuman penting seperti jadwal kuliah berubah.

3. Kapan memakai topik dan token perangkat?
Topik untuk broadcast ke banyak orang, misalnya “Kelas Mobile pindah ke Ruang A2 jam 13.00” ke semua mahasiswa. Token perangkat untuk pesan personal, misalnya “Nilai UTS Anda sudah keluar” atau “Tagihan UKT jatuh tempo besok”. Topik tidak cocok untuk pesan personal karena siapa pun bisa berlangganan.