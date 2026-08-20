import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dashboard/core/theme/app_theme.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Empty State Widget — Premium Floating Icon with Gradient CTA
/// ─────────────────────────────────────────────────────────────────────────────
/// Animated floating icon inside gradient-ringed circle, breathable typography,
/// and a gradient call-to-action button with glow shadow.
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Floating icon with gradient ring + ambient glow
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.secondary.withOpacity(0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.15),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 32,
                    spreadRadius: -8,
                  ),
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.06),
                    blurRadius: 48,
                    spreadRadius: -12,
                  ),
                ],
              ),
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: AppColors.gradientPrimary,
                ).createShader(bounds),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 38,
                ),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(
                  begin: 0,
                  end: -10,
                  duration: 2200.ms,
                  curve: Curves.easeInOut,
                ),
            const SizedBox(height: 32),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textHint,
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 28),
              _GradientActionButton(
                label: actionLabel!,
                onPressed: onAction!,
              ),
            ],
          ],
        )
            .animate()
            .fadeIn(duration: 600.ms, curve: Curves.easeOutCubic)
            .scale(
              begin: const Offset(0.95, 0.95),
              duration: 600.ms,
              curve: Curves.easeOutCubic,
            ),
      ),
    );
  }
}

class _GradientActionButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const _GradientActionButton({
    required this.label,
    required this.onPressed,
  });

  @override
  State<_GradientActionButton> createState() => _GradientActionButtonState();
}

class _GradientActionButtonState extends State<_GradientActionButton> {
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
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          transform: Matrix4.identity()..scale(_hovered ? 1.04 : 1.0),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              colors: _hovered
                  ? AppColors.gradientPrimary
                      .map((c) => Color.lerp(c, Colors.white, 0.08) ?? c)
                      .toList()
                  : AppColors.gradientPrimary,
            ),
            boxShadow: AppColors.gradientGlow(
              AppColors.primary,
              hovered: _hovered,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
