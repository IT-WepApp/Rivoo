import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart' as models;
import 'package:shared_services/shared_services.dart' as svc;

// State for Seller Statistics
class StatisticsState {
  final AsyncValue<List<models.SalesData>> salesData;
  final AsyncValue<List<models.StorePerformance>> storePerformance;

  StatisticsState({
    this.salesData = const AsyncLoading(),
    this.storePerformance = const AsyncLoading(),
  });

  StatisticsState copyWith({
    AsyncValue<List<models.SalesData>>? salesData,
    AsyncValue<List<models.StorePerformance>>? storePerformance,
  }) {
    return StatisticsState(
      salesData: salesData ?? this.salesData,
      storePerformance: storePerformance ?? this.storePerformance,
    );
  }
}

class StatisticsAndReportsNotifier extends StateNotifier<StatisticsState> {
  final svc.StatisticsService _statisticsService;

  StatisticsAndReportsNotifier(this._statisticsService)
      : super(StatisticsState()) {
    final now = DateTime.now();
    final initialRange = DateTimeRange(
      start: now.subtract(const Duration(days: 30)),
      end: now,
    );
    fetchSalesData(initialRange);
    fetchStorePerformance(initialRange);
  }

  Future<void> fetchSalesData(DateTimeRange dateRange) async {
    state = state.copyWith(salesData: const AsyncLoading());
    try {
      final List<svc.SalesData> svcData =
          await _statisticsService.getSalesData(dateRange);

      final data = svcData.map((item) {
        return models.SalesData(
          'Placeholder Month', // Placeholder for month
          double.tryParse(item.totalSales) ?? 0.0, // Convert to double
        );
      }).toList();

      state = state.copyWith(salesData: AsyncData(data));
    } catch (e, st) {
      state = state.copyWith(
        salesData: AsyncError('Failed to fetch sales data: $e', st),
      );
    }
  }

  Future<void> fetchStorePerformance(DateTimeRange dateRange) async {
    state = state.copyWith(storePerformance: const AsyncLoading());
    try {
      final List<svc.StorePerformance> svcPerf =
          await _statisticsService.getStorePerformance(dateRange);

      final perf = svcPerf.map((item) {
        return models.StorePerformance(
          'Placeholder Store Name', // Placeholder for store name
          0.0, // Placeholder for revenue, update as needed
        );
      }).toList();

      state = state.copyWith(storePerformance: AsyncData(perf));
    } catch (e, st) {
      state = state.copyWith(
        storePerformance:
            AsyncError('Failed to fetch store performance: $e', st),
      );
    }
  }
}

// Provider for Seller Statistics Notifier
final statisticsAndReportsProvider =
    StateNotifierProvider<StatisticsAndReportsNotifier, StatisticsState>(
  (ref) {
    final statisticsService = ref.read(svc.statisticsServiceProvider);
    return StatisticsAndReportsNotifier(statisticsService);
  },
);

// Provider for Statistics Service
final statisticsServiceProvider = Provider<svc.StatisticsService>((ref) {
  return svc.StatisticsService();
});

