import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/services/order_service.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/theme/app_colors.dart';

/// صفحة إدارة الطلبات للبائع
class OrdersManagementPage extends ConsumerStatefulWidget {
  const OrdersManagementPage({Key? key}) : super(key: key);

  @override
  ConsumerState<OrdersManagementPage> createState() => _OrdersManagementPageState();
}

class _OrdersManagementPageState extends ConsumerState<OrdersManagementPage> {
  bool _isLoading = true;
  bool _isSubmitting = false;
  String _errorMessage = '';
  
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _filteredOrders = [];
  
  String _searchQuery = '';
  String _selectedStatus = 'الكل';
  List<String> _statusOptions = ['الكل', 'جديد', 'قيد التحضير', 'جاهز للتسليم', 'قيد التوصيل', 'تم التسليم', 'ملغي'];
  
  String _sortBy = 'date';
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _loadOrders();
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
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((order) {
        final orderNumber = order['orderNumber'] as String? ?? '';
        final customerName = order['customerName'] as String? ?? '';
        final searchLower = _searchQuery.toLowerCase();
        
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
        return _sortAscending ? valueA.compareTo(valueB) : valueB.compareTo(valueA);
      } else if (valueA is num && valueB is num) {
        return _sortAscending ? valueA.compareTo(valueB) : valueB.compareTo(valueA);
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
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
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
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.error),
                            ),
                            child: Text(
                              _errorMessage,
                              style: TextStyle(color: AppColors.error),
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
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // شريط البحث
          TextField(
            decoration: InputDecoration(
              hintText: 'البحث برقم الطلب أو اسم العميل...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
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
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'حالة الطلب',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              const SizedBox(width: 16),
              
              // فلتر الترتيب
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _sortBy,
                  decoration: const InputDecoration(
                    labelText: 'ترتيب حسب',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              const SizedBox(width: 8),
              
              // زر تبديل اتجاه الترتيب
              IconButton(
                icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
                onPressed: () {
                  setState(() {
                    _sortAscending = !_sortAscending;
                    _applyFilters();
                  });
                },
                tooltip: _sortAscending ? 'ترتيب تصاعدي' : 'ترتيب تنازلي',
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
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty || _selectedStatus != 'الكل'
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
        final itemsCount = order['items']?.length ?? 0;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () => context.push('${RouteConstants.orderDetails}/$orderId'),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // معلومات الطلب الأساسية
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // رقم الطلب
                      Text(
                        'طلب #$orderNumber',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      // حالة الطلب
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: _getStatusColor(status),
                          ),
                        ),
                        child: Text(
                          status,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _getStatusColor(status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // معلومات العميل والتاريخ
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // اسم العميل
                      Row(
                        children: [
                          Icon(Icons.person, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            customerName,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      
                      // تاريخ الطلب
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            '${orderDate.day}/${orderDate.month}/${orderDate.year} - ${orderDate.hour}:${orderDate.minute.toString().padLeft(2, '0')}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // المبلغ وعدد العناصر
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // المبلغ الإجمالي
                      Row(
                        children: [
                          Icon(Icons.attach_money, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            '${totalAmount.toStringAsFixed(2)} ر.س',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      
                      // عدد العناصر
                      Row(
                        children: [
                          Icon(Icons.shopping_bag, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            '$itemsCount ${itemsCount == 1 ? 'منتج' : 'منتجات'}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const Divider(height: 24),
                  
                  // أزرار التحكم
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // زر عرض التفاصيل
                      OutlinedButton.icon(
                        onPressed: () => context.push('${RouteConstants.orderDetails}/$orderId'),
                        icon: const Icon(Icons.visibility),
                        label: const Text('عرض التفاصيل'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                          side: BorderSide(color: theme.colorScheme.primary),
                        ),
                      ),
                      
                      // زر تحديث الحالة
                      _buildStatusUpdateButton(theme, orderId, status),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusUpdateButton(ThemeData theme, String orderId, String currentStatus) {
    // تحديد الحالة التالية بناءً على الحالة الحالية
    String nextStatus;
    Color buttonColor;
    
    switch (currentStatus) {
      case 'جديد':
        nextStatus = 'قيد التحضير';
        buttonColor = Colors.orange;
        break;
      case 'قيد التحضير':
        nextStatus = 'جاهز للتسليم';
        buttonColor = Colors.purple;
        break;
      case 'جاهز للتسليم':
        nextStatus = 'قيد التوصيل';
        buttonColor = Colors.amber;
        break;
      case 'قيد التوصيل':
        nextStatus = 'تم التسليم';
        buttonColor = Colors.green;
        break;
      case 'تم التسليم':
        // لا يمكن تغيير الحالة بعد التسليم
        return const SizedBox.shrink();
      case 'ملغي':
        // لا يمكن تغيير الحالة بعد الإلغاء
        return const SizedBox.shrink();
      default:
        nextStatus = 'قيد التحضير';
        buttonColor = Colors.orange;
    }
    
    return ElevatedButton.icon(
      onPressed: () => _updateOrderStatus(orderId, nextStatus),
      icon: const Icon(Icons.arrow_forward),
      label: Text('تحديث إلى $nextStatus'),
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}
