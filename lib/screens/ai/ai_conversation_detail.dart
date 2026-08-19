import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ai_provider.dart';
import '../../models/ai_conversation_model.dart';
import '../../models/ai_message_model.dart';
import '../../core/constants/app_colors.dart';
import 'package:intl/intl.dart';

class AIConversationDetail extends StatefulWidget {
  final AIConversationModel conversation;

  const AIConversationDetail({super.key, required this.conversation});

  @override
  State<AIConversationDetail> createState() => _AIConversationDetailState();
}

class _AIConversationDetailState extends State<AIConversationDetail> {
  List<AIMessageModel> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final provider = context.read<AIProvider>();
    final messages = await provider.getConversationMessages(widget.conversation.id);
    setState(() {
      _messages = messages;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final conv = widget.conversation;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            Text('محادثة: ${conv.userName}'),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(conv.model, style: const TextStyle(color: AppColors.accent, fontSize: 12)),
            ),
            const SizedBox(width: 8),
            Text(
              '${conv.messagesCount} رسالة',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _messages.isEmpty
              ? const Center(child: Text('لا توجد رسائل', style: TextStyle(color: AppColors.textMuted)))
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final isUser = msg.role == 'user';

                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
                        decoration: BoxDecoration(
                          color: isUser ? AppColors.primary.withValues(alpha: 0.15) : AppColors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isUser ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isUser ? Icons.person : Icons.smart_toy,
                                  size: 16,
                                  color: isUser ? AppColors.primary : AppColors.accent,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isUser ? 'الطالب' : msg.model,
                                  style: TextStyle(
                                    color: isUser ? AppColors.primary : AppColors.accent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  DateFormat('HH:mm').format(msg.timestamp),
                                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SelectableText(
                              msg.content,
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
