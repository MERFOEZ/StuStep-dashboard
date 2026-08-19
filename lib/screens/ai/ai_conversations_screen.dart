import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ai_provider.dart';
import '../../core/constants/app_colors.dart';
import 'package:intl/intl.dart';
import 'ai_conversation_detail.dart';

class AIConversationsScreen extends StatefulWidget {
  const AIConversationsScreen({super.key});

  @override
  State<AIConversationsScreen> createState() => _AIConversationsScreenState();
}

class _AIConversationsScreenState extends State<AIConversationsScreen> {
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
      default: return AppColors.textMuted;
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
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${provider.totalConversations} محادثة',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
              const SizedBox(width: 12),
              // Model distribution chips
              ...provider.modelDistribution.entries.map((e) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _modelColor(e.key).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${e.key}: ${e.value}',
                    style: TextStyle(color: _modelColor(e.key), fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              )),
            ],
          ),
          const SizedBox(height: 24),

          // Conversations table
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : provider.conversations.isEmpty
                      ? const Center(child: Text('لا توجد محادثات AI مسجّلة بعد', style: TextStyle(color: AppColors.textMuted)))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SingleChildScrollView(
                            child: SizedBox(
                              width: double.infinity,
                              child: DataTable(
                                columnSpacing: 24,
                                horizontalMargin: 24,
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
                                      decoration: BoxDecoration(
                                        color: _modelColor(conv.model).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(conv.model, style: TextStyle(color: _modelColor(conv.model), fontSize: 12, fontWeight: FontWeight.w600)),
                                    )),
                                    DataCell(Text('${conv.messagesCount}')),
                                    DataCell(Text(DateFormat('MM/dd HH:mm').format(conv.startedAt), style: const TextStyle(fontSize: 13, color: AppColors.textMuted))),
                                    DataCell(Text(DateFormat('MM/dd HH:mm').format(conv.lastMessageAt), style: const TextStyle(fontSize: 13, color: AppColors.textMuted))),
                                    DataCell(IconButton(
                                      icon: const Icon(Icons.visibility_outlined, size: 18, color: AppColors.primary),
                                      onPressed: () {
                                        Navigator.push(context, MaterialPageRoute(
                                          builder: (_) => AIConversationDetail(conversation: conv),
                                        ));
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
