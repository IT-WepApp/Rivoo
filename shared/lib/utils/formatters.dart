import 'package:intl/intl.dart';

/// مجموعة من الدوال المساعدة لتنسيق البيانات
class Formatters {
  /// تنسيق التاريخ بالصيغة المحلية
  static String formatDate(DateTime date, {String locale = 'ar'}) {
    return DateFormat.yMMMd(locale).format(date);
  }

  /// تنسيق الوقت بالصيغة المحلية
  static String formatTime(DateTime time, {String locale = 'ar'}) {
    return DateFormat.Hm(locale).format(time);
  }

  /// تنسيق التاريخ والوقت معاً بالصيغة المحلية
  static String formatDateTime(DateTime dateTime, {String locale = 'ar'}) {
    return DateFormat.yMMMd(locale).add_Hm().format(dateTime);
  }

  /// تنسيق المبلغ المالي مع رمز العملة
  static String formatCurrency(double amount,
      {String currencySymbol = 'ر.س', String locale = 'ar'}) {
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: currencySymbol,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  /// تنسيق الرقم بفواصل الآلاف
  static String formatNumber(num number, {String locale = 'ar'}) {
    return NumberFormat.decimalPattern(locale).format(number);
  }
}
