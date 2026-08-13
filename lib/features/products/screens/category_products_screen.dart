import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/empty_view.dart';
import '../providers/products_provider.dart';
import '../widgets/product_card.dart';

/// منتجات تصنيف واحد.
class CategoryProductsScreen extends StatelessWidget {
  const CategoryProductsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  final String categoryId;
  final String categoryName;

  @override
  Widget build(BuildContext context) {
    final products =
        context.watch<ProductsProvider>().byCategory(categoryId);

    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      body: products.isEmpty
          ? const EmptyView(
              icon: Icons.inventory_2_outlined,
              title: 'لا توجد منتجات في هذا التصنيف حالياً',
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
