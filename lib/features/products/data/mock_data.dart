import '../../../core/config/app_config.dart';
import 'models/product.dart';
import 'models/product_category.dart';

/// بيانات تجريبية (تُستبدل لاحقاً ببيانات الـ API الحقيقي).
class MockData {
  MockData._();

  static const String catShoes = 'cat_shoes';
  static const String catBags = 'cat_bags';
  static const String catSunglasses = 'cat_sunglasses';
  static const String catAccessories = 'cat_accessories';

  // مثال على تصنيف جوه تصنيف: "رجالي" وجواه "أحذية" و"شنط".
  static const String catMen = 'cat_men';
  static const String catMenShoes = 'cat_men_shoes';
  static const String catMenBags = 'cat_men_bags';

  /// التصنيفات الأساسية — بتتحمّل دايماً حتى بعد مسح البيانات التجريبية.
  static const List<ProductCategory> baseCategories = [
    ProductCategory(id: catShoes, name: 'أحذية'),
    ProductCategory(id: catBags, name: 'شنط'),
    ProductCategory(id: catSunglasses, name: 'نظارات شمسية'),
    ProductCategory(id: catAccessories, name: 'إكسسوارات'),
  ];

  /// مثال للتصنيف المتداخل — تصنيف رئيسي جواه أقسام.
  /// العميل يدوس على "رجالي" فيدخل على الأقسام اللي جواه.
  static const List<ProductCategory> demoCategories = [
    ProductCategory(id: catMen, name: 'رجالي'),
    ProductCategory(id: catMenShoes, name: 'أحذية رجالي', parentId: catMen),
    ProductCategory(id: catMenBags, name: 'شنط رجالي', parentId: catMen),
  ];

  static List<ProductCategory> get categories => AppConfig.useDemoData
      ? [...baseCategories, ...demoCategories]
      : List.of(baseCategories);

  /// اسم مجموعة الألوان للشنطة اللي ليها 3 ألوان.
  static const String _bagGroup = 'شنطة يد جلد فاخرة';

  static String _img(String seed) =>
      'https://picsum.photos/seed/$seed/800/800?grayscale';

  static final List<Product> products = [
    Product(
      id: 'p1',
      name: 'حذاء كعب كلاسيك أسود',
      description:
          'حذاء بكعب متوسط 7 سم، جلد صناعي عالي الجودة، مريح للاستخدام اليومي والمناسبات. تصميم كلاسيكي أنيق يناسب جميع الإطلالات.',
      price: 1250,
      discountPrice: 950,
      categoryId: catShoes,
      sizes: ['36', '37', '38', '39', '40'],
      colors: ['أسود', 'بيج'],
      stock: 12,
      images: [_img('moda-heel-1'), _img('moda-heel-2'), _img('moda-heel-3')],
      isFeatured: true,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Product(
      id: 'p2',
      name: 'سنيكرز جلد أبيض',
      description:
          'سنيكرز نسائي جلد أبيض بنعل مريح مضاد للانزلاق، مثالي للمشي والخروجات اليومية.',
      price: 1450,
      categoryId: catShoes,
      sizes: ['36', '37', '38', '39', '40', '41'],
      colors: ['أبيض', 'أوف وايت'],
      stock: 20,
      images: [_img('moda-sneaker-1'), _img('moda-sneaker-2')],
      isFeatured: true,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Product(
      id: 'p3',
      name: 'صندل سهرة بكعب رفيع',
      description:
          'صندل سهرة أنيق بكعب رفيع 9 سم مع أحزمة ناعمة، مثالي للمناسبات والأفراح.',
      price: 1600,
      discountPrice: 1280,
      categoryId: catShoes,
      sizes: ['37', '38', '39', '40'],
      colors: ['أسود', 'فضي'],
      stock: 3,
      images: [_img('moda-sandal-1'), _img('moda-sandal-2')],
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    Product(
      id: 'p4',
      name: 'بوت شتوي جلد',
      description:
          'بوت نسائي جلد بطول منتصف الساق، بطانة دافئة ونعل ثابت، خيار مثالي لشتاء أنيق.',
      price: 2200,
      categoryId: catShoes,
      sizes: ['37', '38', '39', '40'],
      colors: ['أسود', 'بني'],
      stock: 8,
      images: [_img('moda-boot-1'), _img('moda-boot-2')],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    // ---- نفس الشنطة بـ 3 ألوان (كل لون منتج مستقل بنفس اسم المجموعة) ----
    Product(
      id: 'p5',
      name: 'شنطة يد جلد فاخرة — أسود',
      description:
          'شنطة يد نسائية جلد طبيعي بتصميم فاخر وحجم متوسط، تتسع لكل احتياجاتك اليومية مع إغلاق مغناطيسي آمن.',
      price: 1850,
      discountPrice: 1480,
      categoryId: catBags,
      colors: ['أسود'],
      stock: 10,
      images: [_img('moda-bag-1'), _img('moda-bag-2'), _img('moda-bag-3')],
      isFeatured: true,
      variantGroup: _bagGroup,
      colorName: 'أسود',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Product(
      id: 'p15',
      name: 'شنطة يد جلد فاخرة — بيج',
      description:
          'نفس الشنطة الفاخرة بلون بيج هادي يناسب إطلالات النهار والصيف.',
      price: 1850,
      discountPrice: 1480,
      categoryId: catBags,
      colors: ['بيج'],
      stock: 6,
      images: [_img('moda-bag-beige-1'), _img('moda-bag-beige-2')],
      variantGroup: _bagGroup,
      colorName: 'بيج',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Product(
      id: 'p16',
      name: 'شنطة يد جلد فاخرة — أبيض',
      description:
          'نفس الشنطة الفاخرة بلون أبيض ناصع يدي إطلالتك لمسة راقية.',
      price: 1850,
      categoryId: catBags,
      colors: ['أبيض'],
      stock: 4,
      images: [_img('moda-bag-white-1'), _img('moda-bag-white-2')],
      variantGroup: _bagGroup,
      colorName: 'أبيض',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Product(
      id: 'p6',
      name: 'شنطة كروس صغيرة',
      description:
          'شنطة كروس صغيرة عملية بحزام قابل للتعديل، مناسبة للخروجات السريعة بإطلالة عصرية.',
      price: 890,
      categoryId: catBags,
      colors: ['أسود', 'أبيض'],
      stock: 15,
      images: [_img('moda-cross-1'), _img('moda-cross-2')],
      isFeatured: true,
      createdAt: DateTime.now(),
    ),
    Product(
      id: 'p7',
      name: 'شنطة ظهر عملية',
      description:
          'شنطة ظهر نسائية خفيفة بجيوب متعددة، مثالية للجامعة والشغل مع تصميم مينيمال أنيق.',
      price: 1100,
      discountPrice: 930,
      categoryId: catBags,
      colors: ['أسود'],
      stock: 2,
      images: [_img('moda-backpack-1'), _img('moda-backpack-2')],
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    Product(
      id: 'p8',
      name: 'نظارة شمس كات آي',
      description:
          'نظارة شمسية بتصميم كات آي جريء، عدسات UV400 للحماية الكاملة من أشعة الشمس.',
      price: 750,
      categoryId: catSunglasses,
      colors: ['أسود', 'نمري'],
      stock: 18,
      images: [_img('moda-cateye-1'), _img('moda-cateye-2')],
      isFeatured: true,
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    Product(
      id: 'p9',
      name: 'نظارة شمس أفياتور',
      description:
          'نظارة أفياتور كلاسيكية بإطار معدني خفيف وعدسات متدرجة، إطلالة ساحرة في كل الأوقات.',
      price: 820,
      discountPrice: 650,
      categoryId: catSunglasses,
      colors: ['فضي', 'ذهبي'],
      stock: 9,
      images: [_img('moda-aviator-1'), _img('moda-aviator-2')],
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
    ),
    Product(
      id: 'p10',
      name: 'نظارة شمس أوفرسايز',
      description:
          'نظارة أوفرسايز بإطار عريض يمنح وجهك حماية وأناقة، مع عدسات داكنة مضادة للانعكاس.',
      price: 690,
      categoryId: catSunglasses,
      colors: ['أسود'],
      stock: 14,
      images: [_img('moda-oversize-1')],
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
    Product(
      id: 'p11',
      name: 'طقم إكسسوارات ذهبي',
      description:
          'طقم متكامل (سلسلة + حلق + أسورة) بطلاء ذهبي ثابت لا يتغير لونه، هدية مثالية.',
      price: 950,
      discountPrice: 760,
      categoryId: catAccessories,
      colors: ['ذهبي'],
      stock: 11,
      images: [_img('moda-set-1'), _img('moda-set-2')],
      isFeatured: true,
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
    Product(
      id: 'p12',
      name: 'سلسلة عنق مينيمال',
      description:
          'سلسلة عنق رفيعة بتصميم مينيمال راقٍ، ستانلس ستيل لا يسبب حساسية.',
      price: 380,
      categoryId: catAccessories,
      colors: ['فضي', 'ذهبي'],
      stock: 25,
      images: [_img('moda-necklace-1'), _img('moda-necklace-2')],
      createdAt: DateTime.now(),
    ),
    Product(
      id: 'p13',
      name: 'أسورة ستانلس أنيقة',
      description:
          'أسورة ستانلس ستيل مقاومة للماء بتصميم بسيط يناسب الاستخدام اليومي.',
      price: 320,
      categoryId: catAccessories,
      colors: ['فضي'],
      stock: 1,
      images: [_img('moda-bracelet-1')],
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    Product(
      id: 'p14',
      name: 'حلق دائري كبير',
      description:
          'حلق دائري (Hoops) بحجم كبير خفيف الوزن، قطعة أساسية في كل إطلالة.',
      price: 280,
      discountPrice: 220,
      categoryId: catAccessories,
      colors: ['ذهبي', 'فضي'],
      stock: 30,
      images: [_img('moda-hoops-1')],
      createdAt: DateTime.now().subtract(const Duration(days: 9)),
    ),

    // ---------- منتجات القسم الرجالي (مثال للتصنيف المتداخل) ----------
    Product(
      id: 'p17',
      name: 'حذاء رجالي جلد كلاسيك',
      description:
          'حذاء رجالي جلد طبيعي بتصميم كلاسيك يناسب الشغل والمناسبات، نعل مريح وخياطة متينة.',
      price: 1950,
      discountPrice: 1590,
      categoryId: catMenShoes,
      sizes: ['40', '41', '42', '43', '44'],
      colors: ['أسود', 'بني'],
      stock: 7,
      images: [_img('moda-men-shoe-1'), _img('moda-men-shoe-2')],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Product(
      id: 'p18',
      name: 'شنطة لابتوب رجالي',
      description:
          'شنطة لابتوب بجيب مبطّن يحمي الجهاز، وحزام كتف قابل للتعديل — عملية وأنيقة.',
      price: 1350,
      categoryId: catMenBags,
      colors: ['أسود', 'رمادي'],
      stock: 9,
      images: [_img('moda-men-bag-1'), _img('moda-men-bag-2')],
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];
}
