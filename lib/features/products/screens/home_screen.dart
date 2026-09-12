import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../notifications/providers/notifications_provider.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../providers/products_provider.dart';
import '../widgets/home_banner.dart';
import '../widgets/product_card.dart';
import '../widgets/section_title.dart';
import '../widgets/ticker_bar.dart';
import 'category_products_screen.dart';

/// الصفحة الرئيسية: الشريط المتحرك + بانرات + تصنيفات + مميزة + وصل حديثاً.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  IconData _categoryIcon(String id) => switch (id) {
        'cat_shoes' => Icons.snowshoeing_outlined,
        'cat_bags' => Icons.shopping_bag_outlined,
        'cat_sunglasses' => Icons.visibility_outlined,
        'cat_accessories' => Icons.diamond_outlined,
        _ => Icons.category_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductsProvider>();
    final unread = context.watch<NotificationsProvider>().unreadCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('M O D A'),
        actions: [
          IconButton(
            tooltip: 'الإشعارات',
            icon: Badge(
              isLabelVisible: unread > 0,
              label: Text('$unread'),
              backgroundColor: Colors.white,
              textColor: Colors.black,
              child: const Icon(Icons.notifications_outlined),
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const NotificationsScreen(),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.load(force: true),
        child: provider.loading && !provider.loaded
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  // الشريط المتحرك (يتحكم فيه الأدمن من الإعدادات)
                  const TickerBar(),
                  const HomeBanner(),
                  const SizedBox(height: 16),
                  // التصنيفات
                  const SectionTitle(title: 'التصنيفات'),
                  SizedBox(
                    height: 106,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: provider.rootCategories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final category = provider.rootCategories[index];
                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CategoryProductsScreen(
                                categoryId: category.id,
                                categoryName: category.name,
                              ),
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  _categoryIcon(category.id),
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                width: 82,
                                child: Text(
                                  category.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  // منتجات مميزة
                  const SectionTitle(title: 'منتجات مميزة'),
                  SizedBox(
                    height: kProductCardListHeight,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: provider.featured.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) => ProductCard(
                        product: provider.featured[index],
                        width: 170,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // عروض وخصومات
                  if (provider.discounted.isNotEmpty) ...[
                    const SectionTitle(title: 'عروض وخصومات'),
                    SizedBox(
                      height: kProductCardListHeight,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: provider.discounted.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, index) => ProductCard(
                          product: provider.discounted[index],
                          width: 170,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  // وصل حديثاً
                  const SectionTitle(title: 'وصل حديثاً'),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: kProductGridAspectRatio,
                    ),
                    itemCount: provider.newArrivals.length,
                    itemBuilder: (context, index) =>
                        ProductCard(product: provider.newArrivals[index]),
                  ),
                  if (provider.error != null)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        provider.error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppTheme.grey),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
