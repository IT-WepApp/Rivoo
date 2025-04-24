import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../../shared_libs/lib/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import '../../../../../../shared_libs/lib/services/services.dart'; // Import shared services
import 'package:go_router/go_router.dart'; // Import GoRouter
import '../../../../../../shared_libs/lib/models/models.dart'; // Import UserModel
import '../../../../../../shared_libs/lib/models/user_model.dart';
class DeliveryLoginPage extends ConsumerStatefulWidget {
  // Changed to Consumer
  const DeliveryLoginPage({Key? key}) : super(key: key);

  @override
  ConsumerState<DeliveryLoginPage> createState() =>
      _DeliveryLoginPageState(); // Changed State
}

class _DeliveryLoginPageState extends ConsumerState<DeliveryLoginPage> {
  // Changed State type
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
      // Use Firebase Auth directly for sign-in attempt
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (!mounted) return;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showErrorSnackBar('Authentication error.');
        setState(() => _isLoading = false);
        return;
      }

      // Use ref to read the UserService provider
      final userService = ref.read(userServiceProvider);
      final UserModel? userData =
          await userService.getUser(user.uid); // Use UserModel

      if (!mounted) return;

      // Check user role from the fetched userData
      if (userData != null && userData.role == 'delivery') {
        context.go('/deliveryHome');
      } else {
        _showErrorSnackBar('Unauthorized: Delivery personnel only.');
        await FirebaseAuth.instance.signOut(); // Sign out if role is incorrect
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final errorMessage = (e.code == 'user-not-found' ||
              e.code == 'invalid-credential' ||
              e.code == 'wrong-password')
          ? 'البريد الإلكتروني أو كلمة المرور غير صحيحة'
          : 'حدث خطأ أثناء تسجيل الدخول: ${e.message}';
      _showErrorSnackBar(errorMessage);
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('حدث خطأ: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("تسجيل دخول عامل التوصيل")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AppTextField(
                controller: _emailController,
                label: "البريد الإلكتروني", // Use label
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "الرجاء إدخال البريد الإلكتروني";
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return "الرجاء إدخال بريد إلكتروني صحيح";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: _passwordController,
                label: "كلمة المرور", // Use label
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "الرجاء إدخال كلمة المرور";
                  }
                  if (value.length < 6) {
                    return "يجب أن تكون كلمة المرور 6 أحرف على الأقل";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator()
                  : AppButton(
                      onPressed: _login,
                      text: "تسجيل الدخول",
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
