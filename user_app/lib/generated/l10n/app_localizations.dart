import 'package:flutter/material.dart';
import 'package:user_app/l10n/app_localizations.dart';

/// توفير الترجمات للتطبيق
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  /// الحصول على مثيل AppLocalizations للسياق الحالي
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ?? AppLocalizations(const Locale('ar'));
  }

  /// مندوب لتحميل الترجمات
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// الترجمات المتاحة
  static const List<Locale> supportedLocales = [
    Locale('ar'), // العربية
    Locale('en'), // الإنجليزية
  ];

  /// ترجمة النصوص
  String translate(String key) {
    final translations = _getTranslations();
    return translations[key] ?? key;
  }

  /// الحصول على الترجمات حسب اللغة
  Map<String, String> _getTranslations() {
    switch (locale.languageCode) {
      case 'ar':
        return _arabicTranslations;
      case 'en':
        return _englishTranslations;
      default:
        return _arabicTranslations;
    }
  }

  /// الترجمات العربية
  static const Map<String, String> _arabicTranslations = {
    'app_name': 'ريفو',
    'home': 'الرئيسية',
    'categories': 'الفئات',
    'cart': 'سلة التسوق',
    'profile': 'الملف الشخصي',
    'settings': 'الإعدادات',
    'login': 'تسجيل الدخول',
    'register': 'إنشاء حساب',
    'logout': 'تسجيل الخروج',
    'email': 'البريد الإلكتروني',
    'password': 'كلمة المرور',
    'forgot_password': 'نسيت كلمة المرور؟',
    'search': 'بحث',
    'add_to_cart': 'إضافة إلى السلة',
    'buy_now': 'شراء الآن',
    'product_details': 'تفاصيل المنتج',
    'description': 'الوصف',
    'reviews': 'التقييمات',
    'related_products': 'منتجات ذات صلة',
    'checkout': 'إتمام الشراء',
    'payment': 'الدفع',
    'shipping': 'الشحن',
    'order_summary': 'ملخص الطلب',
    'total': 'المجموع',
    'confirm_order': 'تأكيد الطلب',
    'order_confirmed': 'تم تأكيد الطلب',
    'order_failed': 'فشل الطلب',
    'try_again': 'حاول مرة أخرى',
    'notifications': 'الإشعارات',
    'favorites': 'المفضلة',
    'orders': 'الطلبات',
    'support': 'الدعم',
    'language': 'اللغة',
    'theme': 'المظهر',
    'dark_mode': 'الوضع الداكن',
    'light_mode': 'الوضع الفاتح',
    'system_default': 'إعدادات النظام',
    'about': 'عن التطبيق',
    'version': 'الإصدار',
    'terms': 'الشروط والأحكام',
    'privacy': 'سياسة الخصوصية',
    'contact_us': 'اتصل بنا',
    'rate_app': 'قيم التطبيق',
    'share_app': 'شارك التطبيق',
    'no_items': 'لا توجد عناصر',
    'empty_cart': 'سلة التسوق فارغة',
    'empty_favorites': 'لا توجد منتجات في المفضلة',
    'empty_orders': 'لا توجد طلبات',
    'empty_notifications': 'لا توجد إشعارات',
    'add_review': 'إضافة تقييم',
    'edit_review': 'تعديل التقييم',
    'delete_review': 'حذف التقييم',
    'submit': 'إرسال',
    'cancel': 'إلغاء',
    'save': 'حفظ',
    'delete': 'حذف',
    'edit': 'تعديل',
    'yes': 'نعم',
    'no': 'لا',
    'ok': 'موافق',
    'error': 'خطأ',
    'success': 'نجاح',
    'warning': 'تحذير',
    'info': 'معلومات',
    'loading': 'جاري التحميل...',
    'please_wait': 'الرجاء الانتظار...',
    'retry': 'إعادة المحاولة',
    'continue': 'متابعة',
    'back': 'رجوع',
    'next': 'التالي',
    'previous': 'السابق',
    'finish': 'إنهاء',
    'done': 'تم',
  };

  /// الترجمات الإنجليزية
  static const Map<String, String> _englishTranslations = {
    'app_name': 'Rivoo',
    'home': 'Home',
    'categories': 'Categories',
    'cart': 'Cart',
    'profile': 'Profile',
    'settings': 'Settings',
    'login': 'Login',
    'register': 'Register',
    'logout': 'Logout',
    'email': 'Email',
    'password': 'Password',
    'forgot_password': 'Forgot Password?',
    'search': 'Search',
    'add_to_cart': 'Add to Cart',
    'buy_now': 'Buy Now',
    'product_details': 'Product Details',
    'description': 'Description',
    'reviews': 'Reviews',
    'related_products': 'Related Products',
    'checkout': 'Checkout',
    'payment': 'Payment',
    'shipping': 'Shipping',
    'order_summary': 'Order Summary',
    'total': 'Total',
    'confirm_order': 'Confirm Order',
    'order_confirmed': 'Order Confirmed',
    'order_failed': 'Order Failed',
    'try_again': 'Try Again',
    'notifications': 'Notifications',
    'favorites': 'Favorites',
    'orders': 'Orders',
    'support': 'Support',
    'language': 'Language',
    'theme': 'Theme',
    'dark_mode': 'Dark Mode',
    'light_mode': 'Light Mode',
    'system_default': 'System Default',
    'about': 'About',
    'version': 'Version',
    'terms': 'Terms & Conditions',
    'privacy': 'Privacy Policy',
    'contact_us': 'Contact Us',
    'rate_app': 'Rate App',
    'share_app': 'Share App',
    'no_items': 'No Items',
    'empty_cart': 'Your cart is empty',
    'empty_favorites': 'No favorite products',
    'empty_orders': 'No orders',
    'empty_notifications': 'No notifications',
    'add_review': 'Add Review',
    'edit_review': 'Edit Review',
    'delete_review': 'Delete Review',
    'submit': 'Submit',
    'cancel': 'Cancel',
    'save': 'Save',
    'delete': 'Delete',
    'edit': 'Edit',
    'yes': 'Yes',
    'no': 'No',
    'ok': 'OK',
    'error': 'Error',
    'success': 'Success',
    'warning': 'Warning',
    'info': 'Info',
    'loading': 'Loading...',
    'please_wait': 'Please wait...',
    'retry': 'Retry',
    'continue': 'Continue',
    'back': 'Back',
    'next': 'Next',
    'previous': 'Previous',
    'finish': 'Finish',
    'done': 'Done',
  };
}

/// مندوب الترجمات
class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ar', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
