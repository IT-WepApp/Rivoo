import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';

/// خدمة قياس الأداء باستخدام Firebase Performance
///
/// تستخدم هذه الخدمة لقياس أداء التطبيق وتتبع الأحداث والعمليات المهمة
/// لتحسين تجربة المستخدم وتحديد نقاط الضعف في الأداء

class PerformanceService {
  // نسخة واحدة من الخدمة (Singleton)
  static final PerformanceService _instance = PerformanceService._internal();
  
  // مثيل Firebase Performance
  final FirebasePerformance _performance = FirebasePerformance.instance;
  
  // قائمة بالمقاييس النشطة
  final Map<String, Trace> _activeTraces = {};
  
  // منشئ خاص
  PerformanceService._internal();
  
  // الحصول على النسخة الوحيدة من الخدمة
  factory PerformanceService() {
    return _instance;
  }
  
  /// تهيئة خدمة قياس الأداء
  Future<void> initialize() async {
    // تمكين جمع البيانات في وضع الإنتاج فقط
    await _performance.setPerformanceCollectionEnabled(!kDebugMode);
  }
  
  /// بدء قياس أداء عملية معينة
  ///
  /// يستخدم لقياس الوقت المستغرق لإكمال عملية معينة
  /// مثل تحميل البيانات أو تهيئة الشاشة
  Trace? startTrace(String traceName) {
    if (_activeTraces.containsKey(traceName)) {
      if (kDebugMode) {
        print('Trace "$traceName" is already active');
      }
      return _activeTraces[traceName];
    }
    
    try {
      final trace = _performance.newTrace(traceName);
      trace.start();
      _activeTraces[traceName] = trace;
      
      if (kDebugMode) {
        print('Started trace: $traceName');
      }
      
      return trace;
    } catch (e) {
      if (kDebugMode) {
        print('Error starting trace "$traceName": $e');
      }
      return null;
    }
  }
  
  /// إنهاء قياس أداء عملية معينة
  ///
  /// يجب استدعاؤه بعد الانتهاء من العملية التي تم بدء قياسها
  Future<void> stopTrace(String traceName) async {
    if (!_activeTraces.containsKey(traceName)) {
      if (kDebugMode) {
        print('Trace "$traceName" is not active');
      }
      return;
    }
    
    try {
      final trace = _activeTraces[traceName]!;
      await trace.stop();
      _activeTraces.remove(traceName);
      
      if (kDebugMode) {
        print('Stopped trace: $traceName');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error stopping trace "$traceName": $e');
      }
    }
  }
  
  /// إضافة قيمة عداد إلى قياس أداء نشط
  ///
  /// يستخدم لتتبع عدد العناصر أو العمليات ضمن قياس أداء معين
  Future<void> incrementMetric(String traceName, String metricName, int incrementBy) async {
    if (!_activeTraces.containsKey(traceName)) {
      if (kDebugMode) {
        print('Cannot increment metric: Trace "$traceName" is not active');
      }
      return;
    }
    
    try {
      final trace = _activeTraces[traceName]!;
      trace.incrementMetric(metricName, incrementBy);
      
      if (kDebugMode) {
        print('Incremented metric "$metricName" in trace "$traceName" by $incrementBy');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error incrementing metric "$metricName" in trace "$traceName": $e');
      }
    }
  }
  
  /// تعيين قيمة عداد في قياس أداء نشط
  ///
  /// يستخدم لتعيين قيمة محددة لعداد ضمن قياس أداء معين
  Future<void> setMetric(String traceName, String metricName, int value) async {
    if (!_activeTraces.containsKey(traceName)) {
      if (kDebugMode) {
        print('Cannot set metric: Trace "$traceName" is not active');
      }
      return;
    }
    
    try {
      final trace = _activeTraces[traceName]!;
      trace.setMetric(metricName, value);
      
      if (kDebugMode) {
        print('Set metric "$metricName" in trace "$traceName" to $value');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error setting metric "$metricName" in trace "$traceName": $e');
      }
    }
  }
  
  /// إضافة بيانات وصفية إلى قياس أداء نشط
  ///
  /// يستخدم لإضافة معلومات إضافية لتحليل الأداء
  Future<void> putAttribute(String traceName, String attributeName, String value) async {
    if (!_activeTraces.containsKey(traceName)) {
      if (kDebugMode) {
        print('Cannot put attribute: Trace "$traceName" is not active');
      }
      return;
    }
    
    try {
      final trace = _activeTraces[traceName]!;
      trace.putAttribute(attributeName, value);
      
      if (kDebugMode) {
        print('Added attribute "$attributeName" to trace "$traceName" with value "$value"');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding attribute "$attributeName" to trace "$traceName": $e');
      }
    }
  }
  
  /// إنشاء قياس أداء HTTP
  ///
  /// يستخدم لقياس أداء طلبات HTTP
  HttpMetric? newHttpMetric(String url, HttpMethod method) {
    try {
      final httpMetric = _performance.newHttpMetric(url, method);
      
      if (kDebugMode) {
        print('Created HTTP metric for ${method.toString()} $url');
      }
      
      return httpMetric;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating HTTP metric for ${method.toString()} $url: $e');
      }
      return null;
    }
  }
  
  /// قياس أداء دالة معينة
  ///
  /// يستخدم لقياس الوقت المستغرق لتنفيذ دالة معينة
  Future<T> traceFunction<T>(String traceName, Future<T> Function() function) async {
    final trace = startTrace(traceName);
    
    try {
      final result = await function();
      await stopTrace(traceName);
      return result;
    } catch (e) {
      await stopTrace(traceName);
      rethrow;
    }
  }
  
  /// قياس أداء دالة متزامنة
  ///
  /// يستخدم لقياس الوقت المستغرق لتنفيذ دالة متزامنة
  T traceSyncFunction<T>(String traceName, T Function() function) {
    final trace = startTrace(traceName);
    
    try {
      final result = function();
      stopTrace(traceName);
      return result;
    } catch (e) {
      stopTrace(traceName);
      rethrow;
    }
  }
}
