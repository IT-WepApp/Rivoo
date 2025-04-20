// shared_modules/shared_widgets/lib/home_choice_page.dart

import 'package:flutter/material.dart';

class HomeChoicePage extends StatelessWidget {
  const HomeChoicePage({super.key});

  /// دالة لإظهار نافذة اختيار لتسجيل دخول البائع أو الديليفري.
  void _showSellerOrDeliveryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("اختر نوع الدخول"),
        content: const Text("من فضلك اختر بين تسجيل دخول البائع أو التوصيل"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/sellerLogin');
            },
            child: const Text("البائع"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/deliveryLogin');
            },
            child: const Text("الديليفري"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("اختر نوع الدخول"),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // المحتوى الرئيسي
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // زر تسجيل دخول المستخدم
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/userLogin');
                    },
                    child: const Text("تسجيل دخول المستخدم"),
                  ),
                  const SizedBox(height: 20),
                  // زر يفتح نافذة اختيار لتسجيل دخول البائع أو الديليفري
                  ElevatedButton(
                    onPressed: () {
                      _showSellerOrDeliveryDialog(context);
                    },
                    child: const Text("تسجيل دخول البائع / الديليفري"),
                  ),
                ],
              ),
            ),
            // خيار مخفي لتسجيل دخول الأدمن
            Positioned(
              bottom: 10,
              right: 10,
              child: GestureDetector(
                onLongPress: () {
                  Navigator.pushNamed(context, '/adminLogin');
                },
                child: const Opacity(
                  opacity: 0.2,
                  child: Text(
                    "Dev Options",
                    style: TextStyle(fontSize: 10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
