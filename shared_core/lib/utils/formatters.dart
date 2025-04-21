// أدوات مساعدة لتنسيق البيانات

import 'package:intl/intl.dart';

/// تنسيق التاريخ بالصيغة المحلية
String formatDate(DateTime date, {String locale = 'ar'}) {
  return DateFormat.yMMMd(locale).format(date);
}

/// تنسيق التاريخ والوقت بالصيغة المحلية
String formatDateTime(DateTime dateTime, {String locale = 'ar'}) {
  return DateFormat.yMMMd(locale).add_jm().format(dateTime);
}

/// تنسيق المبلغ المالي مع رمز العملة
String formatCurrency(double amount,
    {String currencySymbol = 'ر.س', String locale = 'ar'}) {
  final formatter = NumberFormat.currency(
    locale: locale,
    symbol: currencySymbol,
    decimalDigits: 2,
  );
  return formatter.format(amount);
}

/// تنسيق رقم الهاتف بصيغة مقروءة
String formatPhoneNumber(String phoneNumber) {
  // إزالة أي أحرف غير رقمية
  final digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

  // التعامل مع الأرقام الدولية
  if (digitsOnly.startsWith('00') || digitsOnly.startsWith('+')) {
    // تنسيق الرقم الدولي
    final countryCode = digitsOnly.startsWith('00')
        ? digitsOnly.substring(0, 4)
        : '+${digitsOnly.substring(1, 3)}';

    final remaining = digitsOnly.startsWith('00')
        ? digitsOnly.substring(4)
        : digitsOnly.substring(3);

    // تقسيم الرقم إلى مجموعات من 3 أو 4 أرقام
    final parts = <String>[];
    for (int i = 0; i < remaining.length; i += 3) {
      final end = i + 3 > remaining.length ? remaining.length : i + 3;
      parts.add(remaining.substring(i, end));
    }

    return '$countryCode ${parts.join(' ')}';
  } else {
    // تنسيق الرقم المحلي
    if (digitsOnly.length <= 3) {
      return digitsOnly;
    } else if (digitsOnly.length <= 7) {
      return '${digitsOnly.substring(0, 3)} ${digitsOnly.substring(3)}';
    } else {
      return '${digitsOnly.substring(0, 4)} ${digitsOnly.substring(4, 7)} ${digitsOnly.substring(7)}';
    }
  }
}

/// تنسيق النص ليكون بأحرف كبيرة في بداية كل كلمة
String toTitleCase(String text) {
  if (text.isEmpty) return text;

  return text.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}

/// تنسيق حجم الملف (بايت، كيلوبايت، ميجابايت، إلخ)
String formatFileSize(int bytes) {
  if (bytes < 1024) {
    return '$bytes بايت';
  } else if (bytes < 1024 * 1024) {
    final kb = bytes / 1024;
    return '${kb.toStringAsFixed(1)} كيلوبايت';
  } else if (bytes < 1024 * 1024 * 1024) {
    final mb = bytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} ميجابايت';
  } else {
    final gb = bytes / (1024 * 1024 * 1024);
    return '${gb.toStringAsFixed(1)} جيجابايت';
  }
}

/// تنسيق المدة الزمنية بصيغة مقروءة
String formatDuration(Duration duration, {String locale = 'ar'}) {
  if (duration.inSeconds < 60) {
    return '${duration.inSeconds} ثانية';
  } else if (duration.inMinutes < 60) {
    return '${duration.inMinutes} دقيقة';
  } else if (duration.inHours < 24) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (minutes == 0) {
      return '$hours ساعة';
    } else {
      return '$hours ساعة و $minutes دقيقة';
    }
  } else {
    final days = duration.inDays;
    final hours = duration.inHours % 24;

    if (hours == 0) {
      return '$days يوم';
    } else {
      return '$days يوم و $hours ساعة';
    }
  }
}

/// تنسيق رقم بطاقة الائتمان بإخفاء معظم الأرقام
String formatCreditCardNumber(String cardNumber) {
  // إزالة المسافات والشرطات
  final cleanNumber = cardNumber.replaceAll(RegExp(r'[\s-]'), '');

  if (cleanNumber.length < 4) {
    return cleanNumber;
  }

  // إظهار آخر 4 أرقام فقط
  final lastFour = cleanNumber.substring(cleanNumber.length - 4);
  final maskedPart = '*' * (cleanNumber.length - 4);

  // تنسيق الرقم في مجموعات من 4 أرقام
  final masked = '$maskedPart$lastFour';
  final parts = <String>[];
  for (int i = 0; i < masked.length; i += 4) {
    final end = i + 4 > masked.length ? masked.length : i + 4;
    parts.add(masked.substring(i, end));
  }

  return parts.join(' ');
}
