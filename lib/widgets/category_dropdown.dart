import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/categories_provider.dart';
import '../models/category_model.dart';
import '../core/constants/app_colors.dart';

/// Smart category dropdown that loads from Firestore + Quick Add button.
class CategoryDropdown extends StatelessWidget {
  final String selectedCategoryId;
  final ValueChanged<String> onChanged;

  const CategoryDropdown({
    super.key,
    required this.selectedCategoryId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoriesProvider>();
    final categories = provider.activeCategories;

    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: selectedCategoryId.isNotEmpty &&
                    categories.any((c) => c.id == selectedCategoryId)
                ? selectedCategoryId
                : null,
            decoration: const InputDecoration(labelText: 'الفئة'),
            items: categories.map((cat) {
              return DropdownMenuItem(
                value: cat.id,
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _hexToColor(cat.colorHex)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        _getIcon(cat.icon),
                        size: 14,
                        color: _hexToColor(cat.colorHex),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(cat.name),
                  ],
                ),
              );
            }).toList(),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
            validator: (v) => v == null ? 'يرجى اختيار فئة' : null,
          ),
        ),
        const SizedBox(width: 8),
        // ── Quick Add Button ──
        Tooltip(
          message: 'إضافة فئة جديدة',
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _showQuickAdd(context),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.add,
                color: AppColors.primary,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showQuickAdd(BuildContext context) {
    final nameC = TextEditingController();
    final nameEnC = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة فئة سريعة'),
        content: SizedBox(
          width: 350,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameC,
                decoration: const InputDecoration(
                  labelText: 'اسم الفئة (عربي)',
                  hintText: 'مثال: الذكاء الاصطناعي',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameEnC,
                decoration: const InputDecoration(
                  labelText: 'اسم الفئة (إنجليزي)',
                  hintText: 'e.g. Artificial Intelligence',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameC.text.trim().isEmpty) return;
              final provider = context.read<CategoriesProvider>();
              final newCat = await provider.createCategory(CategoryModel(
                id: '',
                name: nameC.text.trim(),
                nameEn: nameEnC.text.trim(),
                sortOrder: provider.categories.length,
              ));
              if (newCat != null) {
                onChanged(newCat.id);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('إنشاء وتحديد'),
          ),
        ],
      ),
    );
  }

  static Color _hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  static IconData _getIcon(String name) {
    const map = {
      'category': Icons.category_rounded,
      'computer': Icons.computer_rounded,
      'calculate': Icons.calculate_rounded,
      'science': Icons.science_rounded,
      'business_center': Icons.business_center_rounded,
      'engineering': Icons.engineering_rounded,
      'medical_services': Icons.medical_services_rounded,
      'design_services': Icons.design_services_rounded,
      'language': Icons.language_rounded,
      'psychology': Icons.psychology_rounded,
      'architecture': Icons.architecture_rounded,
      'palette': Icons.palette_rounded,
      'music_note': Icons.music_note_rounded,
      'gavel': Icons.gavel_rounded,
    };
    return map[name] ?? Icons.category_rounded;
  }
}
