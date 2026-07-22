import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dashboard/core/auth/auth_gate.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Phase 3 router — only the AuthGate entry point.
/// Dashboard routes will be added in Phase 4.
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const AuthGate(),
        transitionsBuilder: _fadeTransition,
      ),
    ),
  ],
);

/// Smooth fade transition.
Widget _fadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(
    opacity: CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
    ),
    child: child,
  );
}
