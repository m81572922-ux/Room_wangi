# RW Gacor Flutter Starter

Flutter project starter untuk aplikasi pendamping gaming dengan UI neon ungu, logo berbasis ikon, panel menu cepat di dalam aplikasi, skin gallery placeholder, catatan Ranked, dan tips konektivitas.

## Persyaratan
- Flutter SDK (stable; Dart 3.3+)
- Android SDK untuk build Android
- Android Studio atau VS Code

## Jalankan
```bash
flutter pub get
flutter run
```

## Build APK
```bash
flutter build apk --release
```
Output umumnya:
`build/app/outputs/flutter-apk/app-release.apk`

## Build platform lain
- Windows: `flutter build windows` (jalankan di Windows dengan desktop support diaktifkan)
- Web: `flutter build web`
- iOS: `flutter build ios` memerlukan macOS + Xcode
Tidak semua target bisa dibangun dari semua OS. Android APK dapat dibangun di Windows, macOS, atau Linux setelah toolchain disiapkan.

## Status fitur
- UI, navigasi, quick menu dalam aplikasi, tombol favorit demo: ada.
- Logo saat ini dibuat dari ikon Flutter (bukan aset logo final).
- Skin gallery masih contoh beberapa hero; data dan gambar belum disertakan.
- Network page memberi tips; tidak mengukur ping server MLBB.
- Belum ada overlay Android di atas aplikasi lain. Overlay sistem memerlukan implementasi native Android dan izin khusus.
- Tidak memanipulasi matchmaking, game memory, posisi musuh, atau skin premium.


## Perbaikan build Android

Build log sebelumnya menunjukkan `Your app is using an unsupported Gradle project`.
Penyebabnya: ZIP awal hanya berisi source Dart dan `pubspec.yaml`, belum menyertakan
scaffold platform Android/Gradle yang dibuat oleh Flutter.

Sebelum build pertama, jalankan salah satu dari berikut dari folder proyek:

- **Windows PowerShell:** `.\prepare_android.ps1`
- **Linux/macOS:** `bash prepare_android.sh`

Script memakai `flutter create --platforms=android` untuk membuat file Android/Gradle
resmi yang sesuai dengan versi Flutter SDK yang terpasang, lalu mengambil dependency.
Setelah itu jalankan `flutter build apk --release`.

Jika build dilakukan lewat layanan CI yang punya langkah build sendiri, pastikan langkah
persiapan Android ini dijalankan sebelum `flutter build apk --release`.

Catatan: perbaikan ini mengatasi struktur proyek yang tidak lengkap; build tetap perlu
dijalankan di lingkungan yang memiliki Flutter SDK, Android SDK, dan koneksi dependency.


## Android scaffold fix (v2)

This ZIP now includes an Android Gradle project scaffold (`android/`) so Flutter can
recognize the project as a standard Android app. On first use, Flutter may create
`android/local.properties` automatically when invoked from a machine with Flutter installed.
If your build service specifically requires a Gradle wrapper (`android/gradlew`), run
`flutter create --platforms=android --project-name rw_gacor .` once in the project root,
then rebuild. This package has not been validated by a completed APK build in this environment.


## Shizuku setup (Android)

1. Install the official **Shizuku** app separately from its official project/release page.
2. In Shizuku, start its service using Wireless debugging (Android 11+) or the supported root method. On non-root devices, the service may need to be started again after a reboot.
3. Open RW GACOR. It checks whether Shizuku is running.
4. Tap **MINTA IZIN SHIZUKU**. Android/Shizuku should show a permission request for RW GACOR; approve it, then tap **CEK ULANG SHIZUKU** if needed.
5. The app only uses this integration to detect service/permission status and gate its local demo UI. It does not use Shizuku to modify Mobile Legends, unlock server-side skins, or change Ranked matchmaking.

Important: RW GACOR is not automatically added as a visible toggle inside Shizuku. Shizuku shows/handles the permission request when the app requests access. This ZIP is source code, not a prebuilt APK, and a release build still needs to be run and tested with Flutter + Android SDK.


## Catatan versi revisi

- Menambahkan deklarasi `ShizukuProvider` pada manifest.
- Menghapus repositori Xposed yang tidak diperlukan; dependency Shizuku diambil dari Maven Central.
- Menambahkan tombol Bot Practice demo pada halaman catatan Ranked. Ini hanya demo lokal dan tidak membuat bot masuk ke matchmaking MLBB.
- Build belum dapat diverifikasi dalam lingkungan pembuatan ZIP ini karena Flutter/Android SDK tidak tersedia di sini. Jangan anggap bebas error sebelum menjalankan build di mesin dengan toolchain Android lengkap.


## Revisi 3: ikon aplikasi dan catatan instalasi

- Launcher icon RW GACOR ditambahkan untuk density mdpi sampai xxxhdpi, termasuk adaptive icon Android 8+.
- AndroidManifest sekarang merujuk ke `@mipmap/ic_launcher`.
- Paket Android menggunakan `applicationId` `com.example.rwgacor`.

Jika APK hasil bot menampilkan pesan “paket tampaknya tidak valid”, itu bukan bukti bahwa ikon penyebabnya. Pastikan file yang diunduh benar-benar berakhiran `.apk` (bukan ZIP/AAB yang hanya diganti nama), unduh ulang bila file mungkin terpotong, dan kirim log detail instalasi atau APK analyzer untuk mengetahui kode kegagalan. Source ZIP ini sendiri belum dikompilasi di lingkungan pembuatnya, jadi jangan anggap APK telah teruji.

## GitHub Actions build
See `README_GITHUB_BUILD.md` for instructions to build a debug APK on GitHub Actions. The workflow verifies the APK signature before uploading it as an artifact.
