import 'package:flutter/material.dart';

/// أدوات مساعدة للتعامل مع النصوص
///
/// يحتوي هذا الملف على دوال مساعدة للتعامل مع النصوص
/// مثل تنسيق النصوص واختصارها وغيرها
class TextUtils {
  /// اختصار النص إذا كان طويلاً
  ///
  /// [text] النص المراد اختصاره
  /// [maxLength] الحد الأقصى لطول النص
  /// [suffix] النص الذي سيضاف في نهاية النص المختصر
  /// يرجع النص المختصر إذا كان طويلاً، أو النص الأصلي إذا كان قصيراً
  static String truncateText(String text,
      {int maxLength = 50, String suffix = '...'}) {
    if (text.length <= maxLength) {
      return text;
    }

    return '${text.substring(0, maxLength)}$suffix';
  }

  /// تنسيق المبلغ بالعملة
  ///
  /// [amount] المبلغ المراد تنسيقه
  /// [currency] رمز العملة
  /// [decimalDigits] عدد الأرقام العشرية
  /// يرجع المبلغ منسقاً بالعملة
  static String formatCurrency(double amount,
      {String currency = 'ر.س', int decimalDigits = 2}) {
    final String formattedAmount = amount.toStringAsFixed(decimalDigits);
    return '$formattedAmount $currency';
  }

  /// تحويل النص إلى حالة العنوان
  ///
  /// [text] النص المراد تحويله
  /// يرجع النص بحالة العنوان (الحرف الأول من كل كلمة كبير)
  static String toTitleCase(String text) {
    if (text.isEmpty) {
      return text;
    }

    return text.split(' ').map((word) {
      if (word.isEmpty) {
        return word;
      }

      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// تحويل النص إلى حالة الجمل
  ///
  /// [text] النص المراد تحويله
  /// يرجع النص بحالة الجمل (الحرف الأول من النص كبير)
  static String toSentenceCase(String text) {
    if (text.isEmpty) {
      return text;
    }

    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// تنسيق رقم الهاتف
  ///
  /// [phoneNumber] رقم الهاتف المراد تنسيقه
  /// يرجع رقم الهاتف منسقاً
  static String formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) {
      return phoneNumber;
    }

    // إزالة أي أحرف غير رقمية
    final String digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // تنسيق رقم الهاتف السعودي
    if (digitsOnly.length == 10 && digitsOnly.startsWith('05')) {
      return '${digitsOnly.substring(0, 2)} ${digitsOnly.substring(2, 5)} ${digitsOnly.substring(5, 8)} ${digitsOnly.substring(8)}';
    } else if (digitsOnly.length == 12 && digitsOnly.startsWith('9665')) {
      return '+${digitsOnly.substring(0, 3)} ${digitsOnly.substring(3, 5)} ${digitsOnly.substring(5, 8)} ${digitsOnly.substring(8, 11)} ${digitsOnly.substring(11)}';
    }

    // إذا لم يكن رقم هاتف سعودي، أرجع الرقم كما هو
    return phoneNumber;
  }

  /// تحويل النص إلى عدد صحيح
  ///
  /// [text] النص المراد تحويله
  /// [defaultValue] القيمة الافتراضية إذا فشل التحويل
  /// يرجع العدد الصحيح المحول من النص، أو القيمة الافتراضية إذا فشل التحويل
  static int parseInteger(String text, {int defaultValue = 0}) {
    return int.tryParse(text) ?? defaultValue;
  }

  /// تحويل النص إلى عدد عشري
  ///
  /// [text] النص المراد تحويله
  /// [defaultValue] القيمة الافتراضية إذا فشل التحويل
  /// يرجع العدد العشري المحول من النص، أو القيمة الافتراضية إذا فشل التحويل
  static double parseDouble(String text, {double defaultValue = 0.0}) {
    return double.tryParse(text) ?? defaultValue;
  }

  /// تحويل العدد إلى نص بالكلمات العربية
  ///
  /// [number] العدد المراد تحويله
  /// يرجع النص العربي للعدد
  static String numberToArabicWords(int number) {
    if (number == 0) {
      return 'صفر';
    }

    final List<String> units = [
      '',
      'واحد',
      'اثنان',
      'ثلاثة',
      'أربعة',
      'خمسة',
      'ستة',
      'سبعة',
      'ثمانية',
      'تسعة',
      'عشرة',
      'أحد عشر',
      'اثنا عشر',
      'ثلاثة عشر',
      'أربعة عشر',
      'خمسة عشر',
      'ستة عشر',
      'سبعة عشر',
      'ثمانية عشر',
      'تسعة عشر'
    ];
    final List<String> tens = [
      '',
      '',
      'عشرون',
      'ثلاثون',
      'أربعون',
      'خمسون',
      'ستون',
      'سبعون',
      'ثمانون',
      'تسعون'
    ];
    final List<String> hundreds = [
      '',
      'مائة',
      'مائتان',
      'ثلاثمائة',
      'أربعمائة',
      'خمسمائة',
      'ستمائة',
      'سبعمائة',
      'ثمانمائة',
      'تسعمائة'
    ];
    final List<String> thousands = [
      '',
      'ألف',
      'ألفان',
      'ثلاثة آلاف',
      'أربعة آلاف',
      'خمسة آلاف',
      'ستة آلاف',
      'سبعة آلاف',
      'ثمانية آلاف',
      'تسعة آلاف'
    ];

    if (number < 20) {
      return units[number];
    } else if (number < 100) {
      final int unit = number % 10;
      final int ten = number ~/ 10;

      if (unit == 0) {
        return tens[ten];
      } else {
        return '${units[unit]} و ${tens[ten]}';
      }
    } else if (number < 1000) {
      final int hundred = number ~/ 100;
      final int remainder = number % 100;

      if (remainder == 0) {
        return hundreds[hundred];
      } else {
        return '${hundreds[hundred]} و ${numberToArabicWords(remainder)}';
      }
    } else if (number < 10000) {
      final int thousand = number ~/ 1000;
      final int remainder = number % 1000;

      if (remainder == 0) {
        return thousands[thousand];
      } else {
        return '${thousands[thousand]} و ${numberToArabicWords(remainder)}';
      }
    } else {
      return number.toString();
    }
  }

  /// تحويل النص إلى لون
  ///
  /// [colorString] النص المراد تحويله
  /// [defaultColor] اللون الافتراضي إذا فشل التحويل
  /// يرجع اللون المحول من النص، أو اللون الافتراضي إذا فشل التحويل
  static Color parseColor(String colorString,
      {Color defaultColor = Colors.black}) {
    if (colorString.isEmpty) {
      return defaultColor;
    }

    if (colorString.startsWith('#')) {
      colorString = colorString.substring(1);
    }

    if (colorString.length == 6) {
      colorString = 'FF$colorString';
    }

    final int? colorValue = int.tryParse(colorString, radix: 16);
    if (colorValue == null) {
      return defaultColor;
    }

    return Color(colorValue);
  }
}
