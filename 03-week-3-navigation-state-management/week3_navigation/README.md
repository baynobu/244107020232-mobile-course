# Praktikum 1
![screenshot](screenshot/Praktikum%201.png)

# Praktikum 2
![screenshot](screenshot/Praktikum%202.png)

# Refleksi Praktikum 3 3
Mengapa menampilkan ulang data lama (stale data) dengan indikator refresh kadang lebih baik daripada mengosongkan layar? Kapan pola itu penting? <br>
Karena pengguna masih dapat melihat informasi yang tersedia sambil menunggu data terbaru dimuat. Jika layar langsung dikosongkan, pengguna dapat merasa aplikasi lambat atau bahkan mengira terjadi kesalahan. Pola ini penting pada aplikasi yang sering mengambil data dari internet, seperti aplikasi ecommerce, media sosial, atau berita, agar pengalaman pengguna tetap nyaman dan informasi tetap dapat diakses selama proses pembaruan data berlangsung.

# AI Promt Chalenge
## Promt
Buatkan halaman Flutter bernama StatsPage menggunakan flutter_riverpod.
Requirements:<br>
- ConsumerWidget dengan satu AsyncNotifierProvider yang mensimulasikan
  pengambilan data statistik (delay 2 detik, kadang gagal 30%).<br>
- UI harus menangani loading (spinner), error (pesan + tombol retry),
  dan success (ListView 3 item).<br>
- Berikan unit test untuk notifier-nya.<br>
Jelaskan setiap bagian kode dalam komentar.
## Hasil
![screenshot](screenshot/AI%20Prompt%20Challenge%201.png)
![screenshot](screenshot/AI%20Prompt%20Challenge%202.png)
## AI Verification Checklist
- Apakah state diubah secara immutable (tidak ada state.add() atau mutasi list langsung)? <br>
Ya, state sudah diubah secara immutable (tidak mutasi langsung). <br>
- Apakah ref.watch hanya dipakai di dalam build, dan ref.read di callback?<br>
Ya, ref.watch hanya dipakai di dalam build, dan ref.read di callback. <br>
- Apakah ketiga state AsyncValue benar-benar ditangani (bukan hanya success)?<br>
Ya, ketiga state AsyncValue benar-benar ditangani (bukan hanya success).<br>
- Apakah provider dideklarasikan dengan tipe eksplisit dan tidak duplikat dengan provider lain?<br>
Ya, provider dideklarasikan dengan tipe eksplisit dan tidak duplikat dengan provider lain.<br>
- Apakah kode AI memakai API Riverpod versi lama (StateProvider antipattern, StateNotifierProvider usang, atau Consumer bertingkat yang tidak perlu)? Perbaiki ke pola Notifier/ConsumerWidget.<br>
Tidak, kode AI TIDAK menggunakan API Riverpod versi lama. Kode sudah menggunakan standar Riverpod versi terbaru (Riverpod 2.0+) dengan pola AsyncNotifier dan ConsumerWidget. <br>
- Jalankan flutter analyze dan flutter test, apakah hasil AI lolos tanpa warning?<br>
![screenshot](screenshot/Flutter%20Analyze%20&%20Flutter%20Test%20AI%20Promt%20Challenge.png)


# Recactoring Challenge
Hasil Flutter analyze dan flutter test pada refactoring challenge
![screenshot](screenshot/Flutter%20Analyze%20&%20Flutter%20Test%20Refactoring%20Challenge.png)

# Refleksi
1. Kapan setState masih cukup, dan kapan state harus naik ke Riverpod?<br>
SetState masih cukup digunakaan jika state hanya digunakan oleh satu widget atau halaman saja. Sedangkan state harus naik riverpod jika data digunakan oleh banyak widget atau halaman.<br>
2. Apa perbedaan context.go dan context.push, dan kapan masing-masing tepat digunakan?<br>
Context.go() digunakan untuk berpindah ke halaman baru dengan mengganti halaman saat ini. Sedangkan context.push() digunakan untuk menambahkan halaman baru di atas halaman yang sedang aktif. Contohnya, jika pengguna berada di home lalu membuka detail produk, maka context.push() lebih tepat digunakan. Namun jika pengguna sudah login dan harus masuk ke home tanpa kembali ke login, maka context.go() lebih tepat digunakan.<br>
3. Bagaimana AsyncValue mencegah bug dibanding tiga boolean terpisah?<br>
AsyncValue mencegah bug karena hanya memiliki satu kondisi yang aktif pada satu waktu, yaitu loading, error, atau data. Jika menggunakan tiga boolean terpisah seperti isLoading, hasError, dan hasData, bisa saja nilainya tidak konsisten, misalnya isLoading dan hasError bernilai true secara bersamaan. Dengan AsyncValue, kondisi tersebut sudah diatur oleh Riverpod sehingga state menjadi lebih jelas, rapi, dan mengurangi kemungkinan kesalahan pada aplikasi.<br>
4. Bagian mana dari hasil AI yang Anda perbaiki, dan mengapa?<br>
Ada beberapa bagian dari kode AI yang saya perbaiki:
-  Mengganti ref.watch pada bagian StatsNotifer dengan ref.read. Karena jika menggunakan ref.watch halaman Statistik tidak otomatis berubah saat ada tugas baru, sedangkan jika menggunakan ref.read halaman statistik akan otomatis berubah saat ada tugas baru.
- Mengganti pump() pada bagian widget_test dengan pumpAndSettle(). Karena pump() hanya menjalankan satu frame sehingga animasi dialog belum selesai sepenuhnya. Akibatnya, pengujian dapat gagal atau mendeteksi widget yang masih muncul. Dengan pumpAndSettle(), pengujian akan menunggu hingga semua animasi selesai sebelum melakukan pengecekan hasil.
- Awalnya rute /detail/:id belum ditambahkan saat menggunakan ShellRoute, sehingga halaman detail tidak berjalan dengan baik. Saya memperbaikinya dengan meletakkan rute detail di luar ShellRoute dan menggunakan context.push(). Dengan cara ini, halaman detail dapat dibuka tanpa menampilkan NavigationBar dan pengguna bisa kembali ke halaman sebelumnya dengan tombol Back seperti biasa.

# Hasil Akhir
## Halaman Home
![screenshot](screenshot/Halaman%20Home.png)

## Halaman Detail
![screenshot](screenshot/Halaman%20Detail.png)

## Halaman Statistik
![screenshot](screenshot/Halaman%20Statistik.png)