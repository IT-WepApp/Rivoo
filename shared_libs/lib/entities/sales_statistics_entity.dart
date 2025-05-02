import 'package:equatable/equatable.dart';

/// كيان إحصائيات المبيعات الذي يمثل بيانات المبيعات في فترة زمنية محددة
class SalesStatisticsEntity extends Equatable {
  final String sellerId;
  final DateTime period;
  final String periodType; // daily, weekly, monthly, yearly
  final double totalSales;
  final int totalOrders;
  final int totalProducts;
  final Map<String, double> salesByCategory;
  final List<SalesTrendEntity> trends;

  const SalesStatisticsEntity({
    required this.sellerId,
    required this.period,
    required this.periodType,
    required this.totalSales,
    required this.totalOrders,
    required this.totalProducts,
    required this.salesByCategory,
    required this.trends,
  });

  @override
  List<Object?> get props => [
        sellerId,
        period,
        periodType,
        totalSales,
        totalOrders,
        totalProducts,
        salesByCategory,
        trends,
      ];

  SalesStatisticsEntity copyWith({
    String? sellerId,
    DateTime? period,
    String? periodType,
    double? totalSales,
    int? totalOrders,
    int? totalProducts,
    Map<String, double>? salesByCategory,
    List<SalesTrendEntity>? trends,
  }) {
    return SalesStatisticsEntity(
      sellerId: sellerId ?? this.sellerId,
      period: period ?? this.period,
      periodType: periodType ?? this.periodType,
      totalSales: totalSales ?? this.totalSales,
      totalOrders: totalOrders ?? this.totalOrders,
      totalProducts: totalProducts ?? this.totalProducts,
      salesByCategory: salesByCategory ?? this.salesByCategory,
      trends: trends ?? this.trends,
    );
  }
}

/// كيان اتجاه المبيعات الذي يمثل بيانات المبيعات في نقطة زمنية محددة
class SalesTrendEntity extends Equatable {
  final DateTime date;
  final double value;

  const SalesTrendEntity({
    required this.date,
    required this.value,
  });

  @override
  List<Object?> get props => [date, value];

  SalesTrendEntity copyWith({
    DateTime? date,
    double? value,
  }) {
    return SalesTrendEntity(
      date: date ?? this.date,
      value: value ?? this.value,
    );
  }
}
