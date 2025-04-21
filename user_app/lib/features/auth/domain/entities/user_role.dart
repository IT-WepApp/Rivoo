import 'package:freezed_annotation/freezed_annotation.dart';

/// أدوار المستخدم في النظام
/// 
/// يستخدم لتحديد صلاحيات المستخدمين في التطبيق
enum UserRole {
  /// مستخدم عادي (زبون)
  customer,
  
  /// سائق توصيل
  driver,
  
  /// مدير النظام
  admin,
  
  /// زائر (غير مسجل)
  guest,
}
