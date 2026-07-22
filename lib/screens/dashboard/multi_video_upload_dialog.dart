import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dashboard/core/theme/app_theme.dart';
import 'package:dashboard/core/l10n/app_localizations.dart';
import 'package:dashboard/core/models/course.dart';
import 'package:dashboard/core/services/firestore_service.dart';
import 'package:dashboard/core/services/storage_service.dart';
import 'package:dashboard/core/widgets/glass_dialog.dart';
import 'package:dashboard/core/widgets/animated_snackbar.dart';

class MultiVideoUploadDialog extends StatefulWidget {
  final Course level;
  const MultiVideoUploadDialog({super.key, required this.level});

  @override
  State<MultiVideoUploadDialog> createState() => _MultiVideoUploadDialogState();
}

class _UploadTaskState {
  final PlatformFile file;
  double progress = 0.0;
  bool isCompleted = false;
  bool isError = false;
  String? errorMessage;
  String? downloadUrl;

  _UploadTaskState({required this.file});
}

class _MultiVideoUploadDialogState extends State<MultiVideoUploadDialog> {
  final _firestoreService = FirestoreService();
  final _storageService = StorageService();

  final List<_UploadTaskState> _uploadTasks = [];
  bool _isUploading = false;

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.video,
        allowMultiple: true,
        withData: true,
      );

      if (result != null) {
        setState(() {
          _uploadTasks.addAll(
            result.files.map((f) => _UploadTaskState(file: f)).toList(),
          );
        });
      }
    } catch (e) {
      if (mounted) {
        showAnimatedSnackBar(context, message: e.toString(), isError: true);
      }
    }
  }

  void _removeFile(int index) {
    if (_isUploading) return;
    setState(() {
      _uploadTasks.removeAt(index);
    });
  }

  Future<void> _startUploads(S s) async {
    if (_uploadTasks.isEmpty) {
      showAnimatedSnackBar(
        context,
        message: s.isArabic
            ? 'الرجاء اختيار فيديو واحد على الأقل'
            : 'Please select at least one video',
        isError: true,
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    // Fetch collegeId
    final major = await _firestoreService.getDepartment(
      widget.level.departmentId,
    );
    final collegeId = major?.collegeId ?? 'unknown_college';
    final majorId = widget.level.departmentId;
    final levelId = widget.level.id;

    // Start all uploads concurrently
    final futures = _uploadTasks.where((t) => !t.isCompleted).map((
      taskState,
    ) async {
      if (taskState.file.bytes == null) {
        setState(() {
          taskState.isError = true;
          taskState.errorMessage = 'File bytes are null';
        });
        return;
      }

      try {
        final downloadUrl = await _storageService.uploadVideo(
          collegeId,
          majorId,
          levelId,
          taskState.file.name,
          taskState.file.bytes!,
          (count, total) {
            if (mounted && total > 0) {
              setState(() {
                taskState.progress = count / total;
              });
            }
          },
        );

        setState(() {
          taskState.downloadUrl = downloadUrl;
          taskState.progress = 1.0;
          taskState.isCompleted = true;
        });

        // Link video to Course (Level) in Firestore
        await _firestoreService.addLectureToCourse(
          levelId,
          taskState.file.name,
          downloadUrl,
        );
      } catch (e) {
        if (mounted) {
          setState(() {
            taskState.isError = true;
            taskState.errorMessage = e.toString();
          });
          print('UPLOAD ERROR for ${taskState.file.name}: $e');
        }
      }
    }).toList();

    await Future.wait(futures);

    if (mounted) {
      setState(() {
        _isUploading = false;
      });
      // Check if all successful
      final allSuccess = _uploadTasks.every((t) => t.isCompleted);
      if (allSuccess) {
        showAnimatedSnackBar(
          context,
          message: s.isArabic
              ? 'تم رفع جميع الفيديوهات بنجاح'
              : 'All videos uploaded successfully',
        );
        Navigator.of(context).pop();
      } else {
        showAnimatedSnackBar(
          context,
          message: s.isArabic
              ? 'حدثت بعض الأخطاء أثناء الرفع'
              : 'Some errors occurred during upload',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Level info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.school_rounded,
                color: AppColors.primaryLight,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${s.isArabic ? 'المستوى:' : 'Level:'} ${widget.level.title}',
                  style: const TextStyle(
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Pick Files Button
        ElevatedButton.icon(
          onPressed: _isUploading ? null : _pickFiles,
          icon: const Icon(Icons.video_library_rounded),
          label: Text(s.isArabic ? 'اختر ملفات الفيديو' : 'Choose Video Files'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.surface3,
            foregroundColor: AppColors.primaryLight,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.glassBorder),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // List of selected files
        if (_uploadTasks.isNotEmpty)
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 250),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _uploadTasks.length,
              itemBuilder: (context, index) {
                final taskState = _uploadTasks[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.glassFillDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.glassBorder.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            taskState.isCompleted
                                ? Icons.check_circle_rounded
                                : taskState.isError
                                ? Icons.error_rounded
                                : Icons.videocam_rounded,
                            color: taskState.isCompleted
                                ? AppColors.success
                                : taskState.isError
                                ? AppColors.error
                                : AppColors.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              taskState.file.name,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!_isUploading && !taskState.isCompleted)
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              color: AppColors.textMuted,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => _removeFile(index),
                            ),
                        ],
                      ),
                      if (_isUploading ||
                          taskState.isCompleted ||
                          taskState.isError)
                        const SizedBox(height: 10),
                      if (_isUploading &&
                          !taskState.isCompleted &&
                          !taskState.isError)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: taskState.progress,
                            backgroundColor: AppColors.surface0,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primaryLight,
                            ),
                            minHeight: 6,
                          ),
                        ),
                      if (taskState.isError)
                        Text(
                          taskState.errorMessage ?? 'Error',
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GlassDialogButton(
              label: s.cancel,
              onPressed: _isUploading
                  ? null
                  : () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 12),
            GlassDialogButton(
              label: s.isArabic ? 'بدء الرفع' : 'Start Upload',
              isPrimary: true,
              isLoading: _isUploading,
              onPressed: _isUploading ? null : () => _startUploads(s),
            ),
          ],
        ),
      ],
    );
  }
}
