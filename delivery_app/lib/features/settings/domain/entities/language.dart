/// نموذج بيانات اللغة
class Language {
  final String code;
  final String name;
  final String flag;
  const Language({
    required this.code,
    required this.name,
    required this.flag,
  });
  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      code: json['code'] as String,
      name: json['name'] as String,
      flag: json['flag'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'flag': flag,
    };
  }
}

/// قائمة اللغات المدعومة في التطبيق
class SupportedLanguages {
  static const List<Language> languages = [
    Language(code: 'ar', name: 'العربية', flag: '🇸🇦'),
    Language(code: 'en', name: 'English', flag: '🇺🇸'),
    Language(code: 'fr', name: 'Français', flag: '🇫🇷'),
    Language(code: 'tr', name: 'Türkçe', flag: '🇹🇷'),
    Language(code: 'ur', name: 'اردو', flag: '🇵🇰'),
  ];
  static Language getLanguageByCode(String code) {
    return languages.firstWhere(
      (language) => language.code == code,
      orElse: () => languages.first,
    );
  }
}
