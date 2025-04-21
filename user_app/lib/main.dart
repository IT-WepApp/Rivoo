import 'package:flutter/material.dart';
import 'package:user_app/package/flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'core/theme/app_theme.dart';
import 'core/state/auth_state_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تهيئة الخدمات
  await initializeServices();
  
  runApp(const MyApp());
}

/// تهيئة الخدمات الأساسية للتطبيق
Future<void> initializeServices() async {
  // تهيئة خدمات التطبيق
  // مثل خدمات المصادقة والتحليلات وغيرها
}

/// التطبيق الرئيسي
class MyApp extends StatelessWidget {
  /// إنشاء التطبيق الرئيسي
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rivoo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const AuthStateProvider(
        authenticated: HomeScreen(),
        unauthenticated: LoginScreen(),
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
