import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_widgets/shared_widgets.dart';
import '../../application/location_notifier.dart';

class LocationTrackingPage extends ConsumerWidget {
  const LocationTrackingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {   
    final locationAsyncValue = ref.watch(locationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تتبع الموقع'),
      ),
      body: locationAsyncValue.when(
        data: (location) {
          return Column(
            children: [
              Expanded(
                flex: 3,
                child: _buildMap(location),
              ),
              Expanded(
                flex: 1,
                child: _buildTripInfo(),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: AppButton(
                  onPressed: () {
                    ref.read(locationProvider.notifier).updateLocationOnce();
                  },
                  text: 'تحديث الموقع',
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('جارٍ جلب الموقع...'),
              SizedBox(height: 20),
              CircularProgressIndicator(),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('خطأ في جلب الموقع: $error'),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => ref.invalidate(locationProvider),
                  child: const Text('إعادة المحاولة'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMap(Position location) {
    final deliveryLocation = LatLng(location.latitude, location.longitude);
    const destination = LatLng(24.7136, 46.6753);

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: deliveryLocation,
        zoom: 15,
      ),
      markers: {
        Marker(
          markerId: const MarkerId('deliveryLocation'),
          position: deliveryLocation,
          infoWindow: const InfoWindow(title: 'موقعك'),
        ),
        Marker(
          markerId: const MarkerId('destination'),
          position: destination,
          infoWindow: const InfoWindow(title: 'وجهة التوصيل'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      },
    );
  }

  Widget _buildTripInfo() {
    const remainingDistance = '5 كم';
    const eta = '10 دقائق';
    final directions = [
      'الاتجاه شمالًا',
      'انعطف يمينًا',
      'استمر على طول الطريق',
    ];

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'المسافة المتبقية: $remainingDistance',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.access_time, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'الوقت المقدر للوصول: $eta',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'التعليمات:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: directions.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_forward, size: 16),
                        const SizedBox(width: 8),
                        Text(directions[index]),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
