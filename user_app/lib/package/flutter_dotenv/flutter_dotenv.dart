// هذا ملف جسر لمكتبة flutter_dotenv
// يقوم بتوفير واجهة وهمية لمكتبة flutter_dotenv

/// فئة لتحميل وقراءة متغيرات البيئة من ملف .env
class DotEnv {
  /// الحصول على نسخة واحدة من فئة DotEnv
  static final DotEnv instance = DotEnv._();
  
  /// متغيرات البيئة المحملة
  final Map<String, String> _env = {};
  
  /// الوصول إلى متغيرات البيئة المحملة
  Map<String, String> get env => _env;

  DotEnv._();

  /// تحميل متغيرات البيئة من ملف
  Future<bool> load({String fileName = '.env'}) async {
    // تنفيذ وهمي
    _env['API_URL'] = 'https://api.example.com';
    _env['API_KEY'] = 'dummy_api_key';
    return true;
  }

  /// الحصول على قيمة متغير بيئة
  String? get(String key) => _env[key];

  /// الحصول على قيمة متغير بيئة أو قيمة افتراضية إذا لم يكن موجودًا
  String maybeGet(String key, {String defaultValue = ''}) => _env[key] ?? defaultValue;

  /// التحقق من وجود متغير بيئة
  bool isDefined(String key) => _env.containsKey(key);

  /// تعيين قيمة متغير بيئة
  void put(String key, String value) => _env[key] = value;

  /// حذف متغير بيئة
  void remove(String key) => _env.remove(key);

  /// مسح جميع متغيرات البيئة
  void clear() => _env.clear();
}

/// نسخة عامة من فئة DotEnv للاستخدام المباشر
final dotenv = DotEnv.instance;
