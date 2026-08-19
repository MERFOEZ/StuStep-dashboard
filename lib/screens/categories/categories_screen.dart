import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/categories_provider.dart';
import '../../models/category_model.dart';
import '../../core/constants/app_colors.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoriesProvider>().fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoriesProvider>();

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${provider.categories.length} فئة',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showCategoryDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('إضافة فئة'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Categories Grid
          Expanded(
            child: provider.isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.primary))
                : provider.categories.isEmpty
                    ? _buildEmptyState()
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 2.2,
                        ),
                        itemCount: provider.categories.length,
                        itemBuilder: (context, index) {
                          return _buildCategoryCard(
                            context,
                            provider.categories[index],
                            provider,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_rounded,
            size: 64,
            color: AppColors.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'لا توجد فئات بعد',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'أنشئ أول فئة لتصنيف الكورسات',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    CategoryModel category,
    CategoriesProvider provider,
  ) {
    final color = _hexToColor(category.colorHex);
    final icon = _getIconData(category.icon);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: category.isActive
              ? color.withValues(alpha: 0.3)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      category.nameEn,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: category.isActive
                      ? AppColors.success.withValues(alpha: 0.15)
                      : AppColors.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  category.isActive ? 'مفعّل' : 'معطّل',
                  style: TextStyle(
                    color: category.isActive
                        ? AppColors.success
                        : AppColors.error,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                tooltip: 'تعديل',
                icon: const Icon(Icons.edit_outlined,
                    size: 18, color: AppColors.primary),
                onPressed: () =>
                    _showCategoryDialog(context, category: category),
              ),
              IconButton(
                tooltip: category.isActive ? 'تعطيل' : 'تفعيل',
                icon: Icon(
                  category.isActive
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18,
                  color: AppColors.warning,
                ),
                onPressed: () => provider.toggleActive(category.id),
              ),
              IconButton(
                tooltip: 'حذف',
                icon: const Icon(Icons.delete_outline,
                    size: 18, color: AppColors.error),
                onPressed: () => _confirmDelete(context, category, provider),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, {CategoryModel? category}) {
    final isEdit = category != null;
    final nameC = TextEditingController(text: category?.name ?? '');
    final nameEnC = TextEditingController(text: category?.nameEn ?? '');
    String selectedIcon = category?.icon ?? 'category';
    String selectedColor = category?.colorHex ?? '#6C5CE7';

    final icons = [
      'category', 'computer', 'calculate', 'science', 'business_center',
      'engineering', 'medical_services', 'design_services', 'language',
      'psychology', 'architecture', 'palette', 'music_note', 'gavel',
    ];

    final colors = [
      '#6C5CE7', '#00CEFF', '#00C853', '#FF5252', '#FFB300',
      '#FF6D00', '#AA00FF', '#2962FF', '#00BFA5', '#F50057',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'تعديل الفئة' : 'إضافة فئة جديدة'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameC,
                  decoration: const InputDecoration(
                    labelText: 'اسم الفئة (عربي)',
                    hintText: 'مثال: علوم الحاسوب',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameEnC,
                  decoration: const InputDecoration(
                    labelText: 'اسم الفئة (إنجليزي)',
                    hintText: 'e.g. Computer Science',
                  ),
                ),
                const SizedBox(height: 20),
                const Text('الأيقونة:',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: icons.map((iconName) {
                    final isSelected = selectedIcon == iconName;
                    return InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () =>
                          setDialogState(() => selectedIcon = iconName),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.2)
                              : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(10),
                          border: isSelected
                              ? Border.all(color: AppColors.primary, width: 2)
                              : null,
                        ),
                        child: Icon(
                          _getIconData(iconName),
                          size: 18,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textMuted,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                const Text('اللون:',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: colors.map((hex) {
                    final isSelected = selectedColor == hex;
                    return InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () =>
                          setDialogState(() => selectedColor = hex),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _hexToColor(hex),
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: _hexToColor(hex)
                                        .withValues(alpha: 0.5),
                                    blurRadius: 8,
                                  )
                                ]
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
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

                if (category != null) {
                  await provider.updateCategory(category.copyWith(
                    name: nameC.text.trim(),
                    nameEn: nameEnC.text.trim(),
                    icon: selectedIcon,
                    colorHex: selectedColor,
                  ));
                } else {
                  await provider.createCategory(CategoryModel(
                    id: '',
                    name: nameC.text.trim(),
                    nameEn: nameEnC.text.trim(),
                    icon: selectedIcon,
                    colorHex: selectedColor,
                    sortOrder: provider.categories.length,
                  ));
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(isEdit ? 'حفظ التعديلات' : 'إنشاء'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    CategoryModel category,
    CategoriesProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الفئة'),
        content: Text('هل أنت متأكد من حذف فئة "${category.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.deleteCategory(category.id);
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف'),
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

  static IconData _getIconData(String name) {
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
