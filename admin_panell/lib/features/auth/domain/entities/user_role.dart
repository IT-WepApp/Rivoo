/// أدوار المستخدمين في النظام
///
/// يستخدم هذا التعداد لتحديد دور المستخدم وصلاحياته في النظام
enum UserRole {
  /// مدير النظام - لديه كامل الصلاحيات
  admin,

  /// مشرف - لديه صلاحيات إدارية محدودة
  supervisor,

  /// مدير محتوى - يمكنه إدارة المحتوى فقط
  contentManager,

  /// مدير مبيعات - يمكنه إدارة المبيعات والطلبات
  salesManager,

  /// مدير مخزون - يمكنه إدارة المنتجات والمخزون
  inventoryManager,

  /// مدير دعم - يمكنه إدارة طلبات الدعم الفني
  supportManager,

  /// مستخدم عادي - لديه صلاحيات محدودة جداً
  user;

  /// الحصول على اسم الدور بصيغة مناسبة للعرض
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'مدير النظام';
      case UserRole.supervisor:
        return 'مشرف';
      case UserRole.contentManager:
        return 'مدير محتوى';
      case UserRole.salesManager:
        return 'مدير مبيعات';
      case UserRole.inventoryManager:
        return 'مدير مخزون';
      case UserRole.supportManager:
        return 'مدير دعم';
      case UserRole.user:
        return 'مستخدم عادي';
    }
  }

  /// تحويل النص إلى دور مستخدم
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.name.toLowerCase() == value.toLowerCase(),
      orElse: () => UserRole.user,
    );
  }

  /// التحقق مما إذا كان الدور يملك صلاحيات إدارية
  bool get isAdmin => this == UserRole.admin;

  /// التحقق مما إذا كان الدور يملك صلاحيات إشرافية
  bool get isSupervisor => this == UserRole.admin || this == UserRole.supervisor;

  /// التحقق مما إذا كان الدور يملك صلاحيات إدارة المحتوى
  bool get canManageContent =>
      this == UserRole.admin ||
      this == UserRole.supervisor ||
      this == UserRole.contentManager;

  /// التحقق مما إذا كان الدور يملك صلاحيات إدارة المبيعات
  bool get canManageSales =>
      this == UserRole.admin ||
      this == UserRole.supervisor ||
      this == UserRole.salesManager;

  /// التحقق مما إذا كان الدور يملك صلاحيات إدارة المخزون
  bool get canManageInventory =>
      this == UserRole.admin ||
      this == UserRole.supervisor ||
      this == UserRole.inventoryManager;

  /// التحقق مما إذا كان الدور يملك صلاحيات إدارة الدعم
  bool get canManageSupport =>
      this == UserRole.admin ||
      this == UserRole.supervisor ||
      this == UserRole.supportManager;
}
