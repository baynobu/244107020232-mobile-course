/// Fungsi validasi judul tugas sesuai modul Codelab Week 12 Bagian 3.
/// Memeriksa apakah judul tugas berisi teks setelah spasi di awal dan akhir diabaikan.
bool isValidTaskTitle(String value) {
  return value.trim().isNotEmpty;
}

