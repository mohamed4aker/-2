import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/empty_view.dart';
import '../providers/products_provider.dart';
import '../widgets/product_card.dart';

/// البحث + الفلترة بالتصنيف والسعر.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String? _selectedCategoryId;
  RangeValues? _priceRange;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductsProvider>();
    final maxPrice = provider.maxPrice;
    final stored = _priceRange ?? RangeValues(0, maxPrice);
    final range = RangeValues(
      stored.start.clamp(0, maxPrice),
      stored.end.clamp(0, maxPrice),
    );

    final results = provider.search(
      query: _searchController.text,
      categoryId: _selectedCategoryId,
      minPrice: range.start,
      maxPrice: range.end,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('البحث')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'ابحثي عن منتج...',
                prefixIcon: const Icon(Icons.search, color: Colors.black54),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      ),
              ),
            ),
          ),
          // فلتر التصنيفات
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ChoiceChip(
                    label: const Text('الكل'),
                    selected: _selectedCategoryId == null,
                    onSelected: (_) =>
                        setState(() => _selectedCategoryId = null),
                  ),
                ),
                ...provider.categories.map(
                  (category) => Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ChoiceChip(
                      label: Text(category.name),
                      selected: _selectedCategoryId == category.id,
                      onSelected: (_) => setState(
                          () => _selectedCategoryId = category.id),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // فلتر السعر
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  formatPrice(range.start),
                  style: const TextStyle(fontSize: 12),
                ),
                Expanded(
                  child: RangeSlider(
                    values: range,
                    min: 0,
                    max: maxPrice,
                    activeColor: Colors.black,
                    inactiveColor: Colors.black26,
                    onChanged: (values) =>
                        setState(() => _priceRange = values),
                  ),
                ),
                Text(
                  formatPrice(range.end),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? const EmptyView(
                    icon: Icons.search_off,
                    title: 'لا توجد نتائج',
                    subtitle: 'جربي كلمة بحث أو فلتر مختلف',
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: results.length,
                    itemBuilder: (context, index) =>
                        ProductCard(product: results[index]),
                  ),
          ),
        ],
      ),
    );
  }
}
