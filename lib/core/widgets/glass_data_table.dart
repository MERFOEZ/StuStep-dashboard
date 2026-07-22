import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dashboard/core/theme/app_theme.dart';

/// Premium glass data table with hover effects, animated rows, and
/// status badges.
class GlassDataTable extends StatelessWidget {
  final List<String> columns;
  final List<GlassTableRow> rows;
  final bool isLoading;

  const GlassDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.glassBorder.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface3.withValues(alpha: 0.5),
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.glassBorder.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                child: Row(
                  children: columns.map((col) {
                    return Expanded(
                      child: Text(
                        col,
                        style: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              // Rows
              ...rows.asMap().entries.map((entry) {
                final index = entry.key;
                final row = entry.value;
                return _AnimatedTableRow(
                  row: row,
                  index: index,
                  columnCount: columns.length,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedTableRow extends StatefulWidget {
  final GlassTableRow row;
  final int index;
  final int columnCount;

  const _AnimatedTableRow({
    required this.row,
    required this.index,
    required this.columnCount,
  });

  @override
  State<_AnimatedTableRow> createState() => _AnimatedTableRowState();
}

class _AnimatedTableRowState extends State<_AnimatedTableRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: _hovered
              ? AppColors.primary.withValues(alpha: 0.05)
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: AppColors.glassBorder.withValues(alpha: 0.1),
            ),
          ),
        ),
        child: Row(
          children: widget.row.cells.map((cell) {
            return Expanded(child: cell);
          }).toList(),
        ),
      ),
    )
        .animate()
        .fade(
          duration: 400.ms,
          delay: Duration(milliseconds: 50 * widget.index),
        )
        .slideX(
          begin: 0.02,
          duration: 400.ms,
          delay: Duration(milliseconds: 50 * widget.index),
          curve: Curves.easeOutCubic,
        );
  }
}

/// A row in the GlassDataTable.
class GlassTableRow {
  final List<Widget> cells;
  final String? id;

  const GlassTableRow({required this.cells, this.id});
}

/// Status badge widget for active/inactive states.
class StatusBadge extends StatelessWidget {
  final bool isActive;
  final String activeLabel;
  final String inactiveLabel;

  const StatusBadge({
    super.key,
    required this.isActive,
    this.activeLabel = 'نشط',
    this.inactiveLabel = 'غير نشط',
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.success : AppColors.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color.withValues(alpha: 0.12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
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
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.6),
                        blurRadius: 6,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? activeLabel : inactiveLabel,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Action buttons for table rows.
class TableActionButtons extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onAddVideo;
  final VoidCallback? onView;
  final String editTooltip;
  final String deleteTooltip;
  final String addVideoTooltip;
  final String viewTooltip;

  const TableActionButtons({
    super.key,
    required this.onEdit,
    required this.onDelete,
    this.onAddVideo,
    this.onView,
    this.editTooltip = 'تعديل',
    this.deleteTooltip = 'حذف',
    this.addVideoTooltip = 'رفع فيديو',
    this.viewTooltip = 'عرض',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onView != null) ...[
          _ActionIcon(
            icon: Icons.visibility_rounded,
            tooltip: viewTooltip,
            color: AppColors.secondary,
            onPressed: onView!,
          ),
          const SizedBox(width: 8),
        ],
        if (onAddVideo != null) ...[
          _ActionIcon(
            icon: Icons.video_call_rounded,
            tooltip: addVideoTooltip,
            color: AppColors.primary,
            onPressed: onAddVideo!,
          ),
          const SizedBox(width: 8),
        ],
        _ActionIcon(
          icon: Icons.edit_rounded,
          tooltip: editTooltip,
          color: AppColors.info,
          onPressed: onEdit,
        ),
        const SizedBox(width: 8),
        _ActionIcon(
          icon: Icons.delete_outline_rounded,
          tooltip: deleteTooltip,
          color: AppColors.error,
          onPressed: onDelete,
        ),
      ],
    );
  }
}

class _ActionIcon extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onPressed;

  const _ActionIcon({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onPressed,
  });

  @override
  State<_ActionIcon> createState() => _ActionIconState();
}

class _ActionIconState extends State<_ActionIcon> {
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
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: _hovered
                  ? widget.color.withValues(alpha: 0.15)
                  : Colors.transparent,
            ),
            child: Icon(
              widget.icon,
              color: _hovered
                  ? widget.color
                  : AppColors.textHint,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}
