import 'package:flutter/material.dart';

/// أدوات مساعدة للتعامل مع التاريخ والوقت
///
/// يحتوي هذا الملف على دوال مساعدة للتعامل مع التاريخ والوقت
/// مثل تنسيق التاريخ وحساب الفرق بين تاريخين وغيرها
class DateTimeUtils {
  /// تنسيق التاريخ بالصيغة العربية
  ///
  /// [date] التاريخ المراد تنسيقه
  /// يرجع التاريخ بصيغة "اليوم، التاريخ الشهر السنة"
  static String formatDateArabic(DateTime date) {
    final List<String> arabicDays = [
      'الأحد',
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت'
    ];
    
    final List<String> arabicMonths = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];
    
    final String day = arabicDays[date.weekday % 7];
    final String month = arabicMonths[date.month - 1];
    
    return '$day، ${date.day} $month ${date.year}';
  }
  
  /// تنسيق الوقت بالصيغة العربية
  ///
  /// [time] الوقت المراد تنسيقه
  /// [use24Hour] استخدام نظام 24 ساعة
  /// يرجع الوقت بصيغة "الساعة:الدقيقة ص/م"
  static String formatTimeArabic(TimeOfDay time, {bool use24Hour = false}) {
    if (use24Hour) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      final int hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
      final String period = time.hour >= 12 ? 'م' : 'ص';
      return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
    }
  }
  
  /// تنسيق التاريخ والوقت بالصيغة العربية
  ///
  /// [dateTime] التاريخ والوقت المراد تنسيقهما
  /// [use24Hour] استخدام نظام 24 ساعة
  /// يرجع التاريخ والوقت بصيغة "اليوم، التاريخ الشهر السنة الساعة:الدقيقة ص/م"
  static String formatDateTimeArabic(DateTime dateTime, {bool use24Hour = false}) {
    final String date = formatDateArabic(dateTime);
    final String time = formatTimeArabic(
      TimeOfDay.fromDateTime(dateTime),
      use24Hour: use24Hour,
    );
    
    return '$date، $time';
  }
  
  /// حساب الوقت المنقضي منذ تاريخ معين
  ///
  /// [dateTime] التاريخ المراد حساب الوقت المنقضي منذه
  /// يرجع نص يصف الوقت المنقضي مثل "منذ 5 دقائق" أو "منذ ساعة" أو "منذ يومين"
  static String timeAgo(DateTime dateTime) {
    final Duration difference = DateTime.now().difference(dateTime);
    
    if (difference.inDays > 365) {
      final int years = (difference.inDays / 365).floor();
      return 'منذ ${years == 1 ? 'سنة' : '$years سنوات'}';
    } else if (difference.inDays > 30) {
      final int months = (difference.inDays / 30).floor();
      return 'منذ ${months == 1 ? 'شهر' : '$months أشهر'}';
    } else if (difference.inDays > 0) {
      return 'منذ ${difference.inDays == 1 ? 'يوم' : '${difference.inDays} أيام'}';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours == 1 ? 'ساعة' : '${difference.inHours} ساعات'}';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes == 1 ? 'دقيقة' : '${difference.inMinutes} دقائق'}';
    } else {
      return 'منذ لحظات';
    }
  }
  
  /// حساب الوقت المتبقي حتى تاريخ معين
  ///
  /// [dateTime] التاريخ المراد حساب الوقت المتبقي حتى الوصول إليه
  /// يرجع نص يصف الوقت المتبقي مثل "5 دقائق" أو "ساعة" أو "يومين"
  static String timeUntil(DateTime dateTime) {
    final Duration difference = dateTime.difference(DateTime.now());
    
    if (difference.inDays > 365) {
      final int years = (difference.inDays / 365).floor();
      return '${years == 1 ? 'سنة' : '$years سنوات'}';
    } else if (difference.inDays > 30) {
      final int months = (difference.inDays / 30).floor();
      return '${months == 1 ? 'شهر' : '$months أشهر'}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays == 1 ? 'يوم' : '${difference.inDays} أيام'}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours == 1 ? 'ساعة' : '${difference.inHours} ساعات'}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes == 1 ? 'دقيقة' : '${difference.inMinutes} دقائق'}';
    } else {
      return 'لحظات';
    }
  }
  
  /// التحقق مما إذا كان التاريخ اليوم
  ///
  /// [date] التاريخ المراد التحقق منه
  /// يرجع true إذا كان التاريخ اليوم، وfalse إذا لم يكن
  static bool isToday(DateTime date) {
    final DateTime now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
  
  /// التحقق مما إذا كان التاريخ أمس
  ///
  /// [date] التاريخ المراد التحقق منه
  /// يرجع true إذا كان التاريخ أمس، وfalse إذا لم يكن
  static bool isYesterday(DateTime date) {
    final DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;
  }
  
  /// التحقق مما إذا كان التاريخ غداً
  ///
  /// [date] التاريخ المراد التحقق منه
  /// يرجع true إذا كان التاريخ غداً، وfalse إذا لم يكن
  static bool isTomorrow(DateTime date) {
    final DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day;
  }
  
  /// الحصول على التاريخ بدون الوقت
  ///
  /// [dateTime] التاريخ والوقت المراد الحصول على التاريخ منهما
  /// يرجع التاريخ بدون الوقت (الساعة 00:00:00)
  static DateTime dateOnly(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }
}
