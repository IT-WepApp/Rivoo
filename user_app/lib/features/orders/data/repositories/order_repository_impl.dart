import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/architecture/domain/failure.dart';
import '../domain/entities/order.dart';
import '../domain/repositories/order_repository.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final Uuid _uuid;

  OrderRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    Uuid? uuid,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _uuid = uuid ?? const Uuid();

  @override
  Future<Either<Failure, List<Order>>> getUserOrders() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return Left(const AuthFailure(message: 'المستخدم غير مسجل الدخول'));
      }

      final ordersSnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('orderDate', descending: true)
          .get();

      final orders = ordersSnapshot.docs.map((doc) {
        final data = doc.data();
        return OrderModel.fromJson(data);
      }).toList();

      return Right(orders);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Order>> getOrderDetails(String orderId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return Left(const AuthFailure(message: 'المستخدم غير مسجل الدخول'));
      }

      final orderDoc = await _firestore.collection('orders').doc(orderId).get();

      if (!orderDoc.exists) {
        return Left(NotFoundFailure(message: 'الطلب غير موجود'));
      }

      final orderData = orderDoc.data()!;
      if (orderData['userId'] != userId) {
        return Left(
            const AuthFailure(message: 'ليس لديك صلاحية للوصول إلى هذا الطلب'));
      }

      final order = OrderModel.fromJson(orderData);
      return Right(order);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Order>> createOrder({
    required List<OrderItem> items,
    required double totalAmount,
    required String shippingAddress,
    required String paymentMethod,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return Left(const AuthFailure(message: 'المستخدم غير مسجل الدخول'));
      }

      final orderId = _uuid.v4();
      final now = DateTime.now();
      final estimatedDelivery = now.add(const Duration(days: 7));

      final orderItems = items.map((item) {
        if (item is OrderItemModel) {
          return item;
        } else {
          return OrderItemModel(
            id: _uuid.v4(),
            productId: item.productId,
            productName: item.productName,
            price: item.price,
            quantity: item.quantity,
            imageUrl: item.imageUrl,
          );
        }
      }).toList();

      final order = OrderModel(
        id: orderId,
        userId: userId,
        items: orderItems,
        totalAmount: totalAmount,
        status: 'pending',
        orderDate: now,
        shippingAddress: shippingAddress,
        paymentMethod: paymentMethod,
        estimatedDeliveryDate: estimatedDelivery,
      );

      await _firestore.collection('orders').doc(orderId).set(order.toJson());

      return Right(order);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> cancelOrder(String orderId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return Left(const AuthFailure(message: 'المستخدم غير مسجل الدخول'));
      }

      final orderDoc = await _firestore.collection('orders').doc(orderId).get();

      if (!orderDoc.exists) {
        return Left(NotFoundFailure(message: 'الطلب غير موجود'));
      }

      final orderData = orderDoc.data()!;
      if (orderData['userId'] != userId) {
        return Left(
            const AuthFailure(message: 'ليس لديك صلاحية لإلغاء هذا الطلب'));
      }

      if (orderData['status'] != 'pending' &&
          orderData['status'] != 'processing') {
        return Left(const ValidationFailure(
            message: 'لا يمكن إلغاء الطلب في هذه المرحلة'));
      }

      await _firestore.collection('orders').doc(orderId).update({
        'status': 'cancelled',
      });

      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> trackOrder(String orderId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return Left(const AuthFailure(message: 'المستخدم غير مسجل الدخول'));
      }

      final orderDoc = await _firestore.collection('orders').doc(orderId).get();

      if (!orderDoc.exists) {
        return Left(NotFoundFailure(message: 'الطلب غير موجود'));
      }

      final orderData = orderDoc.data()!;
      if (orderData['userId'] != userId) {
        return Left(
            const AuthFailure(message: 'ليس لديك صلاحية لتتبع هذا الطلب'));
      }

      final status = orderData['status'] as String;
      final trackingNumber = orderData['trackingNumber'] as String?;

      String trackingInfo;
      switch (status) {
        case 'pending':
          trackingInfo = 'الطلب قيد المعالجة';
          break;
        case 'processing':
          trackingInfo = 'جاري تجهيز الطلب';
          break;
        case 'shipped':
          trackingInfo = 'تم شحن الطلب';
          if (trackingNumber != null) {
            trackingInfo += ' - رقم التتبع: $trackingNumber';
          }
          break;
        case 'delivered':
          trackingInfo = 'تم تسليم الطلب';
          break;
        case 'cancelled':
          trackingInfo = 'تم إلغاء الطلب';
          break;
        default:
          trackingInfo = 'حالة الطلب: $status';
      }

      return Right(trackingInfo);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateShippingAddress(
      String orderId, String newAddress) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return Left(const AuthFailure(message: 'المستخدم غير مسجل الدخول'));
      }

      final orderDoc = await _firestore.collection('orders').doc(orderId).get();

      if (!orderDoc.exists) {
        return Left(NotFoundFailure(message: 'الطلب غير موجود'));
      }

      final orderData = orderDoc.data()!;
      if (orderData['userId'] != userId) {
        return Left(
            const AuthFailure(message: 'ليس لديك صلاحية لتحديث هذا الطلب'));
      }

      if (orderData['status'] != 'pending') {
        return Left(const ValidationFailure(
            message: 'لا يمكن تحديث عنوان الشحن بعد بدء معالجة الطلب'));
      }

      await _firestore.collection('orders').doc(orderId).update({
        'shippingAddress': newAddress,
      });

      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
