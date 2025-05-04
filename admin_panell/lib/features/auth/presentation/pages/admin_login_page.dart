import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_libs/shared_libs.dart'; // Import your AuthNotifier

class AdminLoginPage extends ConsumerWidget {
  const AdminLoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // عرض اسم المستخدم إذا كان مسجل الدخول
            Text(
              authState.user != null
                  ? 'Welcome, ${authState.user!.name}!'
                  : 'Please log in.',
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: authState.user == null
                  ? () async {
                      await authNotifier.signIn(email: 'admin@example.com', password: 'password');
                      if (!context.mounted) return;
                    }
                  : () async {
                      await authNotifier.signOut();
                      if (!context.mounted) return;
                    },
              child: Text(authState.user == null ? 'Sign In' : 'Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
