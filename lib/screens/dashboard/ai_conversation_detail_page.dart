import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dashboard/core/providers/ai_provider.dart';
import 'package:dashboard/core/models/ai_conversation_model.dart';
import 'package:dashboard/core/models/ai_message_model.dart';
import 'package:dashboard/core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class AIConversationDetailPage extends StatefulWidget {
  final AIConversationModel conversation;

  const AIConversationDetailPage(
      {super.key, required this.conversation});

  @override
  State<AIConversationDetailPage> createState() =>
      _AIConversationDetailPageState();
}

class _AIConversationDetailPageState
    extends State<AIConversationDetailPage> {
  List<AIMessageModel> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final provider = context.read<AIProvider>();
    final messages = await provider
        .getConversationMessages(widget.conversation.id);
    setState(() {
      _messages = messages;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final conv = widget.conversation;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Text('محادثة: ${conv.userName}',
                style: const TextStyle(
                    color: AppColors.textPrimary)),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: AppColors.secondary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12)),
              child: Text(conv.model,
                  style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 12)),
            ),
            const SizedBox(width: 8),
            Text('${conv.messagesCount} رسالة',
                style: const TextStyle(
                    color: AppColors.textHint, fontSize: 13)),
          ],
        ),
        iconTheme:
            const IconThemeData(color: AppColors.textPrimary),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: AppColors.primary))
          : _messages.isEmpty
              ? Center(
                  child: Text('لا توجد رسائل',
                      style: TextStyle(
                          color: AppColors.textHint)))
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final isUser = msg.role == 'user';

                    return Align(
                      alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin:
                            const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context)
                                    .size
                                    .width *
                                0.6),
                        decoration: BoxDecoration(
                          color: isUser
                              ? AppColors.primary
                                  .withValues(alpha: 0.08)
                              : AppColors.surface,
                          borderRadius:
                              BorderRadius.circular(16),
                          border: Border.all(
                              color: isUser
                                  ? AppColors.primary
                                      .withValues(alpha: 0.2)
                                  : AppColors.border
                                      .withOpacity(0.3)),
                          boxShadow: AppColors.softShadow,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Icon(
                                  isUser
                                      ? Icons.person
                                      : Icons.smart_toy,
                                  size: 16,
                                  color: isUser
                                      ? AppColors.primary
                                      : AppColors.secondary),
                              const SizedBox(width: 6),
                              Text(
                                  isUser
                                      ? 'الطالب'
                                      : msg.model,
                                  style: TextStyle(
                                      color: isUser
                                          ? AppColors.primary
                                          : AppColors
                                              .secondary,
                                      fontSize: 12,
                                      fontWeight:
                                          FontWeight.w600)),
                              const Spacer(),
                              Text(
                                  DateFormat('HH:mm')
                                      .format(msg.timestamp),
                                  style: const TextStyle(
                                      color:
                                          AppColors.textHint,
                                      fontSize: 11)),
                            ]),
                            const SizedBox(height: 8),
                            SelectableText(msg.content,
                                style: const TextStyle(
                                    color:
                                        AppColors.textPrimary,
                                    fontSize: 14,
                                    height: 1.5)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
