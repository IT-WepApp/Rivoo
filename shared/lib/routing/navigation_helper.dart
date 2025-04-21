import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// مساعد للتنقل بين الشاشات
class NavigationHelper {
  // منع إنشاء نسخ من الكلاس
  NavigationHelper._();

  /// الانتقال إلى مسار محدد
  static void navigateTo(BuildContext context, String path,
      {Map<String, String>? params, Map<String, String>? queryParams}) {
    String finalPath = path;

    // إضافة المعلمات إلى المسار إذا وجدت
    if (params != null) {
      params.forEach((key, value) {
        finalPath = finalPath.replaceAll(':$key', value);
      });
    }

    context.go(finalPath, queryParams: queryParams);
  }

  /// الانتقال إلى مسار محدد مع استبدال المسار الحالي
  static void replaceTo(BuildContext context, String path,
      {Map<String, String>? params, Map<String, String>? queryParams}) {
    String finalPath = path;

    // إضافة المعلمات إلى المسار إذا وجدت
    if (params != null) {
      params.forEach((key, value) {
        finalPath = finalPath.replaceAll(':$key', value);
      });
    }

    context.replace(finalPath, queryParams: queryParams);
  }

  /// الانتقال إلى مسار محدد مع إمكانية العودة
  static void pushTo(BuildContext context, String path,
      {Map<String, String>? params, Map<String, String>? queryParams}) {
    String finalPath = path;

    // إضافة المعلمات إلى المسار إذا وجدت
    if (params != null) {
      params.forEach((key, value) {
        finalPath = finalPath.replaceAll(':$key', value);
      });
    }

    context.push(finalPath, queryParams: queryParams);
  }

  /// العودة إلى المسار السابق
  static void goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    }
  }

  /// العودة إلى المسار الرئيسي
  static void goHome(BuildContext context, String homePath) {
    context.go(homePath);
  }
}
