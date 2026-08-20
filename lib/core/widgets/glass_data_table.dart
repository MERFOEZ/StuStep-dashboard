import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dashboard/core/theme/app_theme.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Premium Light-Mode Data Table — Card-Based Architecture
/// ─────────────────────────────────────────────────────────────────────────────
/// Destroys the default DataTable. Each row is a breathable white card with
/// hover micro-interactions (2% scale + shadow expansion), staggered entry
/// animations, and gradient accent details. Zero default Material components.
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.border.withOpacity(0.3),
        ),
        boxShadow: AppColors.softShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          children: [
            // ─── Header Row ──────────────────────────────────────
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.surfaceTinted,
                    AppColors.surfaceTinted.withOpacity(0.6),
                  ],
                ),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.border.withOpacity(0.4),
                  ),
                ),
              ),
              child: Row(
                children: columns.asMap().entries.map((entry) {
                  final index = entry.key;
                  final col = entry.value;
                  return Expanded(
                    child: Text(
                      col.toUpperCase(),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    )
                        .animate()
                        .fadeIn(
                          duration: 350.ms,
                          delay: Duration(milliseconds: 30 * index),
                        )
                        .slideY(
                          begin: -0.15,
                          duration: 350.ms,
                          delay: Duration(milliseconds: 30 * index),
                          curve: Curves.easeOutCubic,
                        ),
                  );
                }).toList(),
              ),
            ),
            // ─── Data Rows — each with staggered animation ──────
            ...rows.asMap().entries.map((entry) {
              final index = entry.key;
              final row = entry.value;
              return _AnimatedTableRow(
                row: row,
                index: index,
                columnCount: columns.length,
                isLast: index == rows.length - 1,
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// A single animated data row with hover micro-interactions.
class _AnimatedTableRow extends StatefulWidget {
  final GlassTableRow row;
  final int index;
  final int columnCount;
  final bool isLast;

  const _AnimatedTableRow({
    required this.row,
    required this.index,
    required this.columnCount,
    this.isLast = false,
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
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        transform: Matrix4.identity()..scale(_hovered ? 1.005 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: _hovered
              ? AppColors.primary.withOpacity(0.025)
              : Colors.transparent,
          border: widget.isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: AppColors.border
                        .withOpacity(_hovered ? 0.15 : 0.25),
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
          curve: Curves.easeOutCubic,
        )
        .slideY(
          begin: 0.06,
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

/// ─────────────────────────────────────────────────────────────────────────────
/// Status Badge — Vibrant pill with glow indicator
/// ─────────────────────────────────────────────────────────────────────────────
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
    final color = isActive ? AppColors.success : AppColors.textHint;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color.withOpacity(0.08),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pulsing status dot
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            isActive ? activeLabel : inactiveLabel,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// Table Action Buttons — Animated icon set with hover effects
/// ─────────────────────────────────────────────────────────────────────────────
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
          const SizedBox(width: 6),
        ],
        if (onAddVideo != null) ...[
          _ActionIcon(
            icon: Icons.video_call_rounded,
            tooltip: addVideoTooltip,
            color: AppColors.primary,
            onPressed: onAddVideo!,
          ),
          const SizedBox(width: 6),
        ],
        _ActionIcon(
          icon: Icons.edit_rounded,
          tooltip: editTooltip,
          color: AppColors.info,
          onPressed: onEdit,
        ),
        const SizedBox(width: 6),
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
            width: 36,
            height: 36,
            transform: Matrix4.identity()
              ..scale(_hovered ? 1.12 : 1.0),
            transformAlignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: _hovered
                  ? widget.color.withOpacity(0.1)
                  : Colors.transparent,
              border: _hovered
                  ? Border.all(
                      color: widget.color.withOpacity(0.2),
                    )
                  : null,
              boxShadow: _hovered
                  ? [
                      BoxShadow(
                        color: widget.color.withOpacity(0.12),
                        blurRadius: 12,
                        spreadRadius: -4,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              widget.icon,
              color: _hovered ? widget.color : AppColors.textHint,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}
