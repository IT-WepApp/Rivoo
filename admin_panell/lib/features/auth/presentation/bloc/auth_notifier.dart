import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/is_signed_in_usecase.dart';

// حالات BLoC للمصادقة
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;

  AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}

// أحداث BLoC للمصادقة
abstract class AuthEvent {}

class SignInEvent extends AuthEvent {
  final String email;
  final String password;

  SignInEvent({required this.email, required this.password});
}

class SignOutEvent extends AuthEvent {}

class CheckAuthStatusEvent extends AuthEvent {}

// مزود للوصول إلى حالة المصادقة
class AuthNotifier extends Notifier<AuthState> {
  late final SignInUseCase _signInUseCase;
  late final SignOutUseCase _signOutUseCase;
  late final GetCurrentUserUseCase _getCurrentUserUseCase;
  late final IsSignedInUseCase _isSignedInUseCase;

  @override
  AuthState build() {
    _signInUseCase = ref.read(signInUseCaseProvider);
    _signOutUseCase = ref.read(signOutUseCaseProvider);
    _getCurrentUserUseCase = ref.read(getCurrentUserUseCaseProvider);
    _isSignedInUseCase = ref.read(isSignedInUseCaseProvider);
    
    return AuthInitial();
  }

  Future<void> handleEvent(AuthEvent event) async {
    if (event is SignInEvent) {
      await _handleSignIn(event);
    } else if (event is SignOutEvent) {
      await _handleSignOut();
    } else if (event is CheckAuthStatusEvent) {
      await _handleCheckAuthStatus();
    }
  }

  Future<void> _handleSignIn(SignInEvent event) async {
    state = AuthLoading();

    try {
      final user = await _signInUseCase.execute(
          email: event.email, password: event.password);
      state = AuthAuthenticated(user);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> _handleSignOut() async {
    state = AuthLoading();

    try {
      await _signOutUseCase.execute();
      state = AuthUnauthenticated();
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> _handleCheckAuthStatus() async {
    state = AuthLoading();

    try {
      final isSignedIn = await _isSignedInUseCase.execute();

      if (isSignedIn) {
        final user = await _getCurrentUserUseCase.execute();

        if (user != null) {
          state = AuthAuthenticated(user);
        } else {
          state = AuthUnauthenticated();
        }
      } else {
        state = AuthUnauthenticated();
      }
    } catch (e) {
      state = AuthError(e.toString());
    }
  }
}

// تعريف مزودات لحالات الاستخدام
final signInUseCaseProvider = Provider<SignInUseCase>((ref) => throw UnimplementedError());
final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) => throw UnimplementedError());
final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) => throw UnimplementedError());
final isSignedInUseCaseProvider = Provider<IsSignedInUseCase>((ref) => throw UnimplementedError());

// تعريف مزود AuthNotifier
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(() => AuthNotifier());
