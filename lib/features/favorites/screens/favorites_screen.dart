import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/empty_view.dart';
import '../../products/providers/products_provider.dart';
import '../../products/widgets/product_card.dart';
import '../providers/favorites_provider.dart';

/// قائمة المفضلة.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final products = context.watch<ProductsProvider>();

    final items = products.products
        .where((p) => favorites.isFavorite(p.id))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('المفضلة')),
      body: items.isEmpty
          ? const EmptyView(
              icon: Icons.favorite_border,
              title: 'قائمة المفضلة فاضية',
              subtitle: 'اضغط على ♡ في أي منتج عشان تحفظه هنا',
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) =>
                  ProductCard(product: items[index]),
            ),
    );
  }
}
