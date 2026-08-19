import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/courses_provider.dart';
import '../../models/course_model.dart';
import '../../models/lesson_model.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/category_dropdown.dart';

/// Two-column editor: Meta (left) + Lessons (right).
class CourseEditorScreen extends StatefulWidget {
  final CourseModel? course;

  const CourseEditorScreen({super.key, this.course});

  @override
  State<CourseEditorScreen> createState() => _CourseEditorScreenState();
}

class _CourseEditorScreenState extends State<CourseEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleC;
  late TextEditingController _titleEnC;
  late TextEditingController _instructorC;
  late TextEditingController _descriptionC;
  String _categoryId = '';
  String _gradientStart = '#6C5CE7';
  String _gradientEnd = '#00CEFF';
  bool _isPublished = false;
  List<LessonModel> _lessons = [];
  bool _isSaving = false;

  bool get isEdit => widget.course != null;

  @override
  void initState() {
    super.initState();
    final c = widget.course;
    _titleC = TextEditingController(text: c?.title ?? '');
    _titleEnC = TextEditingController(text: c?.titleEn ?? '');
    _instructorC = TextEditingController(text: c?.instructor ?? '');
    _descriptionC = TextEditingController(text: c?.description ?? '');
    _categoryId = c?.categoryId ?? '';
    _gradientStart = c?.gradientStart ?? '#6C5CE7';
    _gradientEnd = c?.gradientEnd ?? '#00CEFF';
    _isPublished = c?.isPublished ?? false;
    _lessons = c?.lessons.map((l) => l.copyWith()).toList() ?? [];
  }

  @override
  void dispose() {
    _titleC.dispose();
    _titleEnC.dispose();
    _instructorC.dispose();
    _descriptionC.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار فئة')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final provider = context.read<CoursesProvider>();
    final totalDuration =
        _lessons.fold<int>(0, (sum, l) => sum + l.durationMinutes);

    final course = CourseModel(
      id: widget.course?.id ?? '',
      title: _titleC.text.trim(),
      titleEn: _titleEnC.text.trim(),
      instructor: _instructorC.text.trim(),
      categoryId: _categoryId,
      description: _descriptionC.text.trim(),
      gradientStart: _gradientStart,
      gradientEnd: _gradientEnd,
      durationMinutes: totalDuration,
      lessons: _lessons,
      isPublished: _isPublished,
    );

    if (isEdit) {
      await provider.updateCourse(course);
    } else {
      await provider.createCourse(course);
    }

    setState(() => _isSaving = false);
    if (mounted) Navigator.pop(context);
  }

  void _addLesson() {
    setState(() {
      _lessons.add(LessonModel(
        title: 'درس ${_lessons.length + 1}',
        sortOrder: _lessons.length,
      ));
    });
  }

  void _removeLesson(int index) {
    setState(() => _lessons.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(isEdit ? 'تعديل الكورس' : 'إنشاء كورس جديد'),
        actions: [
          // Publish toggle
          Row(
            children: [
              Text(
                _isPublished ? 'منشور' : 'مسودة',
                style: TextStyle(
                  color: _isPublished ? AppColors.success : AppColors.warning,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Switch(
                value: _isPublished,
                activeThumbColor: AppColors.success,
                onChanged: (v) => setState(() => _isPublished = v),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Save
          _isSaving
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                )
              : ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save, size: 18),
                  label: const Text('حفظ'),
                ),
          const SizedBox(width: 16),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Left Column: Meta ──
            Expanded(
              flex: 4,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle('معلومات الكورس'),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleC,
                      decoration:
                          const InputDecoration(labelText: 'عنوان الكورس (عربي)'),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'مطلوب' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleEnC,
                      decoration:
                          const InputDecoration(labelText: 'عنوان الكورس (إنجليزي)'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _instructorC,
                      decoration:
                          const InputDecoration(labelText: 'اسم المدرّس'),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'مطلوب' : null,
                    ),
                    const SizedBox(height: 16),

                    // ── Category Dropdown ──
                    CategoryDropdown(
                      selectedCategoryId: _categoryId,
                      onChanged: (id) => setState(() => _categoryId = id),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _descriptionC,
                      decoration:
                          const InputDecoration(labelText: 'وصف الكورس'),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),

                    // ── Colors ──
                    const _SectionTitle('ألوان التدرج'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _ColorPicker(
                          label: 'لون البداية',
                          value: _gradientStart,
                          onChanged: (v) =>
                              setState(() => _gradientStart = v),
                        ),
                        const SizedBox(width: 24),
                        _ColorPicker(
                          label: 'لون النهاية',
                          value: _gradientEnd,
                          onChanged: (v) =>
                              setState(() => _gradientEnd = v),
                        ),
                        const SizedBox(width: 24),
                        // Preview
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _hexToColor(_gradientStart),
                                  _hexToColor(_gradientEnd),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'معاينة التدرج',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Divider ──
            Container(
              width: 1,
              color: AppColors.border,
            ),

            // ── Right Column: Lessons ──
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 16),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.border),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.list_rounded,
                            color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'الدروس (${_lessons.length})',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: _addLesson,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('إضافة درس'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Lessons list
                  Expanded(
                    child: _lessons.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.video_library_outlined,
                                    size: 48,
                                    color: AppColors.textMuted
                                        .withValues(alpha: 0.5)),
                                const SizedBox(height: 12),
                                const Text(
                                  'لا توجد دروس بعد',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ReorderableListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _lessons.length,
                            onReorder: (oldIndex, newIndex) {
                              setState(() {
                                if (newIndex > oldIndex) newIndex--;
                                final item = _lessons.removeAt(oldIndex);
                                _lessons.insert(newIndex, item);
                                // Update sort orders
                                for (var i = 0; i < _lessons.length; i++) {
                                  _lessons[i] =
                                      _lessons[i].copyWith(sortOrder: i);
                                }
                              });
                            },
                            itemBuilder: (context, index) {
                              final lesson = _lessons[index];
                              return _LessonCard(
                                key: ValueKey(lesson.id),
                                index: index,
                                lesson: lesson,
                                onUpdate: (updated) {
                                  setState(() => _lessons[index] = updated);
                                },
                                onDelete: () => _removeLesson(index),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}

// ─── Section Title ───

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }
}

// ─── Color Picker ───

class _ColorPicker extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  const _ColorPicker({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  static const _colors = [
    '#6C5CE7', '#00CEFF', '#00C853', '#FF5252', '#FFB300',
    '#FF6D00', '#AA00FF', '#2962FF', '#00BFA5', '#F50057',
    '#1E3A8A', '#E91E63', '#4CAF50', '#FF9800',
  ];

  Color _hex(String h) {
    h = h.replaceFirst('#', '');
    if (h.length == 6) h = 'FF$h';
    return Color(int.parse(h, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 8),
        PopupMenuButton<String>(
          onSelected: onChanged,
          itemBuilder: (_) => [
            PopupMenuItem(
              enabled: false,
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _colors.map((hex) {
                  return InkWell(
                    onTap: () {
                      onChanged(hex);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: _hex(hex),
                        shape: BoxShape.circle,
                        border: value == hex
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _hex(value),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Lesson Card ───

class _LessonCard extends StatelessWidget {
  final int index;
  final LessonModel lesson;
  final ValueChanged<LessonModel> onUpdate;
  final VoidCallback onDelete;

  const _LessonCard({
    super.key,
    required this.index,
    required this.lesson,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Drag handle
              const Icon(Icons.drag_handle,
                  size: 20, color: AppColors.textMuted),
              const SizedBox(width: 8),
              // Number
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Title
              Expanded(
                child: TextFormField(
                  initialValue: lesson.title,
                  decoration:
                      const InputDecoration(labelText: 'عنوان الدرس'),
                  onChanged: (v) =>
                      onUpdate(lesson.copyWith(title: v.trim())),
                ),
              ),
              const SizedBox(width: 12),
              // Duration
              SizedBox(
                width: 100,
                child: TextFormField(
                  initialValue: lesson.durationMinutes > 0
                      ? '${lesson.durationMinutes}'
                      : '',
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'المدة (دقيقة)'),
                  onChanged: (v) => onUpdate(lesson.copyWith(
                    durationMinutes: int.tryParse(v) ?? 0,
                  )),
                ),
              ),
              const SizedBox(width: 8),
              // Delete
              IconButton(
                tooltip: 'حذف الدرس',
                icon: const Icon(Icons.close,
                    size: 18, color: AppColors.error),
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Video URL
          Row(
            children: [
              Icon(
                lesson.videoUrl != null && lesson.videoUrl!.isNotEmpty
                    ? Icons.check_circle
                    : Icons.videocam_outlined,
                size: 18,
                color: lesson.videoUrl != null && lesson.videoUrl!.isNotEmpty
                    ? AppColors.success
                    : AppColors.textMuted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: lesson.videoUrl ?? '',
                  decoration: const InputDecoration(
                    labelText: 'رابط الفيديو (Archive.org)',
                    hintText: 'https://archive.org/download/...',
                    hintStyle: TextStyle(fontSize: 12),
                  ),
                  style: const TextStyle(fontSize: 13),
                  onChanged: (v) =>
                      onUpdate(lesson.copyWith(videoUrl: v.trim())),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
