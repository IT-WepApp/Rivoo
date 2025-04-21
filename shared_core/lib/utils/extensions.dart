import 'dart:convert';
import 'package:flutter/material.dart';

/// امتدادات مفيدة للأنواع المختلفة في دارت وفلاتر

/// امتدادات للنصوص
extension StringExtensions on String {
  /// تحويل النص إلى عنوان URL آمن
  String toSlug() {
    return toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-');
  }

  /// تحويل النص إلى Base64
  String toBase64() {
    return base64Encode(utf8.encode(this));
  }

  /// فك تشفير النص من Base64
  String fromBase64() {
    try {
      return utf8.decode(base64Decode(this));
    } catch (e) {
      return this;
    }
  }

  /// اقتطاع النص إلى طول محدد مع إضافة علامة القطع
  String truncate(int length, {String ellipsis = '...'}) {
    if (this.length <= length) {
      return this;
    }
    return '${substring(0, length)}$ellipsis';
  }

  /// التحقق من أن النص يحتوي على نص آخر بغض النظر عن حالة الأحرف
  bool containsIgnoreCase(String other) {
    return toLowerCase().contains(other.toLowerCase());
  }

  /// تحويل النص إلى لون
  Color toColor() {
    try {
      final hexColor = replaceAll('#', '');
      if (hexColor.length == 6) {
        return Color(int.parse('FF$hexColor', radix: 16));
      } else if (hexColor.length == 8) {
        return Color(int.parse(hexColor, radix: 16));
      }
    } catch (e) {
      // تجاهل الخطأ
    }
    return Colors.black;
  }
}

/// امتدادات للقوائم
extension ListExtensions<T> on List<T> {
  /// الحصول على عنصر عشوائي من القائمة
  T? getRandom() {
    if (isEmpty) return null;
    return this[DateTime.now().millisecondsSinceEpoch % length];
  }

  /// تقسيم القائمة إلى مجموعات بحجم محدد
  List<List<T>> chunked(int size) {
    final result = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      final end = (i + size < length) ? i + size : length;
      result.add(sublist(i, end));
    }
    return result;
  }

  /// إزالة العناصر المكررة من القائمة
  List<T> distinct() {
    return toSet().toList();
  }

  /// تطبيق دالة على كل عنصر في القائمة وإعادة قائمة جديدة
  List<R> mapIndexed<R>(R Function(int index, T item) transform) {
    final result = <R>[];
    for (var i = 0; i < length; i++) {
      result.add(transform(i, this[i]));
    }
    return result;
  }
}

/// امتدادات للتواريخ
extension DateTimeExtensions on DateTime {
  /// التحقق من أن التاريخ هو اليوم
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// التحقق من أن التاريخ هو الأمس
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// التحقق من أن التاريخ هو الغد
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// الحصول على التاريخ بدون الوقت
  DateTime get dateOnly {
    return DateTime(year, month, day);
  }

  /// إضافة أيام إلى التاريخ
  DateTime addDays(int days) {
    return add(Duration(days: days));
  }

  /// إضافة أشهر إلى التاريخ
  DateTime addMonths(int months) {
    var newMonth = month + months;
    var newYear = year;

    while (newMonth > 12) {
      newMonth -= 12;
      newYear++;
    }

    while (newMonth < 1) {
      newMonth += 12;
      newYear--;
    }

    var newDay = day;
    final daysInMonth = DateTime(newYear, newMonth + 1, 0).day;
    if (newDay > daysInMonth) {
      newDay = daysInMonth;
    }

    return DateTime(newYear, newMonth, newDay, hour, minute, second,
        millisecond, microsecond);
  }
}

/// امتدادات للأرقام
extension NumExtensions on num {
  /// تقريب الرقم إلى عدد محدد من الأرقام العشرية
  double roundTo(int places) {
    final mod = pow(10.0, places);
    return (this * mod).round() / mod;
  }

  /// تحويل الرقم إلى نسبة مئوية
  String toPercentage({int decimalPlaces = 0}) {
    return '${(this * 100).roundTo(decimalPlaces)}%';
  }

  /// تحويل الرقم إلى مدة زمنية
  Duration toDuration() {
    return Duration(milliseconds: (this * 1000).round());
  }

  /// التحقق من أن الرقم بين قيمتين
  bool isBetween(num min, num max) {
    return this >= min && this <= max;
  }
}

/// امتدادات لعناصر واجهة المستخدم
extension WidgetExtensions on Widget {
  /// إضافة هامش حول العنصر
  Widget withPadding(EdgeInsetsGeometry padding) {
    return Padding(padding: padding, child: this);
  }

  /// إضافة حدود حول العنصر
  Widget withBorder({
    Color color = Colors.grey,
    double width = 1.0,
    BorderRadius borderRadius = BorderRadius.zero,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color, width: width),
        borderRadius: borderRadius,
      ),
      child: this,
    );
  }

  /// جعل العنصر قابل للنقر
  Widget onTap(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: this,
    );
  }

  /// إضافة ظل حول العنصر
  Widget withShadow({
    Color color = Colors.black26,
    double blurRadius = 10.0,
    Offset offset = const Offset(0, 2),
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: blurRadius,
            offset: offset,
          ),
        ],
      ),
      child: this,
    );
  }
}

/// دالة مساعدة لحساب القوة
double pow(double x, int exponent) {
  double result = 1.0;
  for (int i = 0; i < exponent; i++) {
    result *= x;
  }
  return result;
}
