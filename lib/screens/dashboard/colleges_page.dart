import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dashboard/core/theme/app_theme.dart';
import 'package:dashboard/core/l10n/app_localizations.dart';
import 'package:dashboard/core/models/college.dart';
import 'package:dashboard/core/services/firestore_service.dart';
import 'package:dashboard/core/widgets/glass_data_table.dart';
import 'package:dashboard/core/widgets/glass_dialog.dart';
import 'package:dashboard/core/widgets/empty_state_widget.dart';
import 'package:dashboard/core/widgets/shimmer_loading.dart';
import 'package:dashboard/core/widgets/animated_snackbar.dart';

/// CRUD page for managing colleges with glass table and dialogs.
class CollegesPage extends StatefulWidget {
  final Function(String collegeId)? onNavigateToDepartments;

  const CollegesPage({
    super.key,
    this.onNavigateToDepartments,
  });

  @override
  State<CollegesPage> createState() => _CollegesPageState();
}

class _CollegesPageState extends State<CollegesPage> {
  final _firestoreService = FirestoreService();

  void _showAddEditDialog({College? college}) {
    final s = S.of(context);
    final nameCtrl = TextEditingController(text: college?.name ?? '');
    bool isActive = college?.isActive ?? true;
    bool isLoading = false;
    final formKey = GlobalKey<FormState>();

    showGlassDialog(
      context: context,
      title: college == null ? s.addCollege : s.editCollege,
      content: StatefulBuilder(
        builder: (context, setDialogState) {
          return Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: s.collegeName,
                    prefixIcon: Icon(
                      Icons.account_balance_rounded,
                      color: AppColors.primaryLight,
                      size: 20,
                    ),
                  ),
                  style: TextStyle(color: AppColors.textPrimary),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? s.requiredField : null,
                ),
                const SizedBox(height: 20),
                // Active toggle
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.glassFillDark,
                    border: Border.all(
                      color: AppColors.glassBorder.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isActive
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            color: isActive
                                ? AppColors.success
                                : AppColors.textMuted,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            s.isActive,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: isActive,
                        onChanged: (v) => setDialogState(() => isActive = v),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      actions: [
        GlassDialogButton(
          label: s.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        StatefulBuilder(
          builder: (context, setButtonState) {
            return GlassDialogButton(
              label: s.save,
              isPrimary: true,
              isLoading: isLoading,
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                setButtonState(() => isLoading = true);
                try {
                  if (college == null) {
                    await _firestoreService.addCollege(
                      College(
                        id: '',
                        name: nameCtrl.text.trim(),
                        isActive: isActive,
                      ),
                    );
                    if (mounted) {
                      Navigator.of(context).pop();
                      showAnimatedSnackBar(context, message: s.collegeAdded);
                    }
                  } else {
                    await _firestoreService.updateCollege(
                      College(
                        id: college.id,
                        name: nameCtrl.text.trim(),
                        isActive: isActive,
                      ),
                    );
                    if (mounted) {
                      Navigator.of(context).pop();
                      showAnimatedSnackBar(context, message: s.collegeUpdated);
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    showAnimatedSnackBar(context,
                        message: e.toString(), isError: true);
                  }
                } finally {
                  if (mounted) setButtonState(() => isLoading = false);
                }
              },
            );
          },
        ),
      ],
    );
  }

  void _handleDelete(College college) async {
    final s = S.of(context);
    final confirmed = await showCascadeDeleteConfirmation(
      context: context,
      title: s.delete,
      warningMessage: s.isArabic
          ? 'سيتم حذف الكلية وجميع التخصصات والمقررات التابعة لها نهائياً. لا يمكن التراجع عن هذا الإجراء.'
          : 'This college and all its associated departments and courses will be permanently deleted. This action cannot be undone.',
      confirmLabel: s.delete,
      cancelLabel: s.cancel,
    );
    if (confirmed == true) {
      try {
        await _firestoreService.deleteCollege(college.id);
        if (mounted) {
          showAnimatedSnackBar(context, message: s.collegeDeleted);
        }
      } catch (e) {
        if (mounted) {
          showAnimatedSnackBar(context,
              message: e.toString(), isError: true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Header
          _buildHeader(s),
          const SizedBox(height: 20),
          // Table
          Expanded(
            child: StreamBuilder<List<College>>(
              stream: _firestoreService.collegesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    children: List.generate(5, (_) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ShimmerTableRow(),
                      );
                    }),
                  );
                }

                final colleges = snapshot.data ?? [];

                if (colleges.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.account_balance_rounded,
                    title: s.noColleges,
                    subtitle: s.isArabic
                        ? 'ابدأ بإضافة أول كلية للنظام'
                        : 'Start by adding the first college',
                    actionLabel: s.addCollege,
                    onAction: () => _showAddEditDialog(),
                  );
                }

                return SingleChildScrollView(
                  child: GlassDataTable(
                    columns: [
                      s.collegeName,
                      s.isActive,
                      s.actions,
                    ],
                    rows: colleges.map((c) {
                      return GlassTableRow(
                        id: c.id,
                        cells: [
                          Text(
                            c.name,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          StatusBadge(
                            isActive: c.isActive,
                            activeLabel: s.active,
                            inactiveLabel: s.inactive,
                          ),
                          TableActionButtons(
                            editTooltip: s.edit,
                            deleteTooltip: s.delete,
                            viewTooltip: s.isArabic ? 'عرض التخصصات' : 'View Departments',
                            onView: widget.onNavigateToDepartments != null
                                ? () => widget.onNavigateToDepartments!(c.id)
                                : null,
                            onEdit: () => _showAddEditDialog(college: c),
                            onDelete: () => _handleDelete(c),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(S s) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 28,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: const LinearGradient(
              colors: AppColors.gradientViolet,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          s.colleges,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const Spacer(),
        _AddButton(
          label: s.addCollege,
          onPressed: () => _showAddEditDialog(),
        ),
      ],
    ).animate().fade(duration: 400.ms).slideY(begin: 0.05);
  }
}

// ─── Add Button ───────────────────────────────────────────────────────────────

class _AddButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const _AddButton({required this.label, required this.onPressed});

  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: _hovered
                  ? [AppColors.primaryLight, AppColors.secondary]
                  : [AppColors.primary, AppColors.blob2],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: _hovered ? 0.4 : 0.2),
                blurRadius: _hovered ? 20 : 12,
                spreadRadius: -4,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
