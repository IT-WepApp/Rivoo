import 'package:flutter/material.dart'; // ✅ لحل مشكلة DateTimeRange
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';

class SalesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getTopSellingProducts(
    String storeId, {
    DateTimeRange? dateRange,
    int limit = 5,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('orders')
          .where('sellerId', isEqualTo: storeId)
          .where('status', isEqualTo: 'delivered');

      if (dateRange != null) {
        query = query.where(
          'orderDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(dateRange.start),
          isLessThanOrEqualTo: Timestamp.fromDate(dateRange.end),
        );
      }

      final querySnapshot = await query.get();

      if (querySnapshot.docs.isEmpty) return [];

      Map<String, int> productCounts = {};

      for (var doc in querySnapshot.docs) {
        try {
          final data = doc.data();
          if (data.containsKey('items') && data['items'] is List) {
            List items = data['items'];
            for (var item in items) {
              if (item is Map<String, dynamic> &&
                  item.containsKey('productId') &&
                  item.containsKey('quantity')) {
                String productId = item['productId'] as String;
                int quantity = (item['quantity'] as num).toInt();
                productCounts.update(productId, (v) => v + quantity,
                    ifAbsent: () => quantity);
              } else {
                log('Skipping invalid item structure in order ${doc.id}: $item',
                    name: 'SalesService');
              }
            }
          } else {
            log("Order ${doc.id} missing or has invalid 'items' field",
                name: 'SalesService');
          }
        } catch (e, stackTrace) {
          log('Error processing order doc ${doc.id}',
              error: e, stackTrace: stackTrace, name: 'SalesService');
        }
      }

      var sortedProducts = productCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      var topProducts = sortedProducts.take(limit);

      return topProducts
          .map((e) => {"productId": e.key, "unitsSold": e.value})
          .toList();
    } catch (e, stacktrace) {
      log('Error fetching top selling products',
          error: e, stackTrace: stacktrace, name: 'SalesService');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getSalesData(
    String storeId,
    DateTimeRange dateRange,
    String aggregationPeriod,
  ) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('orders')
          .where('sellerId', isEqualTo: storeId)
          .where('status', isEqualTo: 'delivered')
          .where(
            'orderDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(dateRange.start),
            isLessThanOrEqualTo: Timestamp.fromDate(dateRange.end),
          );

      final querySnapshot = await query.get();

      if (querySnapshot.docs.isEmpty) return [];

      Map<String, double> salesData = {};

      for (var doc in querySnapshot.docs) {
        try {
          final data = doc.data();
          if (data.containsKey('orderDate') &&
              data['orderDate'] is Timestamp &&
              data.containsKey('totalAmount') &&
              data['totalAmount'] is num) {
            Timestamp timestamp = data['orderDate'] as Timestamp;
            DateTime orderDate = timestamp.toDate();
            double totalAmount = (data['totalAmount'] as num).toDouble();

            String key;
            if (aggregationPeriod == 'daily') {
              key =
                  '${orderDate.year}-${orderDate.month.toString().padLeft(2, '0')}-${orderDate.day.toString().padLeft(2, '0')}';
            } else if (aggregationPeriod == 'monthly') {
              key = '${orderDate.year}-${orderDate.month.toString().padLeft(2, '0')}';
            } else {
              log('Invalid aggregation period: $aggregationPeriod',
                  name: 'SalesService');
              continue;
            }

            salesData.update(key, (v) => v + totalAmount,
                ifAbsent: () => totalAmount);
          } else {
            log('Order ${doc.id} missing or has invalid date/amount field',
                name: 'SalesService');
          }
        } catch (e, stackTrace) {
          log('Error processing sales data for order ${doc.id}',
              error: e, stackTrace: stackTrace, name: 'SalesService');
        }
      }

      return salesData.entries.map((entry) {
        final keyName = aggregationPeriod == 'daily' ? 'date' : 'month';
        return {keyName: entry.key, 'sales': entry.value};
      }).toList()
        ..sort((a, b) => (a.values.first as String)
            .compareTo(b.values.first as String));
    } catch (e, stacktrace) {
      log('Error fetching sales data',
          error: e, stackTrace: stacktrace, name: 'SalesService');
      rethrow;
    }
  }
}
