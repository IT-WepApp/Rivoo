class Validators {
  /// التحقق من صحة البريد الإلكتروني
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegExp.hasMatch(value)) {
      return 'يرجى إدخال بريد إلكتروني صحيح';
    }
    
    return null;
  }

  /// التحقق من صحة كلمة المرور
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    
    if (value.length < 8) {
      return 'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل';
    }
    
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'يجب أن تحتوي كلمة المرور على حرف كبير واحد على الأقل';
    }
    
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'يجب أن تحتوي كلمة المرور على حرف صغير واحد على الأقل';
    }
    
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'يجب أن تحتوي كلمة المرور على رقم واحد على الأقل';
    }
    
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'يجب أن تحتوي كلمة المرور على رمز خاص واحد على الأقل';
    }
    
    return null;
  }

  /// التحقق من تطابق كلمتي المرور
  static String? validatePasswordConfirmation(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'تأكيد كلمة المرور مطلوب';
    }
    
    if (value != password) {
      return 'كلمتا المرور غير متطابقتين';
    }
    
    return null;
  }

  /// التحقق من صحة الاسم
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'الاسم مطلوب';
    }
    
    if (value.length < 2) {
      return 'يجب أن يتكون الاسم من حرفين على الأقل';
    }
    
    return null;
  }

  /// التحقق من صحة رقم الهاتف
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'رقم الهاتف مطلوب';
    }
    
    final phoneRegExp = RegExp(r'^\+?[0-9]{10,15}$');
    
    if (!phoneRegExp.hasMatch(value)) {
      return 'يرجى إدخال رقم هاتف صحيح';
    }
    
    return null;
  }

  /// التحقق من صحة الرمز البريدي
  static String? validateZipCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرمز البريدي مطلوب';
    }
    
    final zipCodeRegExp = RegExp(r'^[0-9]{5}(?:-[0-9]{4})?$');
    
    if (!zipCodeRegExp.hasMatch(value)) {
      return 'يرجى إدخال رمز بريدي صحيح';
    }
    
    return null;
  }

  /// التحقق من صحة العنوان
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'العنوان مطلوب';
    }
    
    if (value.length < 5) {
      return 'يجب أن يتكون العنوان من 5 أحرف على الأقل';
    }
    
    return null;
  }

  /// التحقق من صحة المدينة
  static String? validateCity(String? value) {
    if (value == null || value.isEmpty) {
      return 'المدينة مطلوبة';
    }
    
    return null;
  }

  /// التحقق من صحة الدولة
  static String? validateCountry(String? value) {
    if (value == null || value.isEmpty) {
      return 'الدولة مطلوبة';
    }
    
    return null;
  }

  /// التحقق من صحة رقم بطاقة الائتمان
  static String? validateCreditCard(String? value) {
    if (value == null || value.isEmpty) {
      return 'رقم بطاقة الائتمان مطلوب';
    }
    
    // إزالة المسافات والشرطات
    final cleanValue = value.replaceAll(RegExp(r'[\s-]'), '');
    
    // التحقق من أن القيمة تحتوي على أرقام فقط
    if (!RegExp(r'^[0-9]+$').hasMatch(cleanValue)) {
      return 'يرجى إدخال رقم بطاقة ائتمان صحيح';
    }
    
    // التحقق من طول رقم البطاقة
    if (cleanValue.length < 13 || cleanValue.length > 19) {
      return 'يجب أن يتكون رقم البطاقة من 13 إلى 19 رقمًا';
    }
    
    // خوارزمية Luhn للتحقق من صحة رقم البطاقة
    int sum = 0;
    bool alternate = false;
    for (int i = cleanValue.length - 1; i >= 0; i--) {
      int n = int.parse(cleanValue[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) {
          n = (n % 10) + 1;
        }
      }
      sum += n;
      alternate = !alternate;
    }
    
    if (sum % 10 != 0) {
      return 'رقم بطاقة الائتمان غير صحيح';
    }
    
    return null;
  }

  /// التحقق من صحة تاريخ انتهاء الصلاحية
  static String? validateExpiryDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'تاريخ انتهاء الصلاحية مطلوب';
    }
    
    // التحقق من تنسيق MM/YY
    if (!RegExp(r'^(0[1-9]|1[0-2])\/([0-9]{2})$').hasMatch(value)) {
      return 'يرجى إدخال تاريخ بتنسيق MM/YY';
    }
    
    final parts = value.split('/');
    final month = int.parse(parts[0]);
    final year = int.parse('20${parts[1]}');
    
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;
    
    if (year < currentYear || (year == currentYear && month < currentMonth)) {
      return 'تاريخ انتهاء الصلاحية منتهي';
    }
    
    return null;
  }

  /// التحقق من صحة رمز CVV
  static String? validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return 'رمز CVV مطلوب';
    }
    
    if (!RegExp(r'^[0-9]{3,4}$').hasMatch(value)) {
      return 'يرجى إدخال رمز CVV صحيح (3 أو 4 أرقام)';
    }
    
    return null;
  }

  /// التحقق من صحة رمز التحقق
  static String? validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'رمز التحقق مطلوب';
    }
    
    if (!RegExp(r'^[0-9]{6}$').hasMatch(value)) {
      return 'يرجى إدخال رمز تحقق صحيح (6 أرقام)';
    }
    
    return null;
  }
}
