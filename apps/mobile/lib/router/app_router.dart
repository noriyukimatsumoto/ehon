import 'package:go_router/go_router.dart';

import '../presentation/component/page/ehon_page.dart';
import '../presentation/component/page/home_page.dart';
import '../presentation/component/page/settings_page.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/read',
      builder: (context, state) {
        final jsonPath = state.extra! as String;
        return EhonPage(jsonPath: jsonPath);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);
