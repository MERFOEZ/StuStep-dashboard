import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dashboard/core/theme/app_theme.dart';
import 'package:dashboard/core/services/auth_service.dart';
import 'package:dashboard/core/widgets/animated_snackbar.dart';
import 'package:dashboard/core/l10n/app_localizations.dart';

/// Premium glassmorphism login page with animated mesh background.
///
/// Design: frosted glass card centered on a breathing gradient mesh,
/// with staggered micro-animations, shimmer button, and pulse ring logo.
class LoginPage extends StatefulWidget {
  /// Called after successful admin login with the user's uid.
  final void Function(String uid) onLoginSuccess;

  const LoginPage({super.key, required this.onLoginSuccess});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // ─── Step 1: Authenticate with Firebase ───
      final credential = await _authService.signIn(
        _emailCtrl.text,
        _passwordCtrl.text,
      );

      final uid = credential.user?.uid;
      if (uid == null) {
        throw 'Authentication failed. Please try again.';
      }

      // AuthGate will automatically detect the auth state change,
      // perform the Firestore role check, and handle routing to DashboardShell
      // or signing out if not admin.
    } catch (e) {
      print('LOGIN ERROR: $e');
      if (mounted) {
        showAnimatedSnackBar(context, message: e.toString(), isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: _buildGlassCard(s, textTheme),
          ),
        ),
      ),
    );
  }

  /// The main glass card with backdrop blur, border, and glow.
  Widget _buildGlassCard(S s, TextTheme textTheme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 44),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(77),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withAlpha(20),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(31),
                blurRadius: 48,
                spreadRadius: -8,
              ),
              BoxShadow(
                color: AppColors.secondary.withAlpha(15),
                blurRadius: 80,
                spreadRadius: -12,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ─── Logo with Pulse Ring ───────────────────────────
                _buildPulsingLogo()
                    .animate()
                    .fade(duration: 600.ms, delay: 200.ms)
                    .scale(
                      begin: const Offset(0.7, 0.7),
                      end: const Offset(1, 1),
                      duration: 700.ms,
                      delay: 200.ms,
                      curve: Curves.easeOutBack,
                    ),

                const SizedBox(height: 32),

                // ─── Title ─────────────────────────────────────────
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppColors.primaryLight, AppColors.secondary],
                  ).createShader(bounds),
                  child: Text(
                    s.welcomeBack,
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color: Colors.white,
                    ),
                  ),
                )
                    .animate()
                    .fade(duration: 500.ms, delay: 400.ms)
                    .slideY(
                      begin: 0.15,
                      duration: 500.ms,
                      delay: 400.ms,
                      curve: Curves.easeOutCubic,
                    ),

                const SizedBox(height: 8),

                Text(
                  s.signInToContinue,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textHint,
                  ),
                )
                    .animate()
                    .fade(duration: 500.ms, delay: 500.ms)
                    .slideY(
                      begin: 0.15,
                      duration: 500.ms,
                      delay: 500.ms,
                      curve: Curves.easeOutCubic,
                    ),

                const SizedBox(height: 36),

                // ─── Email Field ───────────────────────────────────
                _buildGlowingTextField(
                  controller: _emailCtrl,
                  label: s.email,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  tooltip: s.isArabic
                      ? 'أدخل بريدك الإلكتروني المسجل'
                      : 'Enter your registered email',
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return s.requiredField;
                    if (!v.contains('@')) return s.invalidEmail;
                    return null;
                  },
                )
                    .animate()
                    .fade(duration: 500.ms, delay: 600.ms)
                    .slideY(
                      begin: 0.1,
                      duration: 500.ms,
                      delay: 600.ms,
                      curve: Curves.easeOutCubic,
                    ),

                const SizedBox(height: 20),

                // ─── Password Field ────────────────────────────────
                _buildGlowingTextField(
                  controller: _passwordCtrl,
                  label: s.password,
                  icon: Icons.lock_outlined,
                  obscure: _obscurePassword,
                  tooltip: s.isArabic
                      ? 'أدخل كلمة المرور الخاصة بك'
                      : 'Enter your password',
                  suffixIcon: Tooltip(
                    message: s.isArabic
                        ? (_obscurePassword ? 'إظهار كلمة المرور' : 'إخفاء كلمة المرور')
                        : (_obscurePassword ? 'Show password' : 'Hide password'),
                    child: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: AppColors.textHint,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return s.requiredField;
                    return null;
                  },
                )
                    .animate()
                    .fade(duration: 500.ms, delay: 700.ms)
                    .slideY(
                      begin: 0.1,
                      duration: 500.ms,
                      delay: 700.ms,
                      curve: Curves.easeOutCubic,
                    ),

                const SizedBox(height: 32),

                // ─── Login Button with Shimmer ─────────────────────
                _buildShimmerButton(s)
                    .animate()
                    .fade(duration: 500.ms, delay: 800.ms)
                    .slideY(
                      begin: 0.1,
                      duration: 500.ms,
                      delay: 800.ms,
                      curve: Curves.easeOutCubic,
                    ),

                const SizedBox(height: 28),

                // ─── Footer ────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.neonGreen,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neonGreen.withAlpha(128),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'StuStep Admin Portal',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textHint.withAlpha(128),
                        letterSpacing: 1.2,
                        fontSize: 11,
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fade(duration: 500.ms, delay: 900.ms),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fade(duration: 800.ms)
        .slideY(
          begin: 0.08,
          duration: 800.ms,
          curve: Curves.easeOutCubic,
        );
  }

  /// Logo with animated pulse ring effect.
  Widget _buildPulsingLogo() {
    return SizedBox(
      width: 88,
      height: 88,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer pulse ring
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withAlpha(51),
                width: 1,
              ),
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.2, 1.2),
                duration: 2000.ms,
                curve: Curves.easeOut,
              )
              .fade(begin: 0.6, end: 0, duration: 2000.ms),
          // Inner pulse ring
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.secondary.withAlpha(38),
                width: 1,
              ),
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.3, 1.3),
                duration: 2000.ms,
                delay: 400.ms,
                curve: Curves.easeOut,
              )
              .fade(begin: 0.4, end: 0, duration: 2000.ms, delay: 400.ms),
          // Logo icon
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(102),
                  blurRadius: 24,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  /// Text field with custom glowing border on focus.
  Widget _buildGlowingTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffixIcon,
    String? tooltip,
    String? Function(String?)? validator,
  }) {
    final field = _GlowingTextField(
      controller: controller,
      label: label,
      icon: icon,
      keyboardType: keyboardType,
      obscure: obscure,
      suffixIcon: suffixIcon,
      validator: validator,
    );
    if (tooltip != null) {
      return Tooltip(message: tooltip, child: field);
    }
    return field;
  }

  /// Gradient login button with shimmer effect.
  Widget _buildShimmerButton(S s) {
    return _ShimmerGradientButton(
      label: _isLoading ? s.signingIn : s.signIn,
      isLoading: _isLoading,
      onPressed: _isLoading ? null : _handleLogin,
    );
  }
}

// ─── Glowing Text Field ─────────────────────────────────────────────────────

class _GlowingTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscure;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _GlowingTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.obscure = false,
    this.suffixIcon,
    this.validator,
  });

  @override
  State<_GlowingTextField> createState() => _GlowingTextFieldState();
}

class _GlowingTextFieldState extends State<_GlowingTextField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: AppColors.primary.withAlpha(51),
                  blurRadius: 20,
                  spreadRadius: -4,
                ),
              ]
            : [],
      ),
      child: Focus(
        onFocusChange: (f) => setState(() => _focused = f),
        child: TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscure,
          validator: widget.validator,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            labelText: widget.label,
            labelStyle: TextStyle(
              color: _focused ? AppColors.primaryLight : AppColors.textHint,
              fontSize: 14,
            ),
            prefixIcon: Icon(
              widget.icon,
              color: _focused ? AppColors.primaryLight : AppColors.textHint,
              size: 20,
            ),
            suffixIcon: widget.suffixIcon,
            filled: true,
            fillColor: Colors.white.withAlpha(8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.white.withAlpha(26),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.white.withAlpha(26),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.error,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Shimmer Gradient Button ────────────────────────────────────────────────

class _ShimmerGradientButton extends StatefulWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _ShimmerGradientButton({
    required this.label,
    required this.isLoading,
    this.onPressed,
  });

  @override
  State<_ShimmerGradientButton> createState() => _ShimmerGradientButtonState();
}

class _ShimmerGradientButtonState extends State<_ShimmerGradientButton>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOut,
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              colors: widget.isLoading
                  ? [
                      AppColors.primary.withAlpha(153),
                      AppColors.blob2.withAlpha(153),
                    ]
                  : [AppColors.primary, AppColors.blob2],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(77),
                blurRadius: 20,
                spreadRadius: -4,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              children: [
                // Shimmer sweep overlay
                if (!widget.isLoading)
                  AnimatedBuilder(
                    animation: _shimmerCtrl,
                    builder: (context, _) {
                      return Positioned(
                        left: -100 + (_shimmerCtrl.value * 600),
                        top: 0,
                        bottom: 0,
                        width: 100,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withAlpha(0),
                                Colors.white.withAlpha(38),
                                Colors.white.withAlpha(0),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                // Content
                Center(
                  child: widget.isLoading
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white.withAlpha(204),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Text(
                              widget.label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white.withAlpha(204),
                              size: 20,
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
