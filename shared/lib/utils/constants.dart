import 'package:flutter/material.dart';

/// ثوابت التطبيق المشتركة
class Constants {
  // ثوابت التخزين المحلي
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userRoleKey = 'user_role';
  static const String languageCodeKey = 'language_code';
  static const String themeKey = 'app_theme';
  
  // ثوابت Firebase
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String ordersCollection = 'orders';
  static const String storesCollection = 'stores';
  static const String categoriesCollection = 'categories';
  static const String promotionsCollection = 'promotions';
  
  // ثوابت التطبيق
  static const int splashDuration = 2; // بالثواني
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 8.0;
  static const double defaultElevation = 2.0;
  
  // أدوار المستخدمين
  static const String roleUser = 'user';
  static const String roleSeller = 'seller';
  static const String roleDelivery = 'delivery';
  static const String roleAdmin = 'admin';
  
  // حالات الطلبات
  static const String orderStatusPending = 'pending';
  static const String orderStatusAccepted = 'accepted';
  static const String orderStatusPreparing = 'preparing';
  static const String orderStatusReady = 'ready';
  static const String orderStatusDelivering = 'delivering';
  static const String orderStatusDelivered = 'delivered';
  static const String orderStatusCancelled = 'cancelled';
}
