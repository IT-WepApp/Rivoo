import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart'; // Assuming you are using geolocator package
import 'dart:async';
import 'dart:developer'; // Import developer log

class LocationNotifier extends StateNotifier<AsyncValue<Position>> {
  StreamSubscription<Position>? _positionStreamSubscription;

  LocationNotifier() : super(const AsyncLoading()) {
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    state = const AsyncLoading();
    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state =
            AsyncError('Location services are disabled.', StackTrace.current);
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state =
              AsyncError('Location permissions are denied', StackTrace.current);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = AsyncError(
            'Location permissions are permanently denied', StackTrace.current);
        return;
      }

      // Permissions are granted, get the current location
      final position = await Geolocator.getCurrentPosition();
      state = AsyncData(position);
      // Start listening for updates
      startTrackingLocation();
    } catch (e, stackTrace) {
      log('Error initializing location',
          error: e, stackTrace: stackTrace, name: 'LocationNotifier');
      state = AsyncError('Failed to get location: $e', stackTrace);
    }
  }

  void startTrackingLocation() {
    _stopTrackingLocation(); // Ensure previous stream is cancelled

    // Configure location settings (adjust accuracy and distance filter as needed)
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update only when moved 10 meters
    );

    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) {
        if (mounted) {
          // Check if notifier is still mounted
          state = AsyncData(position);
          //  Update backend with the new location if necessary
          // _updateBackendLocation(position);
        }
      },
      onError: (error, stackTrace) {
        log('Error tracking location',
            error: error, stackTrace: stackTrace, name: 'LocationNotifier');
        if (mounted) {
          state = AsyncError('Location tracking error: $error', stackTrace);
        }
        _stopTrackingLocation(); // Stop tracking on error
      },
      cancelOnError: false, // Keep listening even after an error (optional)
    );
  }

  void _stopTrackingLocation() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  // Optional: Force a single location update
  Future<void> updateLocationOnce() async {
    state = const AsyncLoading();
    try {
      final position = await Geolocator.getCurrentPosition();
      state = AsyncData(position);
    } catch (e, stackTrace) {
      log('Error getting single location update',
          error: e, stackTrace: stackTrace, name: 'LocationNotifier');
      state = AsyncError('Failed to get location: $e', stackTrace);
    }
  }

  // Optional: Method to update backend
  // Future<void> _updateBackendLocation(Position position) async {
  //   // ... call your API or Firestore service
  // }

  @override
  void dispose() {
    _stopTrackingLocation();
    super.dispose();
  }
}

final locationProvider =
    StateNotifierProvider<LocationNotifier, AsyncValue<Position>>((ref) {
  return LocationNotifier();
});
