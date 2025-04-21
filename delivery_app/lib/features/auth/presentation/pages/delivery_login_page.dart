import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Import your AuthNotifier provider
import 'package:delivery_app/features/auth/application/auth_notifier.dart';

class DeliveryLoginPage extends ConsumerWidget {
  const DeliveryLoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the correct provider name: authNotifierProvider
    final authState = ref.watch(authNotifierProvider);
    final authNotifier = ref.read(authNotifierProvider.notifier);
    // Optional: Track loading state if needed
    // final isLoading = ref.watch(authNotifierProvider.select((state) => state is AsyncLoading));

    return Scaffold(
      appBar: AppBar(title: const Text('Delivery Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TODO: Add TextField widgets for email and password

            // Example: Display user name if logged in
            if (authState != null)
              Text(
                  'Welcome, ${authState.name}!') // Assuming DeliveryPersonModel has 'name'
            else
              const Text('Please log in.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Simplified onPressed logic
                if (authState == null) {
                  // TODO: Get email and password from TextFields
                  final success = await authNotifier.signIn(
                      'delivery@example.com',
                      'password123'); // Use strong password
                  if (!success && context.mounted) {
                    // Check if mounted before showing SnackBar
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Login Failed'),
                          backgroundColor: Colors.red),
                    );
                  }
                  // TODO: Navigate on success (e.g., context.go('/deliveryHome'))
                } else {
                  await authNotifier.signOut();
                }
              },
              // TODO: Add loading indicator to the button
              child: Text(authState == null ? 'Sign In' : 'Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
