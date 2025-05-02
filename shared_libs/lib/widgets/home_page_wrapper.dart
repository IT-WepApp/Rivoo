import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
// Corrected import
// Corrected import
// Corrected import
// Corrected import

// This widget wraps the main pages and provides the bottom navigation bar
class HomePageWrapper extends StatelessWidget {
  final Widget child; // The child widget determined by GoRouter

  const HomePageWrapper({required this.child, super.key});

  // Helper function to determine the current index based on the route
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/cart')) {
      return 1;
    }
    if (location.startsWith('/orders')) {
      return 2;
    }
    if (location.startsWith('/profile')) {
      return 3;
    }
    // Default to home
    return 0;
  }

  // Function to navigate when a bottom bar item is tapped
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0: // Home
        context.go('/');
        break;
      case 1: // Cart
        context.go('/cart');
        break;
      case 2: // Orders
        context.go('/orders');
        break;
      case 3: // Profile
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentIndex = _calculateSelectedIndex(context);

    return Scaffold(
      // AppBar might be managed by individual pages now or kept here if consistent
      appBar: AppBar(
        // Example: Title could change based on the current page
        title: Text(_getTitleForIndex(currentIndex)),
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        // Actions can also be conditional or consistent
        actions: [
          if (currentIndex != 1) // Show cart icon unless already on cart page
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              tooltip: 'View Cart',
              onPressed: () => context.go('/cart'),
            ),
        ],
      ),
      body: child, // Display the child widget provided by GoRouter
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: currentIndex,
        // Use theme colors for consistency
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: Colors.grey.shade600,
        showUnselectedLabels: false, // Optional: cleaner look
        type: BottomNavigationBarType.fixed, // Ensure all items are visible
        onTap: (index) => _onItemTapped(index, context),
      ),
    );
  }

  // Helper to get AppBar title based on index
  String _getTitleForIndex(int index) {
    switch (index) {
      case 1:
        return 'Shopping Cart';
      case 2:
        return 'My Orders';
      case 3:
        return 'My Profile';
      case 0:
      default:
        return 'Browse Products';
    }
  }
}
