import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dashboard/core/providers/groups_provider.dart';
import 'package:dashboard/core/models/group_model.dart';
import 'package:dashboard/core/models/message_model.dart';
import 'package:intl/intl.dart';

class _C {
  static const primary = Color(0xFF6C5CE7);
  static const accent = Color(0xFF00CEFF);
  static const error = Color(0xFFFF5252);
  static const info = Color(0xFF448AFF);
  static const card = Color(0xFF1E1E36);
  static const surface = Color(0xFF1A1A2E);
  static const border = Color(0xFF2A2A45);
  static const textPrimary = Color(0xFFF0F0F5);
  static const textMuted = Color(0xFF6B6B8D);
  static const background = Color(0xFF0F0F1A);
}

/// Message moderation screen — view and delete messages in a group.
class GroupMessagesPage extends StatelessWidget {
  final GroupModel group;

  const GroupMessagesPage({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<GroupsProvider>();

    return Scaffold(
      backgroundColor: _C.background,
      appBar: AppBar(
        backgroundColor: _C.surface,
        title: Row(
          children: [
            Text('رسائل: ${group.name}'),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _C.info.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('${group.memberCount} عضو', style: const TextStyle(color: _C.info, fontSize: 12)),
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<MessageModel>>(
        stream: provider.getMessages(group.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _C.primary));
          }

          final messages = snapshot.data ?? [];
          if (messages.isEmpty) {
            return const Center(child: Text('لا توجد رسائل في هذه المجموعة', style: TextStyle(color: _C.textMuted)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msg = messages[index];
              return _buildMessageItem(context, msg, provider);
            },
          );
        },
      ),
    );
  }

  Widget _buildMessageItem(BuildContext context, MessageModel msg, GroupsProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: _C.primary.withValues(alpha: 0.15),
            child: Text(
              msg.senderName.isNotEmpty ? msg.senderName[0] : '?',
              style: const TextStyle(color: _C.primary, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(msg.senderName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: _C.primary)),
                  const SizedBox(width: 8),
                  Text(DateFormat('yyyy/MM/dd HH:mm').format(msg.timestamp), style: const TextStyle(color: _C.textMuted, fontSize: 11)),
                ]),
                const SizedBox(height: 4),
                if (msg.text.isNotEmpty) Text(msg.text, style: const TextStyle(color: _C.textPrimary, fontSize: 14)),
                if (msg.fileUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(children: [
                      Icon(msg.fileType == 'image' ? Icons.image : Icons.attach_file, size: 14, color: _C.accent),
                      const SizedBox(width: 4),
                      Text(msg.fileName ?? 'مرفق', style: const TextStyle(color: _C.accent, fontSize: 12)),
                    ]),
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'حذف الرسالة',
            icon: const Icon(Icons.delete_outline, size: 18, color: _C.error),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('حذف الرسالة'),
                  content: const Text('هل تريد حذف هذه الرسالة؟'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
                    ElevatedButton(
                      onPressed: () { Navigator.pop(ctx); provider.deleteMessage(group.id, msg.messageId); },
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
    );
  }
}
