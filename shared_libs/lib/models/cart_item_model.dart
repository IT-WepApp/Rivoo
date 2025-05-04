import 'package:json_annotation/json_annotation.dart';
import '../entities/cart_item_entity.dart'; // base entity
import 'package:cloud_firestore/cloud_firestore.dart'; // for Timestamp

part 'cart_item_model.g.dart';

/// بيانات عنصر واحد داخل سلة التسوق، تمتد من الـ Entity الأساسي
@JsonSerializable(explicitToJson: true)
class CartItemModel extends CartItemEntity {
  // الوراثة من CartItemEntity توفر:
  //   id, productId, quantity, addedAt

  /// اسم المنتج (للعرض)
  final String name;
  /// سعر الوحدة
  final double price;
  /// رابط الصورة (إن وجد)
  final String? imageUrl;

  CartItemModel({
    // حقول الـ Entity:
    required String id,
    required String productId,
    required int quantity,
    required DateTime addedAt,

    // الحقول الخاصة بالنموذج
    required this.name,
    required this.price,
    this.imageUrl,
  }) : super(
          id: id,
          productId: productId,
          quantity: quantity,
          addedAt: addedAt,
        );

  /// تحويل من JSON
  factory CartItemModel.fromJson(Map<String, dynamic> json) =>
      _$CartItemModelFromJson(json);

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() => _$CartItemModelToJson(this);

  /// إنشاء نسخة جديدة مع بعض التعديلات
  CartItemModel copyWith({
    // Entity fields
    String? id,
    String? productId,
    int? quantity,
    DateTime? addedAt,
    // نموذج-specific
    String? name,
    double? price,
    String? imageUrl,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        name,
        price,
        imageUrl,
      ];
}

// Json-Timestamp converters
DateTime _dateTimeFromTimestamp(Timestamp t) => t.toDate();
Timestamp _dateTimeToTimestamp(DateTime dt) => Timestamp.fromDate(dt);

DateTime? _nullableDateTimeFromTimestamp(Timestamp? t) => t?.toDate();
Timestamp? _nullableDateTimeToTimestamp(DateTime? dt) =>
    dt == null ? null : Timestamp.fromDate(dt);
