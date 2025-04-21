// أدوات مساعدة للتحقق من صحة المدخلات

/// التحقق من صحة البريد الإلكتروني
bool isValidEmail(String email) {
  final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
  return emailRegExp.hasMatch(email);
}

/// التحقق من صحة كلمة المرور
/// يجب أن تكون كلمة المرور 8 أحرف على الأقل وتحتوي على حرف كبير وحرف صغير ورقم ورمز خاص
bool isValidPassword(String password) {
  if (password.length < 8) return false;

  final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
  final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
  final hasDigit = RegExp(r'[0-9]').hasMatch(password);
  final hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);

  return hasUppercase && hasLowercase && hasDigit && hasSpecialChar;
}

/// التحقق من صحة رقم الهاتف
bool isValidPhoneNumber(String phoneNumber) {
  // يدعم أرقام الهواتف الدولية مع رمز البلد
  final phoneRegExp = RegExp(r'^\+?[0-9]{10,15}$');
  return phoneRegExp.hasMatch(phoneNumber);
}

/// التحقق من صحة الرمز البريدي
bool isValidPostalCode(String postalCode) {
  // يدعم معظم أنماط الرموز البريدية العالمية
  final postalCodeRegExp = RegExp(r'^[a-zA-Z0-9]{3,10}$');
  return postalCodeRegExp.hasMatch(postalCode);
}

/// التحقق من أن النص ليس فارغاً
bool isNotEmpty(String text) {
  return text.trim().isNotEmpty;
}

/// التحقق من صحة اسم المستخدم
bool isValidUsername(String username) {
  // يسمح بالأحرف والأرقام والشرطة السفلية، ويجب أن يكون 3 أحرف على الأقل و20 حرفاً كحد أقصى
  final usernameRegExp = RegExp(r'^[a-zA-Z0-9_]{3,20}$');
  return usernameRegExp.hasMatch(username);
}

/// التحقق من صحة URL
bool isValidUrl(String url) {
  final urlRegExp = RegExp(
    r'^(http|https)://[a-zA-Z0-9-_.]+\.[a-zA-Z]{2,}(:[0-9]{1,5})?(/.*)?$',
  );
  return urlRegExp.hasMatch(url);
}

/// التحقق من صحة تاريخ الميلاد (يجب أن يكون المستخدم أكبر من 13 عاماً)
bool isValidBirthDate(DateTime birthDate) {
  final now = DateTime.now();
  final difference = now.difference(birthDate).inDays;
  final age = difference / 365;
  return age >= 13;
}

/// التحقق من صحة رقم بطاقة الائتمان باستخدام خوارزمية Luhn
bool isValidCreditCardNumber(String cardNumber) {
  // إزالة المسافات والشرطات
  final cleanNumber = cardNumber.replaceAll(RegExp(r'[\s-]'), '');

  // التحقق من أن الرقم يتكون من أرقام فقط
  if (!RegExp(r'^[0-9]{13,19}$').hasMatch(cleanNumber)) {
    return false;
  }

  // تطبيق خوارزمية Luhn
  int sum = 0;
  bool alternate = false;
  for (int i = cleanNumber.length - 1; i >= 0; i--) {
    int n = int.parse(cleanNumber[i]);
    if (alternate) {
      n *= 2;
      if (n > 9) {
        n = (n % 10) + 1;
      }
    }
    sum += n;
    alternate = !alternate;
  }

  return sum % 10 == 0;
}
