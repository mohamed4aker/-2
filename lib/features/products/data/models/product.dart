class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.categoryId,
    this.sizes = const [],
    this.colors = const [],
    required this.stock,
    this.images = const [],
    this.isFeatured = false,
    this.variantGroup,
    this.colorName,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String description;
  final double price;

  /// سعر بعد الخصم (اختياري).
  final double? discountPrice;
  final String categoryId;
  final List<String> sizes;
  final List<String> colors;
  final int stock;
  final List<String> images;
  final bool isFeatured;

  /// اسم مجموعة الألوان — المنتجات اللي ليها نفس الاسم بتتعامل كنفس
  /// المنتج بألوان مختلفة، وبتظهر لبعضها في صفحة المنتج.
  /// مثال: شنطة سوداء وشنطة بيج ليهم نفس `variantGroup = "شنطة يد جلد"`.
  final String? variantGroup;

  /// اسم اللون اللي بيظهر تحت صورة اللون في صفحة المنتج.
  final String? colorName;

  final DateTime createdAt;

  /// هل المنتج ده جزء من مجموعة ألوان؟
  bool get hasVariants =>
      variantGroup != null && variantGroup!.trim().isNotEmpty;

  /// اسم اللون المعروض (لو مش متكتب بياخد أول لون من قائمة الألوان).
  String get displayColor =>
      colorName?.trim().isNotEmpty == true
          ? colorName!.trim()
          : (colors.isNotEmpty ? colors.first : 'اللون');

  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  double get finalPrice => hasDiscount ? discountPrice! : price;

  int get discountPercent =>
      hasDiscount ? (((price - discountPrice!) / price) * 100).round() : 0;

  bool get inStock => stock > 0;

  String get mainImage => images.isNotEmpty ? images.first : '';

  Product copyWith({
    String? name,
    String? description,
    double? price,
    double? discountPrice,
    bool clearDiscount = false,
    String? categoryId,
    List<String>? sizes,
    List<String>? colors,
    int? stock,
    List<String>? images,
    bool? isFeatured,
    String? variantGroup,
    String? colorName,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      discountPrice:
          clearDiscount ? null : (discountPrice ?? this.discountPrice),
      categoryId: categoryId ?? this.categoryId,
      sizes: sizes ?? this.sizes,
      colors: colors ?? this.colors,
      stock: stock ?? this.stock,
      images: images ?? this.images,
      isFeatured: isFeatured ?? this.isFeatured,
      variantGroup: variantGroup ?? this.variantGroup,
      colorName: colorName ?? this.colorName,
      createdAt: createdAt,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        price: (json['price'] as num).toDouble(),
        discountPrice: (json['discountPrice'] as num?)?.toDouble(),
        categoryId: json['categoryId'] as String,
        sizes: List<String>.from(json['sizes'] as List? ?? []),
        colors: List<String>.from(json['colors'] as List? ?? []),
        stock: (json['stock'] as num?)?.toInt() ?? 0,
        images: List<String>.from(json['images'] as List? ?? []),
        isFeatured: json['isFeatured'] as bool? ?? false,
        variantGroup: json['variantGroup'] as String?,
        colorName: json['colorName'] as String?,
        createdAt:
            DateTime.tryParse(json['createdAt'] as String? ?? '') ??
                DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'discountPrice': discountPrice,
        'categoryId': categoryId,
        'sizes': sizes,
        'colors': colors,
        'stock': stock,
        'images': images,
        'isFeatured': isFeatured,
        'variantGroup': variantGroup,
        'colorName': colorName,
        'createdAt': createdAt.toIso8601String(),
      };
}
