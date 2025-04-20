import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delivery_app/presentation/providers/theme_provider.dart';

void main() {
  group('ThemeModeNotifier Tests', () {
    late ProviderContainer container;

    setUp(() async {
      // تهيئة SharedPreferences للاختبار
      SharedPreferences.setMockInitialValues({});
      
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('يجب أن يكون وضع السمة الافتراضي هو إعدادات النظام', () {
      final themeMode = container.read(themeModeProvider);
      expect(themeMode, ThemeMode.system);
    });

    test('يجب أن يتم تغيير وضع السمة عند استدعاء changeThemeMode', () async {
      // تهيئة SharedPreferences للاختبار
      SharedPreferences.setMockInitialValues({});
      
      final notifier = container.read(themeModeProvider.notifier);
      
      // تغيير وضع السمة إلى الوضع الداكن
      await notifier.changeThemeMode(ThemeMode.dark);
      
      // التحقق من تغيير وضع السمة
      final themeMode = container.read(themeModeProvider);
      expect(themeMode, ThemeMode.dark);
    });

    test('يجب أن يتم تبديل وضع السمة عند استدعاء toggleThemeMode', () async {
      // تهيئة SharedPreferences للاختبار
      SharedPreferences.setMockInitialValues({});
      
      final notifier = container.read(themeModeProvider.notifier);
      
      // الوضع الافتراضي هو إعدادات النظام
      expect(container.read(themeModeProvider), ThemeMode.system);
      
      // التبديل من إعدادات النظام إلى الوضع الفاتح
      await notifier.toggleThemeMode();
      expect(container.read(themeModeProvider), ThemeMode.light);
      
      // التبديل من الوضع الفاتح إلى الوضع الداكن
      await notifier.toggleThemeMode();
      expect(container.read(themeModeProvider), ThemeMode.dark);
      
      // التبديل من الوضع الداكن إلى إعدادات النظام
      await notifier.toggleThemeMode();
      expect(container.read(themeModeProvider), ThemeMode.system);
    });

    test('يجب أن تعيد getCurrentThemeModeName اسم وضع السمة الصحيح', () async {
      // تهيئة SharedPreferences للاختبار
      SharedPreferences.setMockInitialValues({});
      
      final notifier = container.read(themeModeProvider.notifier);
      
      // التحقق من اسم وضع السمة الافتراضي (إعدادات النظام)
      expect(notifier.getCurrentThemeModeName(), 'systemDefault');
      
      // تغيير وضع السمة إلى الوضع الفاتح
      await notifier.changeThemeMode(ThemeMode.light);
      
      // التحقق من اسم وضع السمة بعد التغيير
      expect(notifier.getCurrentThemeModeName(), 'lightMode');
      
      // تغيير وضع السمة إلى الوضع الداكن
      await notifier.changeThemeMode(ThemeMode.dark);
      
      // التحقق من اسم وضع السمة بعد التغيير
      expect(notifier.getCurrentThemeModeName(), 'darkMode');
    });

    test('يجب أن تعيد getCurrentThemeModeIcon أيقونة وضع السمة الصحيحة', () async {
      // تهيئة SharedPreferences للاختبار
      SharedPreferences.setMockInitialValues({});
      
      final notifier = container.read(themeModeProvider.notifier);
      
      // التحقق من أيقونة وضع السمة الافتراضي (إعدادات النظام)
      expect(notifier.getCurrentThemeModeIcon(), Icons.settings_suggest);
      
      // تغيير وضع السمة إلى الوضع الفاتح
      await notifier.changeThemeMode(ThemeMode.light);
      
      // التحقق من أيقونة وضع السمة بعد التغيير
      expect(notifier.getCurrentThemeModeIcon(), Icons.wb_sunny);
      
      // تغيير وضع السمة إلى الوضع الداكن
      await notifier.changeThemeMode(ThemeMode.dark);
      
      // التحقق من أيقونة وضع السمة بعد التغيير
      expect(notifier.getCurrentThemeModeIcon(), Icons.nightlight_round);
    });
  });
}
