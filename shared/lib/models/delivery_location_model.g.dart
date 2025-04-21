// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_location_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeliveryLocation _$DeliveryLocationFromJson(Map<String, dynamic> json) =>
    DeliveryLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timestamp: const TimestampConverter().fromJson(json['timestamp']),
    );

Map<String, dynamic> _$DeliveryLocationToJson(DeliveryLocation instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'timestamp': const TimestampConverter().toJson(instance.timestamp),
    };
