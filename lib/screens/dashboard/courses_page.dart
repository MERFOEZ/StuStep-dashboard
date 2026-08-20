import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dashboard/core/theme/app_theme.dart';
import 'package:dashboard/core/l10n/app_localizations.dart';
import 'package:dashboard/core/models/course.dart';
import 'package:dashboard/core/services/firestore_service.dart';
import 'package:dashboard/core/widgets/glass_data_table.dart';
import 'package:dashboard/core/widgets/glass_dialog.dart';
import 'package:dashboard/core/widgets/empty_state_widget.dart';
import 'package:dashboard/core/widgets/shimmer_loading.dart';
import 'package:dashboard/core/widgets/animated_snackbar.dart';
import 'package:dashboard/screens/dashboard/multi_video_upload_dialog.dart';
import 'package:dashboard/screens/dashboard/video_management_panel.dart';

/// CRUD page for managing courses with integrated video management panel.
class CoursesPage extends StatefulWidget {
  final String? departmentId;
  final VoidCallback? onBack;

  const CoursesPage({super.key, this.departmentId, this.onBack});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  final _firestoreService = FirestoreService();
  Course? _selectedCourse; // For the video management panel

  void _showAddEditDialog({Course? course}) async {
    final s = S.of(context);
    final titleCtrl = TextEditingController(text: course?.title ?? '');
    final imageCtrl = TextEditingController(text: course?.coverImageUrl ?? '');
    bool isActive = course?.isActive ?? true;
    String selectedDeptId = course?.departmentId ?? widget.departmentId ?? '';
    bool isLoading = false;
    final formKey = GlobalKey<FormState>();

    if (!mounted) return;

    showGlassDialog(
      context: context,
      title: course == null ? s.addCourse : s.editCourse,
      content: StatefulBuilder(
        builder: (context, setDialogState) {
          return Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    labelText: s.courseTitle,
                    prefixIcon: Icon(
                      Icons.menu_book_rounded,
                      color: AppColors.primaryLight,
                      size: 20,
                    ),
                  ),
                  style: TextStyle(color: AppColors.textPrimary),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? s.requiredField : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: imageCtrl,
                  decoration: InputDecoration(
                    labelText: s.coverImageUrl,
                    prefixIcon: Icon(
                      Icons.image_rounded,
                      color: AppColors.primaryLight,
                      size: 20,
                    ),
                  ),
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 20),
                // Active toggle
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
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
                  if (course == null) {
                    await _firestoreService.addCourse(
                      Course(
                        id: '',
                        title: titleCtrl.text.trim(),
                        departmentId: selectedDeptId,
                        coverImageUrl: imageCtrl.text.trim(),
                        isActive: isActive,
                      ),
                    );
                    if (mounted) {
                      Navigator.of(context).pop();
                      showAnimatedSnackBar(context, message: s.courseAdded);
                    }
                  } else {
                    await _firestoreService.updateCourse(
                      Course(
                        id: course.id,
                        title: titleCtrl.text.trim(),
                        departmentId: selectedDeptId,
                        coverImageUrl: imageCtrl.text.trim(),
                        isActive: isActive,
                      ),
                    );
                    if (mounted) {
                      Navigator.of(context).pop();
                      showAnimatedSnackBar(context, message: s.courseUpdated);
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    showAnimatedSnackBar(
                      context,
                      message: e.toString(),
                      isError: true,
                    );
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

  void _handleDelete(Course course) async {
    final s = S.of(context);
    final confirmed = await showDeleteConfirmation(
      context: context,
      title: s.delete,
      message: s.confirmDelete,
      confirmLabel: s.delete,
      cancelLabel: s.cancel,
    );
    if (confirmed == true) {
      try {
        await _firestoreService.deleteCourse(course.id);
        if (_selectedCourse?.id == course.id) {
          setState(() => _selectedCourse = null);
        }
        if (mounted) {
          showAnimatedSnackBar(context, message: s.courseDeleted);
        }
      } catch (e) {
        if (mounted) {
          showAnimatedSnackBar(context, message: e.toString(), isError: true);
        }
      }
    }
  }

  void _openVideoPanel(Course course) {
    setState(() => _selectedCourse = course);
  }

  void _closeVideoPanel() {
    setState(() => _selectedCourse = null);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Stack(
      children: [
        // ── Main Content ──
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildHeader(s),
              const SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<List<Course>>(
                  stream: widget.departmentId != null
                      ? _firestoreService.coursesByDepartmentStream(
                          widget.departmentId!,
                        )
                      : _firestoreService.coursesStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Column(
                        children: List.generate(
                          5,
                          (_) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ShimmerTableRow(columns: 5),
                          ),
                        ),
                      );
                    }

                    final courses = snapshot.data ?? [];

                    if (courses.isEmpty) {
                      return EmptyStateWidget(
                        icon: Icons.menu_book_rounded,
                        title: s.noCourses,
                        subtitle: s.isArabic
                            ? 'ابدأ بإضافة أول دورة للنظام'
                            : 'Start by adding the first course',
                        actionLabel: s.addCourse,
                        onAction: () => _showAddEditDialog(),
                      );
                    }

                    // Update selected course data from stream
                    if (_selectedCourse != null) {
                      final updated = courses.where((c) => c.id == _selectedCourse!.id);
                      if (updated.isNotEmpty && updated.first.lectures.length != _selectedCourse!.lectures.length) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) setState(() => _selectedCourse = updated.first);
                        });
                      }
                    }

                    return SingleChildScrollView(
                      child: GlassDataTable(
                        columns: [
                          s.courseTitle,
                          s.coverImage,
                          s.isArabic ? 'الفيديوهات' : 'Videos',
                          s.isActive,
                          s.actions,
                        ],
                        rows: courses.map((c) {
                          final isSelected = _selectedCourse?.id == c.id;
                          return GlassTableRow(
                            id: c.id,
                            cells: [
                              Text(
                                c.title,
                                style: TextStyle(
                                  color: isSelected
                                      ? AppColors.primaryLight
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              // Cover image preview
                              c.coverImageUrl.isNotEmpty
                                  ? Tooltip(
                                      message: c.coverImageUrl,
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          color: AppColors.glassFill,
                                          image: DecorationImage(
                                            image: NetworkImage(c.coverImageUrl),
                                            fit: BoxFit.cover,
                                            onError: (e, st) {},
                                          ),
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      Icons.image_not_supported_rounded,
                                      color: AppColors.textMuted,
                                      size: 20,
                                    ),
                              // Video count badge
                              _VideoCountBadge(
                                count: c.lectures.length,
                                isSelected: isSelected,
                                onTap: () => _openVideoPanel(c),
                              ),
                              StatusBadge(
                                isActive: c.isActive,
                                activeLabel: s.active,
                                inactiveLabel: s.inactive,
                              ),
                              TableActionButtons(
                                editTooltip: s.edit,
                                deleteTooltip: s.delete,
                                addVideoTooltip: s.isArabic
                                    ? 'رفع فيديو'
                                    : 'Add Video',
                                onAddVideo: () => _showMultiUploadDialog(c),
                                onEdit: () => _showAddEditDialog(course: c),
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
        ),

        // ── Video Management Side Panel (overlay) ──
        if (_selectedCourse != null) ...[
          // Backdrop
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeVideoPanel,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ),
          ),
          // Panel
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            child: VideoManagementPanel(
              key: ValueKey(_selectedCourse!.id),
              course: _selectedCourse!,
              onClose: _closeVideoPanel,
            ),
          ),
        ],
      ],
    );
  }

  void _showMultiUploadDialog(Course level) {
    showGlassDialog(
      context: context,
      title: S.of(context).isArabic
          ? 'رفع فيديوهات متعددة'
          : 'Multi-Video Upload',
      content: MultiVideoUploadDialog(level: level),
      actions: [], // Actions are built inside the dialog itself
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
              colors: AppColors.gradientGreen,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          s.courses,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        _AddButton(
          label: s.addCourse,
          icon: Icons.add,
          onPressed: () => _showAddEditDialog(),
          gradient: AppColors.gradientGreen,
        ),
      ],
    ).animate().fade(duration: 400.ms).slideY(begin: 0.05);
  }
}

/// Clickable video count badge for opening the management panel.
class _VideoCountBadge extends StatefulWidget {
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _VideoCountBadge({
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_VideoCountBadge> createState() => _VideoCountBadgeState();
}

class _VideoCountBadgeState extends State<_VideoCountBadge> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isSelected
        ? AppColors.primary
        : widget.count > 0
            ? AppColors.secondary
            : AppColors.textMuted;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: color.withValues(alpha: _hovered ? 0.2 : 0.1),
            border: Border.all(
              color: color.withValues(alpha: _hovered ? 0.5 : 0.25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.play_circle_outline_rounded,
                size: 14,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.count}',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_hovered) ...[
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios_rounded, size: 10, color: color),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final List<Color> gradient;
  final IconData icon;

  const _AddButton({
    required this.label,
    required this.icon,
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
                color: widget.gradient.first.withValues(
                  alpha: _hovered ? 0.4 : 0.2,
                ),
                blurRadius: _hovered ? 20 : 12,
                spreadRadius: -4,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: Colors.white, size: 18),
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
