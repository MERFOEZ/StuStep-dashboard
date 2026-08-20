import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dashboard/core/theme/app_theme.dart';
import 'package:dashboard/core/l10n/app_localizations.dart';
import 'package:dashboard/core/models/course.dart';
import 'package:dashboard/core/services/firestore_service.dart';
import 'package:dashboard/core/widgets/glass_dialog.dart';
import 'package:dashboard/core/widgets/animated_snackbar.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

/// Enterprise-grade Curriculum Management Panel.
/// Slide-out panel for granular video management within a course.
class VideoManagementPanel extends StatefulWidget {
  final Course course;
  final VoidCallback onClose;

  const VideoManagementPanel({
    super.key,
    required this.course,
    required this.onClose,
  });

  @override
  State<VideoManagementPanel> createState() => _VideoManagementPanelState();
}

class _VideoManagementPanelState extends State<VideoManagementPanel>
    with SingleTickerProviderStateMixin {
  final _firestoreService = FirestoreService();
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  int? _playingIndex;
  String? _playerViewType;
  bool _isLoading = false;
  late List<Map<String, dynamic>> _lectures;

  @override
  void initState() {
    super.initState();
    _lectures = List<Map<String, dynamic>>.from(widget.course.lectures);

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _closePanel() async {
    await _slideController.reverse();
    widget.onClose();
  }

  void _playVideo(int index) {
    final lecture = _lectures[index];
    final url = lecture['url'] as String? ?? '';
    if (url.isEmpty) return;

    final viewId = 'video-player-${widget.course.id}-$index-${DateTime.now().millisecondsSinceEpoch}';

    // Register the HTML video element
    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
      final video = html.VideoElement()
        ..src = url
        ..controls = true
        ..autoplay = true
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.borderRadius = '12px'
        ..style.backgroundColor = '#000'
        ..style.outline = 'none';
      return video;
    });

    setState(() {
      _playingIndex = index;
      _playerViewType = viewId;
    });
  }

  void _stopVideo() {
    setState(() {
      _playingIndex = null;
      _playerViewType = null;
    });
  }

  Future<void> _deleteVideo(int index) async {
    final s = S.of(context);
    final lecture = _lectures[index];

    final confirmed = await showDeleteConfirmation(
      context: context,
      title: s.isArabic ? 'حذف الفيديو' : 'Delete Video',
      message: s.isArabic
          ? 'هل أنت متأكد من حذف "${lecture['name']}"؟ لا يمكن التراجع عن هذا.'
          : 'Are you sure you want to delete "${lecture['name']}"? This cannot be undone.',
      confirmLabel: s.delete,
      cancelLabel: s.cancel,
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      await _firestoreService.removeLecture(widget.course.id, index);
      setState(() {
        _lectures.removeAt(index);
        if (_playingIndex == index) _stopVideo();
        if (_playingIndex != null && _playingIndex! > index) {
          _playingIndex = _playingIndex! - 1;
        }
      });
      if (mounted) {
        showAnimatedSnackBar(context,
            message: s.isArabic ? 'تم حذف الفيديو بنجاح' : 'Video deleted successfully');
      }
    } catch (e) {
      if (mounted) {
        showAnimatedSnackBar(context, message: e.toString(), isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _editVideo(int index) async {
    final s = S.of(context);
    final lecture = _lectures[index];
    final nameCtrl = TextEditingController(text: lecture['name'] as String? ?? '');
    final urlCtrl = TextEditingController(text: lecture['url'] as String? ?? '');
    final formKey = GlobalKey<FormState>();

    showGlassDialog(
      context: context,
      title: s.isArabic ? 'تعديل بيانات الفيديو' : 'Edit Video Metadata',
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: s.isArabic ? 'اسم الفيديو' : 'Video Name',
                prefixIcon: Icon(Icons.videocam_rounded, color: AppColors.primaryLight, size: 20),
              ),
              style: TextStyle(color: AppColors.textPrimary),
              validator: (v) => v == null || v.trim().isEmpty ? s.requiredField : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: urlCtrl,
              decoration: InputDecoration(
                labelText: s.isArabic ? 'رابط الفيديو' : 'Video URL',
                prefixIcon: Icon(Icons.link_rounded, color: AppColors.primaryLight, size: 20),
              ),
              style: TextStyle(color: AppColors.textPrimary),
              validator: (v) => v == null || v.trim().isEmpty ? s.requiredField : null,
            ),
          ],
        ),
      ),
      actions: [
        GlassDialogButton(
          label: s.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        StatefulBuilder(
          builder: (ctx, setBtn) {
            bool saving = false;
            return GlassDialogButton(
              label: s.save,
              isPrimary: true,
              isLoading: saving,
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                setBtn(() => saving = true);
                try {
                  await _firestoreService.updateLecture(
                    widget.course.id, index, nameCtrl.text.trim(), urlCtrl.text.trim(),
                  );
                  setState(() {
                    _lectures[index] = {
                      'name': nameCtrl.text.trim(),
                      'url': urlCtrl.text.trim(),
                    };
                  });
                  if (mounted) {
                    Navigator.of(context).pop();
                    showAnimatedSnackBar(context,
                        message: s.isArabic ? 'تم تحديث الفيديو بنجاح' : 'Video updated');
                  }
                } catch (e) {
                  if (mounted) {
                    showAnimatedSnackBar(context, message: e.toString(), isError: true);
                  }
                }
              },
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return SlideTransition(
      position: _slideAnimation,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            width: 520,
            decoration: BoxDecoration(
              color: AppColors.sidebarBg.withValues(alpha: 0.95),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              border: Border(
                left: BorderSide(color: AppColors.glassBorder.withValues(alpha: 0.3)),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 40,
                  spreadRadius: -8,
                ),
              ],
            ),
            child: Column(
              children: [
                _buildHeader(s),
                if (_playingIndex != null) _buildVideoPlayer(),
                Expanded(child: _buildVideoList(s)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(S s) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.glassBorder.withValues(alpha: 0.2)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(colors: AppColors.gradientGreen),
                ),
                child: const Icon(Icons.video_library_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.isArabic ? 'إدارة محتوى الدورة' : 'Curriculum Manager',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.course.title,
                      style: TextStyle(color: AppColors.textHint, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close_rounded, color: AppColors.textHint),
                onPressed: _closePanel,
                tooltip: s.isArabic ? 'إغلاق' : 'Close',
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Stats bar
          Row(
            children: [
              _StatChip(
                icon: Icons.play_circle_outline,
                label: '${_lectures.length}',
                subtitle: s.isArabic ? 'فيديو' : 'Videos',
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              _StatChip(
                icon: widget.course.isActive ? Icons.check_circle_outline : Icons.cancel_outlined,
                label: widget.course.isActive
                    ? (s.isArabic ? 'نشط' : 'Active')
                    : (s.isArabic ? 'معطّل' : 'Inactive'),
                subtitle: s.isArabic ? 'الحالة' : 'Status',
                color: widget.course.isActive ? AppColors.success : AppColors.textMuted,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_playerViewType == null || _playingIndex == null) return const SizedBox.shrink();

    final lecture = _lectures[_playingIndex!];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        children: [
          // Player
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: SizedBox(
              height: 260,
              child: HtmlElementView(viewType: _playerViewType!),
            ),
          ),
          // Controls bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface3.withValues(alpha: 0.8),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Icon(Icons.videocam_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    lecture['name'] as String? ?? '',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, size: 18, color: AppColors.textHint),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: _stopVideo,
                  tooltip: 'Close Player',
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fade(duration: 300.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildVideoList(S s) {
    if (_lectures.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.video_library_outlined, size: 56, color: AppColors.textMuted.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              s.isArabic ? 'لا توجد فيديوهات في هذه الدورة' : 'No videos in this course',
              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              s.isArabic ? 'استخدم زر "رفع فيديو" لإضافة محتوى' : 'Use "Upload Video" to add content',
              style: TextStyle(color: AppColors.textHint, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: _lectures.length,
      onReorder: (oldIndex, newIndex) async {
        if (newIndex > oldIndex) newIndex--;
        setState(() {
          final item = _lectures.removeAt(oldIndex);
          _lectures.insert(newIndex, item);
        });
        await _firestoreService.reorderLectures(widget.course.id, _lectures);
      },
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final scale = Tween<double>(begin: 1.0, end: 1.03).evaluate(animation);
            return Transform.scale(scale: scale, child: child);
          },
          child: child,
        );
      },
      itemBuilder: (context, index) {
        final lecture = _lectures[index];
        final name = lecture['name'] as String? ?? 'Untitled';
        final url = lecture['url'] as String? ?? '';
        final isPlaying = _playingIndex == index;

        return _VideoTile(
          key: ValueKey('$index-$name'),
          index: index,
          name: name,
          url: url,
          isPlaying: isPlaying,
          isLoading: _isLoading,
          onPlay: () => isPlaying ? _stopVideo() : _playVideo(index),
          onEdit: () => _editVideo(index),
          onDelete: () => _deleteVideo(index),
        );
      },
    );
  }
}

class _VideoTile extends StatefulWidget {
  final int index;
  final String name;
  final String url;
  final bool isPlaying;
  final bool isLoading;
  final VoidCallback onPlay;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _VideoTile({
    super.key,
    required this.index,
    required this.name,
    required this.url,
    required this.isPlaying,
    required this.isLoading,
    required this.onPlay,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_VideoTile> createState() => _VideoTileState();
}

class _VideoTileState extends State<_VideoTile> {
  bool _hovered = false;

  String _formatName(String name) {
    // Remove file extension for cleaner display
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex > 0) return name.substring(0, dotIndex);
    return name;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: widget.isPlaying
              ? AppColors.primary.withValues(alpha: 0.08)
              : _hovered
                  ? AppColors.surface3.withValues(alpha: 0.6)
                  : AppColors.glassFillDark.withValues(alpha: 0.5),
          border: Border.all(
            color: widget.isPlaying
                ? AppColors.primary.withValues(alpha: 0.4)
                : _hovered
                    ? AppColors.glassBorder.withValues(alpha: 0.3)
                    : AppColors.glassBorder.withValues(alpha: 0.1),
            width: widget.isPlaying ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Index badge
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: widget.isPlaying
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.surface3,
              ),
              child: Center(
                child: Text(
                  '${widget.index + 1}',
                  style: TextStyle(
                    color: widget.isPlaying ? AppColors.primaryLight : AppColors.textHint,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Video info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatName(widget.name),
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.url.length > 50 ? '${widget.url.substring(0, 50)}...' : widget.url,
                    style: TextStyle(color: AppColors.textHint, fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Action buttons — visible on hover or always on playing
            AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: _hovered || widget.isPlaying ? 1.0 : 0.3,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Play/Stop
                  _MiniAction(
                    icon: widget.isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                    color: widget.isPlaying ? AppColors.warning : AppColors.success,
                    tooltip: widget.isPlaying ? 'Stop' : 'Play',
                    onTap: widget.onPlay,
                  ),
                  const SizedBox(width: 4),
                  // Edit
                  _MiniAction(
                    icon: Icons.edit_rounded,
                    color: AppColors.info,
                    tooltip: 'Edit',
                    onTap: widget.onEdit,
                  ),
                  const SizedBox(width: 4),
                  // Delete
                  _MiniAction(
                    icon: Icons.delete_outline_rounded,
                    color: AppColors.error,
                    tooltip: 'Delete',
                    onTap: widget.isLoading ? null : widget.onDelete,
                  ),
                  // Drag handle
                  const SizedBox(width: 4),
                  ReorderableDragStartListener(
                    index: widget.index,
                    child: Icon(Icons.drag_handle_rounded, size: 18, color: AppColors.textHint),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fade(duration: 300.ms, delay: Duration(milliseconds: 30 * widget.index));
  }
}

class _MiniAction extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback? onTap;

  const _MiniAction({
    required this.icon,
    required this.color,
    required this.tooltip,
    this.onTap,
  });

  @override
  State<_MiniAction> createState() => _MiniActionState();
}

class _MiniActionState extends State<_MiniAction> {
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
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 28, height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              color: _hovered ? widget.color.withValues(alpha: 0.15) : Colors.transparent,
            ),
            child: Icon(widget.icon, size: 16, color: _hovered ? widget.color : AppColors.textHint),
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
              Text(subtitle, style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}
