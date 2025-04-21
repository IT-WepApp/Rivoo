import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

/// توفر هذه الفئة ترجمات محلية للتطبيق
class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale);

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  // ترجمات شائعة الاستخدام
  String get appName => 'Rivoo';
  String get home => 'الرئيسية';
  String get categories => 'الفئات';
  String get products => 'المنتجات';
  String get cart => 'سلة التسوق';
  String get profile => 'الملف الشخصي';
  String get settings => 'الإعدادات';
  String get login => 'تسجيل الدخول';
  String get register => 'إنشاء حساب';
  String get logout => 'تسجيل الخروج';
  String get email => 'البريد الإلكتروني';
  String get password => 'كلمة المرور';
  String get forgotPassword => 'نسيت كلمة المرور؟';
  String get search => 'بحث';
  String get filter => 'تصفية';
  String get sort => 'ترتيب';
  String get add => 'إضافة';
  String get remove => 'إزالة';
  String get delete => 'حذف';
  String get edit => 'تعديل';
  String get save => 'حفظ';
  String get cancel => 'إلغاء';
  String get confirm => 'تأكيد';
  String get submit => 'إرسال';
  String get next => 'التالي';
  String get previous => 'السابق';
  String get done => 'تم';
  String get error => 'خطأ';
  String get success => 'نجاح';
  String get warning => 'تحذير';
  String get info => 'معلومات';
  String get loading => 'جاري التحميل...';
  String get noData => 'لا توجد بيانات';
  String get noResults => 'لا توجد نتائج';
  String get noInternet => 'لا يوجد اتصال بالإنترنت';
  String get retry => 'إعادة المحاولة';
  String get tryAgain => 'حاول مرة أخرى';
  String get somethingWentWrong => 'حدث خطأ ما';
  String get pleaseWait => 'يرجى الانتظار';
  String get checkout => 'إتمام الشراء';
  String get payment => 'الدفع';
  String get paymentMethods => 'طرق الدفع';
  String get shippingAddress => 'عنوان الشحن';
  String get billingAddress => 'عنوان الفوترة';
  String get orderSummary => 'ملخص الطلب';
  String get orderDetails => 'تفاصيل الطلب';
  String get orderHistory => 'سجل الطلبات';
  String get orderStatus => 'حالة الطلب';
  String get orderDate => 'تاريخ الطلب';
  String get orderNumber => 'رقم الطلب';
  String get orderTotal => 'إجمالي الطلب';
  String get subtotal => 'المجموع الفرعي';
  String get tax => 'الضريبة';
  String get shipping => 'الشحن';
  String get total => 'الإجمالي';
  String get discount => 'الخصم';
  String get promoCode => 'رمز الخصم';
  String get applyPromoCode => 'تطبيق رمز الخصم';
  String get invalidPromoCode => 'رمز الخصم غير صالح';
  String get quantity => 'الكمية';
  String get price => 'السعر';
  String get ratings => 'التقييمات';
  String get reviews => 'المراجعات';
  String get addReview => 'إضافة مراجعة';
  String get editReview => 'تعديل المراجعة';
  String get deleteReview => 'حذف المراجعة';
  String get writeReview => 'اكتب مراجعتك';
  String get rating => 'التقييم';
  String get comment => 'التعليق';
  String get comments => 'التعليقات';
  String get description => 'الوصف';
  String get specifications => 'المواصفات';
  String get relatedProducts => 'منتجات ذات صلة';
  String get favorites => 'المفضلة';
  String get addToFavorites => 'إضافة إلى المفضلة';
  String get removeFromFavorites => 'إزالة من المفضلة';
  String get addToCart => 'إضافة إلى السلة';
  String get removeFromCart => 'إزالة من السلة';
  String get clearCart => 'تفريغ السلة';
  String get continueShopping => 'مواصلة التسوق';
  String get emptyCart => 'السلة فارغة';
  String get emptyFavorites => 'المفضلة فارغة';
  String get emptyOrders => 'لا توجد طلبات';
  String get emptyNotifications => 'لا توجد إشعارات';
  String get notifications => 'الإشعارات';
  String get markAllAsRead => 'تعيين الكل كمقروء';
  String get clearAll => 'مسح الكل';
  String get theme => 'المظهر';
  String get darkMode => 'الوضع الداكن';
  String get lightMode => 'الوضع الفاتح';
  String get systemMode => 'وضع النظام';
  String get language => 'اللغة';
  String get arabic => 'العربية';
  String get english => 'الإنجليزية';
  String get support => 'الدعم';
  String get contactUs => 'اتصل بنا';
  String get aboutUs => 'من نحن';
  String get termsAndConditions => 'الشروط والأحكام';
  String get privacyPolicy => 'سياسة الخصوصية';
  String get faq => 'الأسئلة الشائعة';
  String get help => 'المساعدة';
  String get version => 'الإصدار';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale.toString()));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
