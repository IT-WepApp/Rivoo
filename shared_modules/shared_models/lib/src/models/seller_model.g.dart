// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seller_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SellerModel _$SellerModelFromJson(Map<String, dynamic> json) => SellerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      storeId: json['storeId'] as String,
      storeName: json['storeName'] as String?,
    );

Map<String, dynamic> _$SellerModelToJson(SellerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'storeId': instance.storeId,
      'storeName': instance.storeName,
    };
