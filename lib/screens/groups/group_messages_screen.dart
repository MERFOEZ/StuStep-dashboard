import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/groups_provider.dart';
import '../../models/group_model.dart';
import '../../models/message_model.dart';
import '../../core/constants/app_colors.dart';
import 'package:intl/intl.dart';

/// Message moderation screen — view and delete messages in a group.
class GroupMessagesScreen extends StatelessWidget {
  final GroupModel group;

  const GroupMessagesScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<GroupsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            Text('رسائل: ${group.name}'),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${group.memberCount} عضو',
                style: const TextStyle(color: AppColors.info, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<MessageModel>>(
        stream: provider.getMessages(group.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final messages = snapshot.data ?? [];
          if (messages.isEmpty) {
            return const Center(
              child: Text('لا توجد رسائل في هذه المجموعة', style: TextStyle(color: AppColors.textMuted)),
            );
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
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: Text(
              msg.senderName.isNotEmpty ? msg.senderName[0] : '?',
              style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      msg.senderName,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.primary),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('yyyy/MM/dd HH:mm').format(msg.timestamp),
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (msg.text.isNotEmpty)
                  Text(msg.text, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                if (msg.fileUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(
                          msg.fileType == 'image' ? Icons.image : Icons.attach_file,
                          size: 14,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          msg.fileName ?? 'مرفق',
                          style: const TextStyle(color: AppColors.accent, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Delete button
          IconButton(
            tooltip: 'حذف الرسالة',
            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('حذف الرسالة'),
                  content: const Text('هل تريد حذف هذه الرسالة؟'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        provider.deleteMessage(group.id, msg.messageId);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
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
