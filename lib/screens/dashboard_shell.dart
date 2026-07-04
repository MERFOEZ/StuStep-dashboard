import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'pages/overview_page.dart';
import 'pages/users_page.dart';
import 'pages/groups_page.dart';
import 'pages/courses_page.dart';
import 'pages/settings_page.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const OverviewPage(),
    const UsersPage(),
    const GroupsPage(),
    const CoursesPage(),
    const SettingsPage(),
  ];

  final List<String> _pageTitles = [
    'Overview Dashboard',
    'User Management Console',
    'Academic Chat Groups',
    'Courses Content Management',
    'Settings & Profile',
  ];

  ImageProvider? _getAvatarProvider(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) return null;
    if (photoUrl.startsWith('data:image/')) {
      try {
        final base64String = photoUrl.split(',').last;
        final bytes = base64Decode(base64String);
        return MemoryImage(bytes);
      } catch (e) {
        return null;
      }
    }
    return NetworkImage(photoUrl);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 850;
    final authProvider = Provider.of<AuthProvider>(context);
    final accentColor = const Color(0xFF2DD4BF);
    final sidebarBgColor = const Color(0xFF0F172A);
    final bodyBgColor = const Color(0xFF0B0F19);

    String t(String en, String ar) => authProvider.isArabic ? ar : en;

    final String pageTitle = t(
      _pageTitles[_selectedIndex],
      _selectedIndex == 0
          ? 'لوحة التحكم العامة'
          : _selectedIndex == 1
              ? 'إدارة المستخدمين'
              : _selectedIndex == 2
                  ? 'مراقبة المجموعات الأكاديمية'
                  : _selectedIndex == 3
                      ? 'إدارة محتوى الكورسات'
                      : 'الإعدادات والملف الشخصي',
    );

    // Sidebar Content Widget
    Widget buildSidebarContent() {
      return Container(
        color: sidebarBgColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sidebar Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.school_rounded, color: accentColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'STUSTEP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: 24),

            // Navigation Items
            _buildSidebarNavItem(0, t('Dashboard', 'لوحة التحكم'), Icons.dashboard_rounded, accentColor),
            _buildSidebarNavItem(1, t('Users Management', 'إدارة المستخدمين'), Icons.people_rounded, accentColor),
            _buildSidebarNavItem(2, t('Groups Monitoring', 'مراقبة المجموعات'), Icons.forum_rounded, accentColor),
            _buildSidebarNavItem(3, t('Courses CMS', 'إدارة الكورسات'), Icons.menu_book_rounded, accentColor),
            _buildSidebarNavItem(4, t('Settings', 'الإعدادات'), Icons.settings_rounded, accentColor),

            const Spacer(),

            // Simulation Banner
            if (authProvider.useMock)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: Color(0xFF2DD4BF), size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            t('Simulation Mode Active', 'وضع المحاكاة نشط'),
                            style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => authProvider.toggleMockMode(false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white10,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 30),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(t('Use Firebase', 'استخدم فايربيس'), style: const TextStyle(fontSize: 10)),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    return Directionality(
      textDirection: authProvider.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: bodyBgColor,
        drawer: !isDesktop
            ? Drawer(
                child: buildSidebarContent(),
              )
            : null,
        body: Row(
          children: [
            // Permanent Sidebar for Desktop
            if (isDesktop)
              SizedBox(
                width: 260,
                child: buildSidebarContent(),
              ),

            // Main Content Area
            Expanded(
              child: Column(
                children: [
                  // Top Navbar (Alnujum Net Style)
                  Container(
                    height: 70,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: sidebarBgColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.04), width: 1.2),
                    ),
                    child: Row(
                      children: [
                        // Drawer Toggle Button for mobile
                        if (!isDesktop) ...[
                          Builder(
                            builder: (context) => IconButton(
                              icon: const Icon(Icons.menu_rounded, color: Colors.white),
                              onPressed: () => Scaffold.of(context).openDrawer(),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],

                        // Page Title on the Right (in RTL)
                        Text(
                          pageTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),

                        // Search Bar (Middle)
                        if (isDesktop) ...[
                          Container(
                            width: 200,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFF090E1A),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.white.withOpacity(0.04)),
                            ),
                            child: TextField(
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                              decoration: InputDecoration(
                                hintText: t('Search...', 'بحث سريع...'),
                                hintStyle: const TextStyle(color: Colors.white24, fontSize: 11),
                                prefixIcon: const Icon(Icons.search_rounded, color: Colors.white24, size: 14),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],

                        // Moon & Notifications Icons
                        IconButton(
                          icon: const Icon(Icons.dark_mode_rounded, color: Colors.white54, size: 18),
                          onPressed: () {},
                        ),
                        const SizedBox(width: 8),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(Icons.notifications_none_rounded, color: Colors.white54, size: 18),
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                padding: const EdgeInsets.all(3.0),
                                decoration: const BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle,
                                ),
                                child: const Text(
                                  '10',
                                  style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),

                        // Vertical Separator
                        Container(height: 20, width: 1, color: Colors.white10),
                        const SizedBox(width: 16),

                        // Admin Profile Menu Button with Dropdown Overlay
                        PopupMenuButton<int>(
                          offset: const Offset(0, 50),
                          color: const Color(0xFF10192D),
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.white.withOpacity(0.05), width: 1.2),
                          ),
                          onSelected: (val) {
                            if (val == 1) {
                              // My Profile
                              setState(() {
                                _selectedIndex = 4;
                              });
                            } else if (val == 2) {
                              // Settings
                              setState(() {
                                _selectedIndex = 4;
                              });
                            } else if (val == 3) {
                              // Logout
                              authProvider.signOut();
                            }
                          },
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: accentColor.withOpacity(0.2),
                                  backgroundImage: _getAvatarProvider(authProvider.currentUser?.photoUrl),
                                  child: authProvider.currentUser?.photoUrl?.isNotEmpty == true
                                      ? null
                                      : Text(
                                          authProvider.currentUser?.name.isNotEmpty == true
                                              ? authProvider.currentUser!.name.substring(0, authProvider.currentUser!.name.length > 2 ? 2 : 1).toUpperCase()
                                              : 'عا',
                                          style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 11),
                                        ),
                                ),
                                const SizedBox(width: 10),
                                if (isDesktop) ...[
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        authProvider.currentUser?.name ?? 'عبدالعزيز الدخين',
                                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        t('General Manager', 'مدير عام'),
                                        style: TextStyle(color: accentColor, fontSize: 10),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_drop_down, color: Colors.white54, size: 16),
                                ],
                              ],
                            ),
                          ),
                          itemBuilder: (context) => [
                            // User Info Header
                            PopupMenuItem<int>(
                              enabled: false,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          authProvider.currentUser?.name ?? 'عبدالعزيز الدخين',
                                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          t('General Manager', 'مدير عام'),
                                          style: TextStyle(color: accentColor, fontSize: 10),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 24),
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: accentColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        authProvider.currentUser?.name.isNotEmpty == true
                                            ? authProvider.currentUser!.name.substring(0, authProvider.currentUser!.name.length > 2 ? 2 : 1).toUpperCase()
                                            : 'عا',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const PopupMenuDivider(height: 1),
                            // Profile option
                            PopupMenuItem<int>(
                              value: 1,
                              child: Row(
                                children: [
                                  const Icon(Icons.person_rounded, color: Colors.white70, size: 18),
                                  const SizedBox(width: 12),
                                  Text(
                                    t('My Profile', 'الملف الشخصي'),
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            // Settings option
                            PopupMenuItem<int>(
                              value: 2,
                              child: Row(
                                children: [
                                  const Icon(Icons.settings_rounded, color: Colors.white70, size: 18),
                                  const SizedBox(width: 12),
                                  Text(
                                    t('Settings', 'الإعدادات'),
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(height: 1),
                            // Logout option
                            PopupMenuItem<int>(
                              value: 3,
                              child: Row(
                                children: [
                                  const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
                                  const SizedBox(width: 12),
                                  Text(
                                    t('Log Out', 'تسجيل الخروج'),
                                    style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Main Page Section
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _pages[_selectedIndex],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarNavItem(int index, String title, IconData icon, Color activeColor) {
    final isSelected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
          // Auto close drawer on mobile after clicking
          if (_scaffoldKey.currentState?.isDrawerOpen == true) {
            Navigator.pop(context);
          }
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withOpacity(0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? activeColor : Colors.white38,
                size: 20,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
