import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart'; // SalesData, StorePerformance
import 'package:intl/intl.dart';

import '../../application/statistics_and_reports_notifier.dart';

class StatisticsAndReportsPage extends ConsumerStatefulWidget {
  const StatisticsAndReportsPage({super.key});

  @override
  ConsumerState<StatisticsAndReportsPage> createState() =>
      _StatisticsAndReportsPageState();
}

class _StatisticsAndReportsPageState
    extends ConsumerState<StatisticsAndReportsPage> {
  DateTimeRange _selectedDateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    final statisticsState = ref.watch(statisticsAndReportsProvider);
    final theme = Theme.of(context);

    // Show error SnackBar if needed for sales data
    ref.listen<AsyncValue<List<SalesData>>>(
      statisticsAndReportsProvider.select((s) => s.salesData),
      (prev, next) {
        if (next is AsyncError && next != prev) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading sales data: ${next.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
    // Show error SnackBar if needed for store performance
    ref.listen<AsyncValue<List<StorePerformance>>>(
      statisticsAndReportsProvider.select((s) => s.storePerformance),
      (prev, next) {
        if (next is AsyncError && next != prev) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading store performance: ${next.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics and Reports'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final notifier = ref.read(statisticsAndReportsProvider.notifier);
          await Future.wait([
            notifier.fetchSalesData(_selectedDateRange),
            notifier.fetchStorePerformance(_selectedDateRange),
          ]);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTimePeriodSelector(context),
              const SizedBox(height: 24),
              Text('Sales Trend', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              _buildSalesTrendChart(statisticsState.salesData),
              const SizedBox(height: 24),
              Text('Store Performance', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              _buildStorePerformanceChart(statisticsState.storePerformance),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePeriodSelector(BuildContext context) {
    final formatter = DateFormat('yyyy-MM-dd');
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${formatter.format(_selectedDateRange.start)}'
          ' - '
          '${formatter.format(_selectedDateRange.end)}',
        ),
        IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () async {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              initialDateRange: _selectedDateRange,
            );
            if (picked != null && picked != _selectedDateRange) {
              setState(() => _selectedDateRange = picked);
              final notifier = ref.read(statisticsAndReportsProvider.notifier);
              notifier.fetchSalesData(_selectedDateRange);
              notifier.fetchStorePerformance(_selectedDateRange);
            }
          },
        ),
      ],
    );
  }

  Widget _buildSalesTrendChart(AsyncValue<List<SalesData>> salesDataAsync) {
    return salesDataAsync.when(
      data: (salesData) {
        if (salesData.isEmpty) {
          return const Center(
              child: Text('No sales data for selected period.'));
        }
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(value.toInt().toString()),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: _calculateTitleInterval(salesData.length),
                        getTitlesWidget: (value, meta) =>
                            _bottomTitleWidgets(value, meta, salesData.length),
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  minY: 0,
                  maxX: (salesData.length - 1).toDouble(),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _generateFlSpots(salesData),
                      isCurved: true,
                      color: Theme.of(context).primaryColor,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox(
          height: 250, child: Center(child: CircularProgressIndicator())),
      error: (error, _) => SizedBox(
          height: 250,
          child: Center(child: Text('Error loading chart: $error'))),
    );
  }

  List<FlSpot> _generateFlSpots(List<SalesData> salesData) {
    return salesData.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.sales);
    }).toList();
  }

  Widget _buildStorePerformanceChart(
      AsyncValue<List<StorePerformance>> perfAsync) {
    return perfAsync.when(
      data: (data) {
        if (data.isEmpty) {
          return const Center(child: Text('No store performance data.'));
        }
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _calculateMaxY(data),
                  minY: 0,
                  groupsSpace: 12,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(value.toInt().toString()),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx >= 0 && idx < data.length) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              space: 4,
                              child: Text(
                                data[idx].storeName,
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  gridData: const FlGridData(show: false),
                  barGroups: _generateBarGroups(data),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.grey,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final name = data[group.x.toInt()].storeName;
                        return BarTooltipItem(
                          '$name\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: rod.toY.toStringAsFixed(2),
                              style: const TextStyle(
                                color: Colors.yellow,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox(
          height: 250, child: Center(child: CircularProgressIndicator())),
      error: (error, _) => SizedBox(
          height: 250,
          child: Center(child: Text('Error loading chart: $error'))),
    );
  }

  List<BarChartGroupData> _generateBarGroups(List<StorePerformance> data) {
    return data.asMap().entries.map((e) {
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: e.value.revenue,
            color: Colors.teal,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }

  double _calculateMaxY(List<StorePerformance> data) {
    if (data.isEmpty) return 10;
    final maxVal = data.map((p) => p.revenue).reduce((a, b) => a > b ? a : b);
    return (maxVal * 1.2).ceilToDouble();
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta, int len) {
    const style = TextStyle(
      color: Color(0xff68737d),
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );
    final idx = value.toInt();
    final text =
        (idx >= 0 && idx < len) ? 'Day ${idx + 1}' : ''; // عدّل حسب الحاجة

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8.0,
      child: Text(text, style: style),
    );
  }

  double _calculateTitleInterval(int len) {
    if (len <= 10) return 1;
    if (len <= 20) return 2;
    return (len / 10).floorToDouble();
  }
}
