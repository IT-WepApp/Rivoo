import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:seller_panel/services/sales_service.dart';

@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  Query,
  QuerySnapshot,
  DocumentSnapshot,
])
void main() {
  late SalesService salesService;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollectionReference;
  late MockQuery<Map<String, dynamic>> mockQuery;
  late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollectionReference = MockCollectionReference<Map<String, dynamic>>();
    mockQuery = MockQuery<Map<String, dynamic>>();
    mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();

    // استبدال الكائنات الحقيقية بالكائنات المزيفة للاختبار
    salesService = SalesService();

    // تعيين الحقول الخاصة باستخدام التفكير (reflection)
    // هذا يتطلب تعديل الفئة SalesService لتسهيل الاختبار
    // أو استخدام مكتبة مثل mockito_extensions
  });

  group('SalesService Tests', () {
    test('getTopSellingProducts يجب أن يعيد قائمة المنتجات الأكثر مبيعًا',
        () async {
      // الإعداد
      const storeId = 'test-store-id';
      final dateRange = DateTimeRange(
        start: DateTime(2025, 1, 1),
        end: DateTime(2025, 12, 31),
      );

      final mockDocs = [
        createMockDocumentSnapshot('order1', {
          'sellerId': storeId,
          'status': 'delivered',
          'items': [
            {'productId': 'product1', 'quantity': 3},
            {'productId': 'product2', 'quantity': 1},
          ],
        }),
        createMockDocumentSnapshot('order2', {
          'sellerId': storeId,
          'status': 'delivered',
          'items': [
            {'productId': 'product1', 'quantity': 2},
            {'productId': 'product3', 'quantity': 4},
          ],
        }),
      ];

      when(mockFirestore.collection('orders'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.where('sellerId', isEqualTo: storeId))
          .thenReturn(mockQuery);
      when(mockQuery.where('status', isEqualTo: 'delivered'))
          .thenReturn(mockQuery);
      when(mockQuery.where(
        'orderDate',
        isGreaterThanOrEqualTo: Timestamp.fromDate(dateRange.start),
        isLessThanOrEqualTo: Timestamp.fromDate(dateRange.end),
      )).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn(mockDocs);

      // التنفيذ
      final result = await salesService.getTopSellingProducts(
        storeId,
        dateRange: dateRange,
        limit: 3,
      );

      // التحقق
      expect(result.length, 3);
      expect(result[0]['productId'], 'product1');
      expect(result[0]['unitsSold'], 5);
      expect(result[1]['productId'], 'product3');
      expect(result[1]['unitsSold'], 4);
      expect(result[2]['productId'], 'product2');
      expect(result[2]['unitsSold'], 1);
    });

    test('getSalesData يجب أن يعيد بيانات المبيعات اليومية', () async {
      // الإعداد
      const storeId = 'test-store-id';
      final dateRange = DateTimeRange(
        start: DateTime(2025, 4, 1),
        end: DateTime(2025, 4, 30),
      );

      final mockDocs = [
        createMockDocumentSnapshot('order1', {
          'sellerId': storeId,
          'status': 'delivered',
          'orderDate': Timestamp.fromDate(DateTime(2025, 4, 10)),
          'totalAmount': 100.0,
        }),
        createMockDocumentSnapshot('order2', {
          'sellerId': storeId,
          'status': 'delivered',
          'orderDate': Timestamp.fromDate(DateTime(2025, 4, 10)),
          'totalAmount': 150.0,
        }),
        createMockDocumentSnapshot('order3', {
          'sellerId': storeId,
          'status': 'delivered',
          'orderDate': Timestamp.fromDate(DateTime(2025, 4, 15)),
          'totalAmount': 200.0,
        }),
      ];

      when(mockFirestore.collection('orders'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.where('sellerId', isEqualTo: storeId))
          .thenReturn(mockQuery);
      when(mockQuery.where('status', isEqualTo: 'delivered'))
          .thenReturn(mockQuery);
      when(mockQuery.where(
        'orderDate',
        isGreaterThanOrEqualTo: Timestamp.fromDate(dateRange.start),
        isLessThanOrEqualTo: Timestamp.fromDate(dateRange.end),
      )).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn(mockDocs);

      // التنفيذ
      final result = await salesService.getSalesData(
        storeId,
        dateRange,
        'daily',
      );

      // التحقق
      expect(result.length, 2);
      expect(result[0]['date'], '2025-04-10');
      expect(result[0]['sales'], 250.0);
      expect(result[1]['date'], '2025-04-15');
      expect(result[1]['sales'], 200.0);
    });

    test('getSalesData يجب أن يعيد بيانات المبيعات الشهرية', () async {
      // الإعداد
      const storeId = 'test-store-id';
      final dateRange = DateTimeRange(
        start: DateTime(2025, 1, 1),
        end: DateTime(2025, 12, 31),
      );

      final mockDocs = [
        createMockDocumentSnapshot('order1', {
          'sellerId': storeId,
          'status': 'delivered',
          'orderDate': Timestamp.fromDate(DateTime(2025, 3, 15)),
          'totalAmount': 100.0,
        }),
        createMockDocumentSnapshot('order2', {
          'sellerId': storeId,
          'status': 'delivered',
          'orderDate': Timestamp.fromDate(DateTime(2025, 3, 20)),
          'totalAmount': 150.0,
        }),
        createMockDocumentSnapshot('order3', {
          'sellerId': storeId,
          'status': 'delivered',
          'orderDate': Timestamp.fromDate(DateTime(2025, 4, 5)),
          'totalAmount': 200.0,
        }),
      ];

      when(mockFirestore.collection('orders'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.where('sellerId', isEqualTo: storeId))
          .thenReturn(mockQuery);
      when(mockQuery.where('status', isEqualTo: 'delivered'))
          .thenReturn(mockQuery);
      when(mockQuery.where(
        'orderDate',
        isGreaterThanOrEqualTo: Timestamp.fromDate(dateRange.start),
        isLessThanOrEqualTo: Timestamp.fromDate(dateRange.end),
      )).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn(mockDocs);

      // التنفيذ
      final result = await salesService.getSalesData(
        storeId,
        dateRange,
        'monthly',
      );

      // التحقق
      expect(result.length, 2);
      expect(result[0]['month'], '2025-03');
      expect(result[0]['sales'], 250.0);
      expect(result[1]['month'], '2025-04');
      expect(result[1]['sales'], 200.0);
    });
  });
}

// دالة مساعدة لإنشاء وثيقة مزيفة للاختبار
MockDocumentSnapshot<Map<String, dynamic>> createMockDocumentSnapshot(
    String id, Map<String, dynamic> data) {
  final mockDoc = MockDocumentSnapshot<Map<String, dynamic>>();
  when(mockDoc.id).thenReturn(id);
  when(mockDoc.data()).thenReturn(data);
  return mockDoc;
}
