import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'delivery_location_model.g.dart';

/// Converter to support Firebase [Timestamp] with json_serializable
class TimestampConverter implements JsonConverter<Timestamp, dynamic> {
  const TimestampConverter();

  @override
  Timestamp fromJson(dynamic json) => json as Timestamp;

  @override
  dynamic toJson(Timestamp object) => object;
}

@JsonSerializable()
class DeliveryLocation {
  final double latitude;
  final double longitude;

  @TimestampConverter()
  final Timestamp timestamp;

  DeliveryLocation({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  factory DeliveryLocation.fromJson(Map<String, dynamic> json) =>
      _$DeliveryLocationFromJson(json);

  Map<String, dynamic> toJson() => _$DeliveryLocationToJson(this);
}
