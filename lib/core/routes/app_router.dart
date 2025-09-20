import 'package:go_router/go_router.dart';
import '../widgets/main_navigation.dart';
import '../../features/inbox/presentation/pages/inbox_home_page.dart';
import '../../features/money_receive/presentation/pages/money_receive_home_page.dart';
import '../../features/pending/presentation/pages/pending_home_page.dart';
import '../../features/history/presentation/pages/history_home_page.dart';

class AppRouter {
  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    initialLocation: '/inbox',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigation(navigationShell: navigationShell);
        },
        branches: [
          // Inbox Navigation Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/inbox',
                builder: (context, state) => const InboxHomePage(),
              ),
            ],
          ),
          // Money Receive Navigation Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/money-receive',
                builder: (context, state) => const MoneyReceiveHomePage(),
              ),
            ],
          ),
          // Pending Navigation Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/pending',
                builder: (context, state) => const PendingHomePage(),
              ),
            ],
          ),
          // History Navigation Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                builder: (context, state) => const HistoryHomePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
