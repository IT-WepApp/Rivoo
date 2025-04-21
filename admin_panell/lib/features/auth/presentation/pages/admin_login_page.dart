import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/auth_notifier.dart'; // Import your AuthNotifier

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
            // Example: Display user name if logged in
            if (authState != null)
              Text('Welcome, ${authState.name}!')
            else
              const Text('Please log in.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: authState == null
                  ? () async {
                      // Example: Call signIn with dummy credentials
                      await authNotifier.signIn(
                          'admin@example.com', 'password');
                      // إضافة فحص mounted قبل استخدام context بعد await
                      if (!context.mounted) return;
                      // يمكن استخدام context هنا بأمان
                    }
                  : () async {
                      await authNotifier.signOut();
                      // إضافة فحص mounted قبل استخدام context بعد await
                      if (!context.mounted) return;
                      // يمكن استخدام context هنا بأمان
                    },
              child: Text(authState == null ? 'Sign In' : 'Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
