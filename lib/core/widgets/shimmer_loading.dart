import 'package:flutter/material.dart';
import 'package:dashboard/core/theme/app_theme.dart';

/// Shimmer loading placeholder with animated gradient sweep.
class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    this.height = 48,
    this.borderRadius = 12,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * _ctrl.value, 0),
              end: Alignment(-1.0 + 2.0 * _ctrl.value + 1.0, 0),
              colors: [
                AppColors.surface2,
                AppColors.surface3.withValues(alpha: 0.8),
                AppColors.surface2,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// Pre-built shimmer for a table row.
class ShimmerTableRow extends StatelessWidget {
  final int columns;

  const ShimmerTableRow({super.key, this.columns = 4});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(columns, (i) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ShimmerLoading(
                height: 16,
                borderRadius: 8,
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Pre-built shimmer for stat cards grid.
class ShimmerStatCards extends StatelessWidget {
  final int count;

  const ShimmerStatCards({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (i) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: ShimmerLoading(
              height: 140,
              borderRadius: 20,
            ),
          ),
        );
      }),
    );
  }
}
