import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_libs/models/models.dart' as models;
import 'package:shared_libs/services/services.dart';
import '../../products/application/products_notifier.dart';

class SellerStatisticsState {
  final AsyncValue<List<models.SalesData>> salesData;
  final AsyncValue<List<models.Product>> topSellingProducts;

  SellerStatisticsState({
    this.salesData = const AsyncLoading(),
    this.topSellingProducts = const AsyncLoading(),
  });

  SellerStatisticsState copyWith({
    AsyncValue<List<models.SalesData>>? salesData,
    AsyncValue<List<models.Product>>? topSellingProducts,
  }) {
    return SellerStatisticsState(
      salesData: salesData ?? this.salesData,
      topSellingProducts: topSellingProducts ?? this.topSellingProducts,
    );
  }
}

class StatisticsNotifier extends StateNotifier<SellerStatisticsState> {
  final StatisticsService _statisticsService;
  final String? _sellerId;

  StatisticsNotifier(this._statisticsService, this._sellerId)
      : super(SellerStatisticsState()) {
    if (_sellerId != null) {
      final now = DateTime.now();
      final initialRange = DateTimeRange(
        start: now.subtract(const Duration(days: 30)),
        end: now,
      );
      fetchSalesData(initialRange);
      fetchTopSellingProducts(initialRange);
    } else {
      state = SellerStatisticsState(
        salesData: AsyncError('Seller ID not available', StackTrace.current),
        topSellingProducts:
            AsyncError('Seller ID not available', StackTrace.current),
      );
    }
  }

  Future<void> fetchSalesData(DateTimeRange dateRange) async {
    if (_sellerId == null) return;
    state = state.copyWith(salesData: const AsyncLoading());
    try {
      final svcData = await _statisticsService.getSellerSalesData(
        _sellerId,
        dateRange,
      );

      // Assuming svcData is a single SalesData object and we need to create a list
      final data = [
        models.SalesData(
          'Placeholder Month',
          double.parse(svcData.totalSales), // Convert totalSales to double
        )
      ];

      state = state.copyWith(salesData: AsyncData(data));
    } catch (e, stacktrace) {
      state = state.copyWith(
        salesData: AsyncError('Failed to fetch sales data: $e', stacktrace),
      );
    }
  }

  Future<void> fetchTopSellingProducts(DateTimeRange dateRange,
      {int limit = 5}) async {
    if (_sellerId == null) return;
    state = state.copyWith(topSellingProducts: const AsyncLoading());
    try {
      final data = await _statisticsService.getSellerTopSellingProducts(
        _sellerId,
        dateRange,
        limit: limit,
      );
      state = state.copyWith(topSellingProducts: AsyncData(data));
    } catch (e, stacktrace) {
      state = state.copyWith(
        topSellingProducts:
            AsyncError('Failed to fetch top products: $e', stacktrace),
      );
    }
  }
}

final sellerStatisticsProvider = StateNotifierProvider.autoDispose<
    StatisticsNotifier, SellerStatisticsState>(
  (ref) {
    final statisticsService = ref.watch(statisticsServiceProvider);
    final sellerId = ref.watch(currentSellerIdProvider);
    return StatisticsNotifier(statisticsService, sellerId);
  },
);
