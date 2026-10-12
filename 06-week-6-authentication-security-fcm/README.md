# WEEK 6 -  Authentication, Security & FCM
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
![Test Praktikum 1](Docs/Test%20Praktikum.png)


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