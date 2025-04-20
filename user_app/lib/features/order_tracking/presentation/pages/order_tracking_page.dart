import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:shared_models/shared_models.dart'; // Use shared models
import 'package:shared_widgets/shared_widgets.dart'; // Use shared widgets
import 'package:user_app/features/order_tracking/application/order_tracking_notifier.dart'; // Correct import
import 'package:location/location.dart'; // For LocationData
import 'package:go_router/go_router.dart'; // For navigation

class OrderTrackingPage extends ConsumerStatefulWidget {
  final String orderId;

  const OrderTrackingPage({super.key, required this.orderId});

  @override
  ConsumerState<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends ConsumerState<OrderTrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();
  final Map<MarkerId, Marker> _markers = {}; // Use final

  // Default camera position (e.g., center of a region)
  static const CameraPosition _kDefaultLocation = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    // Watch the tracking state for the specific orderId
    final trackingState = ref.watch(orderTrackingProvider(widget.orderId));
    final orderDetails = trackingState.orderData;
    final deliveryLocationAsync = trackingState.deliveryLocation; // Keep async value

     // Update markers when location changes
    ref.listen<AsyncValue<LocationData?>>(orderTrackingProvider(widget.orderId).select((s) => s.deliveryLocation), (_, next) {
        next.whenData((location) {
           if (location != null && location.latitude != null && location.longitude != null) {
             _updateMarkers(location);
           }
        });
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Order'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          // Map Area
          Expanded(
            flex: 3, // Give map more space
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _kDefaultLocation,
              onMapCreated: (GoogleMapController controller) {
                if (!_controller.isCompleted) {
                  _controller.complete(controller);
                }
              },
              markers: Set<Marker>.of(_markers.values),
            ),
          ),
          // Order Details Area
          Expanded(
            flex: 2, // Less space for details
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: orderDetails.when(
                data: (order) {
                  if (order == null) {
                    return const Center(child: Text('Order details not available.'));
                  }
                  return _buildOrderDetailsCard(order, deliveryLocationAsync); // Pass location async value
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, st) => Center(child: Text('Error loading order: $err')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsCard(OrderModel order, AsyncValue<LocationData?> deliveryLocationAsync) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID: ${order.id}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Status: ${order.status}', style: TextStyle(fontWeight: FontWeight.bold, color: _getStatusColor(order.status))),
            const SizedBox(height: 8),
            Text('Total: \$${order.total.toStringAsFixed(2)}'),
             const Divider(height: 20),
             // Show delivery location status
             deliveryLocationAsync.when(
                data: (loc) => Text(loc != null ? 'Delivery Location Updated' : 'Awaiting delivery location...'),
                loading: () => const Text('Tracking delivery location...'),
                error: (err, _) => Text('Location Error: $err', style: const TextStyle(color: Colors.red)),
             ),
             const Spacer(), 
             Center(
               child: AppButton(text: 'View Full Details', onPressed: () {
                 // Use correct name based on router.dart
                 context.goNamed('order-details', pathParameters: {'orderId': order.id});
               }),
             )
          ],
        ),
      ),
    );
  }

  // Updates the markers on the map
  void _updateMarkers(LocationData location) {
    // Null check lat/lng rigorously
    if (location.latitude == null || location.longitude == null) return; 

    final markerId = MarkerId('delivery_${widget.orderId}');
    final marker = Marker(
      markerId: markerId,
      position: LatLng(location.latitude!, location.longitude!),
      infoWindow: const InfoWindow(title: 'Delivery Location'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure), 
    );

    // Check mounted before calling setState in listener callback
    if (mounted) {
      setState(() {
        _markers[markerId] = marker;
      });
    }
  }
  
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'processing':
      case 'accepted': return Colors.blue;
      case 'shipped':
      case 'out for delivery': return Colors.purple;
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }
}
