import 'package:json_annotation/json_annotation.dart';
part 'delivery_person_model.g.dart'; // For json_serializable

@JsonSerializable()
class DeliveryPersonModel {
  final String id;
  final String name;
  final String?
      email; // Make email nullable if it might not always be available
  final double? currentLat;
  final double? currentLng;
  final bool isAvailable;
  final String? vehicleDetails;
  // Add other relevant fields like phone number, rating, current order ID, etc.
  // final String? phoneNumber;
  // final double rating;
  // final String? currentOrderId;

  DeliveryPersonModel({
    required this.id,
    required this.name,
    this.email,
    this.currentLat,
    this.currentLng,
    required this.isAvailable,
    this.vehicleDetails,
    // required this.phoneNumber,
    // required this.rating,
    // this.currentOrderId,
  });

  factory DeliveryPersonModel.fromJson(Map<String, dynamic> json) =>
      _$DeliveryPersonModelFromJson(json);

  Map<String, dynamic> toJson() => _$DeliveryPersonModelToJson(this);

  // Consider adding copyWith for easier updates
  DeliveryPersonModel copyWith({
    String? id,
    String? name,
    String? email,
    double? currentLat,
    double? currentLng,
    bool? isAvailable,
    String? vehicleDetails,
  }) {
    return DeliveryPersonModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      currentLat: currentLat ?? this.currentLat,
      currentLng: currentLng ?? this.currentLng,
      isAvailable: isAvailable ?? this.isAvailable,
      vehicleDetails: vehicleDetails ?? this.vehicleDetails,
    );
  }
}
