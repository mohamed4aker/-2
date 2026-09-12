/// تصنيف المنتجات — بيدعم تصنيفات متداخلة (تصنيف جوه تصنيف).
///
/// مثال: "رجالي" تصنيف رئيسي، وجواه "أحذية" و "شنط" كتصنيفات فرعية.
/// التصنيف الفرعي بيبقى [parentId] بتاعه = id التصنيف الرئيسي.
class ProductCategory {
  const ProductCategory({
    required this.id,
    required this.name,
    this.parentId,
    this.image,
  });

  final String id;
  final String name;

  /// null = تصنيف رئيسي · غير null = تصنيف فرعي تابع للتصنيف ده.
  final String? parentId;

  /// صورة اختيارية للتصنيف (بتظهر في شبكة التصنيفات الفرعية).
  final String? image;

  bool get isRoot => parentId == null || parentId!.isEmpty;

  factory ProductCategory.fromJson(Map<String, dynamic> json) =>
      ProductCategory(
        id: json['id'] as String,
        name: json['name'] as String,
        parentId: (json['parentId'] as String?)?.isEmpty ?? true
            ? null
            : json['parentId'] as String,
        image: json['image'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'parentId': parentId,
        'image': image,
      };

  ProductCategory copyWith({
    String? name,
    String? parentId,
    bool clearParent = false,
    String? image,
  }) =>
      ProductCategory(
        id: id,
        name: name ?? this.name,
        parentId: clearParent ? null : (parentId ?? this.parentId),
        image: image ?? this.image,
      );
}
