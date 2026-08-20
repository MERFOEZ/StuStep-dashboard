import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dashboard/core/theme/app_theme.dart';
import 'package:dashboard/core/l10n/app_localizations.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Premium Floating Frosted-Glass Sidebar
/// ─────────────────────────────────────────────────────────────────────────────
/// Detached from all edges by 20px, border-radius 24, BackdropFilter blur 15,
/// white 70% opacity. Animated active indicator with gradient accent bar,
/// staggered nav item entry, collapsible with animated icon rotation.
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

class _GlassSidebarState extends State<GlassSidebar>
    with SingleTickerProviderStateMixin {
  bool _collapsed = false;
  int _hoveredIndex = -1;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    final items = <_SidebarItem>[
      _SidebarItem(
          Icons.dashboard_rounded, s.appTitle.split(' ').first, 'Dashboard',
          gradient: AppColors.gradientPrimary),
      _SidebarItem(
          Icons.account_balance_rounded, s.academicStructure, 'Colleges',
          gradient: AppColors.gradientViolet),
      _SidebarItem(Icons.people_rounded, 'المستخدمين', 'Users',
          gradient: AppColors.gradientGreen),
      _SidebarItem(Icons.chat_rounded, 'المجموعات', 'Groups',
          gradient: AppColors.gradientOrange),
      _SidebarItem(Icons.smart_toy_rounded, 'محادثات AI', 'AI Chats',
          gradient: AppColors.gradientPink),
      _SidebarItem(Icons.settings_rounded, 'الإعدادات', 'Settings',
          gradient: AppColors.gradientBlue),
    ];

    final width = _collapsed ? 80.0 : 264.0;

    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 20, bottom: 20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        width: width,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.72),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.border.withOpacity(0.35),
                  width: 1,
                ),
                boxShadow: AppColors.panelShadow,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // ─── Logo & Brand ──────────────────────────────────
                  _buildLogo(),
                  const SizedBox(height: 12),
                  // Divider with gradient fade
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.border.withOpacity(0),
                            AppColors.border.withOpacity(0.5),
                            AppColors.border.withOpacity(0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // ─── Navigation Items ──────────────────────────────
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return _buildNavItem(items[index], index)
                            .animate()
                            .fadeIn(
                              duration: 450.ms,
                              delay: Duration(milliseconds: 50 * index),
                            )
                            .slideX(
                              begin: -0.12,
                              duration: 450.ms,
                              delay: Duration(milliseconds: 50 * index),
                              curve: Curves.easeOutCubic,
                            );
                      },
                    ),
                  ),
                  // ─── Collapse toggle ───────────────────────────────
                  _buildCollapseButton(),
                  // ─── Sign out ──────────────────────────────────────
                  _buildSignOutButton(s),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Animated gradient logo icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: const LinearGradient(
                colors: AppColors.gradientPrimary,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: AppColors.gradientGlow(AppColors.primary),
            ),
            child: const Icon(Icons.school_rounded,
                color: Colors.white, size: 23),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .shimmer(
                duration: 3000.ms,
                color: Colors.white.withOpacity(0.15),
              ),
          if (!_collapsed) ...[
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: AppColors.gradientPrimary,
                    ).createShader(bounds),
                    child: Text(
                      'StuStep',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  Text(
                    'Admin Panel',
                    style: TextStyle(
                      color: AppColors.textHint,
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
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: _collapsed ? 0 : 14,
                vertical: 12,
              ),
              transform: Matrix4.identity()
                ..scale(isHovered && !isSelected ? 1.02 : 1.0),
              transformAlignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                // Selected: gradient-tinted background
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          item.gradient.first.withOpacity(0.08),
                          item.gradient.last.withOpacity(0.04),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                    : null,
                color: !isSelected
                    ? (isHovered
                        ? AppColors.surfaceHover
                        : Colors.transparent)
                    : null,
                border: isSelected
                    ? Border.all(
                        color: item.gradient.first.withOpacity(0.15),
                        width: 1,
                      )
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: item.gradient.first.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: -4,
                        ),
                      ]
                    : isHovered
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              spreadRadius: -2,
                            ),
                          ]
                        : null,
              ),
              child: Row(
                mainAxisAlignment: _collapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  // Active accent bar with gradient
                  if (isSelected && !_collapsed) ...[
                    Container(
                      width: 3.5,
                      height: 22,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: LinearGradient(
                          colors: item.gradient,
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: item.gradient.first.withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: -2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  // Icon with gradient when selected
                  isSelected
                      ? ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: item.gradient,
                          ).createShader(bounds),
                          child: Icon(
                            item.icon,
                            color: Colors.white,
                            size: 22,
                          ),
                        )
                      : Icon(
                          item.icon,
                          color: isHovered
                              ? AppColors.textPrimary
                              : AppColors.textHint,
                          size: 22,
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
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Selected indicator dot
                    if (isSelected)
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: item.gradient),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  item.gradient.first.withOpacity(0.5),
                              blurRadius: 6,
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
      padding: const EdgeInsets.symmetric(horizontal: 14),
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
                color: AppColors.surfaceTinted,
                border: Border.all(
                  color: AppColors.border.withOpacity(0.3),
                ),
              ),
              child: Center(
                child: AnimatedRotation(
                  turns: _collapsed ? 0.5 : 0,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: _HoverScaleWrapper(
        onTap: () => widget.onItemSelected(-1),
        child: Tooltip(
          message: s.signOut,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: _collapsed ? 0 : 14,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppColors.error.withOpacity(0.06),
              border: Border.all(
                color: AppColors.error.withOpacity(0.12),
              ),
            ),
            child: Row(
              mainAxisAlignment: _collapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.logout_rounded,
                  color: AppColors.error.withOpacity(0.7),
                  size: 20,
                ),
                if (!_collapsed) ...[
                  const SizedBox(width: 14),
                  Text(
                    s.signOut,
                    style: TextStyle(
                      color: AppColors.error.withOpacity(0.7),
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
    );
  }
}

class _SidebarItem {
  final IconData icon;
  final String label;
  final String id;
  final List<Color> gradient;
  const _SidebarItem(this.icon, this.label, this.id,
      {this.gradient = AppColors.gradientPrimary});
}

/// Utility wrapper: hover → 1.02 scale + elevated shadow on any child.
class _HoverScaleWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _HoverScaleWrapper({required this.child, required this.onTap});

  @override
  State<_HoverScaleWrapper> createState() => _HoverScaleWrapperState();
}

class _HoverScaleWrapperState extends State<_HoverScaleWrapper> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(_hovered ? 1.02 : 1.0),
          transformAlignment: Alignment.center,
          child: widget.child,
        ),
      ),
    );
  }
}
