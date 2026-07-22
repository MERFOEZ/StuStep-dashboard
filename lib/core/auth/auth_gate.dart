import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dashboard/core/theme/app_theme.dart';
import 'package:dashboard/core/widgets/animated_gradient_mesh.dart';
import 'package:dashboard/screens/auth/login_page.dart';
import 'package:dashboard/screens/dashboard/dashboard_shell.dart';
import 'package:dashboard/core/services/auth_service.dart';
import 'package:dashboard/core/widgets/animated_snackbar.dart';
import 'package:dashboard/core/l10n/app_localizations.dart';

/// Auth gate that decides what screen to show based on Firebase auth state
/// and Firestore RBAC role check.
///
/// Pattern (from RBAC skill):
///   1. StreamBuilder on authStateChanges → unauthenticated? → LoginPage
///   2. Authenticated → FutureBuilder on checkUserRole(uid)
///      - admin → DashboardShell
///      - not admin → sign out + error
///      - error → fail closed (sign out)
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return AnimatedGradientMesh(
      child: StreamBuilder<User?>(
        stream: _authService.authStateChanges,
        builder: (context, snapshot) {
          // ─── Loading auth state ─────────────────────────────────
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingScreen();
          }

          // ─── Not authenticated → Login ──────────────────────────
          final user = snapshot.data;
          if (user == null) {
            return LoginPage(
              onLoginSuccess: (_) {
                // Auth stream will automatically update — no manual nav needed.
                // The StreamBuilder will pick up the new auth state.
              },
            );
          }

          // ─── Authenticated → Check RBAC role ────────────────────
          return FutureBuilder(
            // Force re-check on every auth state change
            key: ValueKey(user.uid),
            future: _authService.checkUserRole(user.uid),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingScreen();
              }

              if (roleSnapshot.hasError) {
                // Fail closed: sign out on error
                _failClosed();
                return _buildLoadingScreen();
              }

              final appUser = roleSnapshot.data;
              if (appUser == null || !appUser.isAdmin) {
                // Not admin → sign out + show error
                _failClosed(showError: true);
                return _buildLoadingScreen();
              }

              // Admin → Dashboard Shell (the full dashboard)
              return DashboardShell(
                userName: appUser.name.isNotEmpty ? appUser.name : 'Admin',
                onSignOut: () => _authService.signOut(),
              );
            },
          );
        },
      ),
    );
  }

  /// Sign out and optionally show access denied message.
  void _failClosed({bool showError = false}) {
    // Use addPostFrameCallback to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authService.signOut();
      if (showError && mounted) {
        final s = S.of(context);
        showAnimatedSnackBar(context, message: s.accessDenied, isError: true);
      }
    });
  }

  /// Full-screen loading indicator with pulsing animation.
  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pulsing logo
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(102),
                    blurRadius: 24,
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.school_rounded,
                color: Colors.white,
                size: 28,
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1.05, 1.05),
                  duration: 1200.ms,
                  curve: Curves.easeInOut,
                ),
            const SizedBox(height: 24),
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primary.withAlpha(179),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'StuStep',
              style: TextStyle(
                color: AppColors.textHint,
                fontSize: 14,
                letterSpacing: 2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fade(
              begin: 0.6,
              end: 1.0,
              duration: 1200.ms,
            ),
      ),
    );
  }
}
