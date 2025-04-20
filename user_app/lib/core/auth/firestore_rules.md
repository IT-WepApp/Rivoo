# قواعد Firestore للأمان

هذا الملف يحتوي على قواعد الأمان لـ Firestore التي يجب تطبيقها في مشروع Firebase.

## كيفية التطبيق

1. انتقل إلى [Firebase Console](https://console.firebase.google.com/)
2. اختر مشروعك
3. انتقل إلى Firestore Database
4. انقر على تبويب "Rules"
5. انسخ القواعد أدناه والصقها في محرر القواعد
6. انقر على "Publish"

## قواعد الأمان

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // وظائف مساعدة للتحقق
    function isSignedIn() {
      return request.auth != null;
    }
    
    function isAdmin() {
      return isSignedIn() && 
        exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    function isCustomer() {
      return isSignedIn() && 
        exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'customer';
    }
    
    function isDriver() {
      return isSignedIn() && 
        exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'driver';
    }
    
    function isOwner(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }
    
    // قواعد المستخدمين
    match /users/{userId} {
      // يمكن للمستخدمين قراءة بياناتهم الخاصة فقط
      // يمكن للمسؤولين قراءة بيانات جميع المستخدمين
      allow read: if isOwner(userId) || isAdmin();
      
      // يمكن للمستخدمين تحديث بياناتهم الخاصة فقط (باستثناء حقل الدور)
      // يمكن للمسؤولين تحديث بيانات جميع المستخدمين
      allow update: if (isOwner(userId) && !request.resource.data.diff(resource.data).affectedKeys().hasAny(['role'])) || isAdmin();
      
      // يمكن للمسؤولين فقط إنشاء وحذف المستخدمين
      allow create, delete: if isAdmin();
    }
    
    // قواعد المنتجات
    match /products/{productId} {
      // يمكن لجميع المستخدمين المسجلين قراءة المنتجات
      allow read: if isSignedIn();
      
      // يمكن للمسؤولين فقط إنشاء وتحديث وحذف المنتجات
      allow create, update, delete: if isAdmin();
    }
    
    // قواعد الطلبات
    match /orders/{orderId} {
      // يمكن للعملاء قراءة طلباتهم الخاصة فقط
      // يمكن للسائقين قراءة الطلبات المخصصة لهم فقط
      // يمكن للمسؤولين قراءة جميع الطلبات
      allow read: if isAdmin() || 
        (isCustomer() && resource.data.customerId == request.auth.uid) ||
        (isDriver() && resource.data.driverId == request.auth.uid);
      
      // يمكن للعملاء إنشاء طلبات جديدة فقط
      allow create: if isCustomer() && request.resource.data.customerId == request.auth.uid;
      
      // يمكن للعملاء تحديث طلباتهم الخاصة (باستثناء حقول معينة)
      // يمكن للسائقين تحديث حالة الطلبات المخصصة لهم فقط
      // يمكن للمسؤولين تحديث جميع الطلبات
      allow update: if isAdmin() ||
        (isCustomer() && resource.data.customerId == request.auth.uid && 
          !request.resource.data.diff(resource.data).affectedKeys().hasAny(['status', 'driverId', 'adminNotes'])) ||
        (isDriver() && resource.data.driverId == request.auth.uid && 
          request.resource.data.diff(resource.data).affectedKeys().hasOnly(['status', 'driverNotes', 'location']));
      
      // يمكن للمسؤولين فقط حذف الطلبات
      allow delete: if isAdmin();
    }
    
    // قواعد التقييمات
    match /ratings/{ratingId} {
      // يمكن لجميع المستخدمين المسجلين قراءة التقييمات
      allow read: if isSignedIn();
      
      // يمكن للعملاء فقط إنشاء تقييمات جديدة
      allow create: if isCustomer() && request.resource.data.userId == request.auth.uid;
      
      // يمكن للعملاء تحديث تقييماتهم الخاصة فقط
      allow update: if isCustomer() && resource.data.userId == request.auth.uid;
      
      // يمكن للعملاء حذف تقييماتهم الخاصة فقط
      // يمكن للمسؤولين حذف أي تقييم
      allow delete: if isAdmin() || (isCustomer() && resource.data.userId == request.auth.uid);
    }
    
    // قواعد تذاكر الدعم
    match /supportTickets/{ticketId} {
      // يمكن للمستخدمين قراءة تذاكر الدعم الخاصة بهم فقط
      // يمكن للمسؤولين قراءة جميع تذاكر الدعم
      allow read: if isAdmin() || (isSignedIn() && resource.data.userId == request.auth.uid);
      
      // يمكن للمستخدمين المسجلين إنشاء تذاكر دعم جديدة
      allow create: if isSignedIn() && request.resource.data.userId == request.auth.uid;
      
      // يمكن للمستخدمين تحديث تذاكر الدعم الخاصة بهم فقط (باستثناء حقول معينة)
      // يمكن للمسؤولين تحديث جميع تذاكر الدعم
      allow update: if isAdmin() ||
        (isSignedIn() && resource.data.userId == request.auth.uid && 
          !request.resource.data.diff(resource.data).affectedKeys().hasAny(['status', 'adminNotes']));
      
      // يمكن للمسؤولين فقط حذف تذاكر الدعم
      allow delete: if isAdmin();
      
      // قواعد رسائل تذاكر الدعم
      match /messages/{messageId} {
        // يمكن للمستخدمين قراءة رسائل تذاكر الدعم الخاصة بهم فقط
        // يمكن للمسؤولين قراءة جميع رسائل تذاكر الدعم
        allow read: if isAdmin() || (isSignedIn() && get(/databases/$(database)/documents/supportTickets/$(ticketId)).data.userId == request.auth.uid);
        
        // يمكن للمستخدمين إنشاء رسائل جديدة في تذاكر الدعم الخاصة بهم فقط
        // يمكن للمسؤولين إنشاء رسائل في جميع تذاكر الدعم
        allow create: if isAdmin() ||
          (isSignedIn() && get(/databases/$(database)/documents/supportTickets/$(ticketId)).data.userId == request.auth.uid);
        
        // يمكن للمستخدمين تحديث رسائلهم الخاصة فقط
        // يمكن للمسؤولين تحديث جميع الرسائل
        allow update: if isAdmin() || (isSignedIn() && resource.data.userId == request.auth.uid);
        
        // يمكن للمسؤولين فقط حذف الرسائل
        allow delete: if isAdmin();
      }
    }
    
    // قواعد المعاملات المالية
    match /transactions/{transactionId} {
      // يمكن للمستخدمين قراءة معاملاتهم المالية الخاصة فقط
      // يمكن للمسؤولين قراءة جميع المعاملات المالية
      allow read: if isAdmin() || (isSignedIn() && resource.data.userId == request.auth.uid);
      
      // يمكن للمستخدمين إنشاء معاملات مالية جديدة
      allow create: if isSignedIn() && request.resource.data.userId == request.auth.uid;
      
      // لا يمكن لأي مستخدم تحديث المعاملات المالية بعد إنشائها
      allow update: if false;
      
      // يمكن للمسؤولين فقط حذف المعاملات المالية
      allow delete: if isAdmin();
    }
    
    // قواعد الإشعارات
    match /notifications/{notificationId} {
      // يمكن للمستخدمين قراءة إشعاراتهم الخاصة فقط
      allow read: if isSignedIn() && resource.data.userId == request.auth.uid;
      
      // يمكن للمسؤولين فقط إنشاء وتحديث وحذف الإشعارات
      allow create, update, delete: if isAdmin();
    }
    
    // منع الوصول إلى جميع المستندات الأخرى
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

## ملاحظات هامة

1. هذه القواعد تفرض التحقق العميق من صلاحيات المستخدمين بناءً على أدوارهم.
2. تم تحديد وظائف مساعدة للتحقق من حالة تسجيل الدخول ودور المستخدم.
3. تم تقييد الوصول إلى البيانات بحيث يمكن للمستخدمين الوصول إلى بياناتهم الخاصة فقط.
4. تم منح المسؤولين صلاحيات واسعة للوصول إلى جميع البيانات وإدارتها.
5. تم تطبيق قواعد خاصة لكل نوع من البيانات (المستخدمين، المنتجات، الطلبات، التقييمات، تذاكر الدعم، المعاملات المالية، الإشعارات).

## تحديث القواعد

يجب تحديث هذه القواعد بانتظام لضمان أمان التطبيق وحماية بيانات المستخدمين. قم بمراجعة القواعد وتحديثها عند إضافة ميزات جديدة أو تغيير هيكل البيانات.
