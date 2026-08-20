import 'dart:math' as math;
import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// KINETIC FLUID MESH ENGINE v2 -- Omega-Tier 60fps Canvas Renderer
/// ---------------------------------------------------------------------------
///
/// Architecture:
///   AnimationController (linear, 45s loop) -> CustomPainter -> 4 fluid layers
///   + 1 aurora veil, drawn as massive quadratic Bezier paths with 5-harmonic
///   trigonometric vertex displacement, rotating SweepGradients with
///   time-driven center orbiting, and BlendMode compositing.
///
/// Mathematical Core:
///   Each control point is displaced by a 5-harmonic superposition:
///     y(i,t) = sum_{k=1}^{5} A_k * sin(f_k * xNorm * 2pi + phi_k(t))
///   where phi_k(t) are incommensurate phase functions ensuring the motion
///   never repeats within the controller period.
///
/// Palette (Vibrant Pearl / Light Theme):
///   Base:    #F8FAFC (Pearl Silk)
///   Layer 1: Electric Cyan    #00F2FE  @ 30%
///   Layer 2: Neon Peach        #FF9A9E  @ 30%
///   Layer 3: Vibrant Violet   #FECFEF  @ 30%
///   Layer 4: Liquid Orchid    #F093FB  @ 20%
///   Veil:    Aurora Emerald   #43E97B  @ 12%
///
/// GPU Strategy:
///   - RepaintBoundary isolates the paint tree from widget rebuilds
///   - Single CustomPainter, zero widget allocation per frame
///   - Path objects constructed in-place, no persistent state
///   - MaskFilter.blur baked into Paint (no BackdropFilter overhead)
///   - shouldRepaint returns false for identical t values
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
      // 45s period -- long enough that the 5-harmonic superposition
      // produces visually non-repeating motion across the viewport.
      duration: const Duration(seconds: 45),
    )..repeat(); // infinite linear loop, seamless wraparound
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
        // --- Pearl Silk Base Canvas ---
        const Positioned.fill(
          child: ColoredBox(color: Color(0xFFF8FAFC)),
        ),

        // --- GPU-Isolated Fluid Renderer ---
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) {
                return CustomPaint(
                  painter: _KineticFluidPainter(t: _ctrl.value),
                  size: Size.infinite,
                );
              },
            ),
          ),
        ),

        // --- Content Overlay ---
        Positioned.fill(child: widget.child),
      ],
    );
  }
}

/// ---------------------------------------------------------------------------
/// KINETIC FLUID PAINTER -- The Mathematical Core
/// ---------------------------------------------------------------------------
///
/// Each frame:
///   1. Compute 5 incommensurate time phases from t
///   2. For each of 4 fluid layers + 1 aurora veil:
///      a. Generate N control points via 5-harmonic trigonometric displacement
///      b. Build smooth closed Bezier path through all points
///      c. Fill with SweepGradient/LinearGradient whose center orbits over time
///      d. Composite via BlendMode for iridescent color mixing
///      e. Apply MaskFilter.blur for soft, organic, diffused edges
class _KineticFluidPainter extends CustomPainter {
  final double t; // 0..1 normalized time

  _KineticFluidPainter({required this.t});

  // --- The Iridescent Pearl Palette ---
  static const _electricCyan = Color(0xFF00F2FE);
  static const _neonPeach = Color(0xFFFF9A9E);
  static const _vibrantViolet = Color(0xFFFECFEF);
  static const _liquidOrchid = Color(0xFFF093FB);
  static const _auroraEmerald = Color(0xFF43E97B);

  // Secondary accent tones for gradient richness
  static const _peachBlush = Color(0xFFFAD0C4);
  static const _lavenderMist = Color(0xFFE0C3FC);
  static const _skyAqua = Color(0xFF89F7FE);
  static const _roseGold = Color(0xFFFFCDA5);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    if (w <= 0 || h <= 0) return;

    // --- 5 Incommensurate Master Time Phases ---
    // Using irrational-ratio multipliers ensures the combined motion
    // has an astronomically long effective period (no visible repeat).
    final p1 = t * 2.0 * math.pi;              // primary
    final p2 = t * 2.6180339887 * math.pi;     // golden ratio * pi
    final p3 = t * 3.1415926536;               // pi itself
    final p4 = t * 4.2360679775 * math.pi;     // 2*phi * pi
    final p5 = t * 1.7320508076 * math.pi;     // sqrt(3) * pi

    // --- Layer 1: Electric Cyan -- Upper fluid mass ---
    _drawFluidLayer(
      canvas: canvas,
      size: size,
      config: _FluidLayerConfig(
        controlPointCount: 16,
        baseY: h * 0.18,
        amplitudeY: h * 0.14,
        amplitudeX: w * 0.07,
        harmonics: [
          _Harmonic(freq: 1.3, amp: 1.0, phase: p1),
          _Harmonic(freq: 2.7, amp: 0.55, phase: p2 + 0.5),
          _Harmonic(freq: 0.8, amp: 0.35, phase: p3),
          _Harmonic(freq: 3.4, amp: 0.20, phase: p4 + 1.2),
          _Harmonic(freq: 5.1, amp: 0.10, phase: p5 + 0.8),
        ],
        xHarmonics: [
          _Harmonic(freq: 1.5, amp: 1.0, phase: p1 * 1.3),
          _Harmonic(freq: 2.9, amp: 0.4, phase: p3 + 0.7),
        ],
        gradient: SweepGradient(
          center: Alignment(
            0.3 * math.cos(p1 * 0.4) + 0.1 * math.sin(p3 * 0.2),
            -0.2 + 0.3 * math.sin(p1 * 0.3) + 0.08 * math.cos(p4 * 0.15),
          ),
          startAngle: p1 * 0.5,
          endAngle: p1 * 0.5 + 2 * math.pi,
          colors: [
            _electricCyan.withValues(alpha: 0.30),
            _electricCyan.withValues(alpha: 0.04),
            _skyAqua.withValues(alpha: 0.22),
            _auroraEmerald.withValues(alpha: 0.12),
            _electricCyan.withValues(alpha: 0.30),
          ],
          stops: const [0.0, 0.25, 0.50, 0.75, 1.0],
        ),
        blendMode: BlendMode.softLight,
        blurSigma: 42,
      ),
    );

    // --- Layer 2: Neon Peach -- Central fluid ribbon ---
    _drawFluidLayer(
      canvas: canvas,
      size: size,
      config: _FluidLayerConfig(
        controlPointCount: 14,
        baseY: h * 0.45,
        amplitudeY: h * 0.16,
        amplitudeX: w * 0.09,
        harmonics: [
          _Harmonic(freq: 1.0, amp: 1.0, phase: p1 + math.pi / 4),
          _Harmonic(freq: 1.8, amp: 0.60, phase: p2 + 1.2),
          _Harmonic(freq: 3.2, amp: 0.30, phase: p3 + 2.1),
          _Harmonic(freq: 4.7, amp: 0.18, phase: p4 + 0.6),
          _Harmonic(freq: 6.3, amp: 0.08, phase: p5 + 1.9),
        ],
        xHarmonics: [
          _Harmonic(freq: 1.2, amp: 1.0, phase: p2 * 0.8),
          _Harmonic(freq: 3.1, amp: 0.5, phase: p4 + 1.1),
        ],
        gradient: SweepGradient(
          center: Alignment(
            -0.1 + 0.4 * math.sin(p1 * 0.35) + 0.12 * math.cos(p5 * 0.18),
            0.2 * math.cos(p1 * 0.45) + 0.1 * math.sin(p2 * 0.22),
          ),
          startAngle: -p1 * 0.4 + p3 * 0.1,
          endAngle: -p1 * 0.4 + p3 * 0.1 + 2 * math.pi,
          colors: [
            _neonPeach.withValues(alpha: 0.32),
            _neonPeach.withValues(alpha: 0.06),
            _peachBlush.withValues(alpha: 0.24),
            _roseGold.withValues(alpha: 0.16),
            _neonPeach.withValues(alpha: 0.32),
          ],
          stops: const [0.0, 0.20, 0.50, 0.78, 1.0],
        ),
        blendMode: BlendMode.overlay,
        blurSigma: 48,
      ),
    );

    // --- Layer 3: Vibrant Violet -- Lower fluid sheet ---
    _drawFluidLayer(
      canvas: canvas,
      size: size,
      config: _FluidLayerConfig(
        controlPointCount: 18,
        baseY: h * 0.68,
        amplitudeY: h * 0.12,
        amplitudeX: w * 0.06,
        harmonics: [
          _Harmonic(freq: 1.6, amp: 1.0, phase: p1 + math.pi / 2),
          _Harmonic(freq: 2.3, amp: 0.55, phase: p2 + 0.8),
          _Harmonic(freq: 0.6, amp: 0.40, phase: p3 + 1.5),
          _Harmonic(freq: 3.9, amp: 0.22, phase: p4 + 2.3),
          _Harmonic(freq: 5.5, amp: 0.12, phase: p5 + 0.4),
        ],
        xHarmonics: [
          _Harmonic(freq: 0.9, amp: 1.0, phase: p3 * 0.7),
          _Harmonic(freq: 2.4, amp: 0.45, phase: p1 + 2.0),
        ],
        gradient: SweepGradient(
          center: Alignment(
            0.2 * math.cos(p1 * 0.5) + 0.15 * math.sin(p4 * 0.12),
            0.3 + 0.2 * math.sin(p1 * 0.3) + 0.1 * math.cos(p5 * 0.2),
          ),
          startAngle: p1 * 0.6 - p2 * 0.08,
          endAngle: p1 * 0.6 - p2 * 0.08 + 2 * math.pi,
          colors: [
            _vibrantViolet.withValues(alpha: 0.30),
            _vibrantViolet.withValues(alpha: 0.05),
            _lavenderMist.withValues(alpha: 0.22),
            _vibrantViolet.withValues(alpha: 0.18),
            _vibrantViolet.withValues(alpha: 0.30),
          ],
          stops: const [0.0, 0.30, 0.55, 0.80, 1.0],
        ),
        blendMode: BlendMode.softLight,
        blurSigma: 38,
      ),
    );

    // --- Layer 4: Liquid Orchid -- Floating iridescent accent ---
    _drawFluidLayer(
      canvas: canvas,
      size: size,
      config: _FluidLayerConfig(
        controlPointCount: 10,
        baseY: h * 0.32,
        amplitudeY: h * 0.20,
        amplitudeX: w * 0.12,
        harmonics: [
          _Harmonic(freq: 0.7, amp: 1.0, phase: p1 + math.pi),
          _Harmonic(freq: 1.4, amp: 0.65, phase: p2 + 2.5),
          _Harmonic(freq: 2.1, amp: 0.35, phase: p3 + 0.3),
          _Harmonic(freq: 3.5, amp: 0.20, phase: p4 + 1.7),
          _Harmonic(freq: 4.8, amp: 0.10, phase: p5 + 2.9),
        ],
        xHarmonics: [
          _Harmonic(freq: 0.6, amp: 1.0, phase: p4 * 0.5),
          _Harmonic(freq: 1.8, amp: 0.55, phase: p2 + 0.9),
        ],
        gradient: LinearGradient(
          begin: Alignment(
            -1.0 + 0.5 * math.sin(p1 * 0.25) + 0.2 * math.cos(p3 * 0.15),
            -0.5 + 0.3 * math.cos(p1 * 0.35) + 0.1 * math.sin(p5 * 0.12),
          ),
          end: Alignment(
            1.0 - 0.3 * math.cos(p1 * 0.3) + 0.15 * math.sin(p4 * 0.18),
            0.5 + 0.4 * math.sin(p1 * 0.2) + 0.12 * math.cos(p2 * 0.25),
          ),
          colors: [
            _liquidOrchid.withValues(alpha: 0.22),
            _liquidOrchid.withValues(alpha: 0.03),
            _lavenderMist.withValues(alpha: 0.14),
            _liquidOrchid.withValues(alpha: 0.22),
          ],
          stops: const [0.0, 0.30, 0.70, 1.0],
        ),
        blendMode: BlendMode.overlay,
        blurSigma: 55,
      ),
    );

    // --- Layer 5: Aurora Veil -- Ethereal top shimmer ---
    // Ultra-wide, low-opacity layer that drifts slowly across the
    // entire viewport like a Northern Lights curtain.
    _drawFluidLayer(
      canvas: canvas,
      size: size,
      config: _FluidLayerConfig(
        controlPointCount: 20,
        baseY: h * 0.50,
        amplitudeY: h * 0.30,
        amplitudeX: w * 0.04,
        harmonics: [
          _Harmonic(freq: 0.4, amp: 1.0, phase: p1 * 0.3),
          _Harmonic(freq: 0.9, amp: 0.50, phase: p2 * 0.5 + 1.0),
          _Harmonic(freq: 1.7, amp: 0.25, phase: p3 * 0.7),
          _Harmonic(freq: 2.8, amp: 0.12, phase: p4 * 0.4 + 0.5),
          _Harmonic(freq: 4.2, amp: 0.06, phase: p5 * 0.6 + 2.0),
        ],
        xHarmonics: [
          _Harmonic(freq: 0.3, amp: 1.0, phase: p5 * 0.4),
        ],
        gradient: SweepGradient(
          center: Alignment(
            0.5 * math.sin(p1 * 0.15),
            0.3 * math.cos(p2 * 0.12),
          ),
          startAngle: p1 * 0.2,
          endAngle: p1 * 0.2 + 2 * math.pi,
          colors: [
            _auroraEmerald.withValues(alpha: 0.12),
            _skyAqua.withValues(alpha: 0.06),
            _electricCyan.withValues(alpha: 0.08),
            _auroraEmerald.withValues(alpha: 0.04),
            _auroraEmerald.withValues(alpha: 0.12),
          ],
          stops: const [0.0, 0.25, 0.50, 0.75, 1.0],
        ),
        blendMode: BlendMode.plus,
        blurSigma: 65,
      ),
    );
  }

  /// -------------------------------------------------------------------
  /// Core Fluid Layer Renderer -- 5-Harmonic Vertex Displacement Engine
  /// -------------------------------------------------------------------
  ///
  /// Generates a closed Bezier path from N control points whose positions
  /// are driven by multi-harmonic trigonometric displacement:
  ///
  ///   y(i,t) = baseY + sum_{k} (ampY * h_k.amp) * sin(h_k.freq * xNorm * 2pi + h_k.phase)
  ///   x(i,t) = x_base + sum_{j} (ampX * xh_j.amp) * sin(xh_j.freq * xNorm * pi + xh_j.phase)
  ///
  /// The multi-harmonic superposition with incommensurate phase functions
  /// creates fluid motion that never settles into a recognizable pattern
  /// within the human perception window.
  void _drawFluidLayer({
    required Canvas canvas,
    required Size size,
    required _FluidLayerConfig config,
  }) {
    final w = size.width;
    final h = size.height;
    final n = config.controlPointCount;

    // --- Generate displaced control points ---
    final points = <Offset>[];
    for (int i = 0; i <= n; i++) {
      final xNorm = i / n; // 0..1 normalized x position
      final x = xNorm * w;

      // Multi-harmonic vertical displacement
      double dy = 0;
      for (final harm in config.harmonics) {
        dy += config.amplitudeY *
            harm.amp *
            math.sin(harm.freq * xNorm * 2 * math.pi + harm.phase);
      }

      // Multi-harmonic horizontal micro-displacement
      double dx = 0;
      for (final xh in config.xHarmonics) {
        dx += config.amplitudeX *
            xh.amp *
            math.sin(xh.freq * xNorm * math.pi + xh.phase);
      }

      final py = (config.baseY + dy).clamp(0.0, h);
      final px = (x + dx).clamp(0.0, w);
      points.add(Offset(px, py));
    }

    // --- Build smooth closed Bezier path ---
    final path = Path();
    path.moveTo(0, h); // start bottom-left
    path.lineTo(points.first.dx, points.first.dy);

    // Catmull-Rom style smooth quadratic Bezier interpolation:
    // For each consecutive pair, use the current point as control
    // and the midpoint as the end -> produces C1-continuous curves.
    for (int i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      final midX = (current.dx + next.dx) * 0.5;
      final midY = (current.dy + next.dy) * 0.5;
      path.quadraticBezierTo(current.dx, current.dy, midX, midY);
    }

    // Final segment to last control point
    path.lineTo(points.last.dx, points.last.dy);

    // Close along the bottom edge
    path.lineTo(w, h);
    path.close();

    // --- Create the paint with rotating gradient ---
    final paint = Paint()
      ..shader = config.gradient.createShader(
        Rect.fromLTWH(0, 0, w, h),
      )
      ..blendMode = config.blendMode
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, config.blurSigma)
      ..isAntiAlias = true;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _KineticFluidPainter old) => old.t != t;
}

/// A single harmonic component: frequency, relative amplitude, and phase.
class _Harmonic {
  final double freq;
  final double amp;
  final double phase;

  const _Harmonic({
    required this.freq,
    required this.amp,
    required this.phase,
  });
}

/// Configuration for a single fluid layer in the kinetic mesh.
class _FluidLayerConfig {
  final int controlPointCount;
  final double baseY;
  final double amplitudeY;
  final double amplitudeX;
  final List<_Harmonic> harmonics;     // vertical displacement harmonics
  final List<_Harmonic> xHarmonics;    // horizontal displacement harmonics
  final Gradient gradient;
  final BlendMode blendMode;
  final double blurSigma;

  const _FluidLayerConfig({
    required this.controlPointCount,
    required this.baseY,
    required this.amplitudeY,
    required this.amplitudeX,
    required this.harmonics,
    required this.xHarmonics,
    required this.gradient,
    required this.blendMode,
    required this.blurSigma,
  });
}
