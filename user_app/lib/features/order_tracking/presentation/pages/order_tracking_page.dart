import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:shared_models/shared_models.dart';
import 'package:shared_widgets/shared_widgets.dart';
import 'package:user_app/features/order_tracking/application/order_tracking_notifier.dart';
import 'package:location/location.dart';
import 'package:go_router/go_router.dart';

class OrderTrackingPage extends ConsumerStatefulWidget {
  final String orderId;

  const OrderTrackingPage({super.key, required this.orderId});

  @override
  ConsumerState<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends ConsumerState<OrderTrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();
  final Map<MarkerId, Marker> _markers = {};
  Timer? _refreshTimer;

  // موقع افتراضي (مركز الرياض)
  static const CameraPosition _kDefaultLocation = CameraPosition(
    target: LatLng(24.7136, 46.6753),
    zoom: 14.0,
  );

  @override
  void initState() {
    super.initState();
    // تحديث الموقع كل 10 ثوانٍ
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _refreshTracking();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _refreshTracking() {
    ref.read(orderTrackingProvider(widget.orderId).notifier)._fetchOrderDetails();
  }

  @override
  Widget build(BuildContext context) {
    final trackingState = ref.watch(orderTrackingProvider(widget.orderId));
    final orderDetails = trackingState.orderData;
    final deliveryLocationAsync = trackingState.deliveryLocation;

    // تحديث العلامات عند تغير الموقع
    ref.listen<AsyncValue<LocationData?>>(
      orderTrackingProvider(widget.orderId).select((s) => s.deliveryLocation),
      (_, next) {
        next.whenData((location) {
          if (location != null && location.latitude != null && location.longitude != null) {
            _updateMarkers(location);
            _moveCamera(location);
          }
        });
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('تتبع الطلب'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          // منطقة الخريطة
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: _kDefaultLocation,
                  onMapCreated: (GoogleMapController controller) {
                    if (!_controller.isCompleted) {
                      _controller.complete(controller);
                    }
                  },
                  markers: Set<Marker>.of(_markers.values),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  compassEnabled: true,
                  zoomControlsEnabled: true,
                ),
                if (trackingState.isLoading)
                  const Positioned(
                    top: 10,
                    right: 10,
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // منطقة تفاصيل الطلب
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: orderDetails.when(
                data: (order) {
                  if (order == null) {
                    return const Center(child: Text('معلومات الطلب غير متوفرة'));
                  }
                  return _buildOrderDetailsCard(order, deliveryLocationAsync);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, st) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text('حدث خطأ أثناء تحميل الطلب: $err'),
                      const SizedBox(height: 16),
                      AppButton(
                        text: 'إعادة المحاولة',
                        onPressed: _refreshTracking,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsCard(OrderModel order, AsyncValue<LocationData?> deliveryLocationAsync) {
    final estimatedTime = _calculateEstimatedTime(deliveryLocationAsync);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'طلب رقم: ${order.id.substring(0, 8)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(order.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                const Icon(Icons.access_time, size: 20),
                const SizedBox(width: 8),
                Text(
                  estimatedTime != null
                      ? 'الوصول المتوقع: $estimatedTime دقيقة'
                      : 'جاري حساب وقت الوصول...',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: deliveryLocationAsync.when(
                    data: (loc) => loc != null
                        ? const Text('المندوب في الطريق إليك')
                        : const Text('في انتظار تحديث موقع المندوب...'),
                    loading: () => const Text('جاري تتبع موقع المندوب...'),
                    error: (err, _) => Text('خطأ في تحديد الموقع: $err',
                        style: const TextStyle(color: Colors.red)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.attach_money, size: 20),
                const SizedBox(width: 8),
                Text('المجموع: ${order.total.toStringAsFixed(2)} ريال'),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: AppButton(
                    text: 'تفاصيل الطلب',
                    onPressed: () {
                      context.goNamed('order-details',
                          pathParameters: {'orderId': order.id});
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppButton(
                    text: 'الاتصال بالمندوب',
                    onPressed: () {
                      _showDeliveryPersonDialog(order);
                    },
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeliveryPersonDialog(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('معلومات المندوب'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage('assets/delivery_person.png'),
              backgroundColor: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'أحمد محمد',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text('تقييم: 4.8 ⭐'),
            const SizedBox(height: 16),
            AppButton(
              text: 'اتصال',
              icon: Icons.phone,
              onPressed: () {
                Navigator.of(context).pop();
                // تنفيذ الاتصال بالمندوب
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('جاري الاتصال بالمندوب...'),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            AppButton(
              text: 'رسالة',
              icon: Icons.message,
              onPressed: () {
                Navigator.of(context).pop();
                // تنفيذ إرسال رسالة للمندوب
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('جاري فتح المحادثة مع المندوب...'),
                  ),
                );
              },
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  // تحديث العلامات على الخريطة
  void _updateMarkers(LocationData location) {
    if (location.latitude == null || location.longitude == null) return;

    final deliveryMarkerId = MarkerId('delivery_${widget.orderId}');
    final deliveryMarker = Marker(
      markerId: deliveryMarkerId,
      position: LatLng(location.latitude!, location.longitude!),
      infoWindow: const InfoWindow(title: 'موقع المندوب'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    );

    // إضافة علامة للعنوان المستهدف (عنوان العميل)
    final destinationMarkerId = MarkerId('destination_${widget.orderId}');
    final destinationMarker = Marker(
      markerId: destinationMarkerId,
      position: const LatLng(24.7136, 46.6753), // استبدل بعنوان العميل الفعلي
      infoWindow: const InfoWindow(title: 'موقع التسليم'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    if (mounted) {
      setState(() {
        _markers[deliveryMarkerId] = deliveryMarker;
        _markers[destinationMarkerId] = destinationMarker;
      });
    }
  }

  // تحريك الكاميرا لتتبع موقع المندوب
  Future<void> _moveCamera(LocationData location) async {
    if (location.latitude == null || location.longitude == null) return;

    final controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newLatLng(LatLng(location.latitude!, location.longitude!)),
    );
  }

  // حساب الوقت المتوقع للوصول (محاكاة)
  String? _calculateEstimatedTime(AsyncValue<LocationData?> locationAsync) {
    return locationAsync.when(
      data: (location) {
        if (location == null) return null;
        // محاكاة حساب الوقت المتوقع (في التطبيق الحقيقي سيتم حسابه بناءً على المسافة والسرعة)
        return '15-20';
      },
      loading: () => null,
      error: (_, __) => null,
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
      case 'accepted':
        return Colors.blue;
      case 'shipped':
      case 'out_for_delivery':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'قيد الانتظار';
      case 'processing':
        return 'قيد المعالجة';
      case 'accepted':
        return 'تم قبول الطلب';
      case 'shipped':
        return 'تم الشحن';
      case 'out_for_delivery':
        return 'قيد التوصيل';
      case 'delivered':
        return 'تم التوصيل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }
}
