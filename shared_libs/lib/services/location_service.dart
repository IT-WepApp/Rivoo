import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';

/// خدمة الموقع المسؤولة عن تحديد وإدارة موقع المستخدم
/// تستخدم مكتبة Geolocator للحصول على الموقع الجغرافي ومكتبة Geocoding للتحويل بين الإحداثيات والعناوين
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// تهيئة خدمة الموقع
  Future<void> init() async {
    await _checkPermission();
  }

  /// التحقق من أذونات الموقع
  Future<bool> _checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // التحقق من تفعيل خدمة الموقع
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (kDebugMode) {
        print('خدمات الموقع غير مفعلة');
      }
      return false;
    }

    // التحقق من أذونات الموقع
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (kDebugMode) {
          print('تم رفض أذونات الموقع');
        }
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (kDebugMode) {
        print('تم رفض أذونات الموقع بشكل دائم');
      }
      return false;
    }

    return true;
  }

  /// الحصول على الموقع الحالي
  Future<Position?> getCurrentLocation() async {
    try {
      if (!await _checkPermission()) {
        return null;
      }
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      if (kDebugMode) {
        print('خطأ في الحصول على الموقع: $e');
      }
      return null;
    }
  }

  /// الحصول على آخر موقع معروف
  Future<Position?> getLastKnownLocation() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      if (kDebugMode) {
        print('خطأ في الحصول على آخر موقع معروف: $e');
      }
      return null;
    }
  }

  /// حساب المسافة بين موقعين (بالمتر)
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// تحويل الإحداثيات إلى عنوان
  Future<List<Placemark>?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      return await placemarkFromCoordinates(latitude, longitude);
    } catch (e) {
      if (kDebugMode) {
        print('خطأ في تحويل الإحداثيات إلى عنوان: $e');
      }
      return null;
    }
  }

  /// تحويل العنوان إلى إحداثيات
  Future<List<Location>?> getCoordinatesFromAddress(String address) async {
    try {
      return await locationFromAddress(address);
    } catch (e) {
      if (kDebugMode) {
        print('خطأ في تحويل العنوان إلى إحداثيات: $e');
      }
      return null;
    }
  }

  /// مراقبة تغييرات الموقع
  Stream<Position> getPositionStream({
    int distanceFilter = 10,
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      ),
    );
  }
}
