import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/product_image.dart';
import '../data/models/product_category.dart';
import '../providers/products_provider.dart';
import '../widgets/product_card.dart';

/// شاشة التصنيف.
///
/// لو التصنيف جواه تصنيفات فرعية (زي "رجالي" جواها "أحذية" و"شنط")
/// بتعرض التصنيفات الفرعية الأول، والعميل يدوس على واحد يدخل على منتجاته.
/// ولو مفيش فروع، بتعرض المنتجات على طول.
class CategoryProductsScreen extends StatelessWidget {
  const CategoryProductsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  final String categoryId;
  final String categoryName;

  IconData _iconFor(String id) => switch (id) {
        'cat_shoes' => Icons.snowshoeing_outlined,
        'cat_bags' => Icons.shopping_bag_outlined,
        'cat_sunglasses' => Icons.visibility_outlined,
        'cat_accessories' => Icons.diamond_outlined,
        _ => Icons.category_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductsProvider>();
    final children = provider.childrenOf(categoryId);
    final products = provider.byCategory(categoryId);

    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      body: children.isNotEmpty
          ? _SubCategoriesView(
              parentId: categoryId,
              children: children,
              iconFor: _iconFor,
            )
          : products.isEmpty
              ? const EmptyView(
                  icon: Icons.inventory_2_outlined,
                  title: 'لا توجد منتجات في هذا التصنيف حالياً',
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: kProductGridAspectRatio,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) =>
                      ProductCard(product: products[index]),
                ),
    );
  }
}

/// شبكة التصنيفات الفرعية + زر لعرض كل منتجات القسم مجمّعة.
class _SubCategoriesView extends StatelessWidget {
  const _SubCategoriesView({
    required this.parentId,
    required this.children,
    required this.iconFor,
  });

  final String parentId;
  final List<ProductCategory> children;
  final IconData Function(String) iconFor;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductsProvider>();
    final allProducts = provider.byCategory(parentId);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'اختر القسم',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.05,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) {
            final child = children[index];
            final count = provider.productsCountIn(child.id);
            final hasSubs = provider.hasChildren(child.id);

            return InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CategoryProductsScreen(
                    categoryId: child.id,
                    categoryName: child.name,
                  ),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.border),
                  borderRadius: BorderRadius.circular(14),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    Expanded(
                      child: SizedBox(
                        width: double.infinity,
                        child: child.image != null &&
                                child.image!.isNotEmpty
                            ? ProductImage(path: child.image!)
                            : Container(
                                color: AppTheme.lightGrey,
                                alignment: Alignment.center,
                                child: Icon(
                                  iconFor(child.id),
                                  size: 40,
                                  color: Colors.black87,
                                ),
                              ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                      child: Column(
                        children: [
                          Text(
                            child.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            hasSubs
                                ? '${provider.childrenOf(child.id).length} أقسام'
                                : '$count منتج',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        // ---------- كل منتجات القسم مع بعض ----------
        if (allProducts.isNotEmpty) ...[
          const SizedBox(height: 24),
          Row(
            children: [
              Container(width: 4, height: 20, color: Colors.black),
              const SizedBox(width: 8),
              Text(
                'كل المنتجات (${allProducts.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: kProductGridAspectRatio,
            ),
            itemCount: allProducts.length,
            itemBuilder: (context, index) =>
                ProductCard(product: allProducts[index]),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}
