import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/product_image.dart';
import '../../products/data/models/product.dart';
import '../../products/providers/products_provider.dart';

/// نموذج إضافة / تعديل منتج مع اختيار صور من المعرض أو الكاميرا.
class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.product});

  /// عند null: إضافة منتج جديد، وإلا تعديل المنتج الموجود.
  final Product? product;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _discountController;
  late final TextEditingController _sizesController;
  late final TextEditingController _colorsController;
  late final TextEditingController _stockController;

  String? _categoryId;
  bool _isFeatured = false;
  late List<String> _images;
  bool _saving = false;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _descriptionController =
        TextEditingController(text: p?.description ?? '');
    _priceController =
        TextEditingController(text: p == null ? '' : '${p.price}');
    _discountController = TextEditingController(
        text: p?.discountPrice == null ? '' : '${p!.discountPrice}');
    _sizesController =
        TextEditingController(text: p?.sizes.join('، ') ?? '');
    _colorsController =
        TextEditingController(text: p?.colors.join('، ') ?? '');
    _stockController =
        TextEditingController(text: p == null ? '' : '${p.stock}');
    _categoryId = p?.categoryId;
    _isFeatured = p?.isFeatured ?? false;
    _images = List.of(p?.images ?? const []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _sizesController.dispose();
    _colorsController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    final picked = await _picker.pickMultiImage(imageQuality: 85);
    if (picked.isEmpty) return;
    setState(() => _images.addAll(picked.map((x) => x.path)));
  }

  Future<void> _pickFromCamera() async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() => _images.add(picked.path));
  }

  List<String> _splitList(String text) => text
      .split(RegExp(r'[،,]'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختاري التصنيف')),
      );
      return;
    }
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أضيفي صورة واحدة على الأقل')),
      );
      return;
    }

    final price = double.parse(_priceController.text.trim());
    final discountText = _discountController.text.trim();
    final discount =
        discountText.isEmpty ? null : double.parse(discountText);

    if (discount != null && discount >= price) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('سعر الخصم يجب أن يكون أقل من السعر الأساسي')),
      );
      return;
    }

    final product = Product(
      id: widget.product?.id ??
          'p_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: price,
      discountPrice: discount,
      categoryId: _categoryId!,
      sizes: _splitList(_sizesController.text),
      colors: _splitList(_colorsController.text),
      stock: int.parse(_stockController.text.trim()),
      images: _images,
      isFeatured: _isFeatured,
      createdAt: widget.product?.createdAt ?? DateTime.now(),
    );

    setState(() => _saving = true);
    try {
      final provider = context.read<ProductsProvider>();
      if (_isEdit) {
        await provider.updateProduct(product);
      } else {
        await provider.addProduct(product);
      }
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(_isEdit ? 'تم تحديث المنتج' : 'تمت إضافة المنتج'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _numberValidator(String? v, {bool required = true}) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return required ? 'مطلوب' : null;
    if (double.tryParse(value) == null) return 'أدخلي رقماً صحيحاً';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<ProductsProvider>().categories;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'تعديل المنتج' : 'منتج جديد'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // الصور
            const Text(
              'صور المنتج',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _AddImageButton(
                    icon: Icons.photo_library_outlined,
                    label: 'المعرض',
                    onTap: _pickFromGallery,
                  ),
                  const SizedBox(width: 8),
                  _AddImageButton(
                    icon: Icons.camera_alt_outlined,
                    label: 'الكاميرا',
                    onTap: _pickFromCamera,
                  ),
                  const SizedBox(width: 8),
                  ..._images.asMap().entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: ProductImage(
                                  path: entry.value,
                                  width: 90,
                                  height: 90,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: InkWell(
                                  onTap: () => setState(
                                      () => _images.removeAt(entry.key)),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.black,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Colors.white,
                                    ),
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
            const SizedBox(height: 20),
            AppTextField(
              label: 'اسم المنتج',
              controller: _nameController,
              validator: (v) => (v == null || v.trim().length < 2)
                  ? 'أدخلي اسم المنتج'
                  : null,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'الوصف',
              controller: _descriptionController,
              maxLines: 3,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'أدخلي الوصف' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'السعر (ج.م)',
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    validator: _numberValidator,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    label: 'سعر الخصم (اختياري)',
                    controller: _discountController,
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        _numberValidator(v, required: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _categoryId,
              decoration: const InputDecoration(labelText: 'التصنيف'),
              items: categories
                  .map(
                    (c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c.name),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _categoryId = v),
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'المقاسات (افصلي بينها بفاصلة، مثال: 37، 38، 39)',
              controller: _sizesController,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'الألوان (افصلي بينها بفاصلة، مثال: أسود، أبيض)',
              controller: _colorsController,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'الكمية بالمخزون',
              controller: _stockController,
              keyboardType: TextInputType.number,
              validator: (v) {
                final value = v?.trim() ?? '';
                if (value.isEmpty) return 'مطلوب';
                if (int.tryParse(value) == null) {
                  return 'أدخلي رقماً صحيحاً';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              value: _isFeatured,
              onChanged: (v) => setState(() => _isFeatured = v),
              activeColor: Colors.black,
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'منتج مميز',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: const Text(
                'يظهر في قسم "منتجات مميزة" بالصفحة الرئيسية',
                style: TextStyle(fontSize: 12, color: AppTheme.grey),
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: _isEdit ? 'حفظ التعديلات' : 'إضافة المنتج',
              loading: _saving,
              onPressed: _save,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _AddImageButton extends StatelessWidget {
  const _AddImageButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 26),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
