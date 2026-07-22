import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:dashboard/core/theme/app_theme.dart';
import 'package:dashboard/core/l10n/app_localizations.dart';
import 'package:dashboard/main.dart';

/// Glass top bar with search, language toggle, and user profile.
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

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: AppColors.surface1.withValues(alpha: 0.7),
            border: Border(
              bottom: BorderSide(
                color: AppColors.glassBorder.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // ─── Page Title ─────────────────────────────────────
              Text(
                widget.pageTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
              ),

              const Spacer(),

              // ─── Search Bar ─────────────────────────────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                width: _searchFocused ? 300 : 220,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.glassFill,
                  border: Border.all(
                    color: _searchFocused
                        ? AppColors.primary.withValues(alpha: 0.5)
                        : AppColors.glassBorder.withValues(alpha: 0.3),
                  ),
                  boxShadow: _searchFocused
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            blurRadius: 16,
                            spreadRadius: -4,
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
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: _searchFocused
                            ? AppColors.primaryLight
                            : AppColors.textMuted,
                        size: 18,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      isDense: true,
                      filled: false,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // ─── Language Toggle ────────────────────────────────
              Tooltip(
                message: localeProvider.isArabic ? 'English' : 'عربي',
                child: _TopBarIconButton(
                  onPressed: widget.onToggleLocale,
                  child: Text(
                    localeProvider.isArabic ? 'EN' : 'ع',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // ─── Notifications ──────────────────────────────────
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
                                color: AppColors.neonGreen.withValues(alpha: 0.6),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // ─── User Avatar ────────────────────────────────────
              Tooltip(
                message: widget.userName,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.glassFill,
                    border: Border.all(
                      color: AppColors.glassBorder.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: AppColors.gradientViolet,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            widget.userName.isNotEmpty
                                ? widget.userName[0].toUpperCase()
                                : 'A',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
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
              ),
            ],
          ),
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
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: _hovered
                ? AppColors.sidebarHover
                : Colors.transparent,
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}
