import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:dashboard/core/theme/app_theme.dart';
import 'package:dashboard/core/widgets/animated_counter.dart';

/// The current data state of a stat card.
enum StatCardState {
  /// Data is being fetched — show shimmer/loading indicator.
  loading,

  /// Data fetch failed — show error icon with optional retry.
  error,

  /// Data loaded successfully — show the animated counter.
  loaded,
}

/// Premium stat card with gradient glow, animated counter, and hover effect.
///
/// Supports three visual states:
///  - [StatCardState.loading] — pulsing shimmer placeholder
///  - [StatCardState.error]   — error icon with optional retry tap
///  - [StatCardState.loaded]  — animated counter roll-up
class AnimatedStatCard extends StatefulWidget {
  final String label;
  final int value;
  final IconData icon;
  final List<Color> gradient;
  final String? tooltip;
  final VoidCallback? onTap;
  final StatCardState state;
  final VoidCallback? onRetry;

  const AnimatedStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
    this.tooltip,
    this.onTap,
    this.state = StatCardState.loaded,
    this.onRetry,
  });

  @override
  State<AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<AnimatedStatCard>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late final AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final card = MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          transform: _hovered
              ? (Matrix4.identity()..setTranslationRaw(0.0, -4.0, 0.0))
              : Matrix4.identity(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withValues(alpha: _hovered ? 0.12 : 0.07),
                  border: Border.all(
                    color: _hovered
                        ? widget.gradient.first.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.gradient.first
                          .withValues(alpha: _hovered ? 0.25 : 0.1),
                      blurRadius: _hovered ? 32 : 16,
                      spreadRadius: _hovered ? -4 : -8,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Gradient icon container
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: LinearGradient(
                              colors: widget.gradient,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: widget.gradient.first
                                    .withValues(alpha: 0.4),
                                blurRadius: 12,
                                spreadRadius: -2,
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.icon,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        // Status indicator
                        _buildStatusBadge(),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Value area — switches between loading/error/loaded
                    _buildValueArea(context),
                    const SizedBox(height: 6),
                    Text(
                      widget.label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textHint,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(message: widget.tooltip!, child: card);
    }
    return card;
  }

  /// Builds the status badge (top-right of the card).
  Widget _buildStatusBadge() {
    switch (widget.state) {
      case StatCardState.loading:
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.info.withValues(alpha: 0.15),
            border: Border.all(
              color: AppColors.info.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '...',
                style: TextStyle(
                  color: AppColors.info,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );

      case StatCardState.error:
        return GestureDetector(
          onTap: widget.onRetry,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.error.withValues(alpha: 0.15),
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.refresh_rounded,
                  size: 14,
                  color: AppColors.error,
                ),
                const SizedBox(width: 4),
                Text(
                  'خطأ',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );

      case StatCardState.loaded:
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.success.withValues(alpha: 0.15),
            border: Border.all(
              color: AppColors.success.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.trending_up_rounded,
                size: 14,
                color: AppColors.success,
              ),
              const SizedBox(width: 4),
              Text(
                'نشط',
                style: TextStyle(
                  color: AppColors.success,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
    }
  }

  /// Builds the main value display area based on the current state.
  Widget _buildValueArea(BuildContext context) {
    switch (widget.state) {
      case StatCardState.loading:
        // Shimmer placeholder for the number
        return AnimatedBuilder(
          animation: _shimmerCtrl,
          builder: (context, _) {
            final shimmerValue = _shimmerCtrl.value;
            return Container(
              width: 80,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  begin: Alignment(-1.0 + 2.0 * shimmerValue, 0),
                  end: Alignment(1.0 + 2.0 * shimmerValue, 0),
                  colors: [
                    AppColors.glassFill,
                    widget.gradient.first.withValues(alpha: 0.15),
                    AppColors.glassFill,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            );
          },
        );

      case StatCardState.error:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: AppColors.error.withValues(alpha: 0.7),
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              '—',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textMuted,
                    letterSpacing: -0.5,
                  ),
            ),
          ],
        );

      case StatCardState.loaded:
        return AnimatedCounter(
          end: widget.value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
        );
    }
  }
}
