// مصدر البيانات البعيد (Remote Data Source) في طبقة Data
// lib/features/auth/data/datasources/auth_remote_datasource.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// واجهة مصدر البيانات البعيد للمصادقة
abstract class AuthRemoteDataSource {
  Future<UserModel> signIn(String email, String password);
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
}

/// تنفيذ مصدر البيانات البعيد باستخدام Firebase
class FirebaseAuthDataSource implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthDataSource({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserModel> signIn(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user == null) {
        throw Exception('فشل تسجيل الدخول');
      }
      
      // الحصول على بيانات المستخدم من Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();
      
      if (!userDoc.exists) {
        // إذا لم يكن هناك وثيقة للمستخدم، نقوم بإنشاء واحدة
        final userData = {
          'id': userCredential.user!.uid,
          'name': userCredential.user!.displayName ?? 'Admin User',
          'email': userCredential.user!.email,
          'role': 'admin',
          'createdAt': FieldValue.serverTimestamp(),
        };
        
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userData);
            
        return UserModel(
          id: userCredential.user!.uid,
          name: userCredential.user!.displayName ?? 'Admin User',
          email: userCredential.user!.email,
          role: 'admin',
        );
      }
      
      final userData = userDoc.data() as Map<String, dynamic>;
      
      return UserModel(
        id: userCredential.user!.uid,
        name: userData['name'] as String? ?? 'Admin User',
        email: userCredential.user!.email,
        role: userData['role'] as String? ?? 'admin',
      );
    } catch (e) {
      throw Exception('فشل تسجيل الدخول: $e');
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    
    if (user == null) {
      return null;
    }
    
    try {
      // الحصول على بيانات المستخدم من Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (!userDoc.exists) {
        return null;
      }
      
      final userData = userDoc.data() as Map<String, dynamic>;
      
      return UserModel(
        id: user.uid,
        name: userData['name'] as String? ?? 'Admin User',
        email: user.email,
        role: userData['role'] as String? ?? 'admin',
      );
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }
}
