import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dashboard/core/theme/app_theme.dart';
import 'package:dashboard/core/l10n/app_localizations.dart';
import 'package:dashboard/core/models/store_item.dart';
import 'package:dashboard/core/services/firestore_service.dart';
import 'package:dashboard/core/widgets/glass_data_table.dart';
import 'package:dashboard/core/widgets/glass_dialog.dart';
import 'package:dashboard/core/widgets/empty_state_widget.dart';
import 'package:dashboard/core/widgets/shimmer_loading.dart';
import 'package:dashboard/core/widgets/animated_snackbar.dart';

/// CRUD page for managing store/reward items.
class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  final _firestoreService = FirestoreService();

  void _showAddEditDialog({StoreItem? item}) {
    final s = S.of(context);
    final titleCtrl = TextEditingController(text: item?.title ?? '');
    final pointsCtrl = TextEditingController(
        text: item?.requiredPoints.toString() ?? '0');
    final linkCtrl = TextEditingController(text: item?.downloadLink ?? '');
    final imageCtrl =
        TextEditingController(text: item?.coverImageUrl ?? '');
    bool isActive = item?.isActive ?? true;
    bool isLoading = false;
    final formKey = GlobalKey<FormState>();

    showGlassDialog(
      context: context,
      title: item == null ? s.addItem : s.editItem,
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
                    labelText: s.itemTitle,
                    prefixIcon: Icon(
                      Icons.storefront_rounded,
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
                  controller: pointsCtrl,
                  decoration: InputDecoration(
                    labelText: s.requiredPoints,
                    prefixIcon: Icon(
                      Icons.stars_rounded,
                      color: AppColors.neonYellow,
                      size: 20,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: AppColors.textPrimary),
                  validator: (v) {
                    if (v == null || v.isEmpty) return s.requiredField;
                    final n = int.tryParse(v);
                    if (n == null || n < 0) return s.pointsValidation;
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: linkCtrl,
                  decoration: InputDecoration(
                    labelText: s.downloadLink,
                    prefixIcon: Icon(
                      Icons.link_rounded,
                      color: AppColors.secondary,
                      size: 20,
                    ),
                  ),
                  style: TextStyle(color: AppColors.textPrimary),
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
                  final storeItem = StoreItem(
                    id: item?.id ?? '',
                    title: titleCtrl.text.trim(),
                    requiredPoints:
                        int.tryParse(pointsCtrl.text) ?? 0,
                    downloadLink: linkCtrl.text.trim(),
                    coverImageUrl: imageCtrl.text.trim(),
                    isActive: isActive,
                  );
                  if (item == null) {
                    await _firestoreService.addStoreItem(storeItem);
                    if (mounted) {
                      Navigator.of(context).pop();
                      showAnimatedSnackBar(context, message: s.itemAdded);
                    }
                  } else {
                    await _firestoreService.updateStoreItem(storeItem);
                    if (mounted) {
                      Navigator.of(context).pop();
                      showAnimatedSnackBar(context,
                          message: s.itemUpdated);
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

  void _handleDelete(StoreItem item) async {
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
        await _firestoreService.deleteStoreItem(item.id);
        if (mounted) {
          showAnimatedSnackBar(context, message: s.itemDeleted);
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
            child: StreamBuilder<List<StoreItem>>(
              stream: _firestoreService.storeItemsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    children: List.generate(
                        5, (_) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: ShimmerTableRow(columns: 5),
                            )),
                  );
                }

                final items = snapshot.data ?? [];

                if (items.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.storefront_rounded,
                    title: s.noItems,
                    subtitle: s.isArabic
                        ? 'ابدأ بإضافة أول عنصر للمتجر'
                        : 'Start by adding the first store item',
                    actionLabel: s.addItem,
                    onAction: () => _showAddEditDialog(),
                  );
                }

                return SingleChildScrollView(
                  child: GlassDataTable(
                    columns: [
                      s.itemTitle,
                      s.requiredPoints,
                      s.downloadLink,
                      s.isActive,
                      s.actions,
                    ],
                    rows: items.map((item) {
                      return GlassTableRow(
                        id: item.id,
                        cells: [
                          Row(
                            children: [
                              if (item.coverImageUrl.isNotEmpty)
                                Container(
                                  width: 32,
                                  height: 32,
                                  margin: const EdgeInsets.only(left: 8),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          item.coverImageUrl),
                                      fit: BoxFit.cover,
                                      onError: (e, st) {},
                                    ),
                                  ),
                                ),
                              if (item.coverImageUrl.isNotEmpty)
                                const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          // Points badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: AppColors.neonYellow
                                  .withValues(alpha: 0.12),
                              border: Border.all(
                                color: AppColors.neonYellow
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.stars_rounded,
                                    color: AppColors.neonYellow,
                                    size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '${item.requiredPoints}',
                                  style: TextStyle(
                                    color: AppColors.neonYellow,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Download link
                          item.downloadLink.isNotEmpty
                              ? Tooltip(
                                  message: item.downloadLink,
                                  child: Icon(
                                    Icons.link_rounded,
                                    color: AppColors.secondary,
                                    size: 18,
                                  ),
                                )
                              : Text('—',
                                  style: TextStyle(
                                      color: AppColors.textMuted)),
                          StatusBadge(
                            isActive: item.isActive,
                            activeLabel: s.active,
                            inactiveLabel: s.inactive,
                          ),
                          TableActionButtons(
                            editTooltip: s.edit,
                            deleteTooltip: s.delete,
                            onEdit: () =>
                                _showAddEditDialog(item: item),
                            onDelete: () => _handleDelete(item),
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
              colors: AppColors.gradientOrange,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          s.store,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const Spacer(),
        _AddButton(
          label: s.addItem,
          onPressed: () => _showAddEditDialog(),
          gradient: AppColors.gradientOrange,
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
                color: widget.gradient.first
                    .withValues(alpha: _hovered ? 0.4 : 0.2),
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
