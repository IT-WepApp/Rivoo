import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:shared_services/shared_services.dart';
// Import shared services
import 'package:shared_widgets/shared_widgets.dart'; // Import shared widgets
import 'package:go_router/go_router.dart'; // Import GoRouter
// Import specific auth notifier

class SellerLoginPage extends ConsumerStatefulWidget { // Change to StatefulWidget
  const SellerLoginPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SellerLoginPage> createState() => _SellerLoginPageState();
}

class _SellerLoginPageState extends ConsumerState<SellerLoginPage> {
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

 void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
       // Use Firebase Auth for login
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      // Optionally: Verify user role after successful Firebase login
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
          // Fetch user data from your backend/service to check role
          final userService = ref.read(userServiceProvider); // Access UserService via provider
          final userData = await userService.getUser(user.uid);
          if (mounted && userData != null && userData.role == 'seller') {
             // Update Riverpod state if needed (though maybe not necessary just for login)
             // ref.read(sellerAuthProvider.notifier).updateState(userData); 
              context.go('/sellerHome'); // Navigate on successful login and role check
          } else if (mounted) {
              _showErrorSnackBar('Login successful, but user is not a seller.');
              await FirebaseAuth.instance.signOut(); // Sign out if role is incorrect
          }
      } else if (mounted) {
         _showErrorSnackBar('Authentication error occurred.');
      }

    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final errorMessage = (e.code == 'user-not-found' || e.code == 'invalid-credential')
          ? 'Incorrect email or password.'
          : 'Login failed: ${e.message}';
      _showErrorSnackBar(errorMessage);
    } catch (e) {
       if (!mounted) return;
       _showErrorSnackBar('An unexpected error occurred: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Login'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Welcome, Seller!', style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
                 const SizedBox(height: 32),
                AppTextField(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty || !value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _passwordController,
                  label: 'Password',
                  obscureText: true,
                   prefixIcon: Icons.lock_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                     if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : AppButton(
                        text: 'Login',
                        onPressed: _login,
                      ),
                 // Add link for registration or password reset if applicable
                 const SizedBox(height: 16),
                 TextButton(
                   onPressed: () { /* Implement registration/forgot password navigation */ },
                   child: const Text('Forgot Password? / Register'),
                 ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
