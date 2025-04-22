import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_libs/lib/widgets/shared_widgets.dart';
import 'package:shared_libs/lib/services/shared_services.dart'; // ✅ لحل UserService
import 'package:go_router/go_router.dart'; // ✅ لحل context.go

class SellerLoginPage extends StatefulWidget {
  const SellerLoginPage({Key? key}) : super(key: key);

  @override
  State<SellerLoginPage> createState() => _SellerLoginPageState();
}

class _SellerLoginPageState extends State<SellerLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
        _showErrorSnackBar('Authentication error.');
        setState(() => _isLoading = false);
        return;
      }

      final userData = await UserService().getUser(user.uid);
      if (!mounted) return;

      if (userData != null && userData.role == 'seller') {
        context.go('/sellerHome'); // ✅ بعد إضافة import
      } else {
        _showErrorSnackBar('Unauthorized: Sellers only.');
        await FirebaseAuth.instance.signOut();
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final errorMessage =
          (e.code == 'user-not-found' || e.code == 'invalid-credential')
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
      appBar: AppBar(title: const Text("تسجيل الدخول كبائع")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AppTextField(
                controller: _emailController,
                label:
                    "البريد الإلكتروني", // ✅ تم تعديلها من labelText إلى label
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
                label: "كلمة المرور", // ✅ تم تعديلها من labelText إلى label
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
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: AppButton(
                        onPressed: _login,
                        text: "تسجيل الدخول",
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
