import 'package:flutter/material.dart';
import 'package:dashboard/core/widgets/glass_sidebar.dart';
import 'package:dashboard/core/widgets/glass_top_bar.dart';
import 'package:dashboard/core/widgets/animated_gradient_mesh.dart';
import 'package:dashboard/core/l10n/app_localizations.dart';
import 'package:dashboard/main.dart';
import 'package:dashboard/screens/dashboard/dashboard_home.dart';
import 'package:dashboard/screens/dashboard/colleges_page.dart';
import 'package:dashboard/screens/dashboard/departments_page.dart';
import 'package:dashboard/screens/dashboard/courses_page.dart';
import 'package:dashboard/screens/dashboard/users_page.dart';
import 'package:dashboard/screens/dashboard/groups_page.dart';
import 'package:dashboard/screens/dashboard/ai_conversations_page.dart';
import 'package:dashboard/screens/dashboard/settings_page.dart';


enum DashboardView {
  home,
  colleges,
  departments,
  courses,
  users,
  groups,
  aiChats,
  settings,
}

/// ─────────────────────────────────────────────────────────────────────────────
/// Main Dashboard Shell — Stripe-Tier Vibrant Light Mode
/// ─────────────────────────────────────────────────────────────────────────────
/// Living ambient canvas → floating frosted sidebar → frosted top bar →
/// animated content area with seamless route transitions.
/// Static rendering is strictly forbidden — every element breathes.
class DashboardShell extends StatefulWidget {
  final String userName;
  final VoidCallback onSignOut;

  const DashboardShell({
    super.key,
    required this.userName,
    required this.onSignOut,
  });

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int _selectedIndex = 0;
  DashboardView _currentView = DashboardView.home;
  String? _selectedCollegeId;
  String? _selectedDepartmentId;

  void _onItemSelected(int index) {
    if (index == -1) {
      widget.onSignOut();
      return;
    }
    setState(() {
      _selectedIndex = index;
      _selectedCollegeId = null;
      _selectedDepartmentId = null;
      switch (index) {
        case 0:
          _currentView = DashboardView.home;
        case 1:
          _currentView = DashboardView.colleges;
        case 2:
          _currentView = DashboardView.users;
        case 3:
          _currentView = DashboardView.groups;
        case 4:
          _currentView = DashboardView.aiChats;
        case 5:
          _currentView = DashboardView.settings;
        default:
          _currentView = DashboardView.home;
      }
    });
  }

  void _navigateToDepartments(String collegeId) {
    setState(() {
      _selectedCollegeId = collegeId;
      _currentView = DashboardView.departments;
    });
  }

  void _navigateToCourses(String departmentId) {
    setState(() {
      _selectedDepartmentId = departmentId;
      _currentView = DashboardView.courses;
    });
  }

  void _backToColleges() {
    setState(() {
      _selectedCollegeId = null;
      _currentView = DashboardView.colleges;
    });
  }

  void _backToDepartments() {
    setState(() {
      _selectedDepartmentId = null;
      _currentView = DashboardView.departments;
    });
  }

  String _getPageTitle(S s) {
    switch (_currentView) {
      case DashboardView.home:
        return s.appTitle;
      case DashboardView.colleges:
        return s.academicStructure;
      case DashboardView.departments:
        return s.departments;
      case DashboardView.courses:
        return s.courses;
      case DashboardView.users:
        return 'المستخدمين';
      case DashboardView.groups:
        return 'المجموعات';
      case DashboardView.aiChats:
        return 'محادثات AI';
      case DashboardView.settings:
        return 'الإعدادات';
    }
  }

  Widget _getPage() {
    switch (_currentView) {
      case DashboardView.home:
        return DashboardHome(
          userName: widget.userName,
          key: const ValueKey('home'),
        );
      case DashboardView.colleges:
        return CollegesPage(
          key: const ValueKey('colleges'),
          onNavigateToDepartments: _navigateToDepartments,
        );
      case DashboardView.departments:
        return DepartmentsPage(
          key: ValueKey('departments_$_selectedCollegeId'),
          collegeId: _selectedCollegeId,
          onNavigateToCourses: _navigateToCourses,
          onBack: _backToColleges,
        );
      case DashboardView.courses:
        return CoursesPage(
          key: ValueKey('courses_$_selectedDepartmentId'),
          departmentId: _selectedDepartmentId,
          onBack: _backToDepartments,
        );
      case DashboardView.users:
        return const UsersPage(key: ValueKey('users'));
      case DashboardView.groups:
        return const GroupsPage(key: ValueKey('groups'));
      case DashboardView.aiChats:
        return const AIConversationsPage(key: ValueKey('aiChats'));
      case DashboardView.settings:
        return const SettingsPage(key: ValueKey('settings'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final localeProvider = LocaleProviderScope.of(context);

    return AnimatedGradientMesh(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Row(
          children: [
            // ─── Floating Frosted Sidebar ───────────────────────
            GlassSidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: _onItemSelected,
            ),

            // ─── Main Content Area ─────────────────────────────
            Expanded(
              child: Column(
                children: [
                  // ─── Frosted Top Bar ─────────────────────────
                  GlassTopBar(
                    userName: widget.userName,
                    pageTitle: _getPageTitle(s),
                    onToggleLocale: () => localeProvider.toggleLocale(),
                  ),

                  // ─── Page Content — seamless animated transitions ────
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 600),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: CurvedAnimation(
                            parent: animation,
                            curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
                          ),
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.04),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            )),
                            child: child,
                          ),
                        );
                      },
                      child: Padding(
                        key: ValueKey(_currentView.toString() + (_selectedDepartmentId ?? '') + (_selectedCollegeId ?? '')),
                        padding: const EdgeInsets.only(right: 20, top: 0),
                        child: _getPage(),
                      ),
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
}
