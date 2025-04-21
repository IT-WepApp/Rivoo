import 'package:flutter/material.dart';

/// مكون لتوثيق كيفية استخدام خدمات التحليلات في التطبيق
class AnalyticsUsageGuide extends StatelessWidget {
  const AnalyticsUsageGuide({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('دليل استخدام التحليلات'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'كيفية استخدام خدمات التحليلات في التطبيق',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              '1. تتبع مشاهدة الشاشات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'يتم تتبع مشاهدة الشاشات تلقائياً باستخدام AnalyticsObserver المضاف إلى MaterialApp. يمكنك أيضاً استخدام AnalyticsWrapper لتتبع مشاهدة الشاشات يدوياً:',
            ),
            SizedBox(height: 8),
            CodeSnippet(
              code: '''
// استخدام AnalyticsWrapper
AnalyticsWrapper(
  screenName: 'product_details',
  screenParameters: {'product_id': product.id},
  child: ProductDetailsScreen(),
)
''',
            ),
            SizedBox(height: 16),
            Text(
              '2. تتبع أحداث المستخدم',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'يمكنك استخدام AnalyticsProvider لتتبع أحداث المستخدم المختلفة:',
            ),
            SizedBox(height: 8),
            CodeSnippet(
              code: '''
// تتبع النقر على زر
final analytics = ref.read(analyticsProviderService);
analytics.logButtonClick('add_to_cart_button', parameters: {
  'product_id': product.id,
  'product_name': product.name,
});

// تتبع إضافة منتج إلى سلة التسوق
analytics.logAddToCart(
  productId: product.id,
  productName: product.name,
  price: product.price,
  quantity: quantity,
);

// تتبع عملية شراء
analytics.logPurchase(
  orderId: order.id,
  totalValue: order.totalAmount,
  products: order.items.map((item) => {
    'id': item.productId,
    'name': item.productName,
    'price': item.price,
    'quantity': item.quantity,
  }).toList(),
);
''',
            ),
            SizedBox(height: 16),
            Text(
              '3. قياس أداء العمليات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'يمكنك استخدام AnalyticsProvider لقياس أداء العمليات المختلفة:',
            ),
            SizedBox(height: 8),
            CodeSnippet(
              code: '''
// قياس أداء عملية معينة
final result = await analytics.measureOperation(
  operationName: 'load_products',
  operation: () => productsRepository.getProducts(),
  attributes: {'category': category},
);

// قياس أداء طلب HTTP
final response = await analytics.measureHttpRequest(
  url: 'https://api.example.com/products',
  method: 'GET',
  request: () => httpClient.get('https://api.example.com/products'),
);
''',
            ),
            SizedBox(height: 16),
            Text(
              '4. تعيين خصائص المستخدم',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'يمكنك استخدام AnalyticsService مباشرة لتعيين خصائص المستخدم:',
            ),
            SizedBox(height: 8),
            CodeSnippet(
              code: '''
// تعيين خصائص المستخدم
final analyticsService = ref.read(analyticsServiceProvider);
analyticsService.setUserProperties(
  userId: user.id,
  userRole: user.role,
  userLanguage: user.language,
  userTheme: user.theme,
);
''',
            ),
          ],
        ),
      ),
    );
  }
}

class CodeSnippet extends StatelessWidget {
  final String code;

  const CodeSnippet({Key? key, required this.code}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        code,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
        ),
      ),
    );
  }
}
