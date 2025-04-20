import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_app/core/architecture/domain/failure.dart';
import 'package:user_app/core/architecture/presentation/base_view_model.dart';
import 'package:user_app/features/auth/domain/auth_repository.dart';
import 'package:user_app/features/auth/domain/usecases/sign_in_usecase.dart';

/// حالة نموذج عرض المصادقة
class AuthState extends BaseViewState {
  final UserEntity? userData;
  final bool isAuthenticated;
  
  const AuthState({
    required bool isInitial,
    required bool isLoading,
    required bool isSuccess,
    required bool isFailure,
    String? message,
    Failure? failure,
    this.userData,
    this.isAuthenticated = false,
  }) : super(
    isInitial: isInitial,
    isLoading: isLoading,
    isSuccess: isSuccess,
    isFailure: isFailure,
    message: message,
    failure: failure,
  );
  
  /// الحالة الأولية
  const AuthState.initial()
      : userData = null,
        isAuthenticated = false,
        super.initial();
  
  /// حالة التحميل
  const AuthState.loading({UserEntity? userData, bool isAuthenticated = false})
      : userData = userData,
        isAuthenticated = isAuthenticated,
        super.loading();
  
  /// حالة النجاح
  const AuthState.success({
    String? message,
    required UserEntity? userData,
    required bool isAuthenticated,
  }) : userData = userData,
        isAuthenticated = isAuthenticated,
        super.success(message: message);
  
  /// حالة الفشل
  const AuthState.failure({
    required Failure failure,
    UserEntity? userData,
    bool isAuthenticated = false,
  }) : userData = userData,
        isAuthenticated = isAuthenticated,
        super.failure(failure: failure);
  
  /// نسخ الحالة مع تحديث بعض الحقول
  AuthState copyWith({
    bool? isInitial,
    bool? isLoading,
    bool? isSuccess,
    bool? isFailure,
    String? message,
    Failure? failure,
    UserEntity? userData,
    bool? isAuthenticated,
  }) {
    return AuthState(
      isInitial: isInitial ?? this.isInitial,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
      message: message ?? this.message,
      failure: failure ?? this.failure,
      userData: userData ?? this.userData,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

/// نموذج عرض المصادقة
class AuthViewModel extends StateNotifier<AuthState> {
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final SignOutUseCase _signOutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final IsAuthenticatedUseCase _isAuthenticatedUseCase;
  final UpdateUserProfileUseCase _updateUserProfileUseCase;
  final UpdatePasswordUseCase _updatePasswordUseCase;
  final DeleteAccountUseCase _deleteAccountUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;
  
  AuthViewModel({
    required SignInUseCase signInUseCase,
    required SignUpUseCase signUpUseCase,
    required SignOutUseCase signOutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required IsAuthenticatedUseCase isAuthenticatedUseCase,
    required UpdateUserProfileUseCase updateUserProfileUseCase,
    required UpdatePasswordUseCase updatePasswordUseCase,
    required DeleteAccountUseCase deleteAccountUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
  }) : _signInUseCase = signInUseCase,
       _signUpUseCase = signUpUseCase,
       _signOutUseCase = signOutUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase,
       _isAuthenticatedUseCase = isAuthenticatedUseCase,
       _updateUserProfileUseCase = updateUserProfileUseCase,
       _updatePasswordUseCase = updatePasswordUseCase,
       _deleteAccountUseCase = deleteAccountUseCase,
       _resetPasswordUseCase = resetPasswordUseCase,
       super(const AuthState.initial());
  
  /// التحقق من حالة المصادقة عند بدء التطبيق
  Future<void> checkAuthStatus() async {
    state = const AuthState.loading();
    
    final isAuthenticatedResult = await _isAuthenticatedUseCase(NoParams());
    
    isAuthenticatedResult.fold(
      (failure) => state = AuthState.failure(failure: failure),
      (isAuthenticated) async {
        if (isAuthenticated) {
          final userResult = await _getCurrentUserUseCase(NoParams());
          
          userResult.fold(
            (failure) => state = AuthState.failure(failure: failure),
            (user) => state = AuthState.success(
              userData: user,
              isAuthenticated: true,
              message: 'تم تسجيل الدخول بنجاح',
            ),
          );
        } else {
          state = const AuthState.success(
            userData: null,
            isAuthenticated: false,
            message: 'لم يتم تسجيل الدخول',
          );
        }
      },
    );
  }
  
  /// تسجيل الدخول
  Future<void> signIn(String email, String password) async {
    state = const AuthState.loading();
    
    final params = SignInParams(email: email, password: password);
    final result = await _signInUseCase(params);
    
    result.fold(
      (failure) => state = AuthState.failure(failure: failure),
      (user) => state = AuthState.success(
        userData: user,
        isAuthenticated: true,
        message: 'تم تسجيل الدخول بنجاح',
      ),
    );
  }
  
  /// إنشاء حساب جديد
  Future<void> signUp(String email, String password, String name) async {
    state = const AuthState.loading();
    
    final params = SignUpParams(email: email, password: password, name: name);
    final result = await _signUpUseCase(params);
    
    result.fold(
      (failure) => state = AuthState.failure(failure: failure),
      (user) => state = AuthState.success(
        userData: user,
        isAuthenticated: true,
        message: 'تم إنشاء الحساب بنجاح',
      ),
    );
  }
  
  /// تسجيل الخروج
  Future<void> signOut() async {
    state = AuthState.loading(
      userData: state.userData,
      isAuthenticated: state.isAuthenticated,
    );
    
    final result = await _signOutUseCase(NoParams());
    
    result.fold(
      (failure) => state = AuthState.failure(failure: failure),
      (_) => state = const AuthState.success(
        userData: null,
        isAuthenticated: false,
        message: 'تم تسجيل الخروج بنجاح',
      ),
    );
  }
  
  /// إعادة تعيين كلمة المرور
  Future<void> resetPassword(String email) async {
    state = AuthState.loading(
      userData: state.userData,
      isAuthenticated: state.isAuthenticated,
    );
    
    final params = ResetPasswordParams(email: email);
    final result = await _resetPasswordUseCase(params);
    
    result.fold(
      (failure) => state = AuthState.failure(failure: failure),
      (_) => state = AuthState.success(
        userData: state.userData,
        isAuthenticated: state.isAuthenticated,
        message: 'تم إرسال رابط إعادة تعيين كلمة المرور بنجاح',
      ),
    );
  }
  
  /// تحديث بيانات المستخدم
  Future<void> updateUserProfile(UserEntity user) async {
    state = AuthState.loading(
      userData: state.userData,
      isAuthenticated: state.isAuthenticated,
    );
    
    final params = UpdateUserProfileParams(user: user);
    final result = await _updateUserProfileUseCase(params);
    
    result.fold(
      (failure) => state = AuthState.failure(failure: failure),
      (updatedUser) => state = AuthState.success(
        userData: updatedUser,
        isAuthenticated: true,
        message: 'تم تحديث بيانات المستخدم بنجاح',
      ),
    );
  }
  
  /// تحديث كلمة المرور
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    state = AuthState.loading(
      userData: state.userData,
      isAuthenticated: state.isAuthenticated,
    );
    
    final params = UpdatePasswordParams(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    final result = await _updatePasswordUseCase(params);
    
    result.fold(
      (failure) => state = AuthState.failure(failure: failure),
      (_) => state = AuthState.success(
        userData: state.userData,
        isAuthenticated: true,
        message: 'تم تحديث كلمة المرور بنجاح',
      ),
    );
  }
  
  /// حذف الحساب
  Future<void> deleteAccount(String password) async {
    state = AuthState.loading(
      userData: state.userData,
      isAuthenticated: state.isAuthenticated,
    );
    
    final params = DeleteAccountParams(password: password);
    final result = await _deleteAccountUseCase(params);
    
    result.fold(
      (failure) => state = AuthState.failure(failure: failure),
      (_) => state = const AuthState.success(
        userData: null,
        isAuthenticated: false,
        message: 'تم حذف الحساب بنجاح',
      ),
    );
  }
}

/// مزود نموذج عرض المصادقة
final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  final signInUseCase = ref.watch(signInUseCaseProvider);
  final signUpUseCase = ref.watch(signUpUseCaseProvider);
  final signOutUseCase = ref.watch(signOutUseCaseProvider);
  final getCurrentUserUseCase = ref.watch(getCurrentUserUseCaseProvider);
  final isAuthenticatedUseCase = ref.watch(isAuthenticatedUseCaseProvider);
  final updateUserProfileUseCase = ref.watch(updateUserProfileUseCaseProvider);
  final updatePasswordUseCase = ref.watch(updatePasswordUseCaseProvider);
  final deleteAccountUseCase = ref.watch(deleteAccountUseCaseProvider);
  final resetPasswordUseCase = ref.watch(resetPasswordUseCaseProvider);
  
  return AuthViewModel(
    signInUseCase: signInUseCase,
    signUpUseCase: signUpUseCase,
    signOutUseCase: signOutUseCase,
    getCurrentUserUseCase: getCurrentUserUseCase,
    isAuthenticatedUseCase: isAuthenticatedUseCase,
    updateUserProfileUseCase: updateUserProfileUseCase,
    updatePasswordUseCase: updatePasswordUseCase,
    deleteAccountUseCase: deleteAccountUseCase,
    resetPasswordUseCase: resetPasswordUseCase,
  );
});

/// مزودات حالات الاستخدام
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  // يجب تنفيذ هذا المزود في ملف منفصل
  throw UnimplementedError();
});

final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignInUseCase(repository);
});

final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignUpUseCase(repository);
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignOutUseCase(repository);
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentUserUseCase(repository);
});

final isAuthenticatedUseCaseProvider = Provider<IsAuthenticatedUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return IsAuthenticatedUseCase(repository);
});

final updateUserProfileUseCaseProvider = Provider<UpdateUserProfileUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return UpdateUserProfileUseCase(repository);
});

final updatePasswordUseCaseProvider = Provider<UpdatePasswordUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return UpdatePasswordUseCase(repository);
});

final deleteAccountUseCaseProvider = Provider<DeleteAccountUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return DeleteAccountUseCase(repository);
});

final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return ResetPasswordUseCase(repository);
});
