import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // For date formatting

// Use main export for shared_models
import 'package:shared_models/shared_models.dart'; 

import '../../application/statistics_notifier.dart'; // Import seller stats notifier

class StatisticsPage extends ConsumerStatefulWidget {
  const StatisticsPage({super.key});

  @override
  ConsumerState<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends ConsumerState<StatisticsPage> {
  DateTimeRange _selectedDateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    final statisticsState = ref.watch(sellerStatisticsProvider);
    final theme = Theme.of(context);

    // Listen for errors
    ref.listen<SellerStatisticsState>(sellerStatisticsProvider, (previous, next) {
      String? errorMessage;
      if (next.salesData is AsyncError && next.salesData != previous?.salesData) {
        errorMessage = 'Error loading sales data: ${next.salesData.error}';
      } else if (next.topSellingProducts is AsyncError && next.topSellingProducts != previous?.topSellingProducts) {
        errorMessage = 'Error loading top products: ${next.topSellingProducts.error}';
      }

      if (errorMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Sales Statistics')),
      body: RefreshIndicator(
        onRefresh: () async {
          final notifier = ref.read(sellerStatisticsProvider.notifier);
          await Future.wait([
            notifier.fetchSalesData(_selectedDateRange),
            notifier.fetchTopSellingProducts(_selectedDateRange),
            // Add other data fetching futures here
          ]);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTimePeriodSelector(context, ref),
              const SizedBox(height: 24),
              Text('Sales Trend', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              _buildSalesChart(statisticsState.salesData),
              const SizedBox(height: 24),
              Text('Top Selling Products', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              _buildTopSellingProductsList(statisticsState.topSellingProducts),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePeriodSelector(BuildContext context, WidgetRef ref) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${formatter.format(_selectedDateRange.start)} - ${formatter.format(_selectedDateRange.end)}',
        ),
        IconButton(
          icon: const Icon(Icons.calendar_today), // Removed const here
          tooltip: 'Select Date Range',
          onPressed: () async {
            final pickedRange = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              initialDateRange: _selectedDateRange,
            );
            if (pickedRange != null && pickedRange != _selectedDateRange) {
              setState(() {
                _selectedDateRange = pickedRange;
              });
              final notifier = ref.read(sellerStatisticsProvider.notifier);
              notifier.fetchSalesData(_selectedDateRange);
              notifier.fetchTopSellingProducts(_selectedDateRange);
            }
          },
        ),
      ],
    );
  }

  Widget _buildSalesChart(AsyncValue<List<SalesData>> salesDataAsync) {
    return salesDataAsync.when(
      data: (salesData) {
        if (salesData.isEmpty) return const Center(child: Text('No sales data for selected period.'));
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) => _bottomTitleWidgets(value, meta, salesData.length, salesData),
                        interval: _calculateTitleInterval(salesData.length),
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade300)),
                  minY: 0,
                  maxX: (salesData.length - 1).toDouble(),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _generateFlSpots(salesData),
                      isCurved: true,
                      color: Theme.of(context).primaryColor,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox(height: 250, child: Center(child: CircularProgressIndicator())),
      error: (error, _) => SizedBox(height: 250, child: Center(child: Text('Error loading chart: $error'))),
    );
  }

  List<FlSpot> _generateFlSpots(List<SalesData> salesData) {
    return salesData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.sales);
    }).toList();
  }

  Widget _buildTopSellingProductsList(AsyncValue<List<Product>> topProductsAsync) {
    return topProductsAsync.when(
      data: (products) {
        if (products.isEmpty) return const Center(child: Text('No top selling products found.'));
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: products.map((product) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade200,
                    child:  product.imageUrl.isNotEmpty
                        ? ClipOval(child: Image.network(product.imageUrl, fit: BoxFit.cover, width: 40, height: 40))
                        : const Icon(Icons.inventory_2_outlined, size: 20) ,
                  ),
                  title: Text(product.name),
                  trailing: Text('\$${product.price.toStringAsFixed(2)}'),
                );
              }).toList(),
            ),
          ),
        );
      }, 
      loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
      error: (error, _) => SizedBox(height: 100, child: Center(child: Text('Error loading top products: $error'))),
    );
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta, int dataLength, List<SalesData> salesData) {
    final style = TextStyle(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );
    String text = '';
    final index = value.toInt();
    if (index >= 0 && index < dataLength) {
        text = salesData[index].month;
    }
   
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4.0,
      child: Text(text, style: style),
    );
  }

  double _calculateTitleInterval(int dataLength) {
    if (dataLength <= 7) return 1;
    if (dataLength <= 14) return 2;
    if (dataLength <= 31) return 5;
    return (dataLength / 6).floorToDouble();
  }
}
