import 'package:go_router/go_router.dart';
import 'pages/paged_post_page.dart';
import 'pages/post_detail_page.dart';

/// Konfigurasi routing aplikasi menggunakan GoRouter.
/// Mengatur rute daftar post (/) dan halaman detail post (/post/:id).
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'posts',
      builder: (context, state) => const PagedPostPage(),
      routes: [
        GoRoute(
          path: 'post/:id',
          name: 'post_detail',
          builder: (context, state) {
            final idString = state.pathParameters['id'] ?? '0';
            final postId = int.tryParse(idString) ?? 0;
            return PostDetailPage(postId: postId);
          },
        ),
      ],
    ),
  ],
);
