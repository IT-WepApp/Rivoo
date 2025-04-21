// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_person_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeliveryPersonModel _$DeliveryPersonModelFromJson(Map<String, dynamic> json) =>
    DeliveryPersonModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      currentLat: (json['currentLat'] as num?)?.toDouble(),
      currentLng: (json['currentLng'] as num?)?.toDouble(),
      isAvailable: json['isAvailable'] as bool,
      vehicleDetails: json['vehicleDetails'] as String?,
    );

Map<String, dynamic> _$DeliveryPersonModelToJson(
        DeliveryPersonModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'currentLat': instance.currentLat,
      'currentLng': instance.currentLng,
      'isAvailable': instance.isAvailable,
      'vehicleDetails': instance.vehicleDetails,
    };
