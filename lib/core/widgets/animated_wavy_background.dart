import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// AnimatedVibrantWaves — Standalone Kinetic Background Widget
/// ─────────────────────────────────────────────────────────────────────────────
/// A self-contained animated background with 3 sine-wave layers that can be
/// dropped into any screen. Uses CustomPainter + BackdropFilter for a premium
/// liquid glass effect.
///
/// Usage:
/// ```dart
/// Stack(
///   children: [
///     const AnimatedVibrantWaves(),
///     // Your content here
///   ],
/// )
/// ```
class AnimatedVibrantWaves extends StatefulWidget {
  const AnimatedVibrantWaves({super.key});

  @override
  State<AnimatedVibrantWaves> createState() => _AnimatedVibrantWavesState();
}

class _AnimatedVibrantWavesState extends State<AnimatedVibrantWaves>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        children: [
          // ─── Pearl Canvas Base ─────────────────────────────────
          Positioned.fill(
            child: Container(
              color: const Color(0xFFF4F7F9),
            ),
          ),

          // ─── Sine-Wave Layers ──────────────────────────────────
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _WavesPainter(_controller.value),
                  size: Size.infinite,
                );
              },
            ),
          ),

          // ─── Heavy BackdropFilter Blur ─────────────────────────
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(color: Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }
}

class _WavesPainter extends CustomPainter {
  final double progress;
  _WavesPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    final time = progress * 2 * math.pi;

    // Wave 1: Soft Cyan — upper region
    _drawSineWave(
      canvas: canvas,
      size: size,
      color: const Color(0xFFE0F7FA).withOpacity(0.35),
      baseY: h * 0.28,
      amplitude: 70,
      frequency: 1.5,
      phase: time,
      segments: 8,
    );

    // Wave 2: Pastel Purple — mid region
    _drawSineWave(
      canvas: canvas,
      size: size,
      color: const Color(0xFFF3E5F5).withOpacity(0.30),
      baseY: h * 0.52,
      amplitude: 90,
      frequency: 1.0,
      phase: time + math.pi / 3,
      segments: 6,
    );

    // Wave 3: Warm Pearl — lower region
    _drawSineWave(
      canvas: canvas,
      size: size,
      color: const Color(0xFFFDFBF7).withOpacity(0.40),
      baseY: h * 0.70,
      amplitude: 55,
      frequency: 2.0,
      phase: time + 2 * math.pi / 3,
      segments: 10,
    );
  }

  void _drawSineWave({
    required Canvas canvas,
    required Size size,
    required Color color,
    required double baseY,
    required double amplitude,
    required double frequency,
    required double phase,
    required int segments,
  }) {
    final w = size.width;
    final h = size.height;
    final segW = w / segments;

    final path = Path()
      ..moveTo(0, h)
      ..lineTo(
          0,
          baseY +
              amplitude * math.sin(phase));

    for (int i = 0; i < segments; i++) {
      final midX = segW * (i + 0.5);
      final endX = segW * (i + 1);

      final midY = baseY +
          amplitude *
              math.sin(frequency * (midX / w) * 2 * math.pi + phase) +
          amplitude * 0.25 * math.cos(phase * 1.2 + i);
      final endY = baseY +
          amplitude *
              math.sin(frequency * (endX / w) * 2 * math.pi + phase);

      path.quadraticBezierTo(midX, midY, endX, endY);
    }

    path.lineTo(w, h);
    path.close();

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _WavesPainter old) =>
      old.progress != progress;
}
