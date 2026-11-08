# Panduan Pengambilan Screenshot Profiling (Week 11)

Direktori ini digunakan untuk menyimpan seluruh tangkapan layar (*screenshots*) hasil profiling performa menggunakan **Flutter DevTools** dan pengujian otomatis pada terminal.

---

## Daftar File Screenshot yang Wajib Disimpan

| No | Nama Berkas | Lokasi / Tab Sumber | Kondisi & Tampilan yang Diharapkan |
|:---:|---|---|---|
| **1** | `before-profile.png` | **DevTools → Tab Performance** | Grafik **Flame Chart** dan **Frame Chart** baseline (sebelum optimasi) yang memperlihatkan frame bar kuning/merah (> 16.6 ms) serta call stack build widget monolitik saat scrolling cepat. |
| **2** | `after-profile.png` | **DevTools → Tab Performance** | Grafik **Flame Chart** dan **Frame Chart** setelah optimasi kode, memperlihatkan frame bar hijau stabil (< 16.6 ms / 60 FPS) dan call stack yang ramping. |
| **3** | `memory-profile.png` | **DevTools → Tab Memory** | Tampilan **Heap Snapshot** setelah melakukan interaksi navigasi bolak-balik (Dashboard ↔ Detail Pengumuman sebanyak 5x) untuk membuktikan tidak ada akumulasi memori atau memory leak. |
| **4** | `analyze-test.png` | **Terminal (VS Code / PowerShell)** | Tampilan output perintah `flutter analyze` (**No issues found!**) dan `flutter test` (**All tests passed!**). |

---

## Langkah Praktis Pengambilan Screenshot di Flutter DevTools

### 1. Menjalankan Aplikasi dalam Mode Profile
Buka terminal di dalam folder `campus_notify`:
```powershell
cd campus_notify
flutter run -d windows --profile
# Atau jika menggunakan emulator Android:
# flutter run -d <id-device> --profile
```

### 2. Membuka Flutter DevTools di Browser
- Saat aplikasi berjalan di terminal, tekan tombol keyboard `v` untuk membuka DevTools di browser secara otomatis.
- Atau salin URL yang muncul di terminal (misalnya `http://127.0.0.1:9100`).

### 3. Mengambil Screenshot Tab Performance (`before-profile.png` / `after-profile.png`)
1. Di DevTools, klik tab **Performance**.
2. Klik tombol merah **Record**.
3. Di layar aplikasi, lakukan skenario: scroll ke bawah, scroll ke atas, buka detail pengumuman, klik kembali, dan buka AI chat.
4. Klik tombol **Stop** di DevTools.
5. Ambil tangkapan layar (Win + Shift + S di Windows) pada area grafik frame bar dan Flame Chart.
6. Simpan dengan nama `before-profile.png` (untuk baseline) atau `after-profile.png` (setelah kode teroptimasi).

### 4. Mengambil Screenshot Tab Memory (`memory-profile.png`)
1. Di DevTools, klik tab **Memory**.
2. Lakukan navigasi bolak-balik (Buka pengumuman → Kembali → Buka pengumuman → Kembali sebanyak 5 kali).
3. Klik tombol **Take Heap Snapshot** di pojok kiri atas tab Memory.
4. Ambil tangkapan layar tampilan analisis heap snapshot.
5. Simpan dengan nama `memory-profile.png`.

### 5. Mengambil Screenshot Terminal (`analyze-test.png`)
Jalankan perintah berikut di terminal:
```powershell
cd campus_notify
flutter analyze
flutter test
```
Ambil screenshot terminal yang menampilkan kedua perintah tersebut sukses 100%, lalu simpan dengan nama `analyze-test.png`.

