import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'seller_model.g.dart';

@JsonSerializable()
class SellerModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String storeId;
  final String? storeName;

  const SellerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.storeId,
    this.storeName,
  });

  factory SellerModel.fromJson(Map<String, dynamic> json) =>
      _$SellerModelFromJson(json);
  Map<String, dynamic> toJson() => _$SellerModelToJson(this);

  SellerModel copyWith({
    String? id,
    String? name,
    String? email,
    String? storeId,
    String? storeName,
  }) {
    return SellerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
    );
  }

  @override
  List<Object?> get props => [id, name, email, storeId, storeName];
}
