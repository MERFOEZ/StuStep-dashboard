import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dashboard/core/theme/app_theme.dart';
import 'package:dashboard/core/l10n/app_localizations.dart';
import 'package:dashboard/main.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Premium Frosted Top Bar — Vibrant Light Mode
/// ─────────────────────────────────────────────────────────────────────────────
/// Floating glass panel with animated search, gradient-accented user avatar,
/// living notification indicator, and language toggle with micro-interactions.
class GlassTopBar extends StatefulWidget {
  final String userName;
  final String pageTitle;
  final VoidCallback onToggleLocale;

  const GlassTopBar({
    super.key,
    required this.userName,
    required this.pageTitle,
    required this.onToggleLocale,
  });

  @override
  State<GlassTopBar> createState() => _GlassTopBarState();
}

class _GlassTopBarState extends State<GlassTopBar> {
  bool _searchFocused = false;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final localeProvider = LocaleProviderScope.of(context);

    return Container(
      height: 72,
      margin: const EdgeInsets.only(right: 20, top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.82),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border.withOpacity(0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 24,
            offset: const Offset(0, 6),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: AppColors.primary.withOpacity(0.02),
            blurRadius: 32,
            offset: Offset.zero,
            spreadRadius: -8,
          ),
        ],
      ),
      child: Row(
        children: [
          // ─── Animated Page Title with gradient accent ──────────
          _AnimatedPageTitle(title: widget.pageTitle),

          const Spacer(),

          // ─── Search Bar with focus glow ────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            width: _searchFocused ? 320 : 220,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: _searchFocused ? Colors.white : AppColors.surfaceTinted,
              border: Border.all(
                color: _searchFocused
                    ? AppColors.primary.withOpacity(0.4)
                    : AppColors.border.withOpacity(0.5),
              ),
              boxShadow: _searchFocused
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: -4,
                      ),
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.04),
                        blurRadius: 40,
                        spreadRadius: -8,
                      ),
                    ]
                  : null,
            ),
            child: Focus(
              onFocusChange: (f) => setState(() => _searchFocused = f),
              child: TextField(
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  hintText: '${s.appTitle}...',
                  hintStyle: TextStyle(
                    color: AppColors.textHint,
                    fontSize: 13,
                  ),
                  prefixIcon: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.search_rounded,
                      color: _searchFocused
                          ? AppColors.primary
                          : AppColors.textHint,
                      size: 18,
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 11),
                  isDense: true,
                  filled: false,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // ─── Language Toggle ────────────────────────────────────
          Tooltip(
            message: localeProvider.isArabic ? 'English' : 'عربي',
            child: _TopBarIconButton(
              onPressed: widget.onToggleLocale,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.08),
                      AppColors.secondary.withOpacity(0.06),
                    ],
                  ),
                ),
                child: Text(
                  localeProvider.isArabic ? 'EN' : 'ع',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // ─── Notifications with animated pulse ─────────────────
          Tooltip(
            message: 'الإشعارات',
            child: _TopBarIconButton(
              onPressed: () {},
              child: Stack(
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.neonGreen,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neonGreen.withOpacity(0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    )
                        .animate(
                            onPlay: (c) => c.repeat(reverse: true))
                        .scale(
                          begin: const Offset(1.0, 1.0),
                          end: const Offset(1.3, 1.3),
                          duration: 1500.ms,
                          curve: Curves.easeInOut,
                        ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 16),

          // ─── User Avatar — gradient ring + initials ─────────────
          _UserAvatarChip(userName: widget.userName),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, curve: Curves.easeOutCubic)
        .slideY(begin: -0.08, duration: 500.ms, curve: Curves.easeOutCubic);
  }
}

/// Animated page title with gradient accent bar on the left.
class _AnimatedPageTitle extends StatelessWidget {
  final String title;
  const _AnimatedPageTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 3.5,
          height: 22,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: const LinearGradient(
              colors: AppColors.gradientPrimary,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: -2,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOutCubic,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.15),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: Text(
            title,
            key: ValueKey(title),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: AppColors.textPrimary,
                ),
          ),
        ),
      ],
    );
  }
}

/// User avatar chip with gradient ring.
class _UserAvatarChip extends StatefulWidget {
  final String userName;
  const _UserAvatarChip({required this.userName});

  @override
  State<_UserAvatarChip> createState() => _UserAvatarChipState();
}

class _UserAvatarChipState extends State<_UserAvatarChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        transform: Matrix4.identity()..scale(_hovered ? 1.02 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: _hovered ? AppColors.surfaceHover : AppColors.surfaceTinted,
          border: Border.all(
            color: _hovered
                ? AppColors.primary.withOpacity(0.15)
                : AppColors.border.withOpacity(0.4),
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.06),
                    blurRadius: 16,
                    spreadRadius: -4,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Gradient avatar circle
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: AppColors.gradientPrimary,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 10,
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  widget.userName.isNotEmpty
                      ? widget.userName[0].toUpperCase()
                      : 'A',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              widget.userName,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBarIconButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;

  const _TopBarIconButton({
    required this.onPressed,
    required this.child,
  });

  @override
  State<_TopBarIconButton> createState() => _TopBarIconButtonState();
}

class _TopBarIconButtonState extends State<_TopBarIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 38,
          height: 38,
          transform: Matrix4.identity()..scale(_hovered ? 1.08 : 1.0),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: _hovered ? AppColors.surfaceHover : Colors.transparent,
            border: _hovered
                ? Border.all(color: AppColors.border.withOpacity(0.4))
                : null,
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}
