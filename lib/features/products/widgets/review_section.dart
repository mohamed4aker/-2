import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/reviews_provider.dart';

/// قسم التقييمات في صفحة المنتج.
class ReviewSection extends StatelessWidget {
  const ReviewSection({
    super.key,
    required this.productId,
    this.canWrite = false,
  });

  final String productId;
  final bool canWrite;

  Future<void> _writeReview(BuildContext context) async {
    var rating = 5;
    final controller = TextEditingController();

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('اكتب تقييمك'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (i) => IconButton(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      i < rating ? Icons.star : Icons.star_border,
                      size: 30,
                    ),
                    onPressed: () => setState(() => rating = i + 1),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'إيه رأيك في المنتج؟',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'نشر',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );

    if (saved != true || !context.mounted) return;

    final user = context.read<AuthProvider>().user;
    await context.read<ReviewsProvider>().add(
          productId: productId,
          userName: user?.name ?? 'عميل',
          rating: rating,
          comment: controller.text,
        );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('شكراً لتقييمك 🖤')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReviewsProvider>();
    final reviews = provider.forProduct(productId);
    final average = provider.averageFor(productId);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 4, height: 20, color: Colors.black),
              const SizedBox(width: 8),
              const Text(
                'آراء العملاء',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              if (canWrite)
                TextButton.icon(
                  onPressed: () => _writeReview(context),
                  icon: const Icon(Icons.rate_review_outlined, size: 18),
                  label: const Text('اكتب تقييم'),
                ),
            ],
          ),
          const SizedBox(height: 8),

          if (reviews.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.rate_review_outlined,
                      size: 32, color: AppTheme.grey),
                  const SizedBox(height: 8),
                  const Text(
                    'لسه مفيش تقييمات للمنتج ده',
                    style: TextStyle(color: AppTheme.grey),
                  ),
                  if (!canWrite) ...[
                    const SizedBox(height: 4),
                    const Text(
                      'سجّل دخولك عشان تقدر تقيّم',
                      style: TextStyle(fontSize: 12, color: AppTheme.grey),
                    ),
                  ],
                ],
              ),
            )
          else ...[
            // ملخص التقييم
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    average.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < average.round()
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'من ${reviews.length} تقييم',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...reviews.take(5).map(
                  (review) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.black,
                              child: Text(
                                review.userName.characters.first,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    review.userName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    formatDay(review.createdAt),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: List.generate(
                                5,
                                (i) => Icon(
                                  i < review.rating
                                      ? Icons.star
                                      : Icons.star_border,
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (review.comment.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            review.comment,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}
