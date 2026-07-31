import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/product_image.dart';
import '../../cart/providers/cart_provider.dart';
import '../providers/products_provider.dart';

/// تفاصيل المنتج: معرض صور + مقاسات + ألوان + إضافة للسلة.
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
        const SnackBar(content: Text('اختاري المقاس أولاً')),
      );
      return;
    }
    if (product.colors.isNotEmpty && _selectedColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختاري اللون أولاً')),
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

    if (product == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('المنتج غير موجود')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(product.name, maxLines: 1)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // معرض الصور
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
                                  border:
                                      Border.all(color: Colors.white),
                                ),
                              );
                            }),
                          ),
                        ),
                    ],
                  ),
                ),
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
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            formatPrice(product.finalPrice),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (product.hasDiscount) ...[
                            const SizedBox(width: 12),
                            Text(
                              formatPrice(product.price),
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppTheme.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              color: Colors.black,
                              child: Text(
                                'خصم ${product.discountPercent}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.inStock
                            ? 'متوفر (${product.stock} قطعة)'
                            : 'نفدت الكمية',
                        style: TextStyle(
                          color: product.inStock
                              ? AppTheme.grey
                              : Colors.black,
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
                                  onSelected: (_) => setState(
                                      () => _selectedSize = size),
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
                                  onSelected: (_) => setState(
                                      () => _selectedColor = color),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                      const SizedBox(height: 20),
                      // الكمية
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
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // شريط الإضافة للسلة
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
