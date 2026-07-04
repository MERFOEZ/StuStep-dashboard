import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0.0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.1, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleLogin(String Function(String, String) t) async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white),
                const SizedBox(width: 10),
                Text(t('Sign in successful!', 'تم تسجيل الدخول بنجاح!'), style: const TextStyle(color: Colors.white)),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authProvider = Provider.of<AuthProvider>(context);

    String t(String en, String ar) => authProvider.isArabic ? ar : en;

    // Color Palette matching the user's reference screenshot design
    const accentColor = Color(0xFF00ADEF); // Cyan/Sky blue
    const cardBgColor = Color(0xFF10192D); // Lighter dark blue panel
    const fieldBgColor = Color(0xFF090E1A); // Deep black/blue input fields

    return Directionality(
      textDirection: authProvider.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: Stack(
          children: [
            // Dark Radial Gradient Background matching the reference design
            Container(
              width: size.width,
              height: size.height,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.3,
                  colors: [
                    Color(0xFF0F1E36), // Deep blue center
                    Color(0xFF070B13), // Almost black edge
                  ],
                ),
              ),
            ),

            // Subtle Glowing Orbs for premium modern look
            Positioned(
              top: -size.height * 0.1,
              right: -size.width * 0.1,
              child: Container(
                width: size.width * 0.4,
                height: size.width * 0.4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00ADEF).withOpacity(0.08),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 100.0, sigmaY: 100.0),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),

            // Main Content
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        width: 440,
                        decoration: BoxDecoration(
                          color: cardBgColor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 48.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Logo icon matching STUSTEP (school/cap icon) styled in cyan/teal
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00ADEF).withOpacity(0.08),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.school_rounded, // Restored graduation cap logo
                                      size: 44,
                                      color: accentColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Welcome Title
                                Text(
                                  t('Welcome Back', 'مرحباً بك مجدداً'),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Subtitle restored to STUSTEP
                                Text(
                                  t('Sign in to manage STUSTEP Academic Portal', 'سجل دخولك لإدارة لوحة تحكم STUSTEP الأكاديمية'),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white38,
                                  ),
                                ),
                                const SizedBox(height: 36),

                                // Error Banner
                                if (authProvider.errorMessage != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    margin: const EdgeInsets.only(bottom: 24),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 20),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            authProvider.errorMessage!,
                                            style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 13),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                // Email Input field (RTL prefixIcon is placed on the right side)
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  textAlign: authProvider.isArabic ? TextAlign.right : TextAlign.left,
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                  decoration: InputDecoration(
                                    hintText: t('Admin Email', 'البريد الإلكتروني'),
                                    hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
                                    prefixIcon: const Icon(Icons.person_outline_rounded, color: accentColor, size: 18),
                                    filled: true,
                                    fillColor: fieldBgColor,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Colors.white10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: accentColor, width: 1.2),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.redAccent.withOpacity(0.5)),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return t('Please enter email', 'يرجى إدخال البريد الإلكتروني');
                                    }
                                    if (!authProvider.useMock && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                      return t('Please enter a valid email', 'يرجى إدخال بريد إلكتروني صالح');
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 18),

                                // Password Input field (RTL suffixIcon is on the left side)
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _handleLogin(t),
                                  textAlign: authProvider.isArabic ? TextAlign.right : TextAlign.left,
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                  decoration: InputDecoration(
                                    hintText: t('Password', 'كلمة المرور'),
                                    hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
                                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: accentColor, size: 18),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                        color: Colors.white24,
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    filled: true,
                                    fillColor: fieldBgColor,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Colors.white10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: accentColor, width: 1.2),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.redAccent.withOpacity(0.5)),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return t('Please enter password', 'يرجى إدخال كلمة المرور');
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 18),

                                // Remember Me & Forgot Password row matching reference design
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                      onPressed: () {},
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        t('Forgot Password?', 'نسيت كلمة المرور؟'),
                                        style: const TextStyle(color: accentColor, fontSize: 12),
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          t('Remember Me', 'تذكرني'),
                                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                                        ),
                                        const SizedBox(width: 8),
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: Checkbox(
                                            value: _rememberMe,
                                            onChanged: (val) {
                                              setState(() {
                                                _rememberMe = val ?? false;
                                              });
                                            },
                                            activeColor: accentColor,
                                            checkColor: Colors.white,
                                            side: const BorderSide(color: Colors.white24, width: 1.5),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),

                                // Login Button
                                SizedBox(
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: authProvider.isLoading ? null : () => _handleLogin(t),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: accentColor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 4,
                                      shadowColor: accentColor.withOpacity(0.2),
                                    ),
                                    child: authProvider.isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : Text(
                                            t('Sign In to Dashboard', 'تسجيل الدخول'),
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Simulation Mode Toggler
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.02),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white.withOpacity(0.04)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            t('Simulation Mode', 'وضع المحاكاة (Simulation)'),
                                            style: const TextStyle(
                                              color: Colors.white38,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 24,
                                            child: Switch(
                                              value: authProvider.useMock,
                                              onChanged: (val) => authProvider.toggleMockMode(val),
                                              activeColor: accentColor,
                                              activeTrackColor: accentColor.withOpacity(0.15),
                                              inactiveThumbColor: Colors.white24,
                                              inactiveTrackColor: Colors.white10,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (authProvider.useMock) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          t('Demo: admin@stustep.com | Pass: admin123', 'حساب تجريبي: admin@stustep.com | كلمة: admin123'),
                                          style: const TextStyle(color: Colors.white38, fontSize: 10, fontFamily: 'monospace'),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Footer system rights restored to STUSTEP
                                Text(
                                  t('© 2026 STUSTEP - All Rights Reserved', '© 2026 نظام STUSTEP - جميع الحقوق محفوظة'),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white24,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
