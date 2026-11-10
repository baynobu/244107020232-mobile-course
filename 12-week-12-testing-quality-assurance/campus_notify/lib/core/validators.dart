/// Aturan bisnis dan logika validasi input aplikasi Campus Notify.
/// Seluruh fungsi di file ini merupakan pure functions tanpa dependensi ke BuildContext atau UI,
/// sehingga dapat diuji secara terisolasi dengan unit test berkecepatan tinggi.
library;

/// Validasi judul tugas atau pengumuman.
/// Menolak string kosong atau string yang hanya berisi karakter whitespace.
bool isValidTaskTitle(String value) {
  return value.trim().isNotEmpty;
}

/// Validasi masukan email pengguna kampus.
///
/// Kasus yang diperiksa:
/// - Nilai null atau kosong -> 'Email tidak boleh kosong'
/// - Tidak mengandung karakter '@' -> 'Format email tidak valid (harus mengandung @)'
/// - Memiliki spasi di dalam teks email -> 'Email tidak boleh mengandung spasi'
/// - Format domain tidak valid (misal '@' di awal/akhir) -> 'Format alamat email tidak lengkap'
String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Email tidak boleh kosong';
  }

  final trimmed = value.trim();

  if (trimmed.contains(' ')) {
    return 'Email tidak boleh mengandung spasi';
  }

  final atIndex = trimmed.indexOf('@');
  if (atIndex == -1) {
    return 'Format email tidak valid (harus mengandung @)';
  }

  // Cek apakah @ berada di awal atau akhir string
  if (atIndex == 0 || atIndex == trimmed.length - 1) {
    return 'Format alamat email tidak lengkap';
  }

  // Cek apakah ada domain dot setelah @
  final domainPart = trimmed.substring(atIndex + 1);
  if (!domainPart.contains('.')) {
    return 'Format domain email tidak valid (harus memiliki domain seperti .ac.id)';
  }

  return null;
}

/// Validasi masukan kata sandi pengguna.
///
/// Aturan bisnis:
/// - Nilai null atau kosong -> 'Kata sandi tidak boleh kosong'
/// - Panjang kurang dari 6 karakter -> 'Kata sandi minimal 6 karakter'
/// - Melebihi 64 karakter (kasus tepi Denial of Service) -> 'Kata sandi maksimal 64 karakter'
String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Kata sandi tidak boleh kosong';
  }

  if (value.length < 6) {
    return 'Kata sandi minimal 6 karakter';
  }

  if (value.length > 64) {
    return 'Kata sandi maksimal 64 karakter';
  }

  return null;
}

/// Validasi kata kunci pencarian pengumuman atau tugas.
///
/// Aturan:
/// - Nilai kosong atau hanya spasi mengembalikan pesan peringatan
/// - Nilai kurang dari 2 karakter mengembalikan pesan minimal panjang pencarian
/// - Mengembalikan null jika kueri valid
String? validateSearchQuery(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Kata kunci pencarian tidak boleh kosong';
  }

  final trimmed = value.trim();
  if (trimmed.length < 2) {
    return 'Kata kunci pencarian minimal 2 karakter';
  }

  return null;
}

