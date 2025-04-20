/// أدوات التحقق من صحة المدخلات
///
/// يحتوي هذا الملف على دوال للتحقق من صحة المدخلات المختلفة
/// مثل البريد الإلكتروني وكلمة المرور ورقم الهاتف وغيرها
class Validators {
  /// التحقق من صحة البريد الإلكتروني
  ///
  /// يرجع null إذا كان البريد الإلكتروني صحيحاً، أو رسالة خطأ إذا كان غير صحيح
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال البريد الإلكتروني';
    }
    
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'الرجاء إدخال بريد إلكتروني صحيح';
    }
    
    return null;
  }
  
  /// التحقق من صحة كلمة المرور
  ///
  /// يرجع null إذا كانت كلمة المرور صحيحة، أو رسالة خطأ إذا كانت غير صحيحة
  /// كلمة المرور يجب أن تكون على الأقل 8 أحرف وتحتوي على حرف كبير وحرف صغير ورقم
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال كلمة المرور';
    }
    
    if (value.length < 8) {
      return 'كلمة المرور يجب أن تكون على الأقل 8 أحرف';
    }
    
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'كلمة المرور يجب أن تحتوي على حرف كبير واحد على الأقل';
    }
    
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'كلمة المرور يجب أن تحتوي على حرف صغير واحد على الأقل';
    }
    
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'كلمة المرور يجب أن تحتوي على رقم واحد على الأقل';
    }
    
    return null;
  }
  
  /// التحقق من تطابق كلمتي المرور
  ///
  /// [password] كلمة المرور الأصلية
  /// [confirmPassword] تأكيد كلمة المرور
  /// يرجع null إذا كانت كلمتا المرور متطابقتين، أو رسالة خطأ إذا كانتا غير متطابقتين
  static String? validateConfirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'الرجاء تأكيد كلمة المرور';
    }
    
    if (password != confirmPassword) {
      return 'كلمتا المرور غير متطابقتين';
    }
    
    return null;
  }
  
  /// التحقق من صحة رقم الهاتف
  ///
  /// يرجع null إذا كان رقم الهاتف صحيحاً، أو رسالة خطأ إذا كان غير صحيح
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال رقم الهاتف';
    }
    
    // تحقق من أن رقم الهاتف يحتوي على أرقام فقط ويبدأ بـ 05 أو +966
    final phoneRegExp = RegExp(r'^(05|\\+9665)[0-9]{8}$');
    if (!phoneRegExp.hasMatch(value)) {
      return 'الرجاء إدخال رقم هاتف صحيح (05xxxxxxxx أو +966xxxxxxxx)';
    }
    
    return null;
  }
  
  /// التحقق من صحة الاسم
  ///
  /// يرجع null إذا كان الاسم صحيحاً، أو رسالة خطأ إذا كان غير صحيح
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال الاسم';
    }
    
    if (value.length < 3) {
      return 'الاسم يجب أن يكون على الأقل 3 أحرف';
    }
    
    return null;
  }
  
  /// التحقق من صحة العنوان
  ///
  /// يرجع null إذا كان العنوان صحيحاً، أو رسالة خطأ إذا كان غير صحيح
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال العنوان';
    }
    
    if (value.length < 10) {
      return 'العنوان يجب أن يكون على الأقل 10 أحرف';
    }
    
    return null;
  }
  
  /// التحقق من صحة الرمز البريدي
  ///
  /// يرجع null إذا كان الرمز البريدي صحيحاً، أو رسالة خطأ إذا كان غير صحيح
  static String? validateZipCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال الرمز البريدي';
    }
    
    // تحقق من أن الرمز البريدي يحتوي على 5 أرقام
    final zipCodeRegExp = RegExp(r'^[0-9]{5}$');
    if (!zipCodeRegExp.hasMatch(value)) {
      return 'الرجاء إدخال رمز بريدي صحيح (5 أرقام)';
    }
    
    return null;
  }
  
  /// التحقق من صحة رمز التحقق
  ///
  /// يرجع null إذا كان رمز التحقق صحيحاً، أو رسالة خطأ إذا كان غير صحيح
  static String? validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال رمز التحقق';
    }
    
    // تحقق من أن رمز التحقق يحتوي على 6 أرقام
    final otpRegExp = RegExp(r'^[0-9]{6}$');
    if (!otpRegExp.hasMatch(value)) {
      return 'الرجاء إدخال رمز تحقق صحيح (6 أرقام)';
    }
    
    return null;
  }
  
  /// التحقق من صحة المبلغ
  ///
  /// يرجع null إذا كان المبلغ صحيحاً، أو رسالة خطأ إذا كان غير صحيح
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال المبلغ';
    }
    
    // تحقق من أن المبلغ رقم موجب
    final double? amount = double.tryParse(value);
    if (amount == null) {
      return 'الرجاء إدخال مبلغ صحيح';
    }
    
    if (amount <= 0) {
      return 'المبلغ يجب أن يكون أكبر من صفر';
    }
    
    return null;
  }
  
  /// التحقق من صحة التقييم
  ///
  /// يرجع null إذا كان التقييم صحيحاً، أو رسالة خطأ إذا كان غير صحيح
  static String? validateRating(double? value) {
    if (value == null) {
      return 'الرجاء إدخال التقييم';
    }
    
    if (value < 1 || value > 5) {
      return 'التقييم يجب أن يكون بين 1 و 5';
    }
    
    return null;
  }
  
  /// التحقق من صحة التعليق
  ///
  /// يرجع null إذا كان التعليق صحيحاً، أو رسالة خطأ إذا كان غير صحيح
  static String? validateReview(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال التعليق';
    }
    
    if (value.length < 10) {
      return 'التعليق يجب أن يكون على الأقل 10 أحرف';
    }
    
    if (value.length > 500) {
      return 'التعليق يجب أن لا يتجاوز 500 حرف';
    }
    
    return null;
  }
}
