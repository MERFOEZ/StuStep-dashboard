import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _profileFormKey = GlobalKey<FormState>();
  final _securityFormKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _passwordError;
  bool _isProfileUpdating = false;
  bool _isPasswordUpdating = false;

  // Preferences States (emailAlerts, securityLogs etc.)
  bool _emailAlerts = true;
  final bool _securityLogs = true;
  final bool _maintenanceNotif = false;
  final bool _systemAudio = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.currentUser != null) {
        _nameController.text = auth.currentUser!.name;
        _emailController.text = auth.currentUser!.email;
        _phoneController.text = auth.currentUser!.phoneNumber ?? '780077832';
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Translation Helper
  bool get _isArabic => Provider.of<AuthProvider>(context).isArabic;
  String _t(String en, String ar) => _isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final accentColor = const Color(
      0xFF00ADEF,
    ); // Cyan/sky blue accent from screenshot
    final cardColor = const Color(
      0xFF10192D,
    ); // Dark blue card color from screenshot
    final fieldBgColor = const Color(
      0xFF090E1A,
    ); // Deep input field background from screenshot
    final bodyBgColor = const Color(0xFF0B0F19); // Background color of page

    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 950;

    return Directionality(
      textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Top Card: Profile Banner (RTL layout aligned)
                _buildProfileBanner(authProvider, cardColor, accentColor),
                const SizedBox(height: 24),

                // 2. Bottom section: Personal Info & Security
                isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left side: Security & Password
                          Expanded(
                            flex: 5,
                            child: _buildSecurityCard(
                              authProvider,
                              cardColor,
                              fieldBgColor,
                              accentColor,
                            ),
                          ),
                          const SizedBox(width: 24),
                          // Right side: Personal Info
                          Expanded(
                            flex: 6,
                            child: _buildPersonalInfoCard(
                              authProvider,
                              cardColor,
                              fieldBgColor,
                              accentColor,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _buildPersonalInfoCard(
                            authProvider,
                            cardColor,
                            fieldBgColor,
                            accentColor,
                          ),
                          const SizedBox(height: 24),
                          _buildSecurityCard(
                            authProvider,
                            cardColor,
                            fieldBgColor,
                            accentColor,
                          ),
                        ],
                      ),
                const SizedBox(height: 24),

                // 3. System Preferences & Dev Tools (Combined below in the same style)
                _buildSystemPreferencesRow(
                  authProvider,
                  cardColor,
                  accentColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET BUILDERS (MATCHING SCREENSHOT STYLES)
  // ==========================================

  Widget _buildProfileBanner(
    AuthProvider auth,
    Color cardColor,
    Color accentColor,
  ) {
    final user = auth.currentUser;
    final roleText = user?.role == 'admin'
        ? _t('System Administrator', 'مسؤول النظام')
        : user?.role == 'teacher'
        ? _t('Teacher', 'معلم')
        : _t('Student', 'طالب');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.04), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Name and Details Container
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? _t('Academic Admin', 'عبدالعزيز الدخين'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$roleText • ${user?.email ?? 'abdulaziz7878@gmail.com'}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Cyan Square Icon Box on the Left/Right with Glowing shadow
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard(
    AuthProvider auth,
    Color cardColor,
    Color fieldBgColor,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.04), width: 1.5),
      ),
      child: Form(
        key: _profileFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.person_rounded, color: accentColor, size: 22),
                const SizedBox(width: 8),
                Text(
                  _t('Personal Information', 'المعلومات الشخصية'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Actual Name Field
            _buildCustomInputLabel(_t('Actual Name', 'الاسم الفعلي')),
            const SizedBox(height: 8),
            _buildCustomTextField(
              controller: _nameController,
              icon: Icons.edit_rounded,
              accentColor: accentColor,
              fieldBgColor: fieldBgColor,
              validator: (val) => val == null || val.isEmpty
                  ? _t('Name cannot be empty', 'الاسم لا يمكن أن يكون فارغاً')
                  : null,
            ),
            const SizedBox(height: 20),

            // Official Email Field
            _buildCustomInputLabel(
              _t('Official Email', 'البريد الإلكتروني الرسمي'),
            ),
            const SizedBox(height: 8),
            _buildCustomTextField(
              controller: _emailController,
              icon: Icons.email_rounded,
              accentColor: accentColor,
              fieldBgColor: fieldBgColor,
              readOnly: true,
            ),
            const SizedBox(height: 20),

            // Contact Phone Number Field
            _buildCustomInputLabel(
              _t('Contact Phone Number', 'رقم الهاتف للتواصل'),
            ),
            const SizedBox(height: 8),
            _buildCustomTextField(
              controller: _phoneController,
              icon: Icons.phone_android_rounded,
              accentColor: accentColor,
              fieldBgColor: fieldBgColor,
            ),
            const SizedBox(height: 32),

            // Update Data Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isProfileUpdating
                    ? null
                    : () => _updateProfile(auth),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
                icon: _isProfileUpdating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.check_rounded, size: 18),
                label: Text(
                  _t('Update Data', 'تحديث البيانات'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityCard(
    AuthProvider auth,
    Color cardColor,
    Color fieldBgColor,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.04), width: 1.5),
      ),
      child: Form(
        key: _securityFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.lock_rounded, color: accentColor, size: 22),
                const SizedBox(width: 8),
                Text(
                  _t('Security & Protection', 'الأمان والحماية'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Error Banner (Matching screenshot maroon alert banner)
            if (_passwordError != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF451A22), // Deep red background
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFEF4444).withOpacity(0.4),
                  ),
                ),
                child: Text(
                  _passwordError!,
                  style: const TextStyle(
                    color: Color(0xFFFCA5A5),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Current Password
            _buildCustomInputLabel(
              _t('Current Password', 'كلمة المرور الحالية'),
            ),
            const SizedBox(height: 8),
            _buildCustomTextField(
              controller: _currentPasswordController,
              icon: Icons.lock_outline_rounded,
              accentColor: accentColor,
              fieldBgColor: fieldBgColor,
              obscureText: true,
              validator: (val) => val == null || val.isEmpty
                  ? _t(
                      'Current password is required',
                      'كلمة المرور الحالية مطلوبة',
                    )
                  : null,
            ),
            const SizedBox(height: 20),

            // New Password
            _buildCustomInputLabel(_t('New Password', 'كلمة المرور الجديدة')),
            const SizedBox(height: 8),
            _buildCustomTextField(
              controller: _newPasswordController,
              icon: Icons.lock_open_rounded,
              accentColor: accentColor,
              fieldBgColor: fieldBgColor,
              obscureText: true,
              validator: (val) => val == null || val.length < 6
                  ? _t(
                      'Password must be at least 6 characters',
                      'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل',
                    )
                  : null,
            ),
            const SizedBox(height: 20),

            // Confirm Password
            _buildCustomInputLabel(
              _t('Confirm New Password', 'تأكيد كلمة المرور'),
            ),
            const SizedBox(height: 8),
            _buildCustomTextField(
              controller: _confirmPasswordController,
              icon: Icons.verified_user_rounded,
              accentColor: accentColor,
              fieldBgColor: fieldBgColor,
              obscureText: true,
              validator: (val) => val != _newPasswordController.text
                  ? _t('Passwords do not match', 'كلمتا المرور غير متطابقتين')
                  : null,
            ),
            const SizedBox(height: 32),

            // Update Password Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isPasswordUpdating
                    ? null
                    : () => _updatePassword(auth),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
                icon: _isPasswordUpdating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.security_rounded, size: 18),
                label: Text(
                  _t('Update Password', 'تحديث كلمة المرور'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemPreferencesRow(
    AuthProvider authProvider,
    Color cardColor,
    Color accentColor,
  ) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 950;

    Widget buildPreferencesCard() {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.04), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tune_rounded, color: accentColor, size: 22),
                const SizedBox(width: 8),
                Text(
                  _t('Dashboard Preferences', 'تفضيلات لوحة التحكم'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: Text(
                _t('Arabic Language', 'اللغة العربية'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                _t(
                  'Change dashboard settings language to Arabic.',
                  'تغيير لغة إعدادات لوحة التحكم إلى اللغة العربية.',
                ),
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
              value: authProvider.isArabic,
              activeThumbColor: accentColor,
              contentPadding: EdgeInsets.zero,
              onChanged: (val) {
                authProvider.setArabic(val);
              },
            ),
            const Divider(height: 24, color: Colors.white10),
            SwitchListTile(
              title: Text(
                _t('Email Alerts', 'تنبيهات البريد الإلكتروني'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                _t(
                  'Receive security alerts and system updates via email.',
                  'تلقي تنبيهات الأمان وتحديثات النظام عبر البريد الإلكتروني.',
                ),
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
              value: _emailAlerts,
              activeThumbColor: accentColor,
              contentPadding: EdgeInsets.zero,
              onChanged: (val) {
                setState(() {
                  _emailAlerts = val;
                });
              },
            ),
          ],
        ),
      );
    }

    Widget buildDeveloperToolsCard() {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.04), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.developer_board_rounded,
                  color: accentColor,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  _t('Developer Sandbox', 'أدوات المطور والتجربة'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: Text(
                _t('Simulation Mode', 'وضع المحاكاة'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                _t(
                  'Simulates system functionality without hitting Firebase servers.',
                  'محاكاة كاملة للنظام دون الاتصال الفعلي بخوادم Firebase.',
                ),
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
              value: authProvider.useMock,
              activeThumbColor: accentColor,
              contentPadding: EdgeInsets.zero,
              onChanged: (val) {
                authProvider.toggleMockMode(val);
              },
            ),
            const Divider(height: 24, color: Colors.white10),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _t(
                        'Mock Database Seeded Successfully!',
                        'تمت إعادة تهيئة البيانات الافتراضية بنجاح!',
                      ),
                    ),
                    backgroundColor: const Color(0xFF10B981),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.05),
                foregroundColor: Colors.white,
              ),
              child: Text(
                _t('Reset Mock Sandbox Data', 'إعادة ضبط بيانات المحاكاة'),
              ),
            ),
          ],
        ),
      );
    }

    return isWide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: buildPreferencesCard()),
              const SizedBox(width: 24),
              Expanded(child: buildDeveloperToolsCard()),
            ],
          )
        : Column(
            children: [
              buildPreferencesCard(),
              const SizedBox(height: 24),
              buildDeveloperToolsCard(),
            ],
          );
  }

  // ==========================================
  // CUSTOM UI INPUT BUILDERS
  // ==========================================

  Widget _buildCustomInputLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.white60,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required IconData icon,
    required Color accentColor,
    required Color fieldBgColor,
    bool readOnly = false,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      obscureText: obscureText,
      style: TextStyle(
        color: readOnly ? Colors.white38 : Colors.white,
        fontSize: 13,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: fieldBgColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        suffixIcon: Icon(
          icon,
          color: readOnly ? Colors.white10 : accentColor,
          size: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: accentColor, width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.redAccent.withOpacity(0.5)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
        ),
      ),
      validator: validator,
    );
  }

  // ==========================================
  // PROFILE UPDATE ACTION CALLS
  // ==========================================

  void _updateProfile(AuthProvider auth) async {
    if (_profileFormKey.currentState!.validate()) {
      setState(() {
        _isProfileUpdating = true;
      });

      final success = await auth.updateProfile(
        name: _nameController.text.trim(),
        photoUrl: auth.currentUser?.photoUrl,
        phoneNumber: _phoneController.text.trim(),
      );

      setState(() {
        _isProfileUpdating = false;
      });

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _t(
                'Profile details updated successfully!',
                'تم تحديث البيانات الشخصية بنجاح!',
              ),
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _updatePassword(AuthProvider auth) async {
    setState(() {
      _passwordError = null;
    });

    if (_securityFormKey.currentState!.validate()) {
      setState(() {
        _isPasswordUpdating = true;
      });

      final success = await auth.updatePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      setState(() {
        _isPasswordUpdating = false;
      });

      if (success && mounted) {
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _t(
                'Password updated successfully!',
                'تم تحديث كلمة المرور بنجاح!',
              ),
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        setState(() {
          _passwordError =
              auth.errorMessage ??
              _t('Password update failed', 'فشل تحديث كلمة المرور');
        });
      }
    }
  }
}
