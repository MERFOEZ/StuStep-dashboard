import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dashboard/core/theme/app_theme.dart';
import 'package:dashboard/core/l10n/app_localizations.dart';
import 'package:dashboard/core/models/department.dart';
import 'package:dashboard/core/services/firestore_service.dart';
import 'package:dashboard/core/widgets/glass_data_table.dart';
import 'package:dashboard/core/widgets/glass_dialog.dart';
import 'package:dashboard/core/widgets/empty_state_widget.dart';
import 'package:dashboard/core/widgets/shimmer_loading.dart';
import 'package:dashboard/core/widgets/animated_snackbar.dart';

/// CRUD page for managing departments.
class DepartmentsPage extends StatefulWidget {
  final String? collegeId;
  final Function(String departmentId)? onNavigateToCourses;
  final VoidCallback? onBack;

  const DepartmentsPage({
    super.key,
    this.collegeId,
    this.onNavigateToCourses,
    this.onBack,
  });

  @override
  State<DepartmentsPage> createState() => _DepartmentsPageState();
}

class _DepartmentsPageState extends State<DepartmentsPage> {
  final _firestoreService = FirestoreService();

  void _showAddEditDialog({Department? department}) async {
    final s = S.of(context);
    final nameCtrl = TextEditingController(text: department?.name ?? '');
    bool isActive = department?.isActive ?? true;
    String selectedCollegeId = department?.collegeId ?? widget.collegeId ?? '';
    bool isLoading = false;
    final formKey = GlobalKey<FormState>();

    if (!mounted) return;

    showGlassDialog(
      context: context,
      title: department == null ? s.addDepartment : s.editDepartment,
      content: StatefulBuilder(
        builder: (context, setDialogState) {
          return Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Department name
                TextFormField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: s.departmentName,
                    prefixIcon: Icon(
                      Icons.business_rounded,
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
                  if (department == null) {
                    await _firestoreService.addDepartment(
                      Department(
                        id: '',
                        name: nameCtrl.text.trim(),
                        collegeId: selectedCollegeId,
                        isActive: isActive,
                      ),
                    );
                    if (mounted) {
                      Navigator.of(context).pop();
                      showAnimatedSnackBar(context,
                          message: s.departmentAdded);
                    }
                  } else {
                    await _firestoreService.updateDepartment(
                      Department(
                        id: department.id,
                        name: nameCtrl.text.trim(),
                        collegeId: selectedCollegeId,
                        isActive: isActive,
                      ),
                    );
                    if (mounted) {
                      Navigator.of(context).pop();
                      showAnimatedSnackBar(context,
                          message: s.departmentUpdated);
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

  void _handleDelete(Department dept) async {
    final s = S.of(context);
    final confirmed = await showCascadeDeleteConfirmation(
      context: context,
      title: s.delete,
      warningMessage: s.isArabic
          ? 'سيتم حذف هذا التخصص وجميع المقررات التابعة له نهائياً. لا يمكن التراجع.'
          : 'This department and all its courses will be permanently deleted. This action cannot be undone.',
      confirmLabel: s.delete,
      cancelLabel: s.cancel,
    );
    if (confirmed == true) {
      try {
        await _firestoreService.deleteDepartment(dept.id);
        if (mounted) {
          showAnimatedSnackBar(context, message: s.departmentDeleted);
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
          _buildHeader(s),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<List<Department>>(
              stream: widget.collegeId != null 
                  ? _firestoreService.departmentsByCollegeStream(widget.collegeId!)
                  : _firestoreService.departmentsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    children: List.generate(
                        5, (_) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: ShimmerTableRow(),
                            )),
                  );
                }

                final departments = snapshot.data ?? [];

                if (departments.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.business_rounded,
                    title: s.noDepartments,
                    subtitle: s.isArabic
                        ? 'ابدأ بإضافة أول قسم للنظام'
                        : 'Start by adding the first department',
                    actionLabel: s.addDepartment,
                    onAction: () => _showAddEditDialog(),
                  );
                }

                return SingleChildScrollView(
                  child: GlassDataTable(
                    columns: [
                      s.departmentName,
                      s.isActive,
                      s.actions,
                    ],
                    rows: departments.map((d) {
                      return GlassTableRow(
                        id: d.id,
                        cells: [
                          Text(
                            d.name,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          StatusBadge(
                            isActive: d.isActive,
                            activeLabel: s.active,
                            inactiveLabel: s.inactive,
                          ),
                          TableActionButtons(
                            editTooltip: s.edit,
                            deleteTooltip: s.delete,
                            viewTooltip: s.isArabic ? 'عرض المقررات' : 'View Courses',
                            onView: widget.onNavigateToCourses != null
                                ? () => widget.onNavigateToCourses!(d.id)
                                : null,
                            onEdit: () =>
                                _showAddEditDialog(department: d),
                            onDelete: () => _handleDelete(d),
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
        if (widget.onBack != null) ...[
          IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
            onPressed: widget.onBack,
            tooltip: s.isArabic ? 'رجوع' : 'Back',
          ),
          const SizedBox(width: 8),
        ],
        Container(
          width: 4,
          height: 28,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: const LinearGradient(
              colors: AppColors.gradientCyan,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          s.departments,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const Spacer(),
        _AddButton(
          label: s.addDepartment,
          onPressed: () => _showAddEditDialog(),
          gradient: AppColors.gradientCyan,
        ),
      ],
    ).animate().fade(duration: 400.ms).slideY(begin: 0.05);
  }
}


class _AddButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final List<Color> gradient;

  const _AddButton({
    required this.label,
    required this.onPressed,
    this.gradient = AppColors.gradientViolet,
  });

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
            gradient: LinearGradient(colors: widget.gradient),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.first.withValues(alpha: _hovered ? 0.4 : 0.2),
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
