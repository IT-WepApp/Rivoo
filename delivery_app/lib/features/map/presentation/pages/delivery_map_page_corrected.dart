import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../../../shared_libs/lib/models/models.dart'; // Import OrderModel
import '../../../../../../shared_libs/lib/services/services.dart'; // Import orderServiceProvider
import '../../../../../../shared_libs/lib/widgets/widgets .dart';
import '../../../location/application/location_notifier.dart';

/// Fetch a single [OrderModel] by its ID.
final orderDetailsProvider = FutureProvider.autoDispose
    .family<OrderModel?, String>((ref, orderId) async {
  final orderService = ref.watch(orderServiceProvider);
  // Ensure getOrder returns OrderModel? or handle potential null
  return await orderService.getOrder(orderId);
});

class DeliveryMapPage extends ConsumerStatefulWidget {
  final String orderId;

  const DeliveryMapPage({
    required this.orderId,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<DeliveryMapPage> createState() => _DeliveryMapPageState();
}

class _DeliveryMapPageState extends ConsumerState<DeliveryMapPage> {
  final Completer<GoogleMapController> _mapController = Completer();
  final Set<Marker> _markers = {};

  // Stopwatch logic is internal to DeliveryStopwatch widget now
  // Timer? _stopwatchTimer;
  // Duration _elapsedTime = Duration.zero;
  // bool _isTimerRunning = false;

  @override
  void dispose() {
    // _stopStopwatch(); // Managed internally by DeliveryStopwatch
    super.dispose();
  }

  // Stopwatch logic is internal to DeliveryStopwatch widget now
  // void _startStopwatch() { ... }
  // void _stopStopwatch() { ... }
  // void _resetStopwatch() { ... }

  void _updateMarkers(LatLng currentPos, LatLng? destinationPos) {
    // Avoid calling setState if the widget is disposed
    if (!mounted) return;
    setState(() {
      _markers
        ..clear()
        ..add(
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: currentPos,
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure),
            infoWindow: const InfoWindow(title: 'Your Location'),
          ),
        );
      // Only add destination marker if coordinates are available
      if (destinationPos != null) {
        _markers.add(
          Marker(
            markerId: const MarkerId('destination'),
            position: destinationPos,
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: const InfoWindow(title: 'Destination'),
          ),
        );
      }
    });

    _moveCameraToBounds(currentPos, destinationPos);
  }

  Future<void> _moveCameraToBounds(LatLng pos1, LatLng? pos2) async {
    if (!_mapController.isCompleted) return;
    final controller = await _mapController.future;
    // Avoid camera movements if the widget is disposed
    if (!mounted) return;

    if (pos2 == null) {
      // If no destination, just center on current location
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(pos1, 15),
      );
    } else {
      // If destination exists, fit both markers
      final southWest = LatLng(
        pos1.latitude < pos2.latitude ? pos1.latitude : pos2.latitude,
        pos1.longitude < pos2.longitude ? pos1.longitude : pos2.longitude,
      );
      final northEast = LatLng(
        pos1.latitude > pos2.latitude ? pos1.latitude : pos2.latitude,
        pos1.longitude > pos2.longitude ? pos1.longitude : pos2.longitude,
      );
      final bounds = LatLngBounds(southwest: southWest, northeast: northEast);

      controller.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 50), // Adjust padding as needed
      );
    }
  }

  void _markDelivered() {
    // call your orderService to mark the order as delivered
    debugPrint('Order ${widget.orderId} marked as delivered');
    // Optionally navigate back or show confirmation
  }

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(locationProvider);
    final orderAsync = ref.watch(orderDetailsProvider(widget.orderId));

    // Simplified listener: Update markers when location or order data is available.
    ref.listen(
      locationProvider,
      (AsyncValue<Position>? previous, AsyncValue<Position> next) {
        if (next is AsyncData<Position> &&
            orderAsync is AsyncData<OrderModel?>) {
          final currentPosition =
              LatLng(next.value.latitude, next.value.longitude);
          // Destination LatLng is null as OrderModel doesn't have coordinates.
          _updateMarkers(currentPosition, null);
        }
      },
    );
    ref.listen(orderDetailsProvider(widget.orderId),
        (AsyncValue<OrderModel?>? previous, AsyncValue<OrderModel?> next) {
      if (next is AsyncData<OrderModel?> &&
          locationAsync is AsyncData<Position>) {
        final currentPosition =
            LatLng(locationAsync.value.latitude, locationAsync.value.longitude);
        // Destination LatLng is null as OrderModel doesn't have coordinates.
        _updateMarkers(currentPosition, null);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Order Delivery: ${widget.orderId}'),
        actions: const [
          ConnectionStatusIndicator(),
        ],
      ),
      body: Stack(
        children: [
          locationAsync.when(
            data: (position) {
              // Initial marker setup when data is first available
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  final currentPosition =
                      LatLng(position.latitude, position.longitude);
                  // Destination LatLng is null
                  _updateMarkers(currentPosition, null);
                }
              });

              return GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: LatLng(position.latitude, position.longitude),
                  zoom: 14.0,
                ),
                onMapCreated: (ctrl) {
                  if (!_mapController.isCompleted && mounted) {
                    _mapController.complete(ctrl);
                  }
                  // Markers are updated via listeners and postFrameCallback
                },
                markers: _markers,
                myLocationEnabled: false, // Using custom marker
                myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
              );
            },
            // Ensure loading and error states return valid Widgets
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) =>
                Center(child: Text('Error loading map data: $err')),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _markDelivered,
              child: const Text('Mark as Delivered'),
            ),
          ),
          const Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                // Removed the incorrect startTime parameter
                child: DeliveryStopwatch(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
