import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week4_app/data/paged_posts.dart';
import 'package:week4_app/main.dart';

class _FakePagedPostsNotifier extends PagedPostsNotifier {
  @override
  PagedPostsState build() => const PagedPostsState(items: [], hasMore: false);
}

void main() {
  testWidgets('MyApp renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pagedPostsProvider.overrideWith(_FakePagedPostsNotifier.new),
        ],
        child: const MyApp(),
      ),
    );

    expect(find.byType(MyApp), findsOneWidget);
  });
}
