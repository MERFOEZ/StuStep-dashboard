import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dashboard/core/providers/ai_provider.dart';
import 'package:intl/intl.dart';
import 'package:dashboard/screens/dashboard/ai_conversation_detail_page.dart';

class _C {
  static const primary = Color(0xFF6C5CE7);
  static const card = Color(0xFF1E1E36);
  static const border = Color(0xFF2A2A45);
  static const textMuted = Color(0xFF6B6B8D);
}

class AIConversationsPage extends StatefulWidget {
  const AIConversationsPage({super.key});

  @override
  State<AIConversationsPage> createState() => _AIConversationsPageState();
}

class _AIConversationsPageState extends State<AIConversationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AIProvider>().fetchConversations();
    });
  }

  Color _modelColor(String model) {
    switch (model.toLowerCase()) {
      case 'deepseek': return const Color(0xFF00CEFF);
      case 'gemini': return const Color(0xFF4285F4);
      case 'claude': return const Color(0xFFD97706);
      case 'gpt': return const Color(0xFF10A37F);
      default: return _C.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AIProvider>();

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(color: _C.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                child: Text('${provider.totalConversations} محادثة', style: const TextStyle(color: _C.primary, fontWeight: FontWeight.w600, fontSize: 13)),
              ),
              const SizedBox(width: 12),
              ...provider.modelDistribution.entries.map((e) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: _modelColor(e.key).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                  child: Text('${e.key}: ${e.value}', style: TextStyle(color: _modelColor(e.key), fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              )),
            ],
          ),
          const SizedBox(height: 24),

          // Conversations table
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: _C.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: _C.border)),
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator(color: _C.primary))
                  : provider.conversations.isEmpty
                      ? const Center(child: Text('لا توجد محادثات AI مسجّلة بعد', style: TextStyle(color: _C.textMuted)))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SingleChildScrollView(
                            child: SizedBox(
                              width: double.infinity,
                              child: DataTable(
                                columnSpacing: 24, horizontalMargin: 24,
                                columns: const [
                                  DataColumn(label: Text('الطالب')),
                                  DataColumn(label: Text('النموذج')),
                                  DataColumn(label: Text('الرسائل')),
                                  DataColumn(label: Text('البداية')),
                                  DataColumn(label: Text('آخر رسالة')),
                                  DataColumn(label: Text('عرض')),
                                ],
                                rows: provider.conversations.map((conv) {
                                  return DataRow(cells: [
                                    DataCell(Text(conv.userName, style: const TextStyle(fontWeight: FontWeight.w600))),
                                    DataCell(Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(color: _modelColor(conv.model).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                                      child: Text(conv.model, style: TextStyle(color: _modelColor(conv.model), fontSize: 12, fontWeight: FontWeight.w600)),
                                    )),
                                    DataCell(Text('${conv.messagesCount}')),
                                    DataCell(Text(DateFormat('MM/dd HH:mm').format(conv.startedAt), style: const TextStyle(fontSize: 13, color: _C.textMuted))),
                                    DataCell(Text(DateFormat('MM/dd HH:mm').format(conv.lastMessageAt), style: const TextStyle(fontSize: 13, color: _C.textMuted))),
                                    DataCell(IconButton(
                                      icon: const Icon(Icons.visibility_outlined, size: 18, color: _C.primary),
                                      onPressed: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (_) => AIConversationDetailPage(conversation: conv)));
                                      },
                                    )),
                                  ]);
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
