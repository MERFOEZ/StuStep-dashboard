import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:dashboard/core/theme/app_theme.dart';
import 'package:dashboard/core/l10n/app_localizations.dart';

/// Glass sidebar with animated active indicator and collapsible navigation.
class GlassSidebar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const GlassSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  State<GlassSidebar> createState() => _GlassSidebarState();
}

class _GlassSidebarState extends State<GlassSidebar> {
  bool _collapsed = false;
  int _hoveredIndex = -1;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    final items = <_SidebarItem>[
      _SidebarItem(Icons.dashboard_rounded, s.appTitle.split(' ').first, 'Dashboard'),
      _SidebarItem(Icons.account_balance_rounded, s.academicStructure, 'Colleges'),
      _SidebarItem(Icons.analytics_rounded, 'نظرة عامة', 'Overview'),
      _SidebarItem(Icons.people_rounded, 'المستخدمين', 'Users'),
      _SidebarItem(Icons.chat_rounded, 'المجموعات', 'Groups'),
      _SidebarItem(Icons.smart_toy_rounded, 'محادثات AI', 'AI Chats'),
      _SidebarItem(Icons.settings_rounded, 'الإعدادات', 'Settings'),
    ];

    final width = _collapsed ? 72.0 : 240.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      width: width,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(0),
          bottomLeft: Radius.circular(0),
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.sidebarBg.withValues(alpha: 0.85),
              border: Border(
                right: BorderSide(
                  color: AppColors.glassBorder.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // ─── Logo & Brand ──────────────────────────────────
                _buildLogo(),
                const SizedBox(height: 8),
                // Divider
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(
                    color: AppColors.glassBorder.withValues(alpha: 0.3),
                    height: 1,
                  ),
                ),
                const SizedBox(height: 12),
                // ─── Navigation Items ──────────────────────────────
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return _buildNavItem(items[index], index);
                    },
                  ),
                ),
                // ─── Collapse toggle ───────────────────────────────
                _buildCollapseButton(),
                // ─── Sign out ──────────────────────────────────────
                _buildSignOutButton(s),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 16,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: const Icon(Icons.school_rounded, color: Colors.white, size: 22),
          ),
          if (!_collapsed) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'StuStep',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Admin Panel',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavItem(_SidebarItem item, int index) {
    final isSelected = widget.selectedIndex == index;
    final isHovered = _hoveredIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoveredIndex = index),
        onExit: (_) => setState(() => _hoveredIndex = -1),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => widget.onItemSelected(index),
          child: Tooltip(
            message: _collapsed ? item.label : '',
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: _collapsed ? 0 : 14,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: isSelected
                    ? AppColors.sidebarActive
                    : isHovered
                        ? AppColors.sidebarHover
                        : Colors.transparent,
                border: isSelected
                    ? Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        width: 1,
                      )
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 12,
                          spreadRadius: -2,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment:
                    _collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      item.icon,
                      color: isSelected
                          ? AppColors.primaryLight
                          : isHovered
                              ? AppColors.textPrimary
                              : AppColors.textHint,
                      size: 22,
                    ),
                  ),
                  if (!_collapsed) ...[
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        item.label,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.textPrimary
                              : isHovered
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isSelected)
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.6),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCollapseButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => setState(() => _collapsed = !_collapsed),
          child: Tooltip(
            message: _collapsed ? 'توسيع' : 'طي',
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.glassFillDark,
              ),
              child: Center(
                child: AnimatedRotation(
                  turns: _collapsed ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    Icons.keyboard_double_arrow_left_rounded,
                    color: AppColors.textHint,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignOutButton(S s) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            // Sign out handled by parent
            widget.onItemSelected(-1); // -1 signals sign out
          },
          child: Tooltip(
            message: s.signOut,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: _collapsed ? 0 : 14,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: AppColors.error.withValues(alpha: 0.08),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                mainAxisAlignment:
                    _collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.logout_rounded,
                    color: AppColors.error.withValues(alpha: 0.8),
                    size: 20,
                  ),
                  if (!_collapsed) ...[
                    const SizedBox(width: 14),
                    Text(
                      s.signOut,
                      style: TextStyle(
                        color: AppColors.error.withValues(alpha: 0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarItem {
  final IconData icon;
  final String label;
  final String id;
  const _SidebarItem(this.icon, this.label, this.id);
}
