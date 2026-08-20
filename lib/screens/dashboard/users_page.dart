import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dashboard/core/providers/users_provider.dart';
import 'package:dashboard/core/models/admin_user_model.dart';
import 'package:dashboard/core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
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
                  icon: Icons.people),
              const SizedBox(width: 16),
              _MiniStat(
                  label: 'طلاب',
                  value: '${provider.studentCount}',
                  color: AppColors.secondary,
                  icon: Icons.school),
              const SizedBox(width: 16),
              _MiniStat(
                  label: 'مدراء',
                  value: '${provider.adminCount}',
                  color: AppColors.success,
                  icon: Icons.admin_panel_settings),
              const SizedBox(width: 16),
              _MiniStat(
                  label: 'معطّل',
                  value: '${provider.disabledCount}',
                  color: AppColors.error,
                  icon: Icons.block),
              const Spacer(),
              SizedBox(
                width: 280,
                height: 42,
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'بحث بالاسم أو البريد...',
                    hintStyle: const TextStyle(fontSize: 13),
                    prefixIcon: const Icon(Icons.search,
                        size: 20, color: AppColors.textHint),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: AppColors.border)),
                  ),
                  onChanged: (v) => provider.search(v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Glassmorphic Table ──
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.border.withOpacity(0.3)),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: provider.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary))
                      : provider.users.isEmpty
                          ? Center(
                              child: Text('لا يوجد مستخدمين',
                                  style: TextStyle(
                                      color: AppColors.textHint)))
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: SingleChildScrollView(
                                child: SizedBox(
                                  width: double.infinity,
                                  child: DataTable(
                                    columnSpacing: 24,
                                    horizontalMargin: 24,
                                    headingRowHeight: 52,
                                    dataRowMinHeight: 56,
                                    dataRowMaxHeight: 56,
                                    headingRowColor:
                                        WidgetStateProperty.all(
                                            Colors.white
                                                .withOpacity(0.7)),
                                    columns: const [
                                      DataColumn(
                                          label: Text('المستخدم',
                                              style: TextStyle(
                                                  color: AppColors
                                                      .textPrimary,
                                                  fontWeight: FontWeight
                                                      .w700))),
                                      DataColumn(
                                          label: Text('البريد',
                                              style: TextStyle(
                                                  color: AppColors
                                                      .textPrimary,
                                                  fontWeight: FontWeight
                                                      .w700))),
                                      DataColumn(
                                          label: Text('الدور',
                                              style: TextStyle(
                                                  color: AppColors
                                                      .textPrimary,
                                                  fontWeight: FontWeight
                                                      .w700))),
                                      DataColumn(
                                          label: Text('الحالة',
                                              style: TextStyle(
                                                  color: AppColors
                                                      .textPrimary,
                                                  fontWeight: FontWeight
                                                      .w700))),
                                      DataColumn(
                                          label: Text('تاريخ التسجيل',
                                              style: TextStyle(
                                                  color: AppColors
                                                      .textPrimary,
                                                  fontWeight: FontWeight
                                                      .w700))),
                                      DataColumn(
                                          label: Text('إجراءات',
                                              style: TextStyle(
                                                  color: AppColors
                                                      .textPrimary,
                                                  fontWeight: FontWeight
                                                      .w700))),
                                    ],
                                    rows: provider.users
                                        .map((user) => _buildRow(
                                            context, user, provider))
                                        .toList(),
                                  ),
                                ),
                              ),
                            ),
                ),
              ),
            ),
          ),

          if (provider.error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.error, size: 18),
                  const SizedBox(width: 8),
                  Text(provider.error!,
                      style: const TextStyle(
                          color: AppColors.error, fontSize: 13)),
                  const Spacer(),
                  IconButton(
                      icon: const Icon(Icons.close,
                          size: 16, color: AppColors.error),
                      onPressed: provider.clearError),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  DataRow _buildRow(BuildContext context, AdminUserModel user,
      UsersProvider provider) {
    return DataRow(cells: [
      DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
        CircleAvatar(
            radius: 16,
            backgroundColor: user.role == 'admin'
                ? AppColors.primary.withOpacity(0.15)
                : AppColors.surfaceTinted,
            child: Text(
                user.name.isNotEmpty
                    ? user.name[0].toUpperCase()
                    : '?',
                style: TextStyle(
                    color: user.role == 'admin'
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13))),
        const SizedBox(width: 10),
        Text(user.name,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
      ])),
      DataCell(Text(user.email,
          style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 13))),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: (user.role == 'admin'
                    ? AppColors.primary
                    : AppColors.secondary)
                .withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20)),
        child: Text(
            user.role == 'admin' ? 'مدير' : 'طالب',
            style: TextStyle(
                color: user.role == 'admin'
                    ? AppColors.primary
                    : AppColors.secondary,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      )),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: (user.isDisabled
                    ? AppColors.error
                    : AppColors.success)
                .withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.circle,
              size: 6,
              color: user.isDisabled
                  ? AppColors.error
                  : AppColors.success),
          const SizedBox(width: 6),
          Text(user.isDisabled ? 'معطّل' : 'نشط',
              style: TextStyle(
                  color: user.isDisabled
                      ? AppColors.error
                      : AppColors.success,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ]),
      )),
      DataCell(Text(
          DateFormat('yyyy/MM/dd').format(user.createdAt),
          style: const TextStyle(
              color: AppColors.textHint, fontSize: 13))),
      DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
        Tooltip(
            message: user.role == 'admin'
                ? 'تحويل إلى طالب'
                : 'ترقية لمدير',
            child: IconButton(
                icon: Icon(
                    user.role == 'admin'
                        ? Icons.person_outline
                        : Icons.admin_panel_settings_outlined,
                    size: 18,
                    color: AppColors.primary),
                onPressed: () => _confirmAction(context,
                    title: 'تغيير الدور',
                    message: user.role == 'admin'
                        ? 'هل تريد تحويل "${user.name}" إلى طالب؟'
                        : 'هل تريد ترقية "${user.name}" إلى مدير؟',
                    onConfirm: () => provider.updateRole(
                        user.uid,
                        user.role == 'admin'
                            ? 'student'
                            : 'admin')))),
        Tooltip(
            message:
                user.isDisabled ? 'تفعيل الحساب' : 'تعطيل الحساب',
            child: IconButton(
                icon: Icon(
                    user.isDisabled
                        ? Icons.check_circle_outline
                        : Icons.block_outlined,
                    size: 18,
                    color: user.isDisabled
                        ? AppColors.success
                        : AppColors.warning),
                onPressed: () => _confirmAction(context,
                    title: user.isDisabled
                        ? 'تفعيل الحساب'
                        : 'تعطيل الحساب',
                    message: user.isDisabled
                        ? 'هل تريد تفعيل حساب "${user.name}"؟'
                        : 'هل تريد تعطيل حساب "${user.name}"؟',
                    onConfirm: () =>
                        provider.toggleDisable(user.uid)))),
        Tooltip(
            message: 'حذف المستخدم',
            child: IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: 18, color: AppColors.error),
                onPressed: () => _confirmAction(context,
                    title: 'حذف المستخدم',
                    message:
                        'هل أنت متأكد من حذف "${user.name}"?\nهذا الإجراء لا يمكن التراجع عنه.',
                    isDestructive: true,
                    onConfirm: () =>
                        provider.deleteUser(user.uid)))),
      ])),
    ]);
  }

  void _confirmAction(BuildContext context,
      {required String title,
      required String message,
      required VoidCallback onConfirm,
      bool isDestructive = false}) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('إلغاء')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: isDestructive
                            ? AppColors.error
                            : AppColors.primary),
                    child: const Text('تأكيد')),
              ],
            ));
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _MiniStat(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: color.withValues(alpha: 0.15))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(value,
            style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                color: color.withValues(alpha: 0.7),
                fontSize: 12)),
      ]),
    );
  }
}
