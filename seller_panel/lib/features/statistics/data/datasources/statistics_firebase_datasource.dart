import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seller_panel/features/statistics/domain/entities/sales_statistics_entity.dart';

/// مصدر بيانات Firebase للإحصائيات
abstract class StatisticsFirebaseDataSource {
  /// الحصول على إحصائيات المبيعات اليومية
  Future<SalesStatisticsEntity> getDailySalesStatistics(
    String sellerId, {
    DateTime? date,
  });

  /// الحصول على إحصائيات المبيعات الأسبوعية
  Future<SalesStatisticsEntity> getWeeklySalesStatistics(
    String sellerId, {
    DateTime? startDate,
  });

  /// الحصول على إحصائيات المبيعات الشهرية
  Future<SalesStatisticsEntity> getMonthlySalesStatistics(
    String sellerId, {
    DateTime? month,
  });

  /// الحصول على إحصائيات المبيعات السنوية
  Future<SalesStatisticsEntity> getYearlySalesStatistics(
    String sellerId, {
    int? year,
  });

  /// الحصول على المنتجات الأكثر مبيعًا
  Future<List<Map<String, dynamic>>> getTopSellingProducts(
    String sellerId, {
    int limit = 5,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// الحصول على الفئات الأكثر مبيعًا
  Future<List<Map<String, dynamic>>> getTopSellingCategories(
    String sellerId, {
    int limit = 5,
    DateTime? startDate,
    DateTime? endDate,
  });
}

/// تنفيذ مصدر بيانات Firebase للإحصائيات
class StatisticsFirebaseDataSourceImpl implements StatisticsFirebaseDataSource {
  final FirebaseFirestore _firestore;

  StatisticsFirebaseDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<SalesStatisticsEntity> getDailySalesStatistics(
    String sellerId, {
    DateTime? date,
  }) async {
    final targetDate = date ?? DateTime.now();
    final startOfDay =
        DateTime(targetDate.year, targetDate.month, targetDate.day);
    final endOfDay =
        DateTime(targetDate.year, targetDate.month, targetDate.day, 23, 59, 59);

    final querySnapshot = await _firestore
        .collection('orders')
        .where('sellerId', isEqualTo: sellerId)
        .where('orderDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('orderDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .get();

    return _processSalesData(
      sellerId,
      querySnapshot.docs,
      startOfDay,
      'daily',
    );
  }

  @override
  Future<SalesStatisticsEntity> getWeeklySalesStatistics(
    String sellerId, {
    DateTime? startDate,
  }) async {
    final now = DateTime.now();
    final targetDate = startDate ?? now;

    // حساب بداية الأسبوع (الأحد)
    final startOfWeek =
        targetDate.subtract(Duration(days: targetDate.weekday % 7));
    final startDay =
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    // حساب نهاية الأسبوع (السبت)
    final endDay = startDay
        .add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

    final querySnapshot = await _firestore
        .collection('orders')
        .where('sellerId', isEqualTo: sellerId)
        .where('orderDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDay))
        .where('orderDate', isLessThanOrEqualTo: Timestamp.fromDate(endDay))
        .get();

    return _processSalesData(
      sellerId,
      querySnapshot.docs,
      startDay,
      'weekly',
    );
  }

  @override
  Future<SalesStatisticsEntity> getMonthlySalesStatistics(
    String sellerId, {
    DateTime? month,
  }) async {
    final targetDate = month ?? DateTime.now();
    final startOfMonth = DateTime(targetDate.year, targetDate.month, 1);
    final endOfMonth = (targetDate.month < 12)
        ? DateTime(targetDate.year, targetDate.month + 1, 0, 23, 59, 59)
        : DateTime(targetDate.year + 1, 1, 0, 23, 59, 59);

    final querySnapshot = await _firestore
        .collection('orders')
        .where('sellerId', isEqualTo: sellerId)
        .where('orderDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('orderDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .get();

    return _processSalesData(
      sellerId,
      querySnapshot.docs,
      startOfMonth,
      'monthly',
    );
  }

  @override
  Future<SalesStatisticsEntity> getYearlySalesStatistics(
    String sellerId, {
    int? year,
  }) async {
    final targetYear = year ?? DateTime.now().year;
    final startOfYear = DateTime(targetYear, 1, 1);
    final endOfYear = DateTime(targetYear, 12, 31, 23, 59, 59);

    final querySnapshot = await _firestore
        .collection('orders')
        .where('sellerId', isEqualTo: sellerId)
        .where('orderDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfYear))
        .where('orderDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfYear))
        .get();

    return _processSalesData(
      sellerId,
      querySnapshot.docs,
      startOfYear,
      'yearly',
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getTopSellingProducts(
    String sellerId, {
    int limit = 5,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final start =
        startDate ?? DateTime.now().subtract(const Duration(days: 30));
    final end = endDate ?? DateTime.now();

    final querySnapshot = await _firestore
        .collection('orders')
        .where('sellerId', isEqualTo: sellerId)
        .where('orderDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('orderDate', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();

    // تجميع المنتجات وكمياتها
    final Map<String, Map<String, dynamic>> productSales = {};

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      if (data.containsKey('items') && data['items'] is List) {
        for (var item in data['items']) {
          final productId = item['productId'];
          final quantity = (item['quantity'] as num).toInt();
          final price = (item['price'] as num).toDouble();
          final totalPrice = price * quantity;

          if (productSales.containsKey(productId)) {
            productSales[productId]!['quantity'] += quantity;
            productSales[productId]!['totalSales'] += totalPrice;
          } else {
            productSales[productId] = {
              'productId': productId,
              'productName': item['productName'],
              'quantity': quantity,
              'totalSales': totalPrice,
              'imageUrl': item['imageUrl'],
            };
          }
        }
      }
    }

    // تحويل إلى قائمة وترتيبها حسب الكمية
    final topProducts = productSales.values.toList()
      ..sort((a, b) => (b['quantity'] as int).compareTo(a['quantity'] as int));

    // إرجاع العدد المطلوب من المنتجات
    return topProducts.take(limit).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getTopSellingCategories(
    String sellerId, {
    int limit = 5,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // الحصول على المنتجات أولاً
    final topProducts = await getTopSellingProducts(
      sellerId,
      limit: 100, // نحصل على عدد أكبر من المنتجات لتحليل الفئات
      startDate: startDate,
      endDate: endDate,
    );

    // الحصول على فئات المنتجات
    final Map<String, Map<String, dynamic>> categorySales = {};

    for (var product in topProducts) {
      // نحتاج إلى الحصول على فئة المنتج من مجموعة المنتجات
      final productSnapshot = await _firestore
          .collection('products')
          .doc(product['productId'])
          .get();

      if (productSnapshot.exists) {
        final productData = productSnapshot.data()!;
        final categoryId = productData['categoryId'] ?? 'uncategorized';
        final categoryName = productData['categoryName'] ?? 'غير مصنف';

        if (categorySales.containsKey(categoryId)) {
          categorySales[categoryId]!['quantity'] += product['quantity'];
          categorySales[categoryId]!['totalSales'] += product['totalSales'];
        } else {
          categorySales[categoryId] = {
            'categoryId': categoryId,
            'categoryName': categoryName,
            'quantity': product['quantity'],
            'totalSales': product['totalSales'],
          };
        }
      }
    }

    // تحويل إلى قائمة وترتيبها حسب المبيعات
    final topCategories = categorySales.values.toList()
      ..sort((a, b) =>
          (b['totalSales'] as double).compareTo(a['totalSales'] as double));

    // إرجاع العدد المطلوب من الفئات
    return topCategories.take(limit).toList();
  }

  /// معالجة بيانات المبيعات وتحويلها إلى كيان إحصائيات المبيعات
  SalesStatisticsEntity _processSalesData(
    String sellerId,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    DateTime period,
    String periodType,
  ) {
    double totalSales = 0;
    final totalOrders = docs.length;
    final Set<String> uniqueProducts = {};
    final Map<String, double> salesByCategory = {};
    final Map<DateTime, double> salesByDate = {};

    for (var doc in docs) {
      final data = doc.data();
      totalSales += (data['totalAmount'] as num).toDouble();

      // جمع المنتجات الفريدة
      if (data.containsKey('items') && data['items'] is List) {
        for (var item in data['items']) {
          uniqueProducts.add(item['productId']);

          // جمع المبيعات حسب الفئة
          final categoryId = item['categoryId'] ?? 'uncategorized';
          final price = (item['price'] as num).toDouble();
          final quantity = (item['quantity'] as num).toInt();
          final itemTotal = price * quantity;

          if (salesByCategory.containsKey(categoryId)) {
            salesByCategory[categoryId] =
                salesByCategory[categoryId]! + itemTotal;
          } else {
            salesByCategory[categoryId] = itemTotal;
          }
        }
      }

      // جمع المبيعات حسب التاريخ
      final orderDate = (data['orderDate'] as Timestamp).toDate();
      final dateKey = DateTime(orderDate.year, orderDate.month, orderDate.day);

      if (salesByDate.containsKey(dateKey)) {
        salesByDate[dateKey] =
            salesByDate[dateKey]! + (data['totalAmount'] as num).toDouble();
      } else {
        salesByDate[dateKey] = (data['totalAmount'] as num).toDouble();
      }
    }

    // تحويل بيانات المبيعات حسب التاريخ إلى قائمة اتجاهات
    final List<SalesTrendEntity> trends = salesByDate.entries
        .map((entry) => SalesTrendEntity(date: entry.key, value: entry.value))
        .toList();

    // ترتيب الاتجاهات حسب التاريخ
    trends.sort((a, b) => a.date.compareTo(b.date));

    return SalesStatisticsEntity(
      sellerId: sellerId,
      period: period,
      periodType: periodType,
      totalSales: totalSales,
      totalOrders: totalOrders,
      totalProducts: uniqueProducts.length,
      salesByCategory: salesByCategory,
      trends: trends,
    );
  }
}
