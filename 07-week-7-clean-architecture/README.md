# Campus Notify: Refactor Clean Architecture (Minggu 7)

## Tujuan
Merefactor project Minggu 6 (login, secure storage, FCM, daftar pengumuman) menjadi
struktur feature-first Clean Architecture, tanpa mengubah perilaku aplikasi.

## Fitur utama
- Login mock dengan guard route (GoRouter + Riverpod)
- Token di flutter_secure_storage, Dio refresh otomatis saat 401
- FCM: permission, token + onTokenRefresh, topik pengumuman-kampus, klik notifikasi ke /pengumuman/:id
- Daftar dan detail pengumuman

## Stack
Flutter, Riverpod, GoRouter, Dio, flutter_secure_storage, Firebase Messaging, flutter_local_notifications


## Praktikum 1: Pemetaan dan pelanggaran (sebelum refactor)

### Pemetaan file ke layer
(tempel tabel pemetaan yang sudah kamu sesuaikan)

### Hasil pemeriksaan sebelum refactor
| Pemeriksaan | Hasil |
|---|---|
| Presentation menyentuh jaringan/database | 0 temuan |
| Logika bisnis di build() | 0 temuan |
| Instansiasi manual (DI bocor) | 1 temuan: lib/providers/auth_provider.dart:11 (`AuthRepository()`) |

<table>
  <tr>
    <td><img src="Docs/Hasil Praktikum 1.png" width="180"></td>
  </tr>
</table>

Catatan: pemeriksaan 1 dan 2 nol karena halaman memakai data statis lokal. Pelanggaran lain
yang tidak tertangkap grep: halaman membaca lib/data/announcements.dart langsung, dan
AuthNotifier bergantung pada TokenStore (kelas konkret).

## Praktikum 3: Presentation, DI, dan verifikasi

<table>
  <tr>
    <td><img src="Docs/Verif Praktikum 3.png" width="180"></td>
    <td><img src="Docs/Analyze Praktikum 3.png" width="180"></td>
    <td><img src="Docs/Test Praktikum 3.png" width="180"></td>
  </tr>
</table>

## AI Prompt Challenge
Ada pada Docs/ai-prompt.md

## Refactoring Challenge - Refactoring Auth

<table>
  <tr>
    <td><img src="Docs/Verifikasi Refactoring.png" width="180"></td>
    <td><img src="Docs/Analyze Refactoring.png" width="180"></td>
    <td><img src="Docs/Test Refactoring.png" width="180"></td>
  </tr>
</table>

## Struktur File

lib
├── core
│   ├── failures.dart
│   └── format.dart
├── data
│   └── api_errors.dart
├── features
│   ├── announcements
│   │   ├── data
│   │   │   ├── datasources
│   │   │   │   └── announcement_local_source.dart
│   │   │   ├── models
│   │   │   │   └── announcement_model.dart
│   │   │   └── repositories
│   │   │       └── announcement_repository_impl.dart
│   │   ├── domain
│   │   │   ├── entities
│   │   │   │   └── announcement.dart
│   │   │   ├── repositories
│   │   │   │   └── announcement_repository.dart
│   │   │   └── usecases
│   │   │       └── get_announcements.dart
│   │   └── presentation
│   │       ├── pages
│   │       │   ├── announcement_page.dart
│   │       │   └── announcements_list.dart
│   │       └── providers
│   │           └── announcements_providers.dart
│   └── auth
│       ├── data
│       │   ├── api_client.dart
│       │   ├── datasources
│       │   │   └── auth_mock_source.dart
│       │   ├── repositories
│       │   │   └── auth_repository_impl.dart
│       │   └── token_store.dart
│       ├── domain
│       │   ├── entities
│       │   │   └── auth_session.dart
│       │   ├── repositories
│       │   │   └── auth_repository.dart
│       │   └── usecases
│       │       └── login_user.dart
│       └── presentation
│           ├── pages
│           │   └── login_page.dart
│           └── providers
│               └── auth_provider.dart
├── main.dart
├── messaging
│   └── push_service.dart
└── pages
    └── home_page.dart