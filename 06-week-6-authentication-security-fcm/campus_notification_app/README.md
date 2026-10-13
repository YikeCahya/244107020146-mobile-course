# Campus Notification App

Contoh aplikasi Flutter untuk mengelola izin dan token FCM, menampilkan notifikasi
foreground, membuka halaman dari payload notifikasi, dan mengelola topik
`pengumuman-kampus`.

## Stack

- `firebase_messaging` dan `firebase_core`
- `flutter_local_notifications`
- `flutter_secure_storage`
- `go_router`
- `flutter_riverpod`
- `dio`

## Menjalankan

1. Daftarkan aplikasi Android dan iOS di Firebase project yang sama dengan
   application/bundle ID proyek ini (`edu.campus.campus_notification_app`).
2. Konfigurasikan Firebase untuk Android dan iOS:
   - Android: letakkan `google-services.json` di `android/app/`.
   - iOS: tambahkan `GoogleService-Info.plist` ke target Runner di Xcode.
   - Pastikan Cloud Messaging aktif. Untuk pengujian iOS, siapkan APNs
     authentication key di Firebase Console.
3. Jalankan:

   ```powershell
   flutter pub get
   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
   ```

   `10.0.2.2` adalah alamat host dari Android Emulator. Untuk iOS Simulator,
   gunakan misalnya `http://localhost:8000`; untuk perangkat fisik, gunakan
   alamat IP LAN komputer pengembang yang dapat dijangkau ponsel.
4. Pastikan backend menyediakan `POST /devices`, menerima body:

   ```json
   {
     "fcm_token": "<token-perangkat>",
     "platform": "android"
   }
   ```

   `platform` dikirim sebagai `android` atau `ios`. Ubah base URL lewat
   `--dart-define=API_BASE_URL=...` saat menjalankan aplikasi.

## Payload pengujian

Kirim pesan FCM dengan notification title/body dan data berikut:

```json
{
  "notification": {
    "title": "Jadwal kuliah",
    "body": "Perubahan ruang untuk mata kuliah hari ini."
  },
  "data": {
    "route": "/pengumuman/3"
  },
  "topic": "pengumuman-kampus"
}
```

Gunakan tepat salah satu target FCM (`topic` atau `token`) sesuai metode
pengiriman dari Firebase Console/backend. Route hanya dinavigasikan bila
berbentuk path internal yang diawali `/`.

## Perbedaan Android 13+ dan iOS

- **Android 13+ (API 33+):** aplikasi meminta runtime permission
  `POST_NOTIFICATIONS`; permission sudah dideklarasikan di manifest. Aplikasi
  juga membuat channel Android `campus_announcements`. Versi Android lebih
  lama tidak menampilkan dialog izin runtime yang sama.
- **iOS:** `requestPermission` meminta otorisasi alert, badge, dan sound. Push
  memerlukan Push Notifications capability, APNs key di Firebase, serta
  konfigurasi background remote notifications bila pengiriman di background
  hendak diproses. Notifikasi foreground ditampilkan manual oleh local
  notifications.

## Batasan BuildContext

`firebaseMessagingBackgroundHandler` adalah top-level function dengan
`@pragma('vm:entry-point')` dan berjalan pada isolate background. Jangan
mengakses `BuildContext`, widget, Riverpod, atau `GoRouter` dari handler itu.
`PushService` dan semua listener FCM juga tidak menerima atau menyimpan
`BuildContext`; navigasi dilakukan lewat instance `GoRouter`. Gunakan context
hanya di UI, misalnya untuk snackbar atau navigasi yang dipicu pengguna.
