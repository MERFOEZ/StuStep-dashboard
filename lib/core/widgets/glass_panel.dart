import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:dashboard/core/theme/app_theme.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Frosted Glass Panel — Reusable Container
/// ─────────────────────────────────────────────────────────────────────────────
/// White surface with subtle blur, multi-layered soft shadows, refined border,
/// and optional gradient accent on the top edge.
class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blurAmount;
  final bool showTopAccent;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.blurAmount = 14,
    this.showTopAccent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
          child: Container(
            padding: padding ?? const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.88),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: AppColors.border.withOpacity(0.4),
                width: 1,
              ),
              boxShadow: AppColors.softShadow,
            ),
            child: showTopAccent
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Gradient accent line at the top
                      Container(
                        height: 3,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: const LinearGradient(
                            colors: AppColors.gradientPrimary,
                          ),
                        ),
                      ),
                      Expanded(child: child),
                    ],
                  )
                : child,
          ),
        ),
      ),
    );
  }
}
