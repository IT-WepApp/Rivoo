import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_libs/services/services.dart'; 
import 'package:shared_libs/widgets/widgets.dart'; // ✅ لحل UserService
import 'package:go_router/go_router.dart'; // ✅ لحل context.go

class UserLoginPage extends StatefulWidget {
  const UserLoginPage({Key? key}) : super(key: key);

  @override
  State<UserLoginPage> createState() => _UserLoginPageState();
}

class _UserLoginPageState extends State<UserLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _showSnack(String message, {Color background = Colors.red}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: background),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (!mounted) return;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showSnack('Authentication failed.');
        setState(() => _isLoading = false);
        return;
      }

      final userData = await UserService().getUser(user.uid);
      if (!mounted) return;

      if (userData != null && userData.role == 'user') {
        _showSnack('Login successful!', background: Colors.green);
        context.go('/userHome'); // ✅ بعد إضافة import
      } else {
        _showSnack('Unauthorized: not a user.');
        await FirebaseAuth.instance.signOut();
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final msg = (e.code == 'user-not-found' || e.code == 'invalid-credential')
          ? 'Email or password incorrect.'
          : 'Login error: ${e.message}';
      _showSnack(msg);
    } catch (e) {
      if (!mounted) return;
      _showSnack('Unexpected error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AppTextField(
                controller: _emailController,
                label: 'Email', // ✅ استبدال labelText بـ label
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please enter your email';
                  if (!v.contains('@') || !v.contains('.')) {
                    return 'Invalid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _passwordController,
                label: 'Password', // ✅ استبدال labelText بـ label
                obscureText: true,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (v.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: AppButton(
                        onPressed: _login,
                        text: 'Login',
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
