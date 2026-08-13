import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/product_image.dart';
import '../../favorites/providers/favorites_provider.dart';
import '../data/models/product.dart';
import '../screens/product_details_screen.dart';

/// الارتفاع الموصى به للقوائم الأفقية اللي بتعرض [ProductCard].
const double kProductCardListHeight = 285;

/// نسبة العرض للارتفاع في الشبكات (GridView).
const double kProductGridAspectRatio = 0.60;

/// كارت منتج: صورة كبيرة + اسم + سعر (مع الخصم إن وجد).
///
/// الصورة بتاخد نسبة ثابتة والباقي في [Expanded] عشان الكارت
/// ميعملش overflow مهما كان حجم الخط أو الشاشة.
class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, this.width});

  final Product product;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProductDetailsScreen(productId: product.id),
        ),
      ),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- الصورة ----------
            Flexible(
              flex: 5,
              child: SizedBox(
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ProductImage(path: product.mainImage),
                    if (product.hasDiscount)
                      PositionedDirectional(
                        top: 8,
                        end: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          color: Colors.black,
                          child: Text(
                            'خصم ${product.discountPercent}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    if (!product.inStock)
                      Container(
                        color: const Color(0xB3FFFFFF),
                        alignment: Alignment.center,
                        child: const Text(
                          'نفدت الكمية',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    PositionedDirectional(
                      top: 4,
                      start: 4,
                      child: Consumer<FavoritesProvider>(
                        builder: (context, favorites, _) {
                          final isFav = favorites.isFavorite(product.id);
                          return InkWell(
                            onTap: () => favorites.toggle(product.id),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isFav
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 16,
                                color: Colors.black,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ---------- الاسم والسعر ----------
            Flexible(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          height: 1.2,
                        ),
                      ),
                    ),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              formatPrice(product.finalPrice),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                height: 1.2,
                              ),
                            ),
                            if (product.hasDiscount) ...[
                              const SizedBox(width: 6),
                              Text(
                                formatPrice(product.price),
                                style: const TextStyle(
                                  color: AppTheme.grey,
                                  fontSize: 11,
                                  height: 1.2,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
