import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard/core/constants/firestore_paths.dart';

class _C {
  static const primary = Color(0xFF6C5CE7);
  static const accent = Color(0xFF00CEFF);
  static const warning = Color(0xFFFFAB00);
  static const card = Color(0xFF1E1E36);
  static const border = Color(0xFF2A2A45);
  static const textPrimary = Color(0xFFF0F0F5);
  static const textSecondary = Color(0xFF9A9ABF);
  static const textMuted = Color(0xFF6B6B8D);
}

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  int _usersCount = 0;
  int _groupsCount = 0;
  int _aiTodayCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final firestore = FirebaseFirestore.instance;

    try {
      final results = await Future.wait([
        firestore.collection(FirestorePaths.users).count().get(),
        firestore.collection(FirestorePaths.groups).count().get(),
        _getTodayAICount(firestore),
      ]);

      if (mounted) {
        setState(() {
          _usersCount = (results[0] as AggregateQuerySnapshot).count ?? 0;
          _groupsCount = (results[1] as AggregateQuerySnapshot).count ?? 0;
          _aiTodayCount = results[2] as int;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<int> _getTodayAICount(FirebaseFirestore firestore) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    try {
      final snapshot = await firestore
          .collection(FirestorePaths.aiConversations)
          .where('startedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── KPI Cards Row ──
          _isLoading
              ? const Center(
                  child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: _C.primary)),
                )
              : Row(
                  children: [
                    _buildStatCard(icon: Icons.people_rounded, label: 'إجمالي المستخدمين', value: '$_usersCount', color: _C.primary),
                    const SizedBox(width: 20),
                    _buildStatCard(icon: Icons.chat_rounded, label: 'المجموعات', value: '$_groupsCount', color: _C.warning),
                    const SizedBox(width: 20),
                    _buildStatCard(icon: Icons.smart_toy_rounded, label: 'محادثات AI اليوم', value: '$_aiTodayCount', color: _C.accent),
                  ],
                ),
          const SizedBox(height: 32),

          // ── Recent Users Stream ──
          _buildRecentSection(
            title: 'آخر المستخدمين المسجّلين',
            icon: Icons.person_add_rounded,
            stream: FirebaseFirestore.instance
                .collection(FirestorePaths.users)
                .orderBy('createdAt', descending: true)
                .limit(5)
                .snapshots(),
            builder: (docs) => Column(
              children: docs.map((doc) {
                final data = doc.data();
                return ListTile(
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: _C.primary.withValues(alpha: 0.15),
                    child: Text(
                      (data['name'] ?? '?')[0].toString().toUpperCase(),
                      style: const TextStyle(color: _C.primary, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  title: Text(data['name'] ?? '—', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text(data['email'] ?? '', style: const TextStyle(fontSize: 12, color: _C.textMuted)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (data['role'] == 'admin' ? _C.primary : _C.accent).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      data['role'] == 'admin' ? 'مدير' : 'طالب',
                      style: TextStyle(color: data['role'] == 'admin' ? _C.primary : _C.accent, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                  dense: true,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // ── Recent AI Conversations Stream ──
          _buildRecentSection(
            title: 'آخر محادثات AI',
            icon: Icons.smart_toy_rounded,
            stream: FirebaseFirestore.instance
                .collection(FirestorePaths.aiConversations)
                .orderBy('lastMessageAt', descending: true)
                .limit(5)
                .snapshots(),
            builder: (docs) => Column(
              children: docs.map((doc) {
                final data = doc.data();
                return ListTile(
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: _C.accent.withValues(alpha: 0.15),
                    child: const Icon(Icons.smart_toy, size: 18, color: _C.accent),
                  ),
                  title: Text(data['userName'] ?? '—', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    'نموذج: ${data['model'] ?? '—'} • ${data['messagesCount'] ?? 0} رسالة',
                    style: const TextStyle(fontSize: 12, color: _C.textMuted),
                  ),
                  dense: true,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({required IconData icon, required String label, required String value, required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: _C.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: _C.border)),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: _C.textPrimary)),
            Text(label, style: const TextStyle(fontSize: 12, color: _C.textSecondary)),
          ]),
        ]),
      ),
    );
  }

  Widget _buildRecentSection({
    required String title,
    required IconData icon,
    required Stream<QuerySnapshot<Map<String, dynamic>>> stream,
    required Widget Function(List<QueryDocumentSnapshot<Map<String, dynamic>>>) builder,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: _C.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: _C.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: _C.primary, size: 20),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _C.textPrimary)),
          ]),
          const Divider(height: 24, color: _C.border),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator(color: _C.primary, strokeWidth: 2)));
              }
              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return const Padding(padding: EdgeInsets.all(20), child: Center(child: Text('لا توجد بيانات بعد', style: TextStyle(color: _C.textMuted))));
              }
              return builder(docs);
            },
          ),
        ],
      ),
    );
  }
}
