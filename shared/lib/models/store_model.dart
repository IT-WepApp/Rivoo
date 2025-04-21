import 'package:json_annotation/json_annotation.dart';

part 'store_model.g.dart'; // Add part file

@JsonSerializable() // Add annotation
class StoreModel { // Rename class to StoreModel
  final String id;
  final String name;
  final String? imageUrl; // Rename image to imageUrl and make optional
  // Add other fields if needed based on usage elsewhere (e.g., owner, status)
  final String owner; // Added based on admin_panel error
  final String status; // Added based on admin_panel error

  StoreModel({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.owner, // Added
    required this.status, // Added
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) =>
      _$StoreModelFromJson(json);
  Map<String, dynamic> toJson() => _$StoreModelToJson(this);
}
