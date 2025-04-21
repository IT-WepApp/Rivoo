import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/is_signed_in_usecase.dart';

// حالات BLoC للمصادقة
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserEntity user;

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
class AuthNotifier extends StateNotifier<AuthState> {
  final SignInUseCase _signInUseCase;
  final SignOutUseCase _signOutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final IsSignedInUseCase _isSignedInUseCase;

  AuthNotifier({
    required SignInUseCase signInUseCase,
    required SignOutUseCase signOutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required IsSignedInUseCase isSignedInUseCase,
  })  : _signInUseCase = signInUseCase,
        _signOutUseCase = signOutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _isSignedInUseCase = isSignedInUseCase,
        super(AuthInitial());

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
      final user = await _signInUseCase.execute(event.email, event.password);
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
