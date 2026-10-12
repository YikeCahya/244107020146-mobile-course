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

### Hasil
![Hasil](Docs/Praktikum%20Hasil.jpeg)

### Test
![Test](Docs/Praktikum%20Test.png)


## AI Challenge
Dokumentasi AI ada dalam README.md pada folder proyek tersebut.

### Hasil
<table>
  <tr>
    <td><img src="Docs/AI_challenge Hasil Dark.jpeg" width="180"></td>
    <td><img src="Docs/AI_challenge Hasil Light.jpeg" width="180"></td>
  </tr>
</table>

### Test
![Test](Docs/AI_challenge%20Test.png)

### Verifikasi mandiri
1. Daftar catatan di SharedPreferences? Tidak. SharedPreferences hanya menyimpan preferensi tema. catatan disimpan di SQLite—lebih tepat daripada menaruh koleksi besar sebagai JSON di preferences.
2. Antrean sync? Belum ada. Skema mencatat updated_at, tetapi tidak punya dirty flag atau antrean sinkronisasi, implementasinya CRUD lokal.
3. Real-time dengan stream? Perbandingan menyebut Drift punya stream, tetapi aplikasi ini tidak mengimplementasikannya. Daftar dimuat dengan FutureBuilder dan diperbarui setelah CRUD.
4. Boilerplate masuk akal? Ya. Sqflite butuh SQL, pemetaan model, dan pembuatan skema manual. Yang dibuat memakai flutter pub add untuk dependensi serta skema onCreate, belum ada migrasi versi berikutnya. Drift memerlukan setup generator tambahan seperti yang dijelaskan di README.
5. Keputusan final: SharedPreferences untuk tema dan SQLite/sqflite untuk catatan. SQLite lebih sesuai untuk data terstruktur dan query. Jika stream reaktif serta type-safety jadi kebutuhan penting, saya akan mempertimbangkan Drift.



## Refactoring
Sudah sesuai kok.

## Mini project / Industry Challenge
### Hasil
#### Light Mode
<table>
  <tr>
    <td><img src="Docs/Mini_project Dirty Light.jpeg" width="180"></td>
    <td><img src="Docs/Mini_project Clean Light.jpeg" width="180"></td>
  </tr>
</table>

#### Dark Mode
<table>
  <tr>
    <td><img src="Docs/Mini_project Dirty Dark.jpeg" width="180"></td>
    <td><img src="Docs/Mini_project Clean Dark.jpeg" width="180"></td>
  </tr>
</table>

### Test
![Test](Docs/Mini_project%20Test.png)

## Refleksi
1. Catatan tidak cocok disimpan di SharedPreferences karena itu untuk preferensi sederhana, bukan data terstruktur yang perlu dicari, diurutkan, dan diperbarui per catatan. Jika dipaksakan, seluruh daftar harus diserialisasi ulang; perubahan kecil lebih berisiko merusak data dan query menjadi sulit. Karena itu, proyek memakai SQLite.
2. Cache-first cukup untuk catatan atau data yang masih berguna meski tidak paling baru. Untuk data yang harus aktual, misalnya harga real-time lebih tepat network-first, dengan cache sebagai fallback saat jaringan gagal.
3. Dirty flag menjadi antrean sync dengan mengambil catatan isDirty, memprosesnya secara asynchronous, lalu menandainya bersih hanya setelah sync berhasil. UI tidak perlu menunggu proses sinkronisasi agar tetap bisa dipakai. Proyek ini masih memakai proses sederhana berurutan; tabel outbox lebih sesuai jika perlu menyimpan jenis operasi, percobaan ulang, urutan, atau beberapa perubahan untuk satu catatan.
4. Rekomendasi AI yang saya batasi adalah menggunakan fake remote seolah-olah itu sinkronisasi produksi. Fake remote hanya untuk demonstrasi dan pengujian, bukan server sungguhan. Aturan konflik proyek—versi dengan updated_at lebih baru menang dan versi lokal menang jika waktunya sama, juga perlu disepakati ulang ketika backend nyata tersedia.