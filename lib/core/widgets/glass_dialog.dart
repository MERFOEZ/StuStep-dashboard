import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:dashboard/core/theme/app_theme.dart';

/// Shows a premium light-mode dialog with slide-up animation and soft shadows.
Future<T?> showGlassDialog<T>({
  required BuildContext context,
  required String title,
  required Widget content,
  List<Widget>? actions,
  double maxWidth = 480,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withOpacity(0.25),
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Material(
            color: Colors.transparent,
            child: _GlassDialogContent(
              title: title,
              content: content,
              actions: actions,
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curve,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).animate(curve),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1.0).animate(curve),
            child: child,
          ),
        ),
      );
    },
  );
}

class _GlassDialogContent extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;

  const _GlassDialogContent({
    required this.title,
    required this.content,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.border.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 48,
            spreadRadius: -8,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            spreadRadius: -4,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 60,
            spreadRadius: -12,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: const LinearGradient(
                    colors: AppColors.gradientPrimary,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                ),
              ),
              // Close button
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.surfaceTinted,
                      border: Border.all(
                        color: AppColors.border.withOpacity(0.3),
                      ),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: AppColors.textHint,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Content
          content,
          if (actions != null && actions!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Divider(color: AppColors.border.withOpacity(0.4)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions!
                  .expand((w) => [w, const SizedBox(width: 12)])
                  .toList()
                ..removeLast(),
            ),
          ],
        ],
      ),
    );
  }
}

/// Gradient primary button for dialogs — light mode.
class GlassDialogButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isLoading;
  final bool isDestructive;

  const GlassDialogButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isPrimary = false,
    this.isLoading = false,
    this.isDestructive = false,
  });

  @override
  State<GlassDialogButton> createState() => _GlassDialogButtonState();
}

class _GlassDialogButtonState extends State<GlassDialogButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.isDestructive ? AppColors.error : AppColors.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.onPressed != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: widget.isPrimary
                ? LinearGradient(
                    colors: widget.isDestructive
                        ? [AppColors.error, AppColors.neonPink]
                        : AppColors.gradientPrimary,
                  )
                : null,
            color: widget.isPrimary
                ? null
                : (_hovered
                    ? AppColors.surfaceTinted
                    : Colors.transparent),
            border: widget.isPrimary
                ? null
                : Border.all(
                    color: _hovered
                        ? AppColors.textSecondary.withOpacity(0.3)
                        : AppColors.border,
                  ),
            boxShadow: widget.isPrimary && _hovered
                ? AppColors.gradientGlow(baseColor, hovered: true)
                : null,
          ),
          child: widget.isLoading
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: widget.isPrimary
                        ? Colors.white
                        : AppColors.primary,
                  ),
                )
              : Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.isPrimary
                        ? Colors.white
                        : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}

/// Delete confirmation dialog with warning design — light mode.
Future<bool?> showDeleteConfirmation({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
}) {
  return showGlassDialog<bool>(
    context: context,
    title: title,
    maxWidth: 400,
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.error.withOpacity(0.08),
            border: Border.all(
              color: AppColors.error.withOpacity(0.15),
            ),
          ),
          child: Icon(
            Icons.delete_outline_rounded,
            color: AppColors.error,
            size: 28,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          message,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
    actions: [
      GlassDialogButton(
        label: cancelLabel,
        onPressed: () => Navigator.of(context).pop(false),
      ),
      GlassDialogButton(
        label: confirmLabel,
        isPrimary: true,
        isDestructive: true,
        onPressed: () => Navigator.of(context).pop(true),
      ),
    ],
  );
}

/// Cascade delete confirmation with a detailed red warning — light mode.
Future<bool?> showCascadeDeleteConfirmation({
  required BuildContext context,
  required String title,
  required String warningMessage,
  required String confirmLabel,
  required String cancelLabel,
}) {
  return showGlassDialog<bool>(
    context: context,
    title: title,
    maxWidth: 440,
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.error.withOpacity(0.06),
            border: Border.all(
              color: AppColors.error.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.warning_amber_rounded,
            color: AppColors.error,
            size: 32,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: AppColors.error.withOpacity(0.04),
            border: Border.all(
              color: AppColors.error.withOpacity(0.12),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.error.withOpacity(0.7),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  warningMessage,
                  style: TextStyle(
                    color: AppColors.error.withOpacity(0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
    actions: [
      GlassDialogButton(
        label: cancelLabel,
        onPressed: () => Navigator.of(context).pop(false),
      ),
      GlassDialogButton(
        label: confirmLabel,
        isPrimary: true,
        isDestructive: true,
        onPressed: () => Navigator.of(context).pop(true),
      ),
    ],
  );
}
