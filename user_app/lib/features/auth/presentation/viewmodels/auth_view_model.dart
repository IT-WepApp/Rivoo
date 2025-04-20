import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:user_app/core/architecture/presentation/base_view_model.dart';
import 'package:user_app/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:user_app/features/auth/domain/user_model.dart';

part 'auth_view_model.g.dart';

/// نموذج مشاهدة المصادقة
/// يستخدم BaseViewModel من العمارة النظيفة
@riverpod
class AuthViewModel extends _$AuthViewModel implements BaseViewModel<UserModel> {
  late SignInUseCase _signInUseCase;

  @override
  ViewState<UserModel> build() {
    // إعداد حالات الاستخدام
    _signInUseCase = ref.read(signInUseCaseProvider);
    
    // إعادة الحالة الأولية
    return ViewState<UserModel>.initial();
  }

  /// تسجيل الدخول باستخدام البريد الإلكتروني وكلمة المرور
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    // تحديث الحالة إلى حالة تحميل
    state = ViewState<UserModel>.loading();

    // استدعاء حالة استخدام تسجيل الدخول
    final result = await _signInUseCase(
      SignInParams(
        email: email,
        password: password,
      ),
    );

    // تحديث الحالة بناءً على النتيجة
    result.fold(
      (failure) => state = ViewState<UserModel>.fromFailure(failure),
      (user) => state = ViewState<UserModel>.success(user),
    );
  }

  /// التحقق مما إذا كان المستخدم مسجل الدخول
  bool get isAuthenticated => state.isSuccess && state.data != null;

  /// الحصول على المستخدم الحالي
  UserModel? get currentUser => state.data;

  /// الحصول على دور المستخدم الحالي
  String get userRole => state.data?.role ?? 'guest';
}

/// مزود حالة استخدام تسجيل الدخول
@riverpod
SignInUseCase signInUseCase(SignInUseCaseRef ref) {
  // في التطبيق الحقيقي، سنحصل على المستودع من مزود آخر
  // لكن هنا نستخدم قيمة افتراضية للتوضيح فقط
  final authRepository = ref.read(authRepositoryProvider);
  return SignInUseCase(authRepository);
}

/// مزود مستودع المصادقة
@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  // في التطبيق الحقيقي، سنحصل على التبعيات من مزودات أخرى
  // لكن هنا نستخدم قيمة افتراضية للتوضيح فقط
  return AuthRepositoryImpl(
    firebaseAuth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
    googleSignIn: GoogleSignIn(),
    secureStorage: SecureStorageService(),
  );
}
