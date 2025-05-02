import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_app/features/ratings/providers/ratings_notifier.dart';
import 'package:shared_libs/widgets/interactive_rating_stars.dart';

class AddReviewScreen extends ConsumerStatefulWidget {
  final String targetId;
  final String targetType;
  final String targetName;
  final double? initialRating;
  final String? initialComment;

  const AddReviewScreen({
    Key? key,
    required this.targetId,
    required this.targetType,
    required this.targetName,
    this.initialRating,
    this.initialComment,
  }) : super(key: key);

  @override
  ConsumerState<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends ConsumerState<AddReviewScreen> {
  late double _rating;
  late TextEditingController _commentController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating ?? 0;
    _commentController = TextEditingController(text: widget.initialComment);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء تحديد تقييم من 1 إلى 5 نجوم'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ref.read(userRatingsProvider.notifier).addRating(
            targetId: widget.targetId,
            targetType: widget.targetType,
            rating: _rating,
            comment: _commentController.text.isEmpty
                ? null
                : _commentController.text,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ التقييم بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء حفظ التقييم: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.initialRating != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'تعديل التقييم' : 'إضافة تقييم'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // معلومات المنتج/المندوب
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 13), // 0.05 * 255 = 13
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: widget.targetType == 'product'
                          ? Colors.blue.withValues(alpha: 26) // 0.1 * 255 = 26
                          : Colors.green.withValues(alpha: 26), // 0.1 * 255 = 26
                      radius: 24,
                      child: Icon(
                        widget.targetType == 'product'
                            ? Icons.shopping_bag
                            : Icons.delivery_dining,
                        color: widget.targetType == 'product'
                            ? Colors.blue
                            : Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.targetName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.targetType == 'product'
                                ? 'منتج'
                                : 'مندوب توصيل',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // التقييم بالنجوم
              Center(
                child: Column(
                  children: [
                    const Text(
                      'ما هو تقييمك؟',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    InteractiveRatingStars(
                      initialRating: _rating,
                      onRatingChanged: (value) {
                        setState(() {
                          _rating = value;
                        });
                      },
                      size: 48,
                      showRatingNumber: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // حقل التعليق
              Text(
                'اكتب مراجعتك (اختياري)',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'شارك تجربتك مع الآخرين...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.inputDecorationTheme.fillColor,
                ),
                maxLines: 5,
                maxLength: 500,
              ),

              const SizedBox(height: 24),

              // زر الحفظ
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator()
                      : Text(
                          isEditing ? 'تحديث التقييم' : 'إرسال التقييم',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
