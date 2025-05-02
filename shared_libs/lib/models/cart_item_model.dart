import 'package:json_annotation/json_annotation.dart';
import '../entities/cart_item_entity.dart'; // Import the base entity
import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp converters

part 'cart_item_model.g.dart';

@JsonSerializable(explicitToJson: true)
class CartItemModel extends CartItemEntity {
  // Fields inherited from CartItemEntity:
  // id, productId, quantity, addedAt

  // Fields specific to this model (often for display/API interaction):
  final String name;
  final double price;
  final String? imageUrl;

  CartItemModel({
    // Fields for CartItemEntity (passed to super)
    required String id,
    required String productId,
    required int quantity,
    required DateTime addedAt,

    // Fields specific to this model
    required this.name,
    required this.price,
    this.imageUrl,
  }) : super(
          id: id,
          productId: productId,
          quantity: quantity,
          addedAt: addedAt,
        );

  // --- JsonSerializable methods ---
  factory CartItemModel.fromJson(Map<String, dynamic> json) =>
      _$CartItemModelFromJson(json);
  Map<String, dynamic> toJson() => _$CartItemModelToJson(this);

  // --- copyWith method ---
  CartItemModel copyWith({
    // Entity fields
    String? id,
    String? productId,
    int? quantity,
    DateTime? addedAt,
    // Model specific fields
    String? name,
    double? price,
    String? imageUrl,
  }) {
    return CartItemModel(
      // Entity fields
      id: id ?? this.id,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
      // Model specific fields
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  // --- Equatable --- (Updated props)
  @override
  List<Object?> get props => [
        // Include super.props and model-specific props
        ...super.props,
        name,
        price,
        imageUrl,
      ];
}

// --- Json Converters (if needed, especially for DateTime/Timestamp) ---
// Ensure these converters are available or defined here/globally
DateTime _dateTimeFromTimestamp(Timestamp timestamp) => timestamp.toDate();
Timestamp _dateTimeToTimestamp(DateTime dateTime) => Timestamp.fromDate(dateTime);

DateTime? _nullableDateTimeFromTimestamp(Timestamp? timestamp) => timestamp?.toDate();
Timestamp? _nullableDateTimeToTimestamp(DateTime? dateTime) =>
    dateTime == null ? null : Timestamp.fromDate(dateTime);

