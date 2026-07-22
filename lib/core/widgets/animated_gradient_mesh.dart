import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:dashboard/core/theme/app_theme.dart';

/// Full-screen animated gradient mesh with 5 softly shifting color blobs
/// and a subtle grain overlay for a premium feel.
///
/// Uses an [AnimationController] looping 12s with [Curves.easeInOut].
/// Wrapped in [RepaintBoundary] for render performance.
class AnimatedGradientMesh extends StatefulWidget {
  final Widget child;
  const AnimatedGradientMesh({super.key, required this.child});

  @override
  State<AnimatedGradientMesh> createState() => _AnimatedGradientMeshState();
}

class _AnimatedGradientMeshState extends State<AnimatedGradientMesh>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Deep navy base
        Positioned.fill(
          child: Container(color: AppColors.surface0),
        ),
        // Animated blobs
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) {
              return CustomPaint(
                painter: _MeshPainter(_ctrl.value),
                size: Size.infinite,
              );
            },
          ),
        ),
        // Subtle grain overlay for texture
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _GrainPainter(),
            ),
          ),
        ),
        // Content on top
        Positioned.fill(child: widget.child),
      ],
    );
  }
}

class _MeshPainter extends CustomPainter {
  final double progress;
  _MeshPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Eased progress value for smooth movement
    final t = Curves.easeInOut.transform(progress);

    // 5 blobs for a richer visual — deep indigo, vivid violet, bright cyan,
    // primary glow, and a subtle secondary accent.
    final blobs = <_BlobConfig>[
      _BlobConfig(
        color: AppColors.blob1.withAlpha(115), // ~0.45
        cx: w * (0.2 + 0.15 * math.sin(t * math.pi * 2)),
        cy: h * (0.3 + 0.1 * math.cos(t * math.pi * 2)),
        radius: w * 0.38,
      ),
      _BlobConfig(
        color: AppColors.blob2.withAlpha(90), // ~0.35
        cx: w * (0.75 - 0.12 * math.cos(t * math.pi * 2 + 1)),
        cy: h * (0.2 + 0.15 * math.sin(t * math.pi * 2 + 1)),
        radius: w * 0.32,
      ),
      _BlobConfig(
        color: AppColors.blob3.withAlpha(64), // ~0.25
        cx: w * (0.5 + 0.2 * math.sin(t * math.pi * 2 + 2)),
        cy: h * (0.7 - 0.12 * math.cos(t * math.pi * 2 + 2)),
        radius: w * 0.34,
      ),
      _BlobConfig(
        color: AppColors.primary.withAlpha(51), // ~0.2
        cx: w * (0.8 - 0.1 * math.sin(t * math.pi * 2 + 3)),
        cy: h * (0.8 + 0.08 * math.cos(t * math.pi * 2 + 3)),
        radius: w * 0.28,
      ),
      // 5th blob — subtle pulsing secondary accent at top-center
      _BlobConfig(
        color: AppColors.secondary.withAlpha(38), // ~0.15
        cx: w * (0.45 + 0.08 * math.cos(t * math.pi * 2 + 4)),
        cy: h * (0.1 + 0.06 * math.sin(t * math.pi * 2 + 4)),
        radius: w * 0.22,
      ),
    ];

    for (final blob in blobs) {
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [blob.color, blob.color.withAlpha(0)],
          stops: const [0.0, 1.0],
        ).createShader(
          Rect.fromCircle(
              center: Offset(blob.cx, blob.cy), radius: blob.radius),
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 70);

      canvas.drawCircle(Offset(blob.cx, blob.cy), blob.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MeshPainter old) => old.progress != progress;
}

/// Paints a faint noise grain overlay for premium texture.
class _GrainPainter extends CustomPainter {
  final _rng = math.Random(42);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    const density = 2000;
    for (int i = 0; i < density; i++) {
      final x = _rng.nextDouble() * size.width;
      final y = _rng.nextDouble() * size.height;
      final alpha = _rng.nextInt(12); // very subtle
      paint.color = Color.fromARGB(alpha, 255, 255, 255);
      canvas.drawCircle(Offset(x, y), 0.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GrainPainter old) => false;
}

class _BlobConfig {
  final Color color;
  final double cx, cy, radius;
  const _BlobConfig({
    required this.color,
    required this.cx,
    required this.cy,
    required this.radius,
  });
}
