import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/services/order_service.dart';
import '../../../../core/widgets/app_widgets.dart';
import 'package:shared_libs/theme/app_colors.dart';

/// صفحة إدارة الطلبات للبائع
class OrdersManagementPage extends ConsumerStatefulWidget {
  const OrdersManagementPage({Key? key}) : super(key: key);

  @override
  ConsumerState<OrdersManagementPage> createState() =>
      _OrdersManagementPageState();
}

class _OrdersManagementPageState extends ConsumerState<OrdersManagementPage> {
  bool _isLoading = true;
  bool _isSubmitting = false;
  String _errorMessage = '';

  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _filteredOrders = [];

  final _searchController = TextEditingController();
  String _selectedStatus = 'الكل';
  final List<String> _statusOptions = [
    'الكل',
    'جديد',
    'قيد التحضير',
    'جاهز للتسليم',
    'قيد التوصيل',
    'تم التسليم',
    'ملغي'
  ];

  String _sortBy = 'date';
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final orderService = ref.read(orderServiceProvider);
      final orders = await orderService.getSellerOrders();

      setState(() {
        _orders = orders;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'حدث خطأ أثناء تحميل الطلبات: $e';
      });
    }
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_orders);

    // تطبيق فلتر البحث
    if (_searchController.text.isNotEmpty) {
      filtered = filtered.where((order) {
        final orderNumber = order['orderNumber'] as String? ?? '';
        final customerName = order['customerName'] as String? ?? '';
        final searchLower = _searchController.text.toLowerCase();

        return orderNumber.toLowerCase().contains(searchLower) ||
            customerName.toLowerCase().contains(searchLower);
      }).toList();
    }

    // تطبيق فلتر الحالة
    if (_selectedStatus != 'الكل') {
      filtered = filtered.where((order) {
        final status = order['status'] as String? ?? '';
        return status == _selectedStatus;
      }).toList();
    }

    // تطبيق الترتيب
    filtered.sort((a, b) {
      dynamic valueA;
      dynamic valueB;

      switch (_sortBy) {
        case 'date':
          valueA = a['orderDate'] as DateTime? ?? DateTime.now();
          valueB = b['orderDate'] as DateTime? ?? DateTime.now();
          break;
        case 'total':
          valueA = a['totalAmount'] as num? ?? 0;
          valueB = b['totalAmount'] as num? ?? 0;
          break;
        default:
          valueA = a['orderDate'] as DateTime? ?? DateTime.now();
          valueB = b['orderDate'] as DateTime? ?? DateTime.now();
      }

      if (valueA is DateTime && valueB is DateTime) {
        return _sortAscending
            ? valueA.compareTo(valueB)
            : valueB.compareTo(valueA);
      } else if (valueA is num && valueB is num) {
        return _sortAscending
            ? valueA.compareTo(valueB)
            : valueB.compareTo(valueA);
      }

      return 0;
    });

    setState(() {
      _filteredOrders = filtered;
    });
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = '';
    });

    try {
      final orderService = ref.read(orderServiceProvider);
      await orderService.updateOrderStatus(orderId, newStatus);

      // تحديث القائمة المحلية
      setState(() {
        final orderIndex = _orders.indexWhere((o) => o['id'] == orderId);
        if (orderIndex != -1) {
          _orders[orderIndex]['status'] = newStatus;
        }

        _applyFilters();
        _isSubmitting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تحديث حالة الطلب إلى "$newStatus" بنجاح'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'فشل تحديث حالة الطلب: $e';
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'جديد':
        return AppColors.info;
      case 'قيد التحضير':
        return AppColors.warning;
      case 'جاهز للتسليم':
        return AppColors.secondary;
      case 'قيد التوصيل':
        return AppColors.orderDelivering;
      case 'تم التسليم':
        return AppColors.success;
      case 'ملغي':
        return AppColors.error;
      default:
        return AppColors.disabled;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الطلبات'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: _isLoading
          ? AppWidgets.loadingIndicator(message: 'جاري تحميل الطلبات...')
          : _isSubmitting
              ? AppWidgets.loadingIndicator(message: 'جاري تنفيذ العملية...')
              : _errorMessage.isNotEmpty && _orders.isEmpty
                  ? AppWidgets.errorMessage(
                      message: _errorMessage,
                      onRetry: _loadOrders,
                    )
                  : Column(
                      children: [
                        // أدوات البحث والفلترة
                        _buildFilterBar(theme),

                        // رسالة الخطأ
                        if (_errorMessage.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.error),
                            ),
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(color: AppColors.error),
                            ),
                          ),

                        // قائمة الطلبات
                        Expanded(
                          child: _buildOrdersList(theme),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildFilterBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // شريط البحث
        AppWidgets.searchBar(
          controller: _searchController,
          hintText: 'البحث برقم الطلب أو اسم العميل...',
          onChanged: (value) {
                setState(() {
                _applyFilters();
              });
             },
          onSearch: (value) {
                setState(() {
                _applyFilters();
              });
             },
           ),
          const SizedBox(height: 16),

          // فلاتر إضافية
          Row(
            children: [
              // فلتر الحالة
              Expanded(
                child: AppWidgets.appCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  elevation: 0,
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'حالة الطلب',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    items: _statusOptions.map((status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedStatus = value;
                          _applyFilters();
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // فلتر الترتيب
              Expanded(
                child: AppWidgets.appCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  elevation: 0,
                  child: DropdownButtonFormField<String>(
                    value: _sortBy,
                    decoration: const InputDecoration(
                      labelText: 'ترتيب حسب',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    items: const [
                      DropdownMenuItem<String>(
                        value: 'date',
                        child: Text('التاريخ'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'total',
                        child: Text('المبلغ'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _sortBy = value;
                          _applyFilters();
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // زر تبديل اتجاه الترتيب
              AppWidgets.appButton(
                text: '',
                width: 48,
                height: 48,
                icon:
                    _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                onPressed: () {
                  setState(() {
                    _sortAscending = !_sortAscending;
                    _applyFilters();
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(ThemeData theme) {
    if (_filteredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: AppColors.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isNotEmpty || _selectedStatus != 'الكل'
                  ? 'لا توجد طلبات تطابق معايير البحث'
                  : 'لا توجد طلبات حالياً',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredOrders.length,
      itemBuilder: (context, index) {
        final order = _filteredOrders[index];
        final orderId = order['id'] as String;
        final orderNumber = order['orderNumber'] as String? ?? 'بدون رقم';
        final customerName = order['customerName'] as String? ?? 'عميل';
        final orderDate = order['orderDate'] as DateTime? ?? DateTime.now();
        final totalAmount = order['totalAmount'] as num? ?? 0;
        final status = order['status'] as String? ?? 'جديد';

        return AppWidgets.orderListItem(
          orderId: orderNumber,
          status: status,
          amount: totalAmount.toStringAsFixed(2), // ✅ تعديل هنا
          date: '${orderDate.day}/${orderDate.month}/${orderDate.year}', // ✅ تعديل هنا (تحويل DateTime إلى String)
          customerName: customerName,
          onTap: () => context.push('${RouteConstants.orderDetails}/$orderId'),
        );

      },
    );
  }
}
