import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:user_app/core/architecture/domain/failure.dart';

/// حالة العرض الأساسية التي تمثل حالة واجهة المستخدم
/// تستخدم في نموذج المشاهدة (ViewModel) لإدارة حالة الشاشة
class ViewState<T> {
  /// بيانات الحالة (متوفرة في حالة النجاح)
  final T? data;

  /// رسالة الخطأ (متوفرة في حالة الفشل)
  final String? errorMessage;

  /// حالة التحميل
  final bool isLoading;

  /// حالة النجاح
  final bool isSuccess;

  /// حالة الفشل
  final bool isError;

  /// منشئ حالة العرض
  const ViewState({
    this.data,
    this.errorMessage,
    this.isLoading = false,
    this.isSuccess = false,
    this.isError = false,
  });

  /// إنشاء حالة أولية
  factory ViewState.initial() => const ViewState();

  /// إنشاء حالة تحميل
  factory ViewState.loading() => const ViewState(isLoading: true);

  /// إنشاء حالة نجاح مع بيانات
  factory ViewState.success(T data) => ViewState(
        data: data,
        isSuccess: true,
      );

  /// إنشاء حالة فشل مع رسالة خطأ
  factory ViewState.error(String message) => ViewState(
        errorMessage: message,
        isError: true,
      );

  /// إنشاء حالة فشل من كائن Failure
  factory ViewState.fromFailure(Failure failure) => ViewState(
        errorMessage: failure.message,
        isError: true,
      );

  /// نسخ الحالة مع تغيير بعض الخصائص
  ViewState<T> copyWith({
    T? data,
    String? errorMessage,
    bool? isLoading,
    bool? isSuccess,
    bool? isError,
  }) {
    return ViewState<T>(
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      isError: isError ?? this.isError,
    );
  }
}

/// نموذج المشاهدة الأساسي الذي يدير حالة واجهة المستخدم
/// يستخدم مع Riverpod لإدارة الحالة ويعتمد على الأسلوب الآلي Dispose
abstract class BaseViewModel<T> extends AutoDisposeNotifier<ViewState<T>> {
  @override
  ViewState<T> build() {
    return ViewState<T>.initial();
  }

  /// تحديث الحالة إلى حالة تحميل
  void setLoading() {
    state = ViewState<T>.loading();
  }

  /// تحديث الحالة إلى حالة نجاح مع بيانات
  void setSuccess(T data) {
    state = ViewState<T>.success(data);
  }

  /// تحديث الحالة إلى حالة فشل مع رسالة خطأ
  void setError(String message) {
    state = ViewState<T>.error(message);
  }

  /// تحديث الحالة إلى حالة فشل من كائن Failure
  void setFailure(Failure failure) {
    state = ViewState<T>.fromFailure(failure);
  }
}
