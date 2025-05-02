/// أخطاء التطبيق
///
/// هذا الملف يحتوي على تعريفات الأخطاء المستخدمة في التطبيق

import 'package:equatable/equatable.dart';

/// الفئة الأساسية للأخطاء
///
/// جميع أنواع الأخطاء في التطبيق ترث من هذه الفئة
abstract class Failure extends Equatable {
  final String message;

  const Failure({this.message = 'حدث خطأ'});

  @override
  List<Object> get props => [message];
}

/// خطأ الخادم
///
/// يتم استخدام هذا الخطأ عند حدوث مشكلة في الاتصال بالخادم
class ServerFailure extends Failure {
  const ServerFailure({super.message = 'حدث خطأ في الخادم'});
}

/// خطأ التخزين المحلي
///
/// يتم استخدام هذا الخطأ عند حدوث مشكلة في التخزين المحلي
class CacheFailure extends Failure {
  const CacheFailure({super.message = 'حدث خطأ في التخزين المحلي'});
}

/// خطأ المصادقة
///
/// يتم استخدام هذا الخطأ عند حدوث مشكلة في عملية المصادقة
class AuthFailure extends Failure {
  const AuthFailure({super.message = 'حدث خطأ في المصادقة'});
}

/// خطأ الشبكة
///
/// يتم استخدام هذا الخطأ عند عدم وجود اتصال بالإنترنت
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'لا يوجد اتصال بالإنترنت'});
}

/// خطأ عدم وجود البيانات
///
/// يتم استخدام هذا الخطأ عند عدم وجود البيانات المطلوبة
class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message = 'البيانات المطلوبة غير موجودة'});
}

/// خطأ الإدخال غير الصالح
///
/// يتم استخدام هذا الخطأ عند إدخال بيانات غير صالحة
class InvalidInputFailure extends Failure {
  const InvalidInputFailure({super.message = 'البيانات المدخلة غير صالحة'});
}

/// خطأ غير متوقع
///
/// يتم استخدام هذا الخطأ عند حدوث خطأ غير متوقع
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({super.message = 'حدث خطأ غير متوقع'});
}
