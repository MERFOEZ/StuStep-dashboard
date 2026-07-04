import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool isLoading = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 22.0),
      decoration: BoxDecoration(
        color: const Color(0xFF10192D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.04), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Container on the Left (RTL aligned to Left)
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          // Title and Value Column on the Right (RTL aligned to Right)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white30)),
                    )
                  : Text(
                      value,
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  // System Alert Card (Left Column)
  Widget _buildSystemAlertsCard(Color cardColor, Color accentColor, String Function(String, String) t) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.04), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notifications_active_rounded, color: accentColor, size: 18),
              const SizedBox(width: 8),
              Text(
                t('SYSTEM ALERTS', 'تنبيهات النظام'),
                style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Alert block (System Status)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF090E1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.02)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, color: Colors.white54, size: 16),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('System Status', 'حالة النظام'),
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t('All services are operating normally.', 'جميع الخدمات تعمل بشكل طبيعي.'),
                        style: const TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        t('Last Update: 14:19', 'آخر تحديث: 14:19'),
                        style: const TextStyle(color: Colors.white24, fontSize: 9),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Activity Log Timeline Card (Left Column, below Alerts)
  Widget _buildRecentActivityLogCard(bool useMock, Color cardColor, Color accentColor, String Function(String, String) t) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.04), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history_rounded, color: accentColor, size: 18),
              const SizedBox(width: 8),
              Text(
                t('ACTIVITY LOGS', 'سجل أنشطة النظام'),
                style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 280,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('activity_logs')
                  .orderBy('timestamp', descending: true)
                  .limit(5)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                }

                final List<Map<String, dynamic>> mockLogs = [
                  {
                    'title': t('Course created', 'تم إنشاء كورس جديد'),
                    'subtitle': t('Advanced Calculus 101 (Admin Portal)', 'حساب التفاضل والتكامل 101 (لوحة الأدمن)'),
                    'time': t('5m ago', 'منذ 5 د'),
                    'color': Colors.purpleAccent,
                  },
                  {
                    'title': t('Role changed to Teacher', 'تم تغيير الصلاحية لـ معلم'),
                    'subtitle': 'عبدالرحمن غالب عبدالله الدخين',
                    'time': t('1h ago', 'منذ 1 ساعة'),
                    'color': Colors.indigoAccent,
                  },
                  {
                    'title': t('User account activated', 'تم تنشيط حساب مستخدم'),
                    'subtitle': 'خضر حسن محمد المرعني',
                    'time': t('3h ago', 'منذ 3 ساعات'),
                    'color': const Color(0xFF10B981),
                  },
                ];

                final List<Widget> children = [];

                if (useMock || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  for (var log in mockLogs) {
                    children.add(_buildTimelineItem(log['title'], log['subtitle'], log['time'], log['color']));
                  }
                } else {
                  for (var doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final action = data['action'] as String? ?? '';
                    final actorName = data['actorName'] as String? ?? '';
                    final targetName = data['targetName'] as String? ?? '';
                    final details = data['details'] as String? ?? '';
                    final timestamp = data['timestamp'] as Timestamp?;

                    String timeAgo = '--';
                    if (timestamp != null) {
                      final diff = DateTime.now().difference(timestamp.toDate());
                      if (diff.inMinutes < 60) {
                        timeAgo = t('${diff.inMinutes}m ago', 'منذ ${diff.inMinutes} د');
                      } else if (diff.inHours < 24) {
                        timeAgo = t('${diff.inHours}h ago', 'منذ ${diff.inHours} ساعة');
                      } else {
                        timeAgo = t('${diff.inDays}d ago', 'منذ ${diff.inDays} يوم');
                      }
                    }

                    String title = '';
                    String subtitle = '';
                    Color color = accentColor;

                    switch (action) {
                      case 'role_changed':
                        title = t('Role updated', 'تم تحديث صلاحية عضو');
                        subtitle = '$targetName -> $details';
                        color = Colors.indigoAccent;
                        break;
                      case 'user_suspended':
                        title = t('Account suspended', 'تم إيقاف حساب مستخدم');
                        subtitle = targetName;
                        color = Colors.redAccent;
                        break;
                      case 'user_activated':
                        title = t('Account activated', 'تم تنشيط حساب مستخدم');
                        subtitle = targetName;
                        color = const Color(0xFF10B981);
                        break;
                      case 'course_created':
                        title = t('Course created', 'تم إنشاء كورس جديد');
                        subtitle = '$targetName ($actorName)';
                        color = Colors.purpleAccent;
                        break;
                      default:
                        title = action.replaceAll('_', ' ').toUpperCase();
                        subtitle = '$targetName $details';
                    }

                    children.add(_buildTimelineItem(title, subtitle, timeAgo, color));
                  }
                }

                return ListView(
                  physics: const BouncingScrollPhysics(),
                  children: children,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String subtitle, String time, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.4), blurRadius: 6),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(color: Colors.white24, fontSize: 10),
          ),
        ],
      ),
    );
  }

  // Student Registers Table Card (Right Column)
  Widget _buildStudentRegistersCard(bool useMock, Color cardColor, Color accentColor, String Function(String, String) t) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.04), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t('LATEST REGISTERED', 'آخر الطلاب'),
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  minimumSize: Size.zero,
                ),
                child: Text(
                  t('View All', 'عرض الكل'),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Custom Data Table
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .orderBy('createdAt', descending: true)
                .limit(5)
                .snapshots(),
            builder: (context, snapshot) {
              final List<Map<String, dynamic>> mockData = [
                {
                  'id': '#367',
                  'name': 'خضر حسن محمد المرعني',
                  'package': t('Student', 'طالب'),
                  'amount': '1,000',
                  'status': t('Active', 'نشط'),
                },
                {
                  'id': '#366',
                  'name': 'عبدالرحمن غالب عبدالله الدخين',
                  'package': t('Teacher', 'معلم'),
                  'amount': '200',
                  'status': t('Active', 'نشط'),
                },
                {
                  'id': '#365',
                  'name': 'خضر حسن محمد المرعني',
                  'package': t('Student', 'طالب'),
                  'amount': '200',
                  'status': t('Active', 'نشط'),
                },
                {
                  'id': '#364',
                  'name': 'أحمد محمد عبدالوهاب الدخين',
                  'package': t('Student', 'طالب'),
                  'amount': '200',
                  'status': t('Active', 'نشط'),
                },
              ];

              List<Map<String, dynamic>> finalData = [];

              if (useMock || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
                finalData = mockData;
              } else {
                for (var doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final roleText = data['role'] == 'admin'
                      ? t('Admin', 'مدير')
                      : data['role'] == 'teacher'
                          ? t('Teacher', 'معلم')
                          : t('Student', 'طالب');
                  
                  finalData.add({
                    'id': '#${doc.id.substring(0, doc.id.length > 3 ? 3 : 1)}',
                    'name': data['name'] ?? '',
                    'package': roleText,
                    'amount': '0',
                    'status': data['status'] == 'active' ? t('Active', 'نشط') : t('Suspended', 'موقوف'),
                  });
                }
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  horizontalMargin: 0,
                  columnSpacing: 28,
                  headingRowHeight: 40,
                  dataRowHeight: 52,
                  columns: [
                    DataColumn(label: Text(t('Order #', 'رقم الطلب'), style: const TextStyle(color: Colors.white38, fontSize: 11))),
                    DataColumn(label: Text(t('Student', 'المستفيد'), style: const TextStyle(color: Colors.white38, fontSize: 11))),
                    DataColumn(label: Text(t('Role', 'الباقة'), style: const TextStyle(color: Colors.white38, fontSize: 11))),
                    DataColumn(label: Text(t('Score', 'المبلغ'), style: const TextStyle(color: Colors.white38, fontSize: 11))),
                    DataColumn(label: Text(t('Status', 'الحالة'), style: const TextStyle(color: Colors.white38, fontSize: 11))),
                    DataColumn(label: Text(t('Actions', 'الإجراءات'), style: const TextStyle(color: Colors.white38, fontSize: 11))),
                  ],
                  rows: finalData.map((row) {
                    final statusColor = row['status'] == t('Active', 'نشط')
                        ? const Color(0xFF10B981)
                        : Colors.redAccent;
                    return DataRow(
                      cells: [
                        DataCell(Text(row['id'], style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold))),
                        DataCell(Text(row['name'], style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
                        DataCell(Text(row['package'], style: const TextStyle(color: Colors.white38, fontSize: 11))),
                        DataCell(Text('${row['amount']} ر.ي', style: const TextStyle(color: Colors.white70, fontSize: 11))),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: statusColor.withOpacity(0.3)),
                            ),
                            child: Text(
                              row['status'],
                              style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        DataCell(
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor.withOpacity(0.1),
                              foregroundColor: accentColor,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              minimumSize: Size.zero,
                              elevation: 0,
                            ),
                            child: Text(t('Details', 'تفاصيل'), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final accentColor = const Color(0xFF00ADEF); // Cyan accent from screenshot
    final cardColor = const Color(0xFF10192D); // Deep blue card background from screenshot

    String t(String en, String ar) => authProvider.isArabic ? ar : en;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row of stats cards (Dynamic if not mock, side-aligned like screenshot)
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, usersSnapshot) {
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('groups').snapshots(),
                  builder: (context, groupsSnapshot) {
                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('courses').snapshots(),
                      builder: (context, coursesSnapshot) {
                        final totalUsers = usersSnapshot.hasData ? usersSnapshot.data!.docs.length : 34;
                        final activeGroups = groupsSnapshot.hasData ? groupsSnapshot.data!.docs.length : 0;
                        final totalCourses = coursesSnapshot.hasData ? coursesSnapshot.data!.docs.length : 2;

                        // Count admins dynamically
                        int adminCount = 0;
                        if (usersSnapshot.hasData) {
                          adminCount = usersSnapshot.data!.docs
                              .where((doc) => (doc.data() as Map<String, dynamic>)['role'] == 'admin')
                              .length;
                        } else {
                          adminCount = 2;
                        }

                        final totalUsersCard = _buildStatCard(
                          title: t('Total Students', 'إجمالي الزبائن'),
                          value: totalUsers.toString(),
                          icon: Icons.people_rounded,
                          color: const Color(0xFF38BDF8),
                          isLoading: !authProvider.useMock && usersSnapshot.connectionState == ConnectionState.waiting,
                        );

                        final activeGroupsCard = _buildStatCard(
                          title: t('Today\'s Orders', 'طلبات اليوم'),
                          value: activeGroups.toString(),
                          icon: Icons.shopping_cart_rounded,
                          color: const Color(0xFF34D399),
                          isLoading: !authProvider.useMock && groupsSnapshot.connectionState == ConnectionState.waiting,
                        );

                        final totalCoursesCard = _buildStatCard(
                          title: t('Today\'s Sales', 'مبيعات اليوم'),
                          value: t('0 SAR', '0 ريال'),
                          icon: Icons.monetization_on_rounded,
                          color: const Color(0xFFFBBF24),
                          isLoading: !authProvider.useMock && coursesSnapshot.connectionState == ConnectionState.waiting,
                        );

                        final activeNowCard = _buildStatCard(
                          title: t('Total Distributors', 'إجمالي الموزعين'),
                          value: adminCount.toString(),
                          icon: Icons.store_rounded,
                          color: const Color(0xFF818CF8),
                          isLoading: !authProvider.useMock && usersSnapshot.connectionState == ConnectionState.waiting,
                        );

                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth > 1000;
                            final isMedium = constraints.maxWidth > 600 && constraints.maxWidth <= 1000;

                            if (isWide) {
                              return Row(
                                children: [
                                  Expanded(child: totalUsersCard),
                                  const SizedBox(width: 16),
                                  Expanded(child: activeGroupsCard),
                                  const SizedBox(width: 16),
                                  Expanded(child: totalCoursesCard),
                                  const SizedBox(width: 16),
                                  Expanded(child: activeNowCard),
                                ],
                              );
                            } else if (isMedium) {
                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(child: totalUsersCard),
                                      const SizedBox(width: 16),
                                      Expanded(child: activeGroupsCard),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(child: totalCoursesCard),
                                      const SizedBox(width: 16),
                                      Expanded(child: activeNowCard),
                                    ],
                                  ),
                                ],
                              );
                            } else {
                              return Column(
                                children: [
                                  totalUsersCard,
                                  const SizedBox(height: 16),
                                  activeGroupsCard,
                                  const SizedBox(height: 16),
                                  totalCoursesCard,
                                  const SizedBox(height: 16),
                                  activeNowCard,
                                ],
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),

            // Two columns layout: System Alerts (Left) and Student Registers Table (Right)
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 950;
                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Right Column: Student registers
                      Expanded(
                        flex: 5,
                        child: _buildStudentRegistersCard(authProvider.useMock, cardColor, accentColor, t),
                      ),
                      const SizedBox(width: 24),
                      // Left Column: Alerts & logs
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            _buildSystemAlertsCard(cardColor, accentColor, t),
                            const SizedBox(height: 24),
                            _buildRecentActivityLogCard(authProvider.useMock, cardColor, accentColor, t),
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildStudentRegistersCard(authProvider.useMock, cardColor, accentColor, t),
                      const SizedBox(height: 24),
                      _buildSystemAlertsCard(cardColor, accentColor, t),
                      const SizedBox(height: 24),
                      _buildRecentActivityLogCard(authProvider.useMock, cardColor, accentColor, t),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
