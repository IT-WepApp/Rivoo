import 'package:flutter/material.dart';

/// فئة Either لتمثيل إما قيمة ناجحة أو خطأ
class Either<L, R> {
  final L? _left;
  final R? _right;
  final bool isRight;

  /// إنشاء Either مع قيمة يسرى (خطأ)
  const Either.left(L value)
      : _left = value,
        _right = null,
        isRight = false;

  /// إنشاء Either مع قيمة يمنى (نجاح)
  const Either.right(R value)
      : _right = value,
        _left = null,
        isRight = true;

  /// الحصول على القيمة اليسرى (الخطأ)
  L get left => _left as L;

  /// الحصول على القيمة اليمنى (النجاح)
  R get right => _right as R;

  /// هل هذا الكائن يحتوي على قيمة يسرى (خطأ)
  bool get isLeft => !isRight;

  /// تنفيذ دالة على القيمة اليسرى أو اليمنى
  T fold<T>(T Function(L) onLeft, T Function(R) onRight) {
    return isRight ? onRight(_right as R) : onLeft(_left as L);
  }

  /// تطبيق دالة على القيمة اليمنى فقط
  Either<L, T> map<T>(T Function(R) f) {
    return isRight ? Either.right(f(_right as R)) : Either.left(_left as L);
  }

  /// تطبيق دالة على القيمة اليسرى فقط
  Either<T, R> mapLeft<T>(T Function(L) f) {
    return isRight ? Either.right(_right as R) : Either.left(f(_left as L));
  }

  /// تحويل Either إلى نص
  @override
  String toString() => isRight ? 'Right($_right)' : 'Left($_left)';
}
