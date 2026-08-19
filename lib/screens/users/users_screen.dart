import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/users_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/admin_user_model.dart';
import 'package:intl/intl.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UsersProvider>().fetchUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UsersProvider>();

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Stats Row ──
          Row(
            children: [
              _MiniStat(
                label: 'الإجمالي',
                value: '${provider.totalCount}',
                color: AppColors.primary,
                icon: Icons.people,
              ),
              const SizedBox(width: 16),
              _MiniStat(
                label: 'طلاب',
                value: '${provider.studentCount}',
                color: AppColors.accent,
                icon: Icons.school,
              ),
              const SizedBox(width: 16),
              _MiniStat(
                label: 'مدراء',
                value: '${provider.adminCount}',
                color: AppColors.success,
                icon: Icons.admin_panel_settings,
              ),
              const SizedBox(width: 16),
              _MiniStat(
                label: 'معطّل',
                value: '${provider.disabledCount}',
                color: AppColors.error,
                icon: Icons.block,
              ),
              const Spacer(),
              // Search
              SizedBox(
                width: 280,
                height: 42,
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'بحث بالاسم أو البريد...',
                    hintStyle: const TextStyle(fontSize: 13),
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 20,
                      color: AppColors.textMuted,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                  onChanged: (v) => provider.search(v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Table ──
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: provider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : provider.users.isEmpty
                      ? const Center(
                          child: Text(
                            'لا يوجد مستخدمين',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SingleChildScrollView(
                            child: SizedBox(
                              width: double.infinity,
                              child: DataTable(
                                columnSpacing: 24,
                                horizontalMargin: 24,
                                headingRowHeight: 52,
                                dataRowMinHeight: 56,
                                dataRowMaxHeight: 56,
                                columns: const [
                                  DataColumn(label: Text('المستخدم')),
                                  DataColumn(label: Text('البريد')),
                                  DataColumn(label: Text('الدور')),
                                  DataColumn(label: Text('الحالة')),
                                  DataColumn(label: Text('تاريخ التسجيل')),
                                  DataColumn(label: Text('إجراءات')),
                                ],
                                rows: provider.users.map((user) {
                                  return _buildRow(context, user, provider);
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
            ),
          ),

          // ── Error ──
          if (provider.error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    provider.error!,
                    style: const TextStyle(color: AppColors.error, fontSize: 13),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16, color: AppColors.error),
                    onPressed: provider.clearError,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  DataRow _buildRow(
    BuildContext context,
    AdminUserModel user,
    UsersProvider provider,
  ) {
    return DataRow(
      cells: [
        // Name + Avatar
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: user.role == 'admin'
                    ? AppColors.primary
                    : AppColors.surfaceLighter,
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: user.role == 'admin'
                        ? Colors.white
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                user.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),

        // Email
        DataCell(Text(
          user.email,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        )),

        // Role badge
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: user.role == 'admin'
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : AppColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user.role == 'admin' ? 'مدير' : 'طالب',
              style: TextStyle(
                color:
                    user.role == 'admin' ? AppColors.primary : AppColors.accent,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        // Status
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: user.isDisabled
                  ? AppColors.error.withValues(alpha: 0.15)
                  : AppColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.circle,
                  size: 6,
                  color:
                      user.isDisabled ? AppColors.error : AppColors.success,
                ),
                const SizedBox(width: 6),
                Text(
                  user.isDisabled ? 'معطّل' : 'نشط',
                  style: TextStyle(
                    color: user.isDisabled
                        ? AppColors.error
                        : AppColors.success,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Date
        DataCell(Text(
          DateFormat('yyyy/MM/dd').format(user.createdAt),
          style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        )),

        // Actions
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Toggle role
              Tooltip(
                message: user.role == 'admin' ? 'تحويل إلى طالب' : 'ترقية لمدير',
                child: IconButton(
                  icon: Icon(
                    user.role == 'admin'
                        ? Icons.person_outline
                        : Icons.admin_panel_settings_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  onPressed: () {
                    _confirmAction(
                      context,
                      title: 'تغيير الدور',
                      message: user.role == 'admin'
                          ? 'هل تريد تحويل "${user.name}" إلى طالب؟'
                          : 'هل تريد ترقية "${user.name}" إلى مدير؟',
                      onConfirm: () {
                        provider.updateRole(
                          user.uid,
                          user.role == 'admin' ? 'student' : 'admin',
                        );
                      },
                    );
                  },
                ),
              ),
              // Toggle disable
              Tooltip(
                message: user.isDisabled ? 'تفعيل الحساب' : 'تعطيل الحساب',
                child: IconButton(
                  icon: Icon(
                    user.isDisabled
                        ? Icons.check_circle_outline
                        : Icons.block_outlined,
                    size: 18,
                    color:
                        user.isDisabled ? AppColors.success : AppColors.warning,
                  ),
                  onPressed: () {
                    _confirmAction(
                      context,
                      title: user.isDisabled ? 'تفعيل الحساب' : 'تعطيل الحساب',
                      message: user.isDisabled
                          ? 'هل تريد تفعيل حساب "${user.name}"؟'
                          : 'هل تريد تعطيل حساب "${user.name}"؟',
                      onConfirm: () => provider.toggleDisable(user.uid),
                    );
                  },
                ),
              ),
              // Delete
              Tooltip(
                message: 'حذف المستخدم',
                child: IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: AppColors.error,
                  ),
                  onPressed: () {
                    _confirmAction(
                      context,
                      title: 'حذف المستخدم',
                      message:
                          'هل أنت متأكد من حذف "${user.name}"؟\nهذا الإجراء لا يمكن التراجع عنه.',
                      isDestructive: true,
                      onConfirm: () => provider.deleteUser(user.uid),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmAction(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
    bool isDestructive = false,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDestructive ? AppColors.error : AppColors.primary,
            ),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }
}

// ─── Mini Stat Card ───

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
