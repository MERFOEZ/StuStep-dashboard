import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dashboard/core/theme/app_theme.dart';
import 'package:dashboard/core/l10n/app_localizations.dart';
import 'package:dashboard/core/models/course.dart';
import 'package:dashboard/core/services/firestore_service.dart';
import 'package:dashboard/core/widgets/glass_dialog.dart';
import 'package:dashboard/core/widgets/empty_state_widget.dart';
import 'package:dashboard/core/widgets/animated_snackbar.dart';
import 'package:dashboard/screens/dashboard/multi_video_upload_dialog.dart';
import 'package:dashboard/screens/dashboard/video_management_panel.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Courses Page — Premium Card-Based CRUD Interface
/// ─────────────────────────────────────────────────────────────────────────────
/// Destroys the default DataTable. Builds a custom, spacious list view where
/// each course is a beautifully padded white card containing vibrant accents,
/// metadata pills, and animated action buttons.
class CoursesPage extends StatefulWidget {
  final String? departmentId;
  final VoidCallback? onBack;

  const CoursesPage({super.key, this.departmentId, this.onBack});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  final _firestoreService = FirestoreService();
  Course? _selectedCourse;

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
                    prefixIcon: Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 20),
                  ),
                  style: const TextStyle(color: AppColors.textPrimary),
                  validator: (v) => v == null || v.trim().isEmpty ? s.requiredField : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: imageCtrl,
                  decoration: InputDecoration(
                    labelText: s.coverImageUrl,
                    prefixIcon: Icon(Icons.image_rounded, color: AppColors.primary, size: 20),
                  ),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: AppColors.surfaceTinted,
                    border: Border.all(color: AppColors.border.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isActive ? Icons.check_circle_rounded : Icons.cancel_rounded,
                            color: isActive ? AppColors.success : AppColors.textMuted,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(s.isActive, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
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
        GlassDialogButton(label: s.cancel, onPressed: () => Navigator.of(context).pop()),
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
                  final newCourse = Course(
                    id: course?.id ?? '',
                    title: titleCtrl.text.trim(),
                    departmentId: selectedDeptId,
                    coverImageUrl: imageCtrl.text.trim(),
                    isActive: isActive,
                  );
                  if (course == null) {
                    await _firestoreService.addCourse(newCourse);
                    if (mounted) {
                      Navigator.of(context).pop();
                      showAnimatedSnackBar(context, message: s.courseAdded);
                    }
                  } else {
                    await _firestoreService.updateCourse(newCourse);
                    if (mounted) {
                      Navigator.of(context).pop();
                      showAnimatedSnackBar(context, message: s.courseUpdated);
                    }
                  }
                } catch (e) {
                  if (mounted) showAnimatedSnackBar(context, message: e.toString(), isError: true);
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
        if (_selectedCourse?.id == course.id) setState(() => _selectedCourse = null);
        if (mounted) showAnimatedSnackBar(context, message: s.courseDeleted);
      } catch (e) {
        if (mounted) showAnimatedSnackBar(context, message: e.toString(), isError: true);
      }
    }
  }

  void _openVideoPanel(Course course) => setState(() => _selectedCourse = course);
  void _closeVideoPanel() => setState(() => _selectedCourse = null);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildHeader(s),
              const SizedBox(height: 24),
              Expanded(
                child: StreamBuilder<List<Course>>(
                  stream: widget.departmentId != null
                      ? _firestoreService.coursesByDepartmentStream(widget.departmentId!)
                      : _firestoreService.coursesStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return _buildShimmerState();

                    final courses = snapshot.data ?? [];
                    if (courses.isEmpty) {
                      return EmptyStateWidget(
                        icon: Icons.menu_book_rounded,
                        title: s.noCourses,
                        subtitle: s.isArabic ? 'ابدأ بإضافة أول دورة للنظام' : 'Start by adding the first course',
                        actionLabel: s.addCourse,
                        onAction: () => _showAddEditDialog(),
                      );
                    }

                    if (_selectedCourse != null) {
                      final updated = courses.where((c) => c.id == _selectedCourse!.id);
                      if (updated.isNotEmpty && updated.first.lectures.length != _selectedCourse!.lectures.length) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) setState(() => _selectedCourse = updated.first);
                        });
                      }
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: courses.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final c = courses[index];
                        final isSelected = _selectedCourse?.id == c.id;
                        return _CourseCard(
                          course: c,
                          isSelected: isSelected,
                          onVideoTap: () => _openVideoPanel(c),
                          onEdit: () => _showAddEditDialog(course: c),
                          onDelete: () => _handleDelete(c),
                          onAddVideo: () => _showMultiUploadDialog(c),
                        ).animate().fade(duration: 400.ms, delay: Duration(milliseconds: 50 * index))
                            .slideY(begin: 0.1, duration: 400.ms, delay: Duration(milliseconds: 50 * index), curve: Curves.easeOutCubic);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        if (_selectedCourse != null) ...[
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeVideoPanel,
              child: Container(color: Colors.black.withOpacity(0.12)),
            ),
          ).animate().fade(duration: 300.ms, curve: Curves.easeOut),
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            child: VideoManagementPanel(
              key: ValueKey(_selectedCourse!.id),
              course: _selectedCourse!,
              onClose: _closeVideoPanel,
            ),
          ).animate().slideX(begin: 0.3, duration: 400.ms, curve: Curves.easeOutCubic).fade(duration: 300.ms),
        ],
      ],
    );
  }

  void _showMultiUploadDialog(Course level) {
    showGlassDialog(
      context: context,
      title: S.of(context).isArabic ? 'رفع فيديوهات متعددة' : 'Multi-Video Upload',
      content: MultiVideoUploadDialog(level: level),
      actions: [],
    );
  }

  Widget _buildShimmerState() {
    return ListView.separated(
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) => Container(
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.surfaceTinted,
          borderRadius: BorderRadius.circular(20),
        ),
      ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1500.ms, color: Colors.white.withOpacity(0.5)),
    );
  }

  Widget _buildHeader(S s) {
    return Row(
      children: [
        if (widget.onBack != null) ...[
          _BackButton(onTap: widget.onBack!),
          const SizedBox(width: 12),
        ],
        Container(
          width: 4,
          height: 28,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: const LinearGradient(
              colors: AppColors.gradientPrimary,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, spreadRadius: -2)],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          s.courses,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(width: 12),
        StreamBuilder<List<Course>>(
          stream: widget.departmentId != null
              ? _firestoreService.coursesByDepartmentStream(widget.departmentId!)
              : _firestoreService.coursesStream(),
          builder: (context, snapshot) {
            final count = snapshot.data?.length ?? 0;
            if (count == 0) return const SizedBox.shrink();
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [AppColors.primary.withOpacity(0.08), AppColors.secondary.withOpacity(0.06)],
                ),
                border: Border.all(color: AppColors.primary.withOpacity(0.12)),
              ),
              child: Text(
                '$count',
                style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ).animate().scale(begin: const Offset(0.8, 0.8), duration: 400.ms, curve: Curves.easeOutBack);
          },
        ),
        const Spacer(),
        _GradientAddButton(
          label: s.addCourse,
          icon: Icons.add_rounded,
          onPressed: () => _showAddEditDialog(),
          gradient: AppColors.gradientPrimary,
        ),
      ],
    ).animate().fade(duration: 450.ms).slideY(begin: 0.05, curve: Curves.easeOutCubic);
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// Course Card — The beautifully padded white card for each item
/// ─────────────────────────────────────────────────────────────────────────────
class _CourseCard extends StatefulWidget {
  final Course course;
  final bool isSelected;
  final VoidCallback onVideoTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddVideo;

  const _CourseCard({
    required this.course,
    required this.isSelected,
    required this.onVideoTap,
    required this.onEdit,
    required this.onDelete,
    required this.onAddVideo,
  });

  @override
  State<_CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<_CourseCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..scale(_hovered ? 1.02 : 1.0),
        transformAlignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: widget.isSelected
                ? AppColors.primary.withOpacity(0.3)
                : AppColors.border.withOpacity(_hovered ? 0.3 : 0.15),
            width: widget.isSelected ? 1.5 : 1.0,
          ),
          boxShadow: widget.isSelected
              ? [BoxShadow(color: AppColors.primary.withOpacity(0.15), blurRadius: 32, spreadRadius: -4)]
              : _hovered
                  ? AppColors.elevatedShadow
                  : AppColors.softShadow,
        ),
        child: Row(
          children: [
            // Cover Image
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppColors.surfaceTinted,
                image: widget.course.coverImageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(widget.course.coverImageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
                border: Border.all(color: AppColors.border.withOpacity(0.2)),
              ),
              child: widget.course.coverImageUrl.isEmpty
                  ? Icon(Icons.image_not_supported_rounded, color: AppColors.textMuted, size: 28)
                  : null,
            ),
            const SizedBox(width: 20),
            // Title & Status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.isSelected)
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(colors: AppColors.gradientPrimary).createShader(bounds),
                      child: Text(
                        widget.course.title,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    )
                  else
                    Text(
                      widget.course.title,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _StatusPill(
                        isActive: widget.course.isActive,
                        label: widget.course.isActive ? s.active : s.inactive,
                      ),
                      const SizedBox(width: 8),
                      // Video Pill
                      _VideoCountPill(
                        count: widget.course.lectures.length,
                        isSelected: widget.isSelected,
                        onTap: widget.onVideoTap,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Actions
            _AnimatedActionIconButton(
              icon: Icons.video_call_rounded,
              tooltip: s.isArabic ? 'رفع فيديو' : 'Add Video',
              color: AppColors.primary,
              onPressed: widget.onAddVideo,
            ),
            const SizedBox(width: 8),
            _AnimatedActionIconButton(
              icon: Icons.edit_rounded,
              tooltip: s.edit,
              color: AppColors.info,
              onPressed: widget.onEdit,
            ),
            const SizedBox(width: 8),
            _AnimatedActionIconButton(
              icon: Icons.delete_outline_rounded,
              tooltip: s.delete,
              color: AppColors.error,
              onPressed: widget.onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool isActive;
  final String label;

  const _StatusPill({required this.isActive, required this.label});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.success : AppColors.textHint;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.08),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: isActive ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6)] : null,
            ),
          ),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _VideoCountPill extends StatefulWidget {
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _VideoCountPill({required this.count, required this.isSelected, required this.onTap});

  @override
  State<_VideoCountPill> createState() => _VideoCountPillState();
}

class _VideoCountPillState extends State<_VideoCountPill> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.isSelected ? AppColors.primary : (widget.count > 0 ? AppColors.info : AppColors.textMuted);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: _hovered ? baseColor.withOpacity(0.12) : baseColor.withOpacity(0.06),
            border: Border.all(color: baseColor.withOpacity(_hovered ? 0.3 : 0.15)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.play_circle_outline_rounded, size: 14, color: baseColor),
              const SizedBox(width: 6),
              Text('${widget.count} Videos', style: TextStyle(color: baseColor, fontSize: 11, fontWeight: FontWeight.w600)),
              if (_hovered) ...[
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios_rounded, size: 8, color: baseColor),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedActionIconButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onPressed;

  const _AnimatedActionIconButton({required this.icon, required this.tooltip, required this.color, required this.onPressed});

  @override
  State<_AnimatedActionIconButton> createState() => _AnimatedActionIconButtonState();
}

class _AnimatedActionIconButtonState extends State<_AnimatedActionIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            transform: Matrix4.identity()..scale(_hovered ? 1.1 : 1.0),
            transformAlignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: _hovered ? widget.color.withOpacity(0.1) : AppColors.surfaceTinted,
              border: Border.all(color: _hovered ? widget.color.withOpacity(0.2) : AppColors.border.withOpacity(0.4)),
            ),
            child: Icon(widget.icon, color: _hovered ? widget.color : AppColors.textSecondary, size: 20),
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatefulWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});
  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 40,
          height: 40,
          transform: Matrix4.identity()..scale(_hovered ? 1.06 : 1.0),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: _hovered ? AppColors.primary.withOpacity(0.06) : AppColors.surfaceTinted,
            border: Border.all(color: _hovered ? AppColors.primary.withOpacity(0.15) : AppColors.border.withOpacity(0.4)),
          ),
          child: Icon(Icons.arrow_back_rounded, color: _hovered ? AppColors.primary : AppColors.textSecondary, size: 20),
        ),
      ),
    );
  }
}

class _GradientAddButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final List<Color> gradient;
  final IconData icon;

  const _GradientAddButton({required this.label, required this.icon, required this.onPressed, this.gradient = AppColors.gradientPrimary});

  @override
  State<_GradientAddButton> createState() => _GradientAddButtonState();
}

class _GradientAddButtonState extends State<_GradientAddButton> {
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
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          transform: Matrix4.identity()..scale(_hovered ? 1.03 : 1.0),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(colors: _hovered ? widget.gradient.map((c) => Color.lerp(c, Colors.white, 0.1) ?? c).toList() : widget.gradient),
            boxShadow: AppColors.gradientGlow(widget.gradient.first, hovered: _hovered),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(widget.label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.2)),
            ],
          ),
        ),
      ),
    );
  }
}
