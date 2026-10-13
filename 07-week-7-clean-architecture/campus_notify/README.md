# Campus Notify

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

## Pengujian tiga app state
| State      | Diharapkan                               | Hasil | Bukti |
|------------|------------------------------------------|-------|-------|
| Foreground | Banner lokal muncul, klik ke /pengumuman/2 | Lolos   |![Uji Foreground](Docs/mini%20project%20foreground.jpeg)|
| Background | Banner sistem muncul, klik ke rute benar    | Lolos   |![Uji Background](Docs//mini%20project%20background.jpeg)|
| Terminated | Terbuka ke rute benar via getInitialMessage | Lolos   |![Uji Terminated](Docs/mini%20project%20terminated.jpeg)|

## Keterbatasan
Belum ada backend: pengiriman token ke POST /devices baru didokumentasikan (body: fcm_token, platform).