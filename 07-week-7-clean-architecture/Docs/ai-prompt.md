# AI PROMPT CHALLENGE

## Prompt 

## Jawaban

Berikut struktur **feature-first dengan batas Clean Architecture yang pragmatis**. Saya memakai kondisi dan pola yang tampak di proyek—termasuk provider pengumuman yang sekarang menghubungkan repository dan UI di `announcements_providers.dart`. Ini usulan struktur, bukan perubahan file.

### Struktur yang disarankan

```text
lib/
  core/
    network/
      api_client.dart
      dio_failure_mapper.dart

  features/
    auth/
      presentation/
        pages/
          login_page.dart
        providers/
          auth_providers.dart
        controllers/
          auth_controller.dart
      domain/
        entities/
          auth_session.dart
        repositories/
          auth_repository.dart
        # usecases/ hanya jika ada alur bisnis yang memang perlu
      data/
        datasources/
          auth_remote_data_source.dart
          secure_token_data_source.dart
        repositories/
          auth_repository_impl.dart
        models/
          auth_session_model.dart       # nanti, bila perlu memetakan DTO API

    push/
      presentation/
        providers/
          push_providers.dart
        controllers/
          push_controller.dart
      # domain/repositories/push_repository.dart  # opsional
      data/
        datasources/
          firebase_messaging_data_source.dart
          local_notification_data_source.dart
        # repositories/push_repository_impl.dart # opsional

    announcements/
      ... # struktur yang sudah ada

  app/
    pages/
      home_page.dart
    ...
```

**Auth:** UI login berada di `auth/presentation`; kontrak repository dan entitas sesi berada di `auth/domain`; simulasi login dan secure storage merupakan detail `auth/data`. Untuk mock sekarang, `auth_remote_data_source.dart` bisa berisi simulasi login; saat backend tersedia, implementasinya dapat diganti tanpa membuat halaman bergantung pada Firebase atau HTTP.

**Push:** Firebase Messaging dan local notifications adalah detail platform, jadi tempatkan di data source. `PushController` mengelola state yang dibaca UI—misalnya izin, status langganan topik, atau pratinjau token—bukan data source. `HomePage` lebih cocok sebagai halaman komposisi aplikasi karena saat ini menggabungkan auth, push, dan announcements; ia bukan tanggung jawab auth saja. Login page, sebaliknya, memang milik fitur auth.

### Tujuan file lama

| File lama | Tujuan yang disarankan |
|---|---|
| `auth_repository.dart` | **Pecah.** Pindahkan `AuthSession` ke `auth/domain/entities/auth_session.dart`, deklarasikan kontrak `AuthRepository` di `auth/domain/repositories/auth_repository.dart`, dan pindahkan implementasi mock ke `auth/data/repositories/auth_repository_impl.dart`. Logika simulasi login dapat dipisahkan ke remote data source agar implementasi repository berfokus pada orkestrasi dan penyimpanan sesi. |
| `token_store.dart` | **Pindahkan dan beri nama sesuai perannya**, misalnya `auth/data/datasources/secure_token_data_source.dart`. Repository auth yang mengatur baca/simpan/hapus sesi; controller tidak perlu mengenal kelas storage konkret. |
| `api_client.dart` | **Pindahkan** ke `core/network/api_client.dart` jika memang dipakai lintas fitur. Logika refresh token di interceptor adalah concern auth; letakkan terpisah di auth data/network, atau jangan implementasikan dulu selama login masih mock dan client belum digunakan. Hindari `core` yang bergantung pada repository auth konkret. |
| `api_errors.dart` | **Pindahkan atau pecah.** Pemetaan `DioException` ke error/failure teknis dapat berada di `core/network/dio_failure_mapper.dart` bila dipakai beberapa fitur. Pesan yang ditampilkan ke pengguna sebaiknya dipilih di presentation, bukan membuat domain mengenal Dio atau error jaringan. |
| `auth_provider.dart` | **Pindahkan dan rapikan** menjadi provider auth di `features/auth/presentation/providers/`. Provider repository membangun implementasi; `AuthController` menggunakan kontrak repository yang diambil dari Riverpod, bukan membuat `AuthRepository()` sendiri atau bergantung pada `TokenStore` konkret. |
| `push_service.dart` | **Pecah dan hapus file lama setelah semua referensi berpindah.** Pisahkan akses Firebase/local notifications ke data source, state UI ke `PushController`, dan alur notifikasi/aksi yang dibutuhkan UI ke provider/controller atau repository sesuai kompleksitasnya. Hilangkan state global seperti `ValueNotifier`, `pendingDeepLink`, dan callback navigasi global; sampaikan navigasi ke router melalui alur aplikasi/presentation. |
| `login_page.dart` | **Pindahkan** ke `features/auth/presentation/pages/login_page.dart`; UI tetap memanggil controller/provider, tidak mengakses data source. |
| `home_page.dart` | **Pindahkan** ke `app/pages/home_page.dart` atau pertahankan di lokasi halaman aplikasi. Halaman ini merangkai logout, status push, dan daftar announcement, sehingga tidak pas dimiliki auth atau push. Ganti pembacaan `ValueNotifier` push dengan provider Riverpod. |
| `main.dart` | **Tetap menjadi composition root.** Inisialisasi Firebase, router, dan `ProviderScope` tetap di sini; pindahkan detail pendaftaran/listening push dari fungsi global ke pemanggilan provider/controller yang terstruktur. Handler background Firebase tetap top-level sesuai batasan plugin, dan tidak boleh mengakses `BuildContext` atau Riverpod UI. |

### Wiring DI dengan Riverpod

Riverpod sudah menjadi container DI; tidak perlu package DI tambahan. Contoh wiring konseptual untuk auth:

```dart
final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return SecureTokenDataSource(ref.watch(secureStorageProvider));
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return MockAuthRemoteDataSource();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remote: ref.watch(authRemoteDataSourceProvider),
    local: ref.watch(authLocalDataSourceProvider),
  );
});

final authControllerProvider =
    AsyncNotifierProvider<AuthController, bool>(AuthController.new);

class AuthController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() {
    return ref.watch(authRepositoryProvider).hasSession();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).login(email, password),
    );
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(false);
  }
}
```

`AuthRepository` di snippet adalah **kontrak domain**. Implementasinya dapat login lalu menyimpan token melalui data source lokal. Karena controller hanya mengenal repository, detail secure storage tidak bocor ke presentation.

Untuk push, polanya serupa: provider menyediakan `FirebaseMessaging.instance` dan plugin local notification setelah Firebase diinisialisasi; provider data source/repository menghubungkan SDK dengan operasi fitur; `PushController` menyediakan state yang dikonsumsi halaman. Bila pembungkus repository belum menambah manfaat, controller boleh bergantung pada satu service push yang diinjeksi lewat provider. Yang penting, service tersebut tidak menyimpan state UI global atau mengambil alih navigasi secara tersembunyi.

### Kapan perlu use case?

**Repository langsung cukup** untuk operasi lurus seperti login → simpan sesi, logout → hapus sesi, atau ubah langganan satu topik. Menambah kelas use case satu baris untuk meneruskan argumen hanya menambah file dan navigasi kode.

**Use case mulai berguna** saat alur punya kebijakan atau orkestrasi yang pantas diuji terpisah—misalnya autentikasi yang harus memeriksa status akun, menyimpan sesi dan profil, lalu menentukan tindakan lanjutan; atau alur push yang menggabungkan izin, token perangkat, dan pendaftaran token ke backend. Use case juga bisa membantu ketika operasi dipakai dari beberapa entry point dan aturan bisnisnya perlu konsisten.

### Bagian yang berisiko over-engineering

- **Use case untuk setiap method:** tidak diperlukan bila hanya meneruskan panggilan ke repository.
- **Entity/model/mapper terpisah untuk data mock sederhana:** `AuthSession` dapat tetap satu tipe sampai format API/konversi sungguhan dibutuhkan.
- **Repository dan abstraksi untuk setiap pemanggilan Firebase:** berguna bila batas SDK perlu diuji/diganti, tetapi tidak perlu membuat banyak lapisan atau interface satu-method tanpa manfaat nyata.
- **Failure hierarchy dan pemetaan error berlapis untuk satu mock:** mulai sederhana; tambahkan struktur saat ada beberapa sumber error atau kebijakan recovery yang jelas.
- **Auth refresh di API client sebelum ada backend:** daftar fungsi dan interceptor refresh saat ini belum menambah nilai untuk login mock. Pertahankan hanya jika client benar-benar dipakai, lalu pisahkan tanggung jawab auth dari client jaringan generik.
- **Domain push lengkap tanpa aturan domain:** fitur yang dominan berupa integrasi plugin mungkin cukup dengan presentation + data terlebih dahulu. Tambahkan domain/repository ketika ada perilaku aplikasi yang perlu diabstraksikan, bukan sekadar agar semua fitur memiliki jumlah folder yang sama.

Trade-off utamanya: lebih banyak pemisahan membuat implementasi lebih mudah diganti dan diuji secara terisolasi, tetapi juga menambah file serta alur navigasi kode. Untuk proyek kecil ini, pertahankan batas jelas pada auth/storage dan state push, namun jangan menambah use case atau lapisan abstraksi sebelum ada kebutuhan yang bisa ditunjukkan.



## Checklist verifikasi

| Pertanyaan codelab | Temuan pada usulan AI |
| :--- | :--- |
| Interface di `domain`, implementasi di `data`? | **Ya.** `auth/domain/repositories/auth_repository.dart` dan `auth/data/repositories/auth_repository_impl.dart` terpisah. |
| `domain` bebas import Flutter/Dio/SQLite/Firebase? | **Belum terbukti.** Usulan ini hanya daftar folder. Dibuktikan dengan grep setelah refactor, bukan dengan membaca. |
| Use case untuk tiap CRUD satu baris? | **Tidak.** AI sendiri menolak use case per method. Catatannya: AI tidak menyiapkan use case sama sekali untuk auth. |
| Entity bebas mapping? | **Ya.** `AuthSession` tetap satu tipe. Tapi AI tetap menaruh `auth_session_model.dart` di struktur, padahal untuk login mock belum diperlukan. |
| DI terpusat, widget tidak `new Repository()`? | **Ya.** Wiring lewat provider. |

## Keputusan

| No | Usulan AI | Keputusan | Alasan |
| :-: | ----- | :-: | ----- |
| **1** | Pecah `auth_repository.dart`: `AuthSession` ke entity, kontrak ke domain, implementasi ke data | **Terima** | Sama persis dengan masalah di tabel pemetaan, dan mengikuti pola `announcements`. |
| **2** | `AuthRemoteDataSource`, `SecureTokenDataSource`, dan `auth_session_model.dart` | **Sederhanakan** | Login masih mock tanpa format API, jadi model dan remote data source belum menambah apa-apa. Cukup suntikkan fungsi login mock, seperti `loadRows` di `announcements`. |
| **3** | Ganti nama `token_store.dart` jadi `SecureTokenDataSource` | **Pindah, nama tetap TokenStore** | Lokasinya yang menentukan layer, bukan namanya. Mengurangi edit di file lain. |
| **4** | `api_client.dart`: pindah ke core, atau jangan diimplementasikan dulu | **Tolak penghapusan, pindah ke `features/auth/data/`** | Interceptor refresh adalah urusan auth, dan sudah menjadi syarat Minggu 6. Perilaku harus tetap sama. |
| **5** | Pesan error untuk pengguna dipilih di presentation | **Tolak** | Refactoring Challenge 3 minta exception diubah jadi `Failure` yang ramah sebelum sampai UI. `Failure` sudah punya message. |
| **6** | Folder `controllers/` dan `providers/` terpisah | **Tolak** | Notifier cukup di `providers/`, konsisten dengan `announcements`. Satu folder tambahan tanpa manfaat. |
| **7** | Ganti nama menjadi `AuthController` dan `authControllerProvider` | **Tolak** | Nama `authStateProvider` dipakai `main.dart`, `login_page`, dan `home_page`. Ganti nama memaksa edit tiga file tanpa mengubah arah dependensi. |
| **8** | Auth tanpa use case | **Ubah: satu use case LoginUser** | Validasi email dan panjang password sekarang terselip di repository mock. Itu aturan bisnis yang pantas ada di domain dan diuji dengan repository palsu. Logout dan `hasSession` tetap lewat repository langsung. |
| **9** | Pecah `push_service.dart`, hapus `ValueNotifier`, `pendingDeepLink`, dan callback navigasi global | **Tunda, catat sebagai keterbatasan** | Push adalah integrasi plugin tanpa aturan domain. Menghapus state global berisiko merusak klik notifikasi di tiga state yang sudah terbukti, padahal syaratnya perilaku identik. Background handler juga harus tetap top-level. |
| **10** | Pindah `home_page.dart` ke `app/pages/` | **Tolak** | Hanya memindah folder tanpa memutus dependensi terlarang. Tetap di `lib/pages/` sebagai presentation. |
| **11** | `login_page.dart` ke `features/auth/presentation/pages/` | **Terima** | Halaman itu milik fitur auth. |
| **12** | `main.dart` tetap composition root | **Terima** | Tidak ada perubahan. |
