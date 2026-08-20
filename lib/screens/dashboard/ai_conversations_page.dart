import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dashboard/core/providers/ai_provider.dart';
import 'package:dashboard/core/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:dashboard/screens/dashboard/ai_conversation_detail_page.dart';

class AIConversationsPage extends StatefulWidget {
  const AIConversationsPage({super.key});

  @override
  State<AIConversationsPage> createState() =>
      _AIConversationsPageState();
}

class _AIConversationsPageState
    extends State<AIConversationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AIProvider>().fetchConversations();
    });
  }

  Color _modelColor(String model) {
    switch (model.toLowerCase()) {
      case 'deepseek':
        return const Color(0xFF00CEFF);
      case 'gemini':
        return const Color(0xFF4285F4);
      case 'claude':
        return const Color(0xFFD97706);
      case 'gpt':
        return const Color(0xFF10A37F);
      default:
        return AppColors.textHint;
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                    color:
                        AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.primary
                            .withValues(alpha: 0.15))),
                child: Text(
                    '${provider.totalConversations} محادثة',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
              ),
              const SizedBox(width: 12),
              ...provider.modelDistribution.entries.map(
                  (e) => Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              color: _modelColor(e.key)
                                  .withValues(alpha: 0.1),
                              borderRadius:
                                  BorderRadius.circular(12)),
                          child: Text(
                              '${e.key}: ${e.value}',
                              style: TextStyle(
                                  color: _modelColor(e.key),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ),
                      )),
            ],
          ),
          const SizedBox(height: 24),

          // Glassmorphic conversations table
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter:
                    ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.border
                            .withOpacity(0.3)),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: provider.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary))
                      : provider.conversations.isEmpty
                          ? Center(
                              child: Text(
                                  'لا توجد محادثات AI مسجّلة بعد',
                                  style: TextStyle(
                                      color:
                                          AppColors.textHint)))
                          : ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(20),
                              child: SingleChildScrollView(
                                child: SizedBox(
                                  width: double.infinity,
                                  child: DataTable(
                                    columnSpacing: 24,
                                    horizontalMargin: 24,
                                    headingRowColor:
                                        WidgetStateProperty.all(
                                            Colors.white
                                                .withOpacity(
                                                    0.7)),
                                    columns: const [
                                      DataColumn(
                                          label: Text(
                                              'الطالب',
                                              style: TextStyle(
                                                  color: AppColors
                                                      .textPrimary,
                                                  fontWeight:
                                                      FontWeight
                                                          .w700))),
                                      DataColumn(
                                          label: Text(
                                              'النموذج',
                                              style: TextStyle(
                                                  color: AppColors
                                                      .textPrimary,
                                                  fontWeight:
                                                      FontWeight
                                                          .w700))),
                                      DataColumn(
                                          label: Text(
                                              'الرسائل',
                                              style: TextStyle(
                                                  color: AppColors
                                                      .textPrimary,
                                                  fontWeight:
                                                      FontWeight
                                                          .w700))),
                                      DataColumn(
                                          label: Text(
                                              'البداية',
                                              style: TextStyle(
                                                  color: AppColors
                                                      .textPrimary,
                                                  fontWeight:
                                                      FontWeight
                                                          .w700))),
                                      DataColumn(
                                          label: Text(
                                              'آخر رسالة',
                                              style: TextStyle(
                                                  color: AppColors
                                                      .textPrimary,
                                                  fontWeight:
                                                      FontWeight
                                                          .w700))),
                                      DataColumn(
                                          label: Text(
                                              'عرض',
                                              style: TextStyle(
                                                  color: AppColors
                                                      .textPrimary,
                                                  fontWeight:
                                                      FontWeight
                                                          .w700))),
                                    ],
                                    rows: provider
                                        .conversations
                                        .map((conv) {
                                      return DataRow(cells: [
                                        DataCell(Text(
                                            conv.userName,
                                            style: const TextStyle(
                                                fontWeight:
                                                    FontWeight
                                                        .w600,
                                                color: AppColors
                                                    .textPrimary))),
                                        DataCell(Container(
                                          padding:
                                              const EdgeInsets
                                                  .symmetric(
                                                  horizontal:
                                                      10,
                                                  vertical:
                                                      4),
                                          decoration: BoxDecoration(
                                              color: _modelColor(
                                                      conv
                                                          .model)
                                                  .withValues(
                                                      alpha:
                                                          0.1),
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                          12)),
                                          child: Text(
                                              conv.model,
                                              style: TextStyle(
                                                  color: _modelColor(
                                                      conv
                                                          .model),
                                                  fontSize:
                                                      12,
                                                  fontWeight:
                                                      FontWeight
                                                          .w600)),
                                        )),
                                        DataCell(Text(
                                            '${conv.messagesCount}',
                                            style: const TextStyle(
                                                color: AppColors
                                                    .textPrimary))),
                                        DataCell(Text(
                                            DateFormat(
                                                    'MM/dd HH:mm')
                                                .format(conv
                                                    .startedAt),
                                            style: const TextStyle(
                                                fontSize:
                                                    13,
                                                color: AppColors
                                                    .textHint))),
                                        DataCell(Text(
                                            DateFormat(
                                                    'MM/dd HH:mm')
                                                .format(conv
                                                    .lastMessageAt),
                                            style: const TextStyle(
                                                fontSize:
                                                    13,
                                                color: AppColors
                                                    .textHint))),
                                        DataCell(IconButton(
                                          icon: const Icon(
                                              Icons
                                                  .visibility_outlined,
                                              size: 18,
                                              color: AppColors
                                                  .primary),
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        AIConversationDetailPage(
                                                            conversation:
                                                                conv)));
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
            ),
          ),
        ],
      ),
    );
  }
}
