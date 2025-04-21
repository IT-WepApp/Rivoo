import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_app/core/architecture/domain/failure.dart';
import 'package:user_app/core/architecture/presentation/base_view_model.dart';
import 'package:user_app/features/payment/domain/payment_entity.dart';
import 'package:user_app/features/payment/domain/usecases/payment_usecases.dart';

/// حالة نموذج عرض الدفع
class PaymentState extends BaseViewState {
  final List<PaymentMethodEntity> availablePaymentMethods;
  final List<PaymentMethodEntity> savedPaymentMethods;
  final PaymentMethodEntity? selectedPaymentMethod;
  final PaymentIntentEntity? paymentIntent;
  final PaymentResultEntity? paymentResult;
  final List<PaymentResultEntity> paymentHistory;

  const PaymentState({
    required bool isInitial,
    required bool isLoading,
    required bool isSuccess,
    required bool isFailure,
    String? message,
    Failure? failure,
    this.availablePaymentMethods = const [],
    this.savedPaymentMethods = const [],
    this.selectedPaymentMethod,
    this.paymentIntent,
    this.paymentResult,
    this.paymentHistory = const [],
  }) : super(
          isInitial: isInitial,
          isLoading: isLoading,
          isSuccess: isSuccess,
          isFailure: isFailure,
          message: message,
          failure: failure,
        );

  /// الحالة الأولية
  const PaymentState.initial()
      : availablePaymentMethods = const [],
        savedPaymentMethods = const [],
        selectedPaymentMethod = null,
        paymentIntent = null,
        paymentResult = null,
        paymentHistory = const [],
        super.initial();

  /// حالة التحميل
  const PaymentState.loading({
    List<PaymentMethodEntity> availablePaymentMethods = const [],
    List<PaymentMethodEntity> savedPaymentMethods = const [],
    PaymentMethodEntity? selectedPaymentMethod,
    PaymentIntentEntity? paymentIntent,
    PaymentResultEntity? paymentResult,
    List<PaymentResultEntity> paymentHistory = const [],
  })  : availablePaymentMethods = availablePaymentMethods,
        savedPaymentMethods = savedPaymentMethods,
        selectedPaymentMethod = selectedPaymentMethod,
        paymentIntent = paymentIntent,
        paymentResult = paymentResult,
        paymentHistory = paymentHistory,
        super.loading();

  /// حالة النجاح
  const PaymentState.success({
    String? message,
    List<PaymentMethodEntity> availablePaymentMethods = const [],
    List<PaymentMethodEntity> savedPaymentMethods = const [],
    PaymentMethodEntity? selectedPaymentMethod,
    PaymentIntentEntity? paymentIntent,
    PaymentResultEntity? paymentResult,
    List<PaymentResultEntity> paymentHistory = const [],
  })  : availablePaymentMethods = availablePaymentMethods,
        savedPaymentMethods = savedPaymentMethods,
        selectedPaymentMethod = selectedPaymentMethod,
        paymentIntent = paymentIntent,
        paymentResult = paymentResult,
        paymentHistory = paymentHistory,
        super.success(message: message);

  /// حالة الفشل
  const PaymentState.failure({
    required Failure failure,
    List<PaymentMethodEntity> availablePaymentMethods = const [],
    List<PaymentMethodEntity> savedPaymentMethods = const [],
    PaymentMethodEntity? selectedPaymentMethod,
    PaymentIntentEntity? paymentIntent,
    PaymentResultEntity? paymentResult,
    List<PaymentResultEntity> paymentHistory = const [],
  })  : availablePaymentMethods = availablePaymentMethods,
        savedPaymentMethods = savedPaymentMethods,
        selectedPaymentMethod = selectedPaymentMethod,
        paymentIntent = paymentIntent,
        paymentResult = paymentResult,
        paymentHistory = paymentHistory,
        super.failure(failure: failure);

  /// نسخ الحالة مع تحديث بعض الحقول
  PaymentState copyWith({
    bool? isInitial,
    bool? isLoading,
    bool? isSuccess,
    bool? isFailure,
    String? message,
    Failure? failure,
    List<PaymentMethodEntity>? availablePaymentMethods,
    List<PaymentMethodEntity>? savedPaymentMethods,
    PaymentMethodEntity? selectedPaymentMethod,
    PaymentIntentEntity? paymentIntent,
    PaymentResultEntity? paymentResult,
    List<PaymentResultEntity>? paymentHistory,
  }) {
    return PaymentState(
      isInitial: isInitial ?? this.isInitial,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
      message: message ?? this.message,
      failure: failure ?? this.failure,
      availablePaymentMethods:
          availablePaymentMethods ?? this.availablePaymentMethods,
      savedPaymentMethods: savedPaymentMethods ?? this.savedPaymentMethods,
      selectedPaymentMethod:
          selectedPaymentMethod ?? this.selectedPaymentMethod,
      paymentIntent: paymentIntent ?? this.paymentIntent,
      paymentResult: paymentResult ?? this.paymentResult,
      paymentHistory: paymentHistory ?? this.paymentHistory,
    );
  }
}

/// نموذج عرض الدفع
class PaymentViewModel extends StateNotifier<PaymentState> {
  final GetAvailablePaymentMethodsUseCase _getAvailablePaymentMethodsUseCase;
  final GetSavedPaymentMethodsUseCase _getSavedPaymentMethodsUseCase;
  final SavePaymentMethodUseCase _savePaymentMethodUseCase;
  final DeletePaymentMethodUseCase _deletePaymentMethodUseCase;
  final SetDefaultPaymentMethodUseCase _setDefaultPaymentMethodUseCase;
  final CreatePaymentIntentUseCase _createPaymentIntentUseCase;
  final ConfirmPaymentUseCase _confirmPaymentUseCase;
  final ProcessPaymentUseCase _processPaymentUseCase;
  final GetPaymentHistoryUseCase _getPaymentHistoryUseCase;

  PaymentViewModel({
    required GetAvailablePaymentMethodsUseCase
        getAvailablePaymentMethodsUseCase,
    required GetSavedPaymentMethodsUseCase getSavedPaymentMethodsUseCase,
    required SavePaymentMethodUseCase savePaymentMethodUseCase,
    required DeletePaymentMethodUseCase deletePaymentMethodUseCase,
    required SetDefaultPaymentMethodUseCase setDefaultPaymentMethodUseCase,
    required CreatePaymentIntentUseCase createPaymentIntentUseCase,
    required ConfirmPaymentUseCase confirmPaymentUseCase,
    required ProcessPaymentUseCase processPaymentUseCase,
    required GetPaymentHistoryUseCase getPaymentHistoryUseCase,
  })  : _getAvailablePaymentMethodsUseCase = getAvailablePaymentMethodsUseCase,
        _getSavedPaymentMethodsUseCase = getSavedPaymentMethodsUseCase,
        _savePaymentMethodUseCase = savePaymentMethodUseCase,
        _deletePaymentMethodUseCase = deletePaymentMethodUseCase,
        _setDefaultPaymentMethodUseCase = setDefaultPaymentMethodUseCase,
        _createPaymentIntentUseCase = createPaymentIntentUseCase,
        _confirmPaymentUseCase = confirmPaymentUseCase,
        _processPaymentUseCase = processPaymentUseCase,
        _getPaymentHistoryUseCase = getPaymentHistoryUseCase,
        super(const PaymentState.initial());

  /// تهيئة نموذج العرض
  Future<void> initialize() async {
    state = const PaymentState.loading();

    await Future.wait([
      loadAvailablePaymentMethods(),
      loadSavedPaymentMethods(),
      loadPaymentHistory(),
    ]);

    state = PaymentState.success(
      availablePaymentMethods: state.availablePaymentMethods,
      savedPaymentMethods: state.savedPaymentMethods,
      paymentHistory: state.paymentHistory,
      message: 'تم تحميل بيانات الدفع بنجاح',
    );
  }

  /// تحميل طرق الدفع المتاحة
  Future<void> loadAvailablePaymentMethods() async {
    final result = await _getAvailablePaymentMethodsUseCase(NoParams());

    result.fold(
      (failure) => state = PaymentState.failure(
        failure: failure,
        savedPaymentMethods: state.savedPaymentMethods,
        selectedPaymentMethod: state.selectedPaymentMethod,
        paymentIntent: state.paymentIntent,
        paymentResult: state.paymentResult,
        paymentHistory: state.paymentHistory,
      ),
      (paymentMethods) => state = state.copyWith(
        availablePaymentMethods: paymentMethods,
      ),
    );
  }

  /// تحميل طرق الدفع المحفوظة
  Future<void> loadSavedPaymentMethods() async {
    final result = await _getSavedPaymentMethodsUseCase(NoParams());

    result.fold(
      (failure) => state = PaymentState.failure(
        failure: failure,
        availablePaymentMethods: state.availablePaymentMethods,
        selectedPaymentMethod: state.selectedPaymentMethod,
        paymentIntent: state.paymentIntent,
        paymentResult: state.paymentResult,
        paymentHistory: state.paymentHistory,
      ),
      (paymentMethods) {
        state = state.copyWith(
          savedPaymentMethods: paymentMethods,
        );

        // تحديد طريقة الدفع الافتراضية
        if (paymentMethods.isNotEmpty && state.selectedPaymentMethod == null) {
          final defaultMethod = paymentMethods.firstWhere(
            (method) => method.isDefault,
            orElse: () => paymentMethods.first,
          );

          state = state.copyWith(
            selectedPaymentMethod: defaultMethod,
          );
        }
      },
    );
  }

  /// تحميل سجل المدفوعات
  Future<void> loadPaymentHistory() async {
    final result = await _getPaymentHistoryUseCase(NoParams());

    result.fold(
      (failure) => state = PaymentState.failure(
        failure: failure,
        availablePaymentMethods: state.availablePaymentMethods,
        savedPaymentMethods: state.savedPaymentMethods,
        selectedPaymentMethod: state.selectedPaymentMethod,
        paymentIntent: state.paymentIntent,
        paymentResult: state.paymentResult,
      ),
      (paymentHistory) => state = state.copyWith(
        paymentHistory: paymentHistory,
      ),
    );
  }

  /// اختيار طريقة دفع
  void selectPaymentMethod(PaymentMethodEntity paymentMethod) {
    state = state.copyWith(
      selectedPaymentMethod: paymentMethod,
    );
  }

  /// حفظ طريقة دفع جديدة
  Future<void> savePaymentMethod(PaymentMethodEntity paymentMethod) async {
    state = PaymentState.loading(
      availablePaymentMethods: state.availablePaymentMethods,
      savedPaymentMethods: state.savedPaymentMethods,
      selectedPaymentMethod: state.selectedPaymentMethod,
      paymentIntent: state.paymentIntent,
      paymentResult: state.paymentResult,
      paymentHistory: state.paymentHistory,
    );

    final params = SavePaymentMethodParams(paymentMethod: paymentMethod);
    final result = await _savePaymentMethodUseCase(params);

    result.fold(
      (failure) => state = PaymentState.failure(
        failure: failure,
        availablePaymentMethods: state.availablePaymentMethods,
        savedPaymentMethods: state.savedPaymentMethods,
        selectedPaymentMethod: state.selectedPaymentMethod,
        paymentIntent: state.paymentIntent,
        paymentResult: state.paymentResult,
        paymentHistory: state.paymentHistory,
      ),
      (savedMethod) async {
        // إعادة تحميل طرق الدفع المحفوظة
        await loadSavedPaymentMethods();

        state = PaymentState.success(
          message: 'تم حفظ طريقة الدفع بنجاح',
          availablePaymentMethods: state.availablePaymentMethods,
          savedPaymentMethods: state.savedPaymentMethods,
          selectedPaymentMethod: state.selectedPaymentMethod,
          paymentIntent: state.paymentIntent,
          paymentResult: state.paymentResult,
          paymentHistory: state.paymentHistory,
        );
      },
    );
  }

  /// حذف طريقة دفع
  Future<void> deletePaymentMethod(String paymentMethodId) async {
    state = PaymentState.loading(
      availablePaymentMethods: state.availablePaymentMethods,
      savedPaymentMethods: state.savedPaymentMethods,
      selectedPaymentMethod: state.selectedPaymentMethod,
      paymentIntent: state.paymentIntent,
      paymentResult: state.paymentResult,
      paymentHistory: state.paymentHistory,
    );

    final params = DeletePaymentMethodParams(paymentMethodId: paymentMethodId);
    final result = await _deletePaymentMethodUseCase(params);

    result.fold(
      (failure) => state = PaymentState.failure(
        failure: failure,
        availablePaymentMethods: state.availablePaymentMethods,
        savedPaymentMethods: state.savedPaymentMethods,
        selectedPaymentMethod: state.selectedPaymentMethod,
        paymentIntent: state.paymentIntent,
        paymentResult: state.paymentResult,
        paymentHistory: state.paymentHistory,
      ),
      (success) async {
        // إعادة تحميل طرق الدفع المحفوظة
        await loadSavedPaymentMethods();

        // إعادة تعيين طريقة الدفع المحددة إذا تم حذفها
        if (state.selectedPaymentMethod?.id == paymentMethodId) {
          final newSelectedMethod = state.savedPaymentMethods.isNotEmpty
              ? state.savedPaymentMethods.first
              : null;

          state = state.copyWith(
            selectedPaymentMethod: newSelectedMethod,
          );
        }

        state = PaymentState.success(
          message: 'تم حذف طريقة الدفع بنجاح',
          availablePaymentMethods: state.availablePaymentMethods,
          savedPaymentMethods: state.savedPaymentMethods,
          selectedPaymentMethod: state.selectedPaymentMethod,
          paymentIntent: state.paymentIntent,
          paymentResult: state.paymentResult,
          paymentHistory: state.paymentHistory,
        );
      },
    );
  }

  /// تعيين طريقة دفع افتراضية
  Future<void> setDefaultPaymentMethod(String paymentMethodId) async {
    state = PaymentState.loading(
      availablePaymentMethods: state.availablePaymentMethods,
      savedPaymentMethods: state.savedPaymentMethods,
      selectedPaymentMethod: state.selectedPaymentMethod,
      paymentIntent: state.paymentIntent,
      paymentResult: state.paymentResult,
      paymentHistory: state.paymentHistory,
    );

    final params =
        SetDefaultPaymentMethodParams(paymentMethodId: paymentMethodId);
    final result = await _setDefaultPaymentMethodUseCase(params);

    result.fold(
      (failure) => state = PaymentState.failure(
        failure: failure,
        availablePaymentMethods: state.availablePaymentMethods,
        savedPaymentMethods: state.savedPaymentMethods,
        selectedPaymentMethod: state.selectedPaymentMethod,
        paymentIntent: state.paymentIntent,
        paymentResult: state.paymentResult,
        paymentHistory: state.paymentHistory,
      ),
      (success) async {
        // إعادة تحميل طرق الدفع المحفوظة
        await loadSavedPaymentMethods();

        state = PaymentState.success(
          message: 'تم تعيين طريقة الدفع الافتراضية بنجاح',
          availablePaymentMethods: state.availablePaymentMethods,
          savedPaymentMethods: state.savedPaymentMethods,
          selectedPaymentMethod: state.selectedPaymentMethod,
          paymentIntent: state.paymentIntent,
          paymentResult: state.paymentResult,
          paymentHistory: state.paymentHistory,
        );
      },
    );
  }

  /// إنشاء نية دفع
  Future<void> createPaymentIntent({
    required int amount,
    required String currency,
    String? paymentMethodId,
  }) async {
    state = PaymentState.loading(
      availablePaymentMethods: state.availablePaymentMethods,
      savedPaymentMethods: state.savedPaymentMethods,
      selectedPaymentMethod: state.selectedPaymentMethod,
      paymentIntent: state.paymentIntent,
      paymentResult: state.paymentResult,
      paymentHistory: state.paymentHistory,
    );

    // استخدام طريقة الدفع المحددة إذا لم يتم تحديد طريقة دفع
    final methodId = paymentMethodId ?? state.selectedPaymentMethod?.id;

    if (methodId == null) {
      state = PaymentState.failure(
        failure: const ValidationFailure(
          message: 'يجب اختيار طريقة دفع',
        ),
        availablePaymentMethods: state.availablePaymentMethods,
        savedPaymentMethods: state.savedPaymentMethods,
        selectedPaymentMethod: state.selectedPaymentMethod,
        paymentIntent: state.paymentIntent,
        paymentResult: state.paymentResult,
        paymentHistory: state.paymentHistory,
      );
      return;
    }

    final params = CreatePaymentIntentParams(
      amount: amount,
      currency: currency,
      paymentMethodId: methodId,
    );
    final result = await _createPaymentIntentUseCase(params);

    result.fold(
      (failure) => state = PaymentState.failure(
        failure: failure,
        availablePaymentMethods: state.availablePaymentMethods,
        savedPaymentMethods: state.savedPaymentMethods,
        selectedPaymentMethod: state.selectedPaymentMethod,
        paymentIntent: state.paymentIntent,
        paymentResult: state.paymentResult,
        paymentHistory: state.paymentHistory,
      ),
      (paymentIntent) => state = PaymentState.success(
        message: 'تم إنشاء نية الدفع بنجاح',
        availablePaymentMethods: state.availablePaymentMethods,
        savedPaymentMethods: state.savedPaymentMethods,
        selectedPaymentMethod: state.selectedPaymentMethod,
        paymentIntent: paymentIntent,
        paymentResult: state.paymentResult,
        paymentHistory: state.paymentHistory,
      ),
    );
  }

  /// تأكيد الدفع
  Future<void> confirmPayment({
    String? paymentIntentId,
    String? clientSecret,
  }) async {
    state = PaymentState.loading(
      availablePaymentMethods: state.availablePaymentMethods,
      savedPaymentMethods: state.savedPaymentMethods,
      selectedPaymentMethod: state.selectedPaymentMethod,
      paymentIntent: state.paymentIntent,
      paymentResult: state.paymentResult,
      paymentHistory: state.paymentHistory,
    );

    // استخدام نية الدفع المحددة إذا لم يتم تحديد نية دفع
    final intentId = paymentIntentId ?? state.paymentIntent?.id;
    final secret = clientSecret ?? state.paymentIntent?.clientSecret;

    if (intentId == null || secret == null) {
      state = PaymentState.failure(
        failure: const ValidationFailure(
          message: 'يجب إنشاء نية دفع أولاً',
        ),
        availablePaymentMethods: state.availablePaymentMethods,
        savedPaymentMethods: state.savedPaymentMethods,
        selectedPaymentMethod: state.selectedPaymentMethod,
        paymentIntent: state.paymentIntent,
        paymentResult: state.paymentResult,
        paymentHistory: state.paymentHistory,
      );
      return;
    }

    final params = ConfirmPaymentParams(
      paymentIntentId: intentId,
      clientSecret: secret,
    );
    final result = await _confirmPaymentUseCase(params);

    result.fold(
      (failure) => state = PaymentState.failure(
        failure: failure,
        availablePaymentMethods: state.availablePaymentMethods,
        savedPaymentMethods: state.savedPaymentMethods,
        selectedPaymentMethod: state.selectedPaymentMethod,
        paymentIntent: state.paymentIntent,
        paymentResult: state.paymentResult,
        paymentHistory: state.paymentHistory,
      ),
      (paymentResult) async {
        // إعادة تحميل سجل المدفوعات
        await loadPaymentHistory();

        state = PaymentState.success(
          message: paymentResult.success
              ? 'تم تأكيد الدفع بنجاح'
              : 'فشل تأكيد الدفع: ${paymentResult.status}',
          availablePaymentMethods: state.availablePaymentMethods,
          savedPaymentMethods: state.savedPaymentMethods,
          selectedPaymentMethod: state.selectedPaymentMethod,
          paymentIntent: state.paymentIntent,
          paymentResult: paymentResult,
          paymentHistory: state.paymentHistory,
        );
      },
    );
  }

  /// معالجة عملية الدفع بالكامل
  Future<void> processPayment({
    required int amount,
    required String currency,
    String? paymentMethodId,
  }) async {
    state = PaymentState.loading(
      availablePaymentMethods: state.availablePaymentMethods,
      savedPaymentMethods: state.savedPaymentMethods,
      selectedPaymentMethod: state.selectedPaymentMethod,
      paymentIntent: state.paymentIntent,
      paymentResult: state.paymentResult,
      paymentHistory: state.paymentHistory,
    );

    // استخدام طريقة الدفع المحددة إذا لم يتم تحديد طريقة دفع
    final methodId = paymentMethodId ?? state.selectedPaymentMethod?.id;

    if (methodId == null) {
      state = PaymentState.failure(
        failure: const ValidationFailure(
          message: 'يجب اختيار طريقة دفع',
        ),
        availablePaymentMethods: state.availablePaymentMethods,
        savedPaymentMethods: state.savedPaymentMethods,
        selectedPaymentMethod: state.selectedPaymentMethod,
        paymentIntent: state.paymentIntent,
        paymentResult: state.paymentResult,
        paymentHistory: state.paymentHistory,
      );
      return;
    }

    final params = ProcessPaymentParams(
      amount: amount,
      currency: currency,
      paymentMethodId: methodId,
    );
    final result = await _processPaymentUseCase(params);

    result.fold(
      (failure) => state = PaymentState.failure(
        failure: failure,
        availablePaymentMethods: state.availablePaymentMethods,
        savedPaymentMethods: state.savedPaymentMethods,
        selectedPaymentMethod: state.selectedPaymentMethod,
        paymentIntent: state.paymentIntent,
        paymentResult: state.paymentResult,
        paymentHistory: state.paymentHistory,
      ),
      (paymentResult) async {
        // إعادة تحميل سجل المدفوعات
        await loadPaymentHistory();

        state = PaymentState.success(
          message: paymentResult.success
              ? 'تم إتمام عملية الدفع بنجاح'
              : 'فشل عملية الدفع: ${paymentResult.status}',
          availablePaymentMethods: state.availablePaymentMethods,
          savedPaymentMethods: state.savedPaymentMethods,
          selectedPaymentMethod: state.selectedPaymentMethod,
          paymentIntent: state.paymentIntent,
          paymentResult: paymentResult,
          paymentHistory: state.paymentHistory,
        );
      },
    );
  }
}

/// مزود نموذج عرض الدفع
final paymentViewModelProvider =
    StateNotifierProvider<PaymentViewModel, PaymentState>((ref) {
  final getAvailablePaymentMethodsUseCase =
      ref.watch(getAvailablePaymentMethodsUseCaseProvider);
  final getSavedPaymentMethodsUseCase =
      ref.watch(getSavedPaymentMethodsUseCaseProvider);
  final savePaymentMethodUseCase = ref.watch(savePaymentMethodUseCaseProvider);
  final deletePaymentMethodUseCase =
      ref.watch(deletePaymentMethodUseCaseProvider);
  final setDefaultPaymentMethodUseCase =
      ref.watch(setDefaultPaymentMethodUseCaseProvider);
  final createPaymentIntentUseCase =
      ref.watch(createPaymentIntentUseCaseProvider);
  final confirmPaymentUseCase = ref.watch(confirmPaymentUseCaseProvider);
  final processPaymentUseCase = ref.watch(processPaymentUseCaseProvider);
  final getPaymentHistoryUseCase = ref.watch(getPaymentHistoryUseCaseProvider);

  return PaymentViewModel(
    getAvailablePaymentMethodsUseCase: getAvailablePaymentMethodsUseCase,
    getSavedPaymentMethodsUseCase: getSavedPaymentMethodsUseCase,
    savePaymentMethodUseCase: savePaymentMethodUseCase,
    deletePaymentMethodUseCase: deletePaymentMethodUseCase,
    setDefaultPaymentMethodUseCase: setDefaultPaymentMethodUseCase,
    createPaymentIntentUseCase: createPaymentIntentUseCase,
    confirmPaymentUseCase: confirmPaymentUseCase,
    processPaymentUseCase: processPaymentUseCase,
    getPaymentHistoryUseCase: getPaymentHistoryUseCase,
  );
});

/// مزودات حالات الاستخدام
final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  // يجب تنفيذ هذا المزود في ملف منفصل
  throw UnimplementedError();
});

final getAvailablePaymentMethodsUseCaseProvider =
    Provider<GetAvailablePaymentMethodsUseCase>((ref) {
  final repository = ref.watch(paymentRepositoryProvider);
  return GetAvailablePaymentMethodsUseCase(repository);
});

final getSavedPaymentMethodsUseCaseProvider =
    Provider<GetSavedPaymentMethodsUseCase>((ref) {
  final repository = ref.watch(paymentRepositoryProvider);
  return GetSavedPaymentMethodsUseCase(repository);
});

final savePaymentMethodUseCaseProvider =
    Provider<SavePaymentMethodUseCase>((ref) {
  final repository = ref.watch(paymentRepositoryProvider);
  return SavePaymentMethodUseCase(repository);
});

final deletePaymentMethodUseCaseProvider =
    Provider<DeletePaymentMethodUseCase>((ref) {
  final repository = ref.watch(paymentRepositoryProvider);
  return DeletePaymentMethodUseCase(repository);
});

final setDefaultPaymentMethodUseCaseProvider =
    Provider<SetDefaultPaymentMethodUseCase>((ref) {
  final repository = ref.watch(paymentRepositoryProvider);
  return SetDefaultPaymentMethodUseCase(repository);
});

final createPaymentIntentUseCaseProvider =
    Provider<CreatePaymentIntentUseCase>((ref) {
  final repository = ref.watch(paymentRepositoryProvider);
  return CreatePaymentIntentUseCase(repository);
});

final confirmPaymentUseCaseProvider = Provider<ConfirmPaymentUseCase>((ref) {
  final repository = ref.watch(paymentRepositoryProvider);
  return ConfirmPaymentUseCase(repository);
});

final processPaymentUseCaseProvider = Provider<ProcessPaymentUseCase>((ref) {
  final repository = ref.watch(paymentRepositoryProvider);
  return ProcessPaymentUseCase(repository);
});

final getPaymentHistoryUseCaseProvider =
    Provider<GetPaymentHistoryUseCase>((ref) {
  final repository = ref.watch(paymentRepositoryProvider);
  return GetPaymentHistoryUseCase(repository);
});
