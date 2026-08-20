import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dashboard/core/providers/ai_provider.dart';
import 'package:dashboard/core/models/ai_conversation_model.dart';
import 'package:dashboard/core/models/ai_message_model.dart';
import 'package:intl/intl.dart';

class _C {
  static const primary = Color(0xFF6C5CE7);
  static const accent = Color(0xFF00CEFF);
  static const card = Color(0xFF1E1E36);
  static const surface = Color(0xFF1A1A2E);
  static const border = Color(0xFF2A2A45);
  static const textPrimary = Color(0xFFF0F0F5);
  static const textMuted = Color(0xFF6B6B8D);
  static const background = Color(0xFF0F0F1A);
}

class AIConversationDetailPage extends StatefulWidget {
  final AIConversationModel conversation;

  const AIConversationDetailPage({super.key, required this.conversation});

  @override
  State<AIConversationDetailPage> createState() => _AIConversationDetailPageState();
}

class _AIConversationDetailPageState extends State<AIConversationDetailPage> {
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
      backgroundColor: _C.background,
      appBar: AppBar(
        backgroundColor: _C.surface,
        title: Row(
          children: [
            Text('محادثة: ${conv.userName}'),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: _C.accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
              child: Text(conv.model, style: const TextStyle(color: _C.accent, fontSize: 12)),
            ),
            const SizedBox(width: 8),
            Text('${conv.messagesCount} رسالة', style: const TextStyle(color: _C.textMuted, fontSize: 13)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _C.primary))
          : _messages.isEmpty
              ? const Center(child: Text('لا توجد رسائل', style: TextStyle(color: _C.textMuted)))
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
                          color: isUser ? _C.primary.withValues(alpha: 0.15) : _C.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isUser ? _C.primary.withValues(alpha: 0.3) : _C.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Icon(isUser ? Icons.person : Icons.smart_toy, size: 16, color: isUser ? _C.primary : _C.accent),
                              const SizedBox(width: 6),
                              Text(isUser ? 'الطالب' : msg.model,
                                style: TextStyle(color: isUser ? _C.primary : _C.accent, fontSize: 12, fontWeight: FontWeight.w600)),
                              const Spacer(),
                              Text(DateFormat('HH:mm').format(msg.timestamp), style: const TextStyle(color: _C.textMuted, fontSize: 11)),
                            ]),
                            const SizedBox(height: 8),
                            SelectableText(msg.content, style: const TextStyle(color: _C.textPrimary, fontSize: 14, height: 1.5)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
