import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_app/core/architecture/domain/failure.dart';

/// نموذج العرض الأساسي
/// يوفر وظائف مشتركة لجميع نماذج العرض في التطبيق
abstract class BaseViewModel extends StateNotifier<BaseViewState> {
  BaseViewModel() : super(const BaseViewState.initial());
  
  /// تحديث الحالة إلى حالة التحميل
  void setLoading() {
    state = const BaseViewState.loading();
  }
  
  /// تحديث الحالة إلى حالة النجاح
  void setSuccess([String? message]) {
    state = BaseViewState.success(message: message);
  }
  
  /// تحديث الحالة إلى حالة الفشل
  void setFailure(Failure failure) {
    state = BaseViewState.failure(failure: failure);
  }
  
  /// إعادة تعيين الحالة إلى الحالة الأولية
  void resetState() {
    state = const BaseViewState.initial();
  }
}

/// حالة نموذج العرض الأساسية
/// تمثل الحالات المختلفة التي يمكن أن يكون فيها نموذج العرض
class BaseViewState {
  final bool isInitial;
  final bool isLoading;
  final bool isSuccess;
  final bool isFailure;
  final String? message;
  final Failure? failure;
  
  const BaseViewState({
    this.isInitial = false,
    this.isLoading = false,
    this.isSuccess = false,
    this.isFailure = false,
    this.message,
    this.failure,
  });
  
  /// الحالة الأولية
  const BaseViewState.initial()
      : isInitial = true,
        isLoading = false,
        isSuccess = false,
        isFailure = false,
        message = null,
        failure = null;
  
  /// حالة التحميل
  const BaseViewState.loading()
      : isInitial = false,
        isLoading = true,
        isSuccess = false,
        isFailure = false,
        message = null,
        failure = null;
  
  /// حالة النجاح
  const BaseViewState.success({String? message})
      : isInitial = false,
        isLoading = false,
        isSuccess = true,
        isFailure = false,
        message = message,
        failure = null;
  
  /// حالة الفشل
  const BaseViewState.failure({required Failure failure})
      : isInitial = false,
        isLoading = false,
        isSuccess = false,
        isFailure = true,
        message = failure.message,
        failure = failure;
}
