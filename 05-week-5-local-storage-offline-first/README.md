## Praktikum 3: Offline First

### Analisis singkat

Aplikasi punya dua contoh:

- **Posts:** membaca data yang tersimpan di HP dulu, lalu mencoba mengambil data
  terbaru dari internet.
- **Catatan:** menyimpan catatan di HP. Catatan baru diberi tanda **belum sync**.
  Tombol **Sync** menunggu sebentar lalu mengubah tandanya menjadi **sudah sync**.
  Ini simulasi, belum mengirim catatan ke server sungguhan.

### Langkah sederhana

1. Saat **online**, buka tab **Posts** dan tunggu daftar post muncul.
2. Matikan internet, lalu buka kembali tab **Posts**. Post yang sudah pernah
   dimuat masih bisa dilihat dari cache.
3. Di tab **Catatan**, tekan **+** dan simpan catatan. Catatan tetap tersimpan
   walaupun internet mati; jumlah catatan **belum sync** terlihat di layar.
4. Nyalakan internet kembali, lalu tekan **Sync**. Setelah sebentar, tanda
   catatan berubah menjadi **sudah sync** dan jumlah belum sync menjadi 0.

### Offline dan online

- **Offline:** tidak ada koneksi internet. Posts hanya dapat memakai cache yang
  sudah tersimpan. Catatan tetap bisa disimpan di HP.
- **Online:** ada koneksi internet. Posts dapat diperbarui dari API. Tombol
  **Sync** mendemonstrasikan perubahan status catatan.

**Catatan:** Sync catatan di praktikum ini hanya simulasi lokal, sehingga tombol
tetap dapat dijalankan tanpa internet. Aplikasi tidak mendeteksi status Wi-Fi
secara otomatis.




## AI Challenge

1. Daftar catatan di SharedPreferences? Tidak. SharedPreferences hanya menyimpan preferensi tema. catatan disimpan di SQLite—lebih tepat daripada menaruh koleksi besar sebagai JSON di preferences.
2. Antrean sync? Belum ada. Skema mencatat updated_at, tetapi tidak punya dirty flag atau antrean sinkronisasi, implementasinya CRUD lokal.
3. Real-time dengan stream? Perbandingan menyebut Drift punya stream, tetapi aplikasi ini tidak mengimplementasikannya. Daftar dimuat dengan FutureBuilder dan diperbarui setelah CRUD.
4. Boilerplate masuk akal? Ya. Sqflite butuh SQL, pemetaan model, dan pembuatan skema manual. Yang dibuat memakai flutter pub add untuk dependensi serta skema onCreate, belum ada migrasi versi berikutnya. Drift memerlukan setup generator tambahan seperti yang dijelaskan di README.
5. Keputusan final: SharedPreferences untuk tema dan SQLite/sqflite untuk catatan. SQLite lebih sesuai untuk data terstruktur dan query. Jika stream reaktif serta type-safety jadi kebutuhan penting, saya akan mempertimbangkan Drift.



## Refactoring
Sudah sesuai kok.