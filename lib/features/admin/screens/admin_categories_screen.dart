import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_view.dart';
import '../../products/data/models/product_category.dart';
import '../../products/providers/products_provider.dart';

/// إدارة التصنيفات — بتدعم تصنيف جوه تصنيف.
///
/// مثال: تعمل تصنيف رئيسي اسمه "رجالي"، وتدوس على زرار "+ قسم فرعي"
/// اللي جنبه وتضيف جواه "أحذية" و"شنط". العميل لما يدوس على "رجالي"
/// هيلاقي الأقسام دي قدامه.
class AdminCategoriesScreen extends StatelessWidget {
  const AdminCategoriesScreen({super.key});

  /// نافذة إضافة / تعديل تصنيف.
  ///
  /// [parent] = التصنيف الأب لما نضيف قسم فرعي (null = تصنيف رئيسي).
  Future<void> _showCategoryDialog(
    BuildContext context, {
    ProductCategory? category,
    ProductCategory? parent,
  }) async {
    final controller = TextEditingController(text: category?.name ?? '');
    final isEdit = category != null;

    final title = isEdit
        ? 'تعديل التصنيف'
        : parent == null
            ? 'تصنيف رئيسي جديد'
            : 'قسم جديد داخل "${parent.name}"';

    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(title, style: const TextStyle(fontSize: 17)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isEdit && parent == null)
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  'التصنيف الرئيسي بيظهر في الصفحة الرئيسية للعميل، '
                  'وتقدر تضيف جواه أقسام بعد كده.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.grey,
                    height: 1.6,
                  ),
                ),
              ),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'اسم التصنيف'),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  Navigator.of(dialogContext).pop(value.trim());
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                Navigator.of(dialogContext).pop(value);
              }
            },
            child: const Text(
              'حفظ',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );

    if (name == null || !context.mounted) return;
    final provider = context.read<ProductsProvider>();
    if (isEdit) {
      await provider.updateCategory(category.copyWith(name: name));
    } else {
      await provider.addCategory(name, parentId: parent?.id);
    }
  }

  Future<void> _delete(
      BuildContext context, ProductCategory category) async {
    final provider = context.read<ProductsProvider>();
    final childrenCount = provider.childrenOf(category.id).length;
    final productsCount = provider.productsCountIn(category.id);

    // بنمنع الحذف قبل ما نفتح النافذة أصلاً، عشان نقول له السبب.
    if (childrenCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'مينفعش تحذف "${category.name}" وجواه $childrenCount أقسام — '
            'احذف الأقسام اللي جواه الأول',
          ),
        ),
      );
      return;
    }
    if (productsCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'مينفعش تحذف "${category.name}" وفيه $productsCount منتج — '
            'انقل المنتجات أو احذفها الأول',
          ),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('حذف التصنيف'),
        content: Text('تحذف تصنيف "${category.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'حذف',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final ok = await provider.deleteCategory(category.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'تم حذف التصنيف' : 'تعذر حذف التصنيف'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductsProvider>();
    final roots = provider.rootCategories;

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_category',
        onPressed: () => _showCategoryDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('تصنيف رئيسي'),
      ),
      body: roots.isEmpty
          ? const EmptyView(
              icon: Icons.category_outlined,
              title: 'مفيش تصنيفات لسه',
              subtitle: 'أضف أول تصنيف بالزر بالأسفل',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: roots.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _CategoryTile(
                category: roots[index],
                onEdit: (c) => _showCategoryDialog(context, category: c),
                onDelete: (c) => _delete(context, c),
                onAddChild: (c) => _showCategoryDialog(context, parent: c),
              ),
            ),
    );
  }
}

/// كارت التصنيف الرئيسي + الأقسام اللي جواه.
class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.onEdit,
    required this.onDelete,
    required this.onAddChild,
  });

  final ProductCategory category;
  final void Function(ProductCategory) onEdit;
  final void Function(ProductCategory) onDelete;
  final void Function(ProductCategory) onAddChild;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductsProvider>();
    final children = provider.childrenOf(category.id);
    final productsCount = provider.productsCountIn(category.id);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- التصنيف الرئيسي ----------
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(12, 6, 4, 0),
            leading: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                category.name.characters.first,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ),
            title: Text(
              category.name,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(
              children.isEmpty
                  ? '$productsCount منتج'
                  : '${children.length} أقسام · $productsCount منتج',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'تعديل الاسم',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => onEdit(category),
                ),
                IconButton(
                  tooltip: 'حذف',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => onDelete(category),
                ),
              ],
            ),
          ),

          // ---------- الأقسام اللي جواه ----------
          if (children.isNotEmpty)
            Padding(
              padding: const EdgeInsetsDirectional.only(
                start: 24,
                end: 8,
                top: 4,
              ),
              child: Column(
                children: children
                    .map(
                      (child) => _SubCategoryRow(
                        category: child,
                        productsCount: provider.productsCountIn(child.id),
                        onEdit: onEdit,
                        onDelete: onDelete,
                      ),
                    )
                    .toList(),
              ),
            ),

          // ---------- زرار إضافة قسم فرعي ----------
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: () => onAddChild(category),
                icon: const Icon(Icons.add, size: 18),
                label: const Text(
                  'إضافة قسم داخل ده',
                  style: TextStyle(fontSize: 13),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// صف القسم الفرعي جوه كارت التصنيف الرئيسي.
class _SubCategoryRow extends StatelessWidget {
  const _SubCategoryRow({
    required this.category,
    required this.productsCount,
    required this.onEdit,
    required this.onDelete,
  });

  final ProductCategory category;
  final int productsCount;
  final void Function(ProductCategory) onEdit;
  final void Function(ProductCategory) onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.subdirectory_arrow_left, size: 16,
            color: AppTheme.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              Text(
                '$productsCount منتج',
                style: const TextStyle(fontSize: 11, color: AppTheme.grey),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'تعديل الاسم',
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.edit_outlined, size: 18),
          onPressed: () => onEdit(category),
        ),
        IconButton(
          tooltip: 'حذف',
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.delete_outline, size: 18),
          onPressed: () => onDelete(category),
        ),
      ],
    );
  }
}
