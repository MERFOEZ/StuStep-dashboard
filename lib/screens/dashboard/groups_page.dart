import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dashboard/core/providers/groups_provider.dart';
import 'package:dashboard/core/models/group_model.dart';
import 'package:intl/intl.dart';
import 'package:dashboard/screens/dashboard/group_messages_page.dart';

/// Design tokens.
class _C {
  static const primary = Color(0xFF6C5CE7);
  static const error = Color(0xFFFF5252);
  static const info = Color(0xFF448AFF);
  static const card = Color(0xFF1E1E36);
  static const surfaceLight = Color(0xFF252542);
  static const border = Color(0xFF2A2A45);
  static const textMuted = Color(0xFF6B6B8D);
}

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupsProvider>().fetchGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GroupsProvider>();

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: _C.info.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${provider.groups.length} مجموعة • ${provider.totalMembers} عضو',
                  style: const TextStyle(color: _C.info, fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showCreateDialog(context, provider),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('مجموعة جديدة'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Groups list
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator(color: _C.primary))
                : provider.groups.isEmpty
                    ? const Center(child: Text('لا توجد مجموعات', style: TextStyle(color: _C.textMuted)))
                    : ListView.builder(
                        itemCount: provider.groups.length,
                        itemBuilder: (context, index) {
                          return _buildGroupTile(context, provider.groups[index], provider);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupTile(BuildContext context, GroupModel group, GroupsProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: _C.info.withValues(alpha: 0.15),
          child: Text(
            group.name.isNotEmpty ? group.name[0] : '?',
            style: const TextStyle(color: _C.info, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(group.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Row(
          children: [
            Text('${group.memberCount} عضو', style: const TextStyle(color: _C.textMuted, fontSize: 12)),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: _C.surfaceLight, borderRadius: BorderRadius.circular(8)),
              child: Text(group.category, style: const TextStyle(color: _C.textMuted, fontSize: 11)),
            ),
            if (group.lastMessageTime != null) ...[
              const SizedBox(width: 12),
              Text(DateFormat('MM/dd HH:mm').format(group.lastMessageTime!), style: const TextStyle(color: _C.textMuted, fontSize: 11)),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'عرض الرسائل',
              icon: const Icon(Icons.message_outlined, size: 20, color: _C.primary),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => GroupMessagesPage(group: group)));
              },
            ),
            IconButton(
              tooltip: 'حذف المجموعة',
              icon: const Icon(Icons.delete_outline, size: 20, color: _C.error),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('حذف المجموعة'),
                    content: Text('هل أنت متأكد من حذف "${group.name}" وجميع رسائلها؟'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
                      ElevatedButton(
                        onPressed: () { Navigator.pop(ctx); provider.deleteGroup(group.id); },
                        style: ElevatedButton.styleFrom(backgroundColor: _C.error),
                        child: const Text('حذف'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateDialog(BuildContext context, GroupsProvider provider) {
    final nameC = TextEditingController();
    final descC = TextEditingController();
    String category = 'Engineering';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('إنشاء مجموعة جديدة'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameC, decoration: const InputDecoration(labelText: 'اسم المجموعة')),
                const SizedBox(height: 16),
                TextField(controller: descC, decoration: const InputDecoration(labelText: 'الوصف')),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: const InputDecoration(labelText: 'التصنيف'),
                  items: const [
                    DropdownMenuItem(value: 'Engineering', child: Text('هندسة')),
                    DropdownMenuItem(value: 'Medicine', child: Text('طب')),
                    DropdownMenuItem(value: 'Science', child: Text('علوم')),
                    DropdownMenuItem(value: 'General', child: Text('عام')),
                  ],
                  onChanged: (v) => setState(() => category = v ?? category),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                if (nameC.text.trim().isEmpty) return;
                Navigator.pop(ctx);
                await provider.createGroup(name: nameC.text.trim(), description: descC.text.trim(), category: category);
              },
              child: const Text('إنشاء'),
            ),
          ],
        ),
      ),
    );
  }
}
