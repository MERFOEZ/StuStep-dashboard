import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/course_model.dart';
import '../../models/chapter_model.dart';
import '../../models/lesson_model.dart';
import '../../providers/courses_provider.dart';
import '../../providers/auth_provider.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  // Forms states
  final _courseFormKey = GlobalKey<FormState>();
  final _courseTitleController = TextEditingController();
  final _courseDescController = TextEditingController();
  final _courseCategoryController = TextEditingController();
  final _courseCoverUrlController = TextEditingController();
  String? _selectedCourseGroupId;

  final _lessonFormKey = GlobalKey<FormState>();
  final _lessonTitleController = TextEditingController();
  final _lessonDescController = TextEditingController();
  String _selectedLessonType = 'video';
  final _lessonDurationController = TextEditingController();
  String? _selectedLessonGroupId;

  // Track editing states
  ChapterModel? _editingChapter;
  final TextEditingController _chapterTitleController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _courseTitleController.dispose();
    _courseDescController.dispose();
    _courseCategoryController.dispose();
    _courseCoverUrlController.dispose();
    _lessonTitleController.dispose();
    _lessonDescController.dispose();
    _lessonDurationController.dispose();
    _chapterTitleController.dispose();
    super.dispose();
  }

  void _populateCourseFields(CourseModel course) {
    _courseTitleController.text = course.title;
    _courseDescController.text = course.description;
    _courseCategoryController.text = course.category;
    _courseCoverUrlController.text = course.coverImageUrl;
    _selectedCourseGroupId = course.relatedChatGroupId;
  }

  void _populateLessonFields(LessonModel lesson) {
    _lessonTitleController.text = lesson.title;
    _lessonDescController.text = lesson.description;
    _selectedLessonType = lesson.type;
    _lessonDurationController.text = (lesson.durationSeconds ~/ 60).toString();
    _selectedLessonGroupId = lesson.relatedChatGroupId;
  }

  void _showAddCourseDialog(String Function(String, String) t) {
    final titleC = TextEditingController();
    final descC = TextEditingController();
    final catC = TextEditingController(text: 'General');
    final coverC = TextEditingController(
      text: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&q=80&w=300'
    );
    String? tempGroupId;
    bool isPickingCover = false;

    showDialog(
      context: context,
      builder: (context) {
        final provider = Provider.of<CoursesProvider>(context, listen: false);
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void pickCover() {
              final uploadInput = html.FileUploadInputElement();
              uploadInput.accept = 'image/*';
              uploadInput.click();
              
              uploadInput.onChange.listen((e) {
                final files = uploadInput.files;
                if (files != null && files.isNotEmpty) {
                  final file = files.first;
                  final reader = html.FileReader();
                  
                  setDialogState(() {
                    isPickingCover = true;
                  });

                  reader.onLoadEnd.listen((e) {
                    final result = reader.result as String?;
                    if (result != null) {
                      setDialogState(() {
                        coverC.text = result;
                        isPickingCover = false;
                      });
                    }
                  });
                  reader.readAsDataUrl(file);
                }
              });
            }

            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(t('Create New Course', 'إنشاء كورس جديد'), style: const TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Interactive Cover Image Preview Container
                      Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white10),
                          image: coverC.text.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(coverC.text),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: isPickingCover
                            ? const Center(child: CircularProgressIndicator())
                            : coverC.text.isEmpty
                                ? const Center(child: Icon(Icons.image_not_supported_rounded, color: Colors.white24, size: 40))
                                : null,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: pickCover,
                        icon: const Icon(Icons.cloud_upload_rounded, size: 16),
                        label: Text(t('Upload Cover Image', 'تحميل صورة الغلاف')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white10,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 36),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: titleC,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: t('Course Title', 'عنوان الكورس'),
                          labelStyle: const TextStyle(color: Colors.white54),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descC,
                        maxLines: 3,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: t('Description', 'الوصف'),
                          labelStyle: const TextStyle(color: Colors.white54),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: catC,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: t('Category', 'التصنيف'),
                          labelStyle: const TextStyle(color: Colors.white54),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildGroupDropdown(
                        currentValue: tempGroupId,
                        onChanged: (val) {
                          tempGroupId = val;
                        },
                        t: t,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(t('Cancel', 'إلغاء'), style: const TextStyle(color: Colors.white38)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (titleC.text.trim().isEmpty) return;
                    
                    final newCourse = CourseModel(
                      id: '',
                      title: titleC.text.trim(),
                      description: descC.text.trim(),
                      category: catC.text.trim(),
                      instructorId: 'admin_uid',
                      instructorName: 'Academic Admin',
                      coverImageUrl: coverC.text.trim(),
                      totalDuration: 0,
                      totalLessons: 0,
                      relatedChatGroupId: tempGroupId,
                    );

                    final success = await provider.createCourse(newCourse);
                    if (success && mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(t('Course created successfully!', 'تم إنشاء الكورس بنجاح!')),
                          backgroundColor: const Color(0xFF10B981),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2DD4BF)),
                  child: Text(t('Create', 'إنشاء'), style: const TextStyle(color: Color(0xFF0F172A))),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddChapterDialog(String courseId, String Function(String, String) t) {
    _chapterTitleController.clear();
    showDialog(
      context: context,
      builder: (context) {
        final provider = Provider.of<CoursesProvider>(context, listen: false);
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(t('Create New Chapter', 'إنشاء فصل جديد'), style: const TextStyle(color: Colors.white)),
          content: TextField(
            controller: _chapterTitleController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: t('Chapter Title', 'عنوان الفصل'),
              labelStyle: const TextStyle(color: Colors.white54),
              hintText: t('e.g., Chapter 1: Introduction', 'مثال: الفصل الأول: مقدمة'),
              hintStyle: const TextStyle(color: Colors.white24),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(t('Cancel', 'إلغاء'), style: const TextStyle(color: Colors.white38)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_chapterTitleController.text.trim().isEmpty) return;
                final success = await provider.createChapter(courseId, _chapterTitleController.text.trim());
                if (success && mounted) {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2DD4BF)),
              child: Text(t('Create', 'إنشاء'), style: const TextStyle(color: Color(0xFF0F172A))),
            ),
          ],
        );
      },
    );
  }

  void _showAddLessonDialog(String courseId, String chapterId, String Function(String, String) t) {
    final titleC = TextEditingController();
    String tempType = 'video';

    showDialog(
      context: context,
      builder: (context) {
        final provider = Provider.of<CoursesProvider>(context, listen: false);
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(t('Add Lesson to Chapter', 'إضافة درس للفصل'), style: const TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleC,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: t('Lesson Title', 'عنوان الدرس'),
                      labelStyle: const TextStyle(color: Colors.white54),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(t('Content Type:', 'نوع المحتوى:'), style: const TextStyle(color: Colors.white70)),
                      DropdownButton<String>(
                        value: tempType,
                        dropdownColor: const Color(0xFF1E293B),
                        style: const TextStyle(color: Colors.white),
                        items: ['video', 'pdf'].map((tString) {
                          return DropdownMenuItem<String>(
                            value: tString,
                            child: Text(tString.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              tempType = val;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(t('Cancel', 'إلغاء'), style: const TextStyle(color: Colors.white38)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (titleC.text.trim().isEmpty) return;
                    final success = await provider.createLesson(
                      courseId: courseId,
                      chapterId: chapterId,
                      title: titleC.text.trim(),
                      type: tempType,
                    );
                    if (success && mounted) {
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2DD4BF)),
                  child: Text(t('Add Lesson', 'إضافة درس'), style: const TextStyle(color: Color(0xFF0F172A))),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _pickAndUploadFile(CoursesProvider provider, String fileType, String lessonId) {
    final uploadInput = html.FileUploadInputElement();
    uploadInput.accept = fileType == 'video' ? 'video/*' : 'application/pdf';
    uploadInput.click();
    
    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final file = files.first;
        provider.uploadLessonFile(
          courseId: provider.selectedCourse!.id,
          chapterId: _findChapterIdForLesson(provider, lessonId),
          lessonId: lessonId,
          file: file,
          fileType: fileType,
        );
      }
    });
  }

  String _findChapterIdForLesson(CoursesProvider provider, String lessonId) {
    for (var ch in provider.chapters) {
      final lessons = provider.getLessonsForChapter(ch.id);
      if (lessons.any((l) => l.id == lessonId)) {
        return ch.id;
      }
    }
    return '';
  }

  Widget _buildGroupDropdown({
    required String? currentValue,
    required Function(String?) onChanged,
    required String Function(String, String) t,
  }) {
    final groupsList = [
      {'id': 'g1', 'name': 'Advanced Calculus Study'},
      {'id': 'g2', 'name': 'Computer Science Thesis'},
      {'id': 'g3', 'name': 'Physics Lab 3 - Team B'},
      {'id': 'g4', 'name': 'University Freshmen Lounge'},
    ];

    return DropdownButtonFormField<String>(
      value: currentValue,
      dropdownColor: const Color(0xFF1E293B),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: t('Linked Chat Group', 'مجموعة الدردشة المرتبطة'),
        labelStyle: const TextStyle(color: Colors.white54),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
      ),
      items: [
        DropdownMenuItem<String>(
          value: null,
          child: Text(t('None (Unlinked)', 'بدون ارتباط')),
        ),
        ...groupsList.map((g) {
          return DropdownMenuItem<String>(
            value: g['id'],
            child: Text(g['name']!),
          );
        }),
      ],
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CoursesProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final accentColor = const Color(0xFF2DD4BF);
    final cardColor = const Color(0xFF1E293B);

    String t(String en, String ar) => authProvider.isArabic ? ar : en;

    // If a course is selected, show the 3-column editor. Otherwise, show the course list grid.
    if (provider.selectedCourse != null) {
      return _buildThreeColumnEditor(provider, cardColor, accentColor, t);
    }

    // Filter courses list
    final filtered = provider.courses.where((c) {
      return c.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.category.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Toolbar Search & Add Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: t('Search courses by title or category...', 'بحث الكورسات بالاسم أو التصنيف...'),
                      hintStyle: const TextStyle(color: Colors.white30),
                      prefixIcon: const Icon(Icons.search, color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.03),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: accentColor.withOpacity(0.4)),
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _showAddCourseDialog(t),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(t('Add Course', 'إضافة كورس'), style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Main content: Loading indicator, Error banner, or Course Grid
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.errorMessage != null
                    ? Center(
                        child: Text(
                          'Error: ${provider.errorMessage}',
                          style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                        ),
                      )
                    : _buildCourseGrid(filtered, cardColor, accentColor, provider, t),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseGrid(
    List<CourseModel> list,
    Color cardColor,
    Color accentColor,
    CoursesProvider provider,
    String Function(String, String) t,
  ) {
    if (list.isEmpty) {
      return Center(
        child: Text(
          t('No courses found. Add a course to start building the curriculum.', 'لم يتم العثور على كورسات. أضف كورس للبدء في بناء المنهج الدراسي.'),
          style: const TextStyle(color: Colors.white30, fontSize: 16),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 1;
        if (constraints.maxWidth > 1100) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth > 800) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth > 500) {
          crossAxisCount = 2;
        }

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 0.85,
          ),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final course = list[index];
            return Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(0.04)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Cover Image Container
                  Expanded(
                    flex: 4,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          course.coverImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.white.withOpacity(0.05),
                              child: const Icon(Icons.image_not_supported_rounded, color: Colors.white24, size: 40),
                            );
                          },
                        ),
                        // Category Tag (Top Right)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Text(
                              course.category,
                              style: TextStyle(color: accentColor, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Metadata
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.title,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            course.description,
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          const Divider(color: Colors.white10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t('Instructor', 'المحاضر'),
                                    style: TextStyle(color: Colors.white.withOpacity(0.24), fontSize: 9),
                                  ),
                                  Text(
                                    course.instructorName,
                                    style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.settings_suggest_rounded, size: 20),
                                    color: accentColor,
                                    tooltip: t('Manage Content / Curriculum', 'إدارة المحتوى / المنهج'),
                                    onPressed: () {
                                      provider.selectCourse(course);
                                      _populateCourseFields(course);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, size: 20),
                                    color: Colors.redAccent,
                                    tooltip: t('Delete Course', 'حذف الكورس'),
                                    onPressed: () {
                                      _showDeleteCourseDialog(course, provider, t);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteCourseDialog(CourseModel course, CoursesProvider provider, String Function(String, String) t) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(t('Delete Course?', 'حذف الكورس؟'), style: const TextStyle(color: Colors.redAccent)),
          content: Text(
            t(
              'Are you sure you want to permanently delete "${course.title}"?\nAll chapters and lessons will be lost.',
              'هل أنت متأكد من حذف الكورس "${course.title}" نهائياً؟\nستفقد جميع الفصول والدروس.',
            ),
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(t('Cancel', 'إلغاء'), style: const TextStyle(color: Colors.white38)),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await provider.deleteCourse(course.id);
                if (success && mounted) {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: Text(t('Delete', 'حذف'), style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // =========================================================================
  // 3-COLUMN CMS EDITOR PANEL
  // =========================================================================

  Widget _buildThreeColumnEditor(CoursesProvider provider, Color cardColor, Color accentColor, String Function(String, String) t) {
    final size = MediaQuery.of(context).size;
    final bool isWideScreen = size.width > 1200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Editor Top Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white70),
                tooltip: t('Back to Courses Grid', 'العودة لشبكة الكورسات'),
                onPressed: () => provider.selectCourse(null),
              ),
              const SizedBox(width: 8),
              Text(
                t('CMS Console: ${provider.selectedCourse!.title}', 'لوحة التحكم: ${provider.selectedCourse!.title}'),
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (provider.useMock)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.withOpacity(0.24)),
                  ),
                  child: Text(
                    t('Sandbox Mode', 'وضع التجربة'),
                    style: const TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),

        // Main Columns Area
        Expanded(
          child: isWideScreen
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Column 1: Course Meta Editor
                    SizedBox(width: 320, child: _buildColumn1(provider, cardColor, accentColor, t)),
                    const VerticalDivider(width: 1),
                    // Column 2: Curriculum Outline
                    Expanded(flex: 4, child: _buildColumn2(provider, cardColor, accentColor, t)),
                    const VerticalDivider(width: 1),
                    // Column 3: Lesson detail configuration
                    Expanded(flex: 5, child: _buildColumn3(provider, cardColor, accentColor, t)),
                  ],
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildColumn1(provider, cardColor, accentColor, t),
                        const SizedBox(height: 16),
                        _buildColumn2(provider, cardColor, accentColor, t),
                        const SizedBox(height: 16),
                        _buildColumn3(provider, cardColor, accentColor, t),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  // Column 1: Course Metadata Form
  Widget _buildColumn1(CoursesProvider provider, Color cardColor, Color accentColor, String Function(String, String) t) {
    final course = provider.selectedCourse!;
    return Container(
      color: const Color(0xFF0F172A).withOpacity(0.3),
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _courseFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.edit_note_rounded, color: accentColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  t('COURSE SETTINGS', 'إعدادات الكورس'),
                  style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _courseTitleController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                labelText: t('Title', 'العنوان'),
                labelStyle: const TextStyle(color: Colors.white38),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
              ),
              validator: (v) => v == null || v.isEmpty ? t('Title is required', 'العنوان مطلوب') : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _courseDescController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                labelText: t('Description', 'الوصف'),
                labelStyle: const TextStyle(color: Colors.white38),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
              ),
              validator: (v) => v == null || v.isEmpty ? t('Description is required', 'الوصف مطلوب') : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _courseCategoryController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                labelText: t('Category', 'التصنيف'),
                labelStyle: const TextStyle(color: Colors.white38),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
              ),
            ),
            const SizedBox(height: 16),
            _buildCourseCoverUploader(accentColor, t),
            const SizedBox(height: 16),
            _buildGroupDropdown(
              currentValue: _selectedCourseGroupId,
              onChanged: (val) {
                setState(() {
                  _selectedCourseGroupId = val;
                });
              },
              t: t,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                if (_courseFormKey.currentState!.validate()) {
                  final updated = course.copyWith(
                    title: _courseTitleController.text.trim(),
                    description: _courseDescController.text.trim(),
                    category: _courseCategoryController.text.trim(),
                    coverImageUrl: _courseCoverUrlController.text.trim(),
                    relatedChatGroupId: _selectedCourseGroupId,
                  );
                  final success = await provider.updateCourse(updated);
                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(t('Course settings updated!', 'تم تحديث إعدادات الكورس!')),
                        backgroundColor: const Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: const Color(0xFF0F172A),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(t('Save Settings', 'حفظ الإعدادات'), style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // Column 2: Chapters Outline Tree
  Widget _buildColumn2(CoursesProvider provider, Color cardColor, Color accentColor, String Function(String, String) t) {
    final course = provider.selectedCourse!;

    return Container(
      color: const Color(0xFF0B0F19),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.list_alt_rounded, color: accentColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    t('CURRICULUM OUTLINE', 'منهج الكورس'),
                    style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.create_new_folder_rounded, size: 22),
                color: accentColor,
                tooltip: t('Add Chapter', 'إضافة فصل'),
                onPressed: () => _showAddChapterDialog(course.id, t),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: provider.chapters.isEmpty
                ? Center(
                    child: Text(
                      t('No chapters added yet.', 'لم يتم إضافة فصول بعد.'),
                      style: const TextStyle(color: Colors.white24, fontSize: 13),
                    ),
                  )
                : ListView.builder(
                    itemCount: provider.chapters.length,
                    itemBuilder: (context, index) {
                      final chapter = provider.chapters[index];
                      final lessons = provider.getLessonsForChapter(chapter.id);
                      final isChapterEditing = _editingChapter?.id == chapter.id;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: cardColor.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.03)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Chapter Header
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.02),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.folder_open_rounded, color: Colors.amber, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: isChapterEditing
                                        ? TextField(
                                            controller: _chapterTitleController,
                                            style: const TextStyle(color: Colors.white, fontSize: 13),
                                            decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.zero),
                                            onSubmitted: (val) async {
                                              if (val.trim().isNotEmpty) {
                                                await provider.updateChapter(
                                                  course.id,
                                                  chapter.copyWith(title: val.trim()),
                                                );
                                              }
                                              setState(() {
                                                _editingChapter = null;
                                              });
                                            },
                                          )
                                        : Text(
                                            chapter.title,
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                  ),
                                  // Reorder/Delete/Add Lesson buttons
                                  if (!isChapterEditing) ...[
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                                      color: accentColor,
                                      tooltip: t('Add Lesson', 'إضافة درس'),
                                      onPressed: () => _showAddLessonDialog(course.id, chapter.id, t),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, size: 16),
                                      color: Colors.white54,
                                      tooltip: t('Edit Title', 'تعديل العنوان'),
                                      onPressed: () {
                                        setState(() {
                                          _editingChapter = chapter;
                                          _chapterTitleController.text = chapter.title;
                                        });
                                      },
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    const SizedBox(width: 8),
                                    if (index > 0)
                                      IconButton(
                                        icon: const Icon(Icons.arrow_upward_rounded, size: 16),
                                        color: Colors.white30,
                                        onPressed: () => provider.reorderChapters(course.id, index, index - 1),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    if (index < provider.chapters.length - 1)
                                      IconButton(
                                        icon: const Icon(Icons.arrow_downward_rounded, size: 16),
                                        color: Colors.white30,
                                        onPressed: () => provider.reorderChapters(course.id, index, index + 2),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, size: 16),
                                      color: Colors.redAccent.withOpacity(0.7),
                                      onPressed: () => provider.deleteChapter(course.id, chapter.id),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ] else
                                    IconButton(
                                      icon: const Icon(Icons.check_rounded, size: 16, color: Colors.greenAccent),
                                      onPressed: () async {
                                        if (_chapterTitleController.text.trim().isNotEmpty) {
                                          await provider.updateChapter(
                                            course.id,
                                            chapter.copyWith(title: _chapterTitleController.text.trim()),
                                          );
                                        }
                                        setState(() {
                                          _editingChapter = null;
                                        });
                                      },
                                    ),
                                ],
                              ),
                            ),
                            // Lessons sublist
                            if (lessons.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                child: Text(t('Empty chapter. Add lessons above.', 'فصل فارغ. أضف دروساً من الأعلى.'), style: const TextStyle(color: Colors.white24, fontSize: 11)),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: lessons.length,
                                itemBuilder: (context, lesIndex) {
                                  final les = lessons[lesIndex];
                                  final isSelected = provider.selectedLesson?.id == les.id;

                                  return InkWell(
                                    onTap: () {
                                      provider.selectLesson(les);
                                      _populateLessonFields(les);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: isSelected ? accentColor.withOpacity(0.08) : Colors.transparent,
                                        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.02))),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            les.type == 'video' ? Icons.play_circle_fill_rounded : Icons.description_rounded,
                                            color: isSelected ? accentColor : (les.type == 'video' ? Colors.blueAccent : Colors.tealAccent),
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              les.title,
                                              style: TextStyle(
                                                color: isSelected ? Colors.white : Colors.white70,
                                                fontSize: 12,
                                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          // Up/Down/Delete for lessons
                                          if (lesIndex > 0)
                                            IconButton(
                                              icon: const Icon(Icons.keyboard_arrow_up_rounded, size: 14),
                                              color: Colors.white24,
                                              onPressed: () => provider.reorderLessons(course.id, chapter.id, lesIndex, lesIndex - 1),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                            ),
                                          if (lesIndex < lessons.length - 1)
                                            IconButton(
                                              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 14),
                                              color: Colors.white24,
                                              onPressed: () => provider.reorderLessons(course.id, chapter.id, lesIndex, lesIndex + 2),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                            ),
                                          const SizedBox(width: 6),
                                          IconButton(
                                            icon: const Icon(Icons.close_rounded, size: 14),
                                            color: Colors.redAccent.withOpacity(0.4),
                                            onPressed: () => provider.deleteLesson(course.id, chapter.id, les.id),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Column 3: Selected Lesson Configuration & Native Chunked Upload
  Widget _buildColumn3(CoursesProvider provider, Color cardColor, Color accentColor, String Function(String, String) t) {
    final lesson = provider.selectedLesson;
    if (lesson == null) {
      return Container(
        color: const Color(0xFF0F172A).withOpacity(0.1),
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.design_services_rounded, color: Colors.white24, size: 48),
              const SizedBox(height: 12),
              Text(
                t('No Lesson Selected', 'لم يتم اختيار درس'),
                style: const TextStyle(color: Colors.white30, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                t('Select a lesson in the curriculum outline to edit its parameters and upload contents.', 'اختر درساً من منهج الكورس لتعديل خصائصه ورفع المحتوى الخاص به.'),
                style: const TextStyle(color: Colors.white24, fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final fileId = '${lesson.id}_${lesson.type}';
    final uploadStatus = provider.getStatus(fileId);
    final uploadProgress = provider.getProgress(fileId);
    final uploadSpeed = provider.getSpeed(fileId);
    final uploadError = provider.getError(fileId);

    return Container(
      color: const Color(0xFF0F172A).withOpacity(0.2),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _lessonFormKey,
        child: ListView(
          children: [
            Row(
              children: [
                Icon(
                  lesson.type == 'video' ? Icons.video_collection_rounded : Icons.library_books_rounded,
                  color: accentColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  t('LESSON & CONTENT SETTINGS', 'إعدادات الدرس والمحتوى'),
                  style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _lessonTitleController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                labelText: t('Lesson Title', 'عنوان الدرس'),
                labelStyle: const TextStyle(color: Colors.white38),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
              ),
              validator: (v) => v == null || v.isEmpty ? t('Lesson title is required', 'عنوان الدرس مطلوب') : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lessonDescController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                labelText: t('Lesson Description', 'وصف الدرس'),
                labelStyle: const TextStyle(color: Colors.white38),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedLessonType,
                    dropdownColor: const Color(0xFF1E293B),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: t('Content Type', 'نوع المحتوى'),
                      labelStyle: const TextStyle(color: Colors.white38),
                      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
                    ),
                    items: ['video', 'pdf'].map((tString) {
                      return DropdownMenuItem<String>(
                        value: tString,
                        child: Text(tString == 'video' ? t('VIDEO', 'فيديو') : t('PDF', 'ملف PDF')),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedLessonType = val;
                        });
                      }
                    },
                  ),
                ),
                if (_selectedLessonType == 'video') ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _lessonDurationController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: t('Duration (Minutes)', 'المدة (بالدقائق)'),
                        labelStyle: const TextStyle(color: Colors.white38),
                        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            _buildGroupDropdown(
              currentValue: _selectedLessonGroupId,
              onChanged: (val) {
                setState(() {
                  _selectedLessonGroupId = val;
                });
              },
              t: t,
            ),
            const SizedBox(height: 32),

            // UPLOAD MANAGER SECTION
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.04)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        t('Resource Upload (Chunked)', 'رفع الملف (مقطّع)'),
                        style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      if (uploadStatus != 'idle')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusColor(uploadStatus).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: _getStatusColor(uploadStatus).withOpacity(0.3)),
                          ),
                          child: Text(
                            uploadStatus == 'uploading'
                                ? t('UPLOADING', 'جاري الرفع')
                                : uploadStatus == 'paused'
                                    ? t('PAUSED', 'موقوف مؤقتاً')
                                    : uploadStatus == 'completed'
                                        ? t('COMPLETED', 'مكتمل')
                                        : uploadStatus == 'error'
                                            ? t('ERROR', 'خطأ')
                                            : uploadStatus == 'retrying'
                                                ? t('RETRYING', 'إعادة المحاولة')
                                                : uploadStatus.toUpperCase(),
                            style: TextStyle(color: _getStatusColor(uploadStatus), fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Active Progress indicators
                  if (uploadStatus == 'uploading' || uploadStatus == 'paused' || uploadStatus == 'retrying') ...[
                    LinearProgressIndicator(
                      value: uploadProgress,
                      backgroundColor: Colors.white10,
                      valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          t('${(uploadProgress * 100).toStringAsFixed(1)}% Completed', 'مكتمل بنسبة ${(uploadProgress * 100).toStringAsFixed(1)}%'),
                          style: const TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                        Text(
                          t('Speed: ${uploadSpeed.toStringAsFixed(2)} MB/s', 'السرعة: ${uploadSpeed.toStringAsFixed(2)} ميغابايت/ث'),
                          style: TextStyle(color: accentColor, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (uploadStatus == 'uploading')
                          IconButton(
                            icon: const Icon(Icons.pause_circle_filled_rounded, color: Colors.amber, size: 28),
                            onPressed: () => provider.pauseUpload(fileId),
                            tooltip: t('Pause Upload', 'إيقاف مؤقت للرفع'),
                          )
                        else if (uploadStatus == 'paused')
                          IconButton(
                            icon: const Icon(Icons.play_circle_filled_rounded, color: Colors.greenAccent, size: 28),
                            onPressed: () => provider.resumeUpload(fileId),
                            tooltip: t('Resume Upload', 'استئناف الرفع'),
                          ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.cancel_rounded, color: Colors.redAccent, size: 28),
                          onPressed: () => provider.cancelUpload(fileId),
                          tooltip: t('Cancel Upload', 'إلغاء الرفع'),
                        ),
                      ],
                    ),
                  ] else if (uploadStatus == 'completed') ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t('Upload Completed Successfully!', 'اكتمل الرفع بنجاح!'),
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'URL: ${lesson.type == 'video' ? lesson.videoUrl : lesson.pdfUrl}',
                                  style: const TextStyle(color: Colors.white54, fontSize: 10, fontFamily: 'monospace'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => _pickAndUploadFile(provider, lesson.type, lesson.id),
                      icon: const Icon(Icons.cloud_upload_rounded),
                      label: Text(t('Replace Uploaded File', 'استبدال الملف المرفوع')),
                      style: ElevatedButton.styleFrom(backgroundColor: cardColor, foregroundColor: Colors.white),
                    ),
                  ] else ...[
                    // Idle or Error State
                    if (uploadStatus == 'error' && uploadError != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                        ),
                        child: Text(
                          uploadError,
                          style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 11),
                        ),
                      ),
                    ],
                    
                    Text(
                      t('No file uploaded for this resource yet. Select a file from your system to initiate a chunked upload session.', 'لا يوجد ملف مرفوع لهذا الدرس بعد. اختر ملفاً من جهازك لبدء جلسة الرفع مقطّعة.'),
                      style: const TextStyle(color: Colors.white30, fontSize: 11),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _pickAndUploadFile(provider, lesson.type, lesson.id),
                      icon: const Icon(Icons.cloud_upload_rounded),
                      label: Text(lesson.type == 'video' ? t('Select & Upload Video', 'اختر وارفع الفيديو') : t('Select & Upload PDF', 'اختر وارفع ملف PDF')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: const Color(0xFF0F172A),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Save Lesson Metadata
            ElevatedButton(
              onPressed: () async {
                if (_lessonFormKey.currentState!.validate()) {
                  final dur = int.tryParse(_lessonDurationController.text.trim()) ?? 0;
                  final updated = lesson.copyWith(
                    title: _lessonTitleController.text.trim(),
                    description: _lessonDescController.text.trim(),
                    type: _selectedLessonType,
                    durationSeconds: dur * 60,
                    relatedChatGroupId: _selectedLessonGroupId,
                  );
                  final success = await provider.updateLesson(
                    provider.selectedCourse!.id,
                    _findChapterIdForLesson(provider, lesson.id),
                    updated,
                  );
                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(t('Lesson details saved!', 'تم حفظ تفاصيل الدرس!')),
                        backgroundColor: const Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white10,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(t('Save Lesson Details', 'حفظ تفاصيل الدرس')),
            ),
          ],
        ),
      ),
    );
  }

  bool _isColumn1PickingCover = false;

  Widget _buildCourseCoverUploader(Color accentColor, String Function(String, String) t) {
    void pickColumn1Cover() {
      final uploadInput = html.FileUploadInputElement();
      uploadInput.accept = 'image/*';
      uploadInput.click();
      
      uploadInput.onChange.listen((e) {
        final files = uploadInput.files;
        if (files != null && files.isNotEmpty) {
          final file = files.first;
          final reader = html.FileReader();
          
          setState(() {
            _isColumn1PickingCover = true;
          });

          reader.onLoadEnd.listen((e) {
            final result = reader.result as String?;
            if (result != null) {
              setState(() {
                _courseCoverUrlController.text = result;
                _isColumn1PickingCover = false;
              });
            }
          });
          reader.readAsDataUrl(file);
        }
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('Course Cover Image', 'صورة غلاف الكورس'),
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
            image: _courseCoverUrlController.text.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(_courseCoverUrlController.text),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: _isColumn1PickingCover
              ? const Center(child: CircularProgressIndicator())
              : _courseCoverUrlController.text.isEmpty
                  ? const Center(child: Icon(Icons.image_not_supported_rounded, color: Colors.white24, size: 40))
                  : null,
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: pickColumn1Cover,
          icon: const Icon(Icons.cloud_upload_rounded, size: 16),
          label: Text(t('Upload Cover Image', 'تحميل صورة الغلاف')),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white10,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 36),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'uploading':
        return const Color(0xFF6366F1);
      case 'paused':
        return Colors.orangeAccent;
      case 'completed':
        return const Color(0xFF10B981);
      case 'error':
        return Colors.redAccent;
      case 'retrying':
        return Colors.amberAccent;
      default:
        return Colors.white54;
    }
  }
}
