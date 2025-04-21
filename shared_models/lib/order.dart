class Order {
  final String id;
  final String customerId;
  final String storeId;
  final List<OrderItem> items;
  final double totalAmount;
  final DateTime orderDate;
  final String status; // Added status field
  final Location?
      deliveryPersonnelLocation; // Added deliveryPersonnelLocation field
  final String? deliveryPersonnelId; // Add deliveryPersonnelId field

  Order({
    required this.id,
    required this.customerId,
    required this.storeId,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    required this.status,
    this.deliveryPersonnelId,
    this.deliveryPersonnelLocation,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      customerId: json['customerId'],
      storeId: json['storeId'],
      items: (json['items'] as List).map((i) => OrderItem.fromJson(i)).toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      orderDate: DateTime.parse(json['orderDate']),
      status: json['status'],
      deliveryPersonnelLocation: json['deliveryPersonnelLocation'] != null
          ? Location.fromJson(json['deliveryPersonnelLocation'])
          : null,
      deliveryPersonnelId: json['deliveryPersonnelId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'storeId': storeId,
      'items': items.map((i) => i.toJson()).toList(),
      'totalAmount': totalAmount,
      'orderDate': orderDate.toIso8601String(),
      'status': status,
      'deliveryPersonnelId': deliveryPersonnelId,
      'deliveryPersonnelLocation': deliveryPersonnelLocation?.toJson(),
    };
  }
}

class OrderItem {
  final String productId;
  final int quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'],
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
      'price': price,
    };
  }
}

class Location {
  final double latitude;
  final double longitude;

  Location({
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
