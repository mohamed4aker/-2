import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/product_image.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../favorites/providers/favorites_provider.dart';
import '../../orders/providers/orders_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../data/models/product.dart';
import '../data/recommendation_engine.dart';
import '../providers/products_provider.dart';
import '../providers/reviews_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/review_section.dart';

/// تفاصيل المنتج: معرض صور + الأسعار قبل وبعد الخصم + مقاسات + ألوان
/// + منتجات مقترحة تكمّل الإطلالة + تقييمات.
class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key, required this.productId});

  final String productId;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final _pageController = PageController();
  int _currentImage = 0;
  String? _selectedSize;
  String? _selectedColor;
  int _quantity = 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _addToCart() {
    final product =
        context.read<ProductsProvider>().productById(widget.productId);
    if (product == null) return;

    if (product.sizes.isNotEmpty && _selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر المقاس أولاً')),
      );
      return;
    }
    if (product.colors.isNotEmpty && _selectedColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر اللون أولاً')),
      );
      return;
    }

    context.read<CartProvider>().addToCart(
          product,
          quantity: _quantity,
          size: _selectedSize,
          color: _selectedColor,
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تمت الإضافة إلى السلة')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductsProvider>();
    final product = provider.productById(widget.productId);
    final favorites = context.watch<FavoritesProvider>();
    final settings = context.watch<SettingsProvider>().settings;
    final reviews = context.watch<ReviewsProvider>();

    if (product == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('المنتج غير موجود')),
      );
    }

    // المنتجات المقترحة (كمّل إطلالتك)
    final List<Product> suggestions = settings.recommendationsEnabled
        ? RecommendationEngine.suggestFor(
            product,
            allProducts: provider.products,
            orders: context.watch<OrdersProvider>().allOrders,
            auto: settings.recommendationsAuto,
          )
        : const [];

    final rating = reviews.averageFor(product.id);
    final reviewsCount = reviews.countFor(product.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name, maxLines: 1),
        actions: [
          IconButton(
            tooltip: 'المفضلة',
            icon: Icon(
              favorites.isFavorite(product.id)
                  ? Icons.favorite
                  : Icons.favorite_border,
            ),
            onPressed: () => favorites.toggle(product.id),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // ---------- معرض الصور ----------
                SizedBox(
                  height: 340,
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount:
                            product.images.isEmpty ? 1 : product.images.length,
                        onPageChanged: (i) =>
                            setState(() => _currentImage = i),
                        itemBuilder: (context, index) => ProductImage(
                          path: product.images.isEmpty
                              ? ''
                              : product.images[index],
                        ),
                      ),
                      if (product.hasDiscount)
                        PositionedDirectional(
                          top: 12,
                          start: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            color: Colors.black,
                            child: Text(
                              'وفّر ${product.discountPercent}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      if (product.images.length > 1)
                        Positioned(
                          bottom: 12,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:
                                List.generate(product.images.length, (i) {
                              final active = i == _currentImage;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                width: active ? 20 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color:
                                      active ? Colors.black : Colors.black26,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.white),
                                ),
                              );
                            }),
                          ),
                        ),
                    ],
                  ),
                ),

                // ---------- نفس المنتج بألوان تانية ----------
                _VariantsRow(product: product),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              provider.categoryName(product.categoryId),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),

                      if (settings.reviewsEnabled && reviewsCount > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ...List.generate(
                              5,
                              (i) => Icon(
                                i < rating.round()
                                    ? Icons.star
                                    : Icons.star_border,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${rating.toStringAsFixed(1)} ($reviewsCount تقييم)',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.grey,
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 12),

                      // ---------- السعر قبل وبعد الخصم ----------
                      if (product.hasDiscount)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.black, width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'السعر قبل الخصم',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.grey,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    formatPrice(product.price),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: AppTheme.grey,
                                      decoration:
                                          TextDecoration.lineThrough,
                                      decorationThickness: 2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Text(
                                    'السعر بعد الخصم',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    formatPrice(product.finalPrice),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 20),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8),
                                color: Colors.black,
                                child: Text(
                                  'بتوفّر ${formatPrice(product.price - product.finalPrice)} '
                                  '(${product.discountPercent}%)',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Text(
                          formatPrice(product.finalPrice),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                      const SizedBox(height: 12),
                      Text(
                        product.inStock
                            ? 'متوفر (${product.stock} قطعة)'
                            : 'نفدت الكمية',
                        style: TextStyle(
                          color:
                              product.inStock ? AppTheme.grey : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Divider(height: 32),
                      Text(
                        product.description,
                        style: const TextStyle(height: 1.8, fontSize: 14),
                      ),

                      if (product.sizes.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'المقاس',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: product.sizes
                              .map(
                                (size) => ChoiceChip(
                                  label: Text(size),
                                  selected: _selectedSize == size,
                                  onSelected: (_) =>
                                      setState(() => _selectedSize = size),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                      if (product.colors.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'اللون',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: product.colors
                              .map(
                                (color) => ChoiceChip(
                                  label: Text(color),
                                  selected: _selectedColor == color,
                                  onSelected: (_) =>
                                      setState(() => _selectedColor = color),
                                ),
                              )
                              .toList(),
                        ),
                      ],

                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Text(
                            'الكمية',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          _QuantityButton(
                            icon: Icons.remove,
                            onTap: _quantity > 1
                                ? () => setState(() => _quantity--)
                                : null,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '$_quantity',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          _QuantityButton(
                            icon: Icons.add,
                            onTap: _quantity < product.stock
                                ? () => setState(() => _quantity++)
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ---------- كمّل إطلالتك ----------
                if (suggestions.isNotEmpty) ...[
                  const Divider(height: 8, thickness: 8,
                      color: AppTheme.lightGrey),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        Container(width: 4, height: 20, color: Colors.black),
                        const SizedBox(width: 8),
                        const Text(
                          'كمّل إطلالتك',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'قطع تتماشى مع المنتج ده',
                      style: TextStyle(fontSize: 12, color: AppTheme.grey),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: kProductCardListHeight,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: suggestions.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) => ProductCard(
                        product: suggestions[index],
                        width: 170,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // ---------- التقييمات ----------
                if (settings.reviewsEnabled) ...[
                  const Divider(height: 8, thickness: 8,
                      color: AppTheme.lightGrey),
                  ReviewSection(
                    productId: product.id,
                    canWrite:
                        context.watch<AuthProvider>().isLoggedIn,
                  ),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),

          // ---------- شريط الإضافة للسلة ----------
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppTheme.border)),
              ),
              child: AppButton(
                label: product.inStock
                    ? 'إضافة إلى السلة · ${formatPrice(product.finalPrice * _quantity)}'
                    : 'نفدت الكمية',
                icon: Icons.shopping_bag_outlined,
                onPressed: product.inStock ? _addToCart : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// شريط ألوان نفس المنتج — بيظهر تحت الصورة الكبيرة على طول.
///
/// كل لون منتج مستقل عنده صوره وسعره ومخزونه، ولما العميل يدوس على لون
/// بيتنقل لصفحة اللون ده.
class _VariantsRow extends StatelessWidget {
  const _VariantsRow({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final variants = context.watch<ProductsProvider>().variantGroupOf(product);

    // مفيش ألوان تانية → مفيش شريط.
    if (variants.length < 2) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            children: [
              Container(width: 4, height: 18, color: Colors.black),
              const SizedBox(width: 8),
              const Text(
                'نفس المنتج بألوان تانية',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Text(
                '${variants.length} ألوان',
                style: const TextStyle(fontSize: 12, color: AppTheme.grey),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 116,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: variants.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final variant = variants[index];
              final selected = variant.id == product.id;

              return InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: selected
                    ? null
                    : () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailsScreen(productId: variant.id),
                          ),
                        ),
                child: SizedBox(
                  width: 78,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 78,
                        height: 84,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selected ? Colors.black : AppTheme.border,
                            width: selected ? 2.5 : 1,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ProductImage(path: variant.mainImage),
                            if (!variant.inStock)
                              Container(
                                color: Colors.white70,
                                alignment: Alignment.center,
                                child: const Text(
                                  'نفدت',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        variant.displayColor,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              selected ? FontWeight.w800 : FontWeight.w500,
                          color: selected ? Colors.black : AppTheme.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          border: Border.all(
            color: onTap == null ? Colors.black26 : Colors.black,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: onTap == null ? Colors.black26 : Colors.black,
        ),
      ),
    );
  }
}
