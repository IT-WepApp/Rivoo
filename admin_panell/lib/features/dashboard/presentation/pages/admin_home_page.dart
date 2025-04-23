import 'package:flutter/material.dart';
import '../../../../../../shared_libs/lib/widgets/widgets.dart';
import 'package:go_router/go_router.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة الإدارة'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'مرحباً بك في لوحة الإدارة',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 30),
              // إدارة المستخدمين
              SizedBox(
                width: 200,
                child: AppButton(
                  text: 'إدارة المستخدمين',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Navigation to User Management (TODO)')),
                    );
                  },
                ),
              ),
              const SizedBox(height: 15),
              // إدارة الفئات
              SizedBox(
                width: 200,
                child: AppButton(
                  text: 'إدارة الفئات',
                  onPressed: () {
                    context.go('/categoryManagement');
                  },
                ),
              ),
              const SizedBox(height: 15),
              // إدارة المنتجات
              SizedBox(
                width: 200,
                child: AppButton(
                  text: 'إدارة المنتجات',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Navigation to Product Management (TODO)')),
                    );
                  },
                ),
              ),
              const SizedBox(height: 15),
              // التقارير
              SizedBox(
                width: 200,
                child: AppButton(
                  text: 'عرض التقارير والإحصائيات',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Navigation to Statistics (TODO)')),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
