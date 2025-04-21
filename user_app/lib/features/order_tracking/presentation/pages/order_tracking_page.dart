import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:shared_models/shared_models.dart';
import 'package:shared_widgets/shared_widgets.dart';
import 'package:user_app/features/order_tracking/application/order_tracking_notifier.dart';
import 'package:location/location.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OrderTrackingPage extends ConsumerStatefulWidget {
  final String orderId;

  const OrderTrackingPage({super.key, required this.orderId});

  @override
  ConsumerState<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends ConsumerState<OrderTrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();
  final Map<MarkerId, Marker> _markers = {};
  final Set<Polyline> _polylines = {};
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
    ref.invalidate(orderTrackingProvider(widget.orderId));
  }

  @override
  Widget build(BuildContext context) {
    final trackingState = ref.watch(orderTrackingProvider(widget.orderId));
    final orderDetails = trackingState.orderData;
    final deliveryLocationAsync = trackingState.deliveryLocation;
    final locationHistoryAsync = trackingState.locationHistory;
    final l10n = AppLocalizations.of(context)!;

    // تحديث العلامات والمسار عند تغير الموقع
    ref.listen<AsyncValue<LocationData?>>(
      orderTrackingProvider(widget.orderId).select((s) => s.deliveryLocation),
      (_, next) {
        next.whenData((location) {
          if (location != null &&
              location.latitude != null &&
              location.longitude != null) {
            _updateMarkers(location, orderDetails);
            _moveCamera(location);
          }
        });
      },
    );

    // تحديث المسار عند تغير سجل المواقع
    ref.listen<AsyncValue<List<LocationData>>>(
      orderTrackingProvider(widget.orderId).select((s) => s.locationHistory),
      (_, next) {
        next.whenData((locationHistory) {
          if (locationHistory.isNotEmpty) {
            _updatePolylines(locationHistory);
          }
        });
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.trackingTitle),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshTracking,
            tooltip: l10n.retry,
          ),
        ],
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
                  polylines: _polylines,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  compassEnabled: true,
                  zoomControlsEnabled: true,
                  trafficEnabled: true,
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
                // عرض الحالة الحالية للتتبع
                Positioned(
                  top: 10,
                  left: 10,
                  right: 10,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: deliveryLocationAsync.when(
                        data: (location) => location != null
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.directions_car,
                                      color: Colors.green),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.estimatedArrival,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 4),
                                  Text('15-20 ${l10n.minutesAbbreviation}'),
                                ],
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.access_time,
                                      color: Colors.orange),
                                  const SizedBox(width: 8),
                                  Text(l10n.waitingForDriver),
                                ],
                              ),
                        loading: () => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 8),
                            Text(l10n.loadingLocationData),
                          ],
                        ),
                        error: (err, _) => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(l10n.locationError),
                          ],
                        ),
                      ),
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
                    return Center(child: Text(l10n.orderInfoNotAvailable));
                  }
                  return _buildOrderDetailsCard(order, deliveryLocationAsync);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, st) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text('${l10n.errorLoadingOrder}: $err'),
                      const SizedBox(height: 16),
                      AppButton(
                        text: l10n.retry,
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

  Widget _buildOrderDetailsCard(
      OrderModel order, AsyncValue<LocationData?> deliveryLocationAsync) {
    final l10n = AppLocalizations.of(context)!;
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
                  '${l10n.orderNumber}: ${order.id.substring(0, 8)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                      ? '${l10n.estimatedArrival}: $estimatedTime ${l10n.minutesAbbreviation}'
                      : l10n.calculatingArrivalTime,
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
                        ? Text(l10n.driverOnTheWay)
                        : Text(l10n.waitingForDriverLocation),
                    loading: () => Text(l10n.trackingDriverLocation),
                    error: (err, _) => Text('${l10n.locationError}: $err',
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
                Text(
                    '${l10n.totalAmount}: ${order.total.toStringAsFixed(2)} ${l10n.currencySymbol}'),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: AppButton(
                    text: l10n.orderDetails,
                    onPressed: () {
                      context.goNamed('order-details',
                          pathParameters: {'orderId': order.id});
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppButton(
                    text: l10n.contactDelivery,
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
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deliveryPersonInfo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage('assets/delivery_person.png'),
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 40, color: Colors.white),
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
              text: l10n.call,
              icon: Icons.phone,
              onPressed: () {
                Navigator.of(context).pop();
                // تنفيذ الاتصال بالمندوب
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.callingDriver),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            AppButton(
              text: l10n.message,
              icon: Icons.message,
              onPressed: () {
                Navigator.of(context).pop();
                // تنفيذ إرسال رسالة للمندوب
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.openingChatWithDriver),
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
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  // تحديث العلامات على الخريطة
  void _updateMarkers(
      LocationData location, AsyncValue<OrderModel?> orderAsync) {
    if (location.latitude == null || location.longitude == null) return;

    const deliveryMarkerId = MarkerId('delivery_marker');
    final deliveryMarker = Marker(
      markerId: deliveryMarkerId,
      position: LatLng(location.latitude!, location.longitude!),
      infoWindow:
          InfoWindow(title: AppLocalizations.of(context)!.driverLocation),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      // إضافة تدوير العلامة حسب اتجاه السائق إذا كان متوفرًا
      rotation: location.heading ?? 0.0,
      flat: location.heading != null,
    );

    // إضافة علامة للعنوان المستهدف (عنوان العميل)
    const destinationMarkerId = MarkerId('destination_marker');

    // استخدام عنوان العميل من الطلب إذا كان متوفرًا
    double destinationLat = 24.7136;
    double destinationLng = 46.6753;

    orderAsync.whenData((order) {
      if (order?.deliveryAddress?.latitude != null &&
          order?.deliveryAddress?.longitude != null) {
        destinationLat = order!.deliveryAddress!.latitude!;
        destinationLng = order.deliveryAddress!.longitude!;
      }
    });

    final destinationMarker = Marker(
      markerId: destinationMarkerId,
      position: LatLng(destinationLat, destinationLng),
      infoWindow:
          InfoWindow(title: AppLocalizations.of(context)!.deliveryAddress),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    if (mounted) {
      setState(() {
        _markers[deliveryMarkerId] = deliveryMarker;
        _markers[destinationMarkerId] = destinationMarker;
      });
    }
  }

  // تحديث المسار على الخريطة
  void _updatePolylines(List<LocationData> locationHistory) {
    if (locationHistory.length < 2) return;

    final List<LatLng> points = locationHistory
        .where((loc) => loc.latitude != null && loc.longitude != null)
        .map((loc) => LatLng(loc.latitude!, loc.longitude!))
        .toList();

    final polyline = Polyline(
      polylineId: const PolylineId('driver_path'),
      color: Colors.blue,
      points: points,
      width: 5,
      patterns: [PatternItem.dash(10), PatternItem.gap(5)],
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );

    if (mounted) {
      setState(() {
        _polylines.clear();
        _polylines.add(polyline);
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

  // حساب الوقت المتوقع للوصول
  String? _calculateEstimatedTime(AsyncValue<LocationData?> locationAsync) {
    return locationAsync.when(
      data: (location) {
        if (location == null) return null;

        // في التطبيق الحقيقي، سيتم استخدام خدمة حساب المسافة والوقت
        // مثل Google Distance Matrix API
        // هنا نستخدم قيمة ثابتة للتجربة
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
    final l10n = AppLocalizations.of(context)!;

    switch (status.toLowerCase()) {
      case 'pending':
        return l10n.orderStatusPending;
      case 'processing':
        return l10n.orderStatusProcessing;
      case 'accepted':
        return l10n.orderStatusAccepted;
      case 'shipped':
        return l10n.orderStatusShipped;
      case 'out_for_delivery':
        return l10n.orderStatusOutForDelivery;
      case 'delivered':
        return l10n.orderStatusDelivered;
      case 'cancelled':
        return l10n.orderStatusCancelled;
      default:
        return status;
    }
  }
}
