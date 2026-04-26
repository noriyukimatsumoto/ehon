import 'package:go_router/go_router.dart';

import '../presentation/component/page/book_selection_page.dart';
import '../presentation/component/page/ehon_page.dart';
import '../presentation/component/page/settings_page.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const BookSelectionPage(),
    ),
    GoRoute(
      path: '/read',
      builder: (context, state) {
        final xmlPath = state.extra! as String;
        return EhonPage(xmlPath: xmlPath);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);
