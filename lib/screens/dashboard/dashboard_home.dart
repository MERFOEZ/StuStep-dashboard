import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard/core/theme/app_theme.dart';
import 'package:dashboard/core/l10n/app_localizations.dart';
import 'package:dashboard/core/widgets/animated_stat_card.dart';

/// Premium dashboard home with animated stat cards, welcome banner,
/// quick actions grid, and activity timeline.
class DashboardHome extends StatefulWidget {
  final String userName;

  const DashboardHome({
    super.key,
    required this.userName,
  });

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  late Future<Map<String, int>> _countsFuture;

  @override
  void initState() {
    super.initState();
    _countsFuture = fetchStatistics();
  }

  Future<Map<String, int>> fetchStatistics() async {
    final results = await Future.wait([
      FirebaseFirestore.instance.collection('colleges').count().get(),
      FirebaseFirestore.instance.collection('departments').count().get(),
      FirebaseFirestore.instance.collection('courses').count().get(),
      FirebaseFirestore.instance.collection('store_items').count().get(),
    ]);

    return {
      'colleges': results[0].count ?? 0,
      'departments': results[1].count ?? 0,
      'courses': results[2].count ?? 0,
      'store_items': results[3].count ?? 0,
    };
  }

  void _reloadCounts() {
    setState(() {
      _countsFuture = fetchStatistics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final textTheme = Theme.of(context).textTheme;
    final now = DateTime.now();
    final greeting = _getGreeting(s, now);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Welcome Banner ────────────────────────────────────
          _buildWelcomeBanner(textTheme, greeting, s)
              .animate()
              .fade(duration: 600.ms, delay: 100.ms)
              .slideY(begin: 0.05, duration: 600.ms, delay: 100.ms),

          const SizedBox(height: 28),

          // ─── Stat Cards ────────────────────────────────────────
          _buildStatCards(s),

          const SizedBox(height: 28),

          // ─── Quick Actions + Recent Activity ───────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Actions
              Expanded(
                flex: 3,
                child: _buildQuickActions(s)
                    .animate()
                    .fade(duration: 500.ms, delay: 600.ms)
                    .slideY(begin: 0.05, delay: 600.ms),
              ),
              const SizedBox(width: 20),
              // Activity Timeline
              Expanded(
                flex: 2,
                child: _buildActivityTimeline(s)
                    .animate()
                    .fade(duration: 500.ms, delay: 700.ms)
                    .slideY(begin: 0.05, delay: 700.ms),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getGreeting(S s, DateTime now) {
    if (now.hour < 12) return s.isArabic ? 'صباح الخير' : 'Good Morning';
    if (now.hour < 17) return s.isArabic ? 'مساء الخير' : 'Good Afternoon';
    return s.isArabic ? 'مساء الخير' : 'Good Evening';
  }

  Widget _buildWelcomeBanner(TextTheme textTheme, String greeting, S s) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.secondary.withValues(alpha: 0.08),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '$greeting, ',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      widget.userName,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        foreground: Paint()
                          ..shader = const LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                          ).createShader(
                              const Rect.fromLTWH(0, 0, 200, 40)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('👋', style: const TextStyle(fontSize: 24))
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .rotate(
                          begin: -0.05,
                          end: 0.05,
                          duration: 600.ms,
                        ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  s.isArabic
                      ? 'لوحة التحكم الخاصة بك جاهزة — إليك ملخص سريع'
                      : 'Your dashboard is ready — here\'s a quick summary',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          // Date & Time
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.glassFill,
              border: Border.all(
                color: AppColors.glassBorder.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Text(
                  _formatDate(DateTime.now(), s),
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textHint,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTime(DateTime.now()),
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt, S s) {
    final months = s.isArabic
        ? ['يناير','فبراير','مارس','أبريل','مايو','يونيو','يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر']
        : ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  Widget _buildStatCards(S s) {
    return FutureBuilder<Map<String, int>>(
      future: _countsFuture,
      builder: (context, snapshot) {
        final bool isLoading = snapshot.connectionState == ConnectionState.waiting;
        final bool hasError = snapshot.hasError;
        
        final StatCardState cardState = isLoading 
            ? StatCardState.loading 
            : (hasError ? StatCardState.error : StatCardState.loaded);

        final counts = snapshot.data ?? {};

        return Row(
          children: [
            Expanded(
              child: AnimatedStatCard(
                label: s.colleges,
                value: counts['colleges'] ?? 0,
                icon: Icons.account_balance_rounded,
                gradient: AppColors.gradientViolet,
                state: cardState,
                onRetry: _reloadCounts,
                tooltip: s.isArabic
                    ? 'إجمالي عدد الكليات المسجلة'
                    : 'Total registered colleges',
              ).animate()
                  .fade(duration: 600.ms, delay: 200.ms)
                  .scale(
                    begin: const Offset(0.9, 0.9),
                    duration: 600.ms,
                    delay: 200.ms,
                    curve: Curves.easeOutBack,
                  ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AnimatedStatCard(
                label: s.departments,
                value: counts['departments'] ?? 0,
                icon: Icons.business_rounded,
                gradient: AppColors.gradientCyan,
                state: cardState,
                onRetry: _reloadCounts,
                tooltip: s.isArabic
                    ? 'إجمالي عدد الأقسام'
                    : 'Total departments',
              ).animate()
                  .fade(duration: 600.ms, delay: 350.ms)
                  .scale(
                    begin: const Offset(0.9, 0.9),
                    duration: 600.ms,
                    delay: 350.ms,
                    curve: Curves.easeOutBack,
                  ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AnimatedStatCard(
                label: s.courses,
                value: counts['courses'] ?? 0,
                icon: Icons.menu_book_rounded,
                gradient: AppColors.gradientGreen,
                state: cardState,
                onRetry: _reloadCounts,
                tooltip: s.isArabic
                    ? 'إجمالي عدد المقررات'
                    : 'Total courses',
              ).animate()
                  .fade(duration: 600.ms, delay: 500.ms)
                  .scale(
                    begin: const Offset(0.9, 0.9),
                    duration: 600.ms,
                    delay: 500.ms,
                    curve: Curves.easeOutBack,
                  ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AnimatedStatCard(
                label: s.store,
                value: counts['store_items'] ?? 0,
                icon: Icons.storefront_rounded,
                gradient: AppColors.gradientOrange,
                state: cardState,
                onRetry: _reloadCounts,
                tooltip: s.isArabic
                    ? 'إجمالي عناصر المتجر'
                    : 'Total store items',
              ).animate()
                  .fade(duration: 600.ms, delay: 650.ms)
                  .scale(
                    begin: const Offset(0.9, 0.9),
                    duration: 600.ms,
                    delay: 650.ms,
                    curve: Curves.easeOutBack,
                  ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions(S s) {
    final actions = <_QuickAction>[
      _QuickAction(
        icon: Icons.add_business_rounded,
        label: s.addCollege,
        gradient: AppColors.gradientViolet,
        tooltip: s.isArabic ? 'إضافة كلية جديدة' : 'Add a new college',
      ),
      _QuickAction(
        icon: Icons.domain_add_rounded,
        label: s.addDepartment,
        gradient: AppColors.gradientCyan,
        tooltip: s.isArabic ? 'إضافة قسم جديد' : 'Add a new department',
      ),
      _QuickAction(
        icon: Icons.post_add_rounded,
        label: s.addCourse,
        gradient: AppColors.gradientGreen,
        tooltip: s.isArabic ? 'إضافة مقرر جديد' : 'Add a new course',
      ),
      _QuickAction(
        icon: Icons.add_shopping_cart_rounded,
        label: s.addItem,
        gradient: AppColors.gradientOrange,
        tooltip: s.isArabic ? 'إضافة عنصر للمتجر' : 'Add a store item',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(
          color: AppColors.glassBorder.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flash_on_rounded, color: AppColors.neonYellow, size: 20),
              const SizedBox(width: 8),
              Text(
                s.isArabic ? 'إجراءات سريعة' : 'Quick Actions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.8,
            children: actions.map((action) {
              return _QuickActionCard(action: action);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTimeline(S s) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(
          color: AppColors.glassBorder.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.timeline_rounded, color: AppColors.secondary, size: 20),
              const SizedBox(width: 8),
              Text(
                s.isArabic ? 'آخر النشاطات' : 'Recent Activity',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .orderBy('createdAt', descending: true)
                .limit(3)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    s.isArabic ? 'حدث خطأ' : 'An error occurred',
                    style: const TextStyle(color: AppColors.error),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      s.isArabic ? 'لا توجد نشاطات حديثة' : 'No recent activity',
                      style: const TextStyle(color: AppColors.textHint),
                    ),
                  ),
                );
              }

              final docs = snapshot.data!.docs;
              return Column(
                children: docs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final doc = entry.value;
                  final data = doc.data() as Map<String, dynamic>? ?? {};
                  
                  final name = data['name'] ?? data['email'] ?? (s.isArabic ? 'مستخدم مجهول' : 'Unknown User');
                  final timestamp = data['createdAt'] as Timestamp?;
                  final timeStr = timestamp != null 
                      ? _formatTime(timestamp.toDate()) 
                      : (s.isArabic ? 'الآن' : 'Just now');

                  final activity = _Activity(
                    icon: Icons.person_add_alt_1_rounded,
                    color: AppColors.info,
                    title: s.isArabic ? 'تسجيل مستخدم جديد' : 'New User Registered',
                    subtitle: name,
                    time: timeStr,
                  );

                  return _ActivityItem(
                    activity: activity,
                    isLast: index == docs.length - 1,
                  )
                      .animate()
                      .fade(
                        duration: 400.ms,
                        delay: Duration(milliseconds: 200 + index * 150),
                      )
                      .slideX(
                        begin: 0.05,
                        duration: 400.ms,
                        delay: Duration(milliseconds: 200 + index * 150),
                      );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Quick Action Card ────────────────────────────────────────────────────────

class _QuickAction {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final String tooltip;
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.tooltip,
  });
}

class _QuickActionCard extends StatefulWidget {
  final _QuickAction action;
  const _QuickActionCard({required this.action});

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.action.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: _hovered
                ? widget.action.gradient.first.withValues(alpha: 0.1)
                : AppColors.glassFillDark,
            border: Border.all(
              color: _hovered
                  ? widget.action.gradient.first.withValues(alpha: 0.3)
                  : AppColors.glassBorder.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: widget.action.gradient,
                  ),
                  boxShadow: _hovered
                      ? [
                          BoxShadow(
                            color: widget.action.gradient.first
                                .withValues(alpha: 0.4),
                            blurRadius: 12,
                            spreadRadius: -2,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  widget.action.icon,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.action.label,
                  style: TextStyle(
                    color: _hovered
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: _hovered ? AppColors.textHint : AppColors.textMuted,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Activity Timeline ────────────────────────────────────────────────────────

class _Activity {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String time;
  const _Activity({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.time,
  });
}

class _ActivityItem extends StatelessWidget {
  final _Activity activity;
  final bool isLast;

  const _ActivityItem({required this.activity, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: activity.color.withValues(alpha: 0.15),
                  border: Border.all(
                    color: activity.color.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(
                  activity.icon,
                  color: activity.color,
                  size: 16,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          activity.color.withValues(alpha: 0.3),
                          activity.color.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        activity.title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        activity.time,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    activity.subtitle,
                    style: const TextStyle(
                      color: AppColors.textHint,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
