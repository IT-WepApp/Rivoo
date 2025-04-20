import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:shared_widgets/shared_widgets.dart';
// Removed unused AuthService import
import 'package:user_app/features/auth/application/auth_notifier.dart'; // Import auth notifier
// Removed unused GoRouter import

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Access the notifier via ref
        final authNotifier = ref.read(authProvider.notifier);
        await authNotifier.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        // Navigation is handled by the GoRouter redirect based on auth state

      } on fb_auth.FirebaseAuthException catch (e) {
        _handleAuthError(e);
      } catch (e) {
        _showErrorSnackBar('An unexpected error occurred: ${e.toString()}');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _handleAuthError(fb_auth.FirebaseAuthException e) {
    String errorMessage;
    switch (e.code) {
      case 'user-not-found':
      case 'invalid-email':
        errorMessage = 'Invalid email or user not found.';
        break;
      case 'wrong-password':
      case 'invalid-credential': // General credential error
        errorMessage = 'Incorrect password.';
        break;
      case 'user-disabled':
        errorMessage = 'This user account has been disabled.';
        break;
      case 'too-many-requests':
         errorMessage = 'Too many login attempts. Please try again later.';
         break;
      default:
        errorMessage = 'Login failed: ${e.message ?? e.code}';
    }
    _showErrorSnackBar(errorMessage);
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes to potentially show errors from the notifier
    ref.listen(authProvider, (previous, next) {
      // Handle potential errors pushed onto the state by the notifier if needed
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"), 
      ),
      body: Center( 
        child: SingleChildScrollView( 
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch, 
              children: [
                Text(
                  "Welcome Back!",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                     color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 30),
                AppTextField(
                  controller: _emailController,
                  label: "Email",
                  hintText: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => (value?.isEmpty ?? true) ? 'Please enter email' : null,
                ),
                const SizedBox(height: 15),
                AppTextField(
                  controller: _passwordController,
                  label: "Password",
                  hintText: 'Enter your password',
                  obscureText: true,
                  validator: (value) => (value?.isEmpty ?? true) ? 'Please enter password' : null,
                ),
                const SizedBox(height: 30),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : AppButton(
                        onPressed: _login,
                        text: "Login",
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}