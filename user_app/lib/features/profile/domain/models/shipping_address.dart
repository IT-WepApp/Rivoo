class ShippingAddress {
  final String id;
  final String userId;
  final String name;
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String phoneNumber;
  final bool isDefault;
  final String? additionalInfo;
  final double? latitude;
  final double? longitude;

  ShippingAddress({
    required this.id,
    required this.userId,
    required this.name,
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.phoneNumber,
    this.isDefault = false,
    this.additionalInfo,
    this.latitude,
    this.longitude,
  });

  ShippingAddress copyWith({
    String? id,
    String? userId,
    String? name,
    String? street,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    String? phoneNumber,
    bool? isDefault,
    String? additionalInfo,
    double? latitude,
    double? longitude,
  }) {
    return ShippingAddress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isDefault: isDefault ?? this.isDefault,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'street': street,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'phoneNumber': phoneNumber,
      'isDefault': isDefault,
      'additionalInfo': additionalInfo,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory ShippingAddress.fromMap(Map<String, dynamic> map) {
    return ShippingAddress(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      street: map['street'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      postalCode: map['postalCode'] ?? '',
      country: map['country'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      isDefault: map['isDefault'] ?? false,
      additionalInfo: map['additionalInfo'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }

  @override
  String toString() {
    return '$name, $street, $city, $state $postalCode, $country';
  }
}
