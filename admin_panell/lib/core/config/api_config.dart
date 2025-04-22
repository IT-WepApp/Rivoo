/// تكوين إعدادات API للتطبيق
///
/// يحتوي هذا الملف على إعدادات الاتصال بالخادم الخلفي
/// مثل عناوين URL والمهلة الزمنية وإعدادات أخرى
class ApiConfig {
  /// عنوان URL الأساسي للخادم
  final String baseUrl;
  
  /// المهلة الزمنية للاتصال بالخادم بالثواني
  final int timeoutSeconds;
  
  /// مفتاح API إذا كان مطلوبًا
  final String? apiKey;
  
  /// إنشاء كائن جديد من تكوين API
  const ApiConfig({
    required this.baseUrl,
    this.timeoutSeconds = 30,
    this.apiKey,
  });
  
  /// إنشاء نسخة من التكوين للبيئة المحلية
  factory ApiConfig.development() {
    return const ApiConfig(
      baseUrl: 'http://localhost:8000/api',
      timeoutSeconds: 30,
    );
  }
  
  /// إنشاء نسخة من التكوين لبيئة الاختبار
  factory ApiConfig.staging() {
    return const ApiConfig(
      baseUrl: 'https://staging-api.rivoo.com/api',
      timeoutSeconds: 30,
    );
  }
  
  /// إنشاء نسخة من التكوين لبيئة الإنتاج
  factory ApiConfig.production() {
    return const ApiConfig(
      baseUrl: 'https://api.rivoo.com/api',
      timeoutSeconds: 30,
    );
  }
  
  /// الحصول على رؤوس HTTP الافتراضية
  Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (apiKey != null) 'X-API-Key': apiKey!,
  };
  
  /// إنشاء نسخة جديدة من التكوين مع تحديث بعض القيم
  ApiConfig copyWith({
    String? baseUrl,
    int? timeoutSeconds,
    String? apiKey,
  }) {
    return ApiConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
      apiKey: apiKey ?? this.apiKey,
    );
  }
}

/// مزود لتكوين API يمكن استخدامه مع Riverpod
final apiConfigProvider = ApiConfig.development();
