import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'address_model.g.dart';

/// نموذج العنوان
/// يستخدم لتمثيل بيانات عناوين المستخدمين في التطبيق
@JsonSerializable()
class AddressModel extends Equatable {
  /// معرف العنوان الفريد
  final String id;
  
  /// معرف المستخدم صاحب العنوان
  final String userId;
  
  /// اسم المستلم
  final String name;
  
  /// رقم هاتف المستلم
  final String phone;
  
  /// الدولة
  final String country;
  
  /// المدينة
  final String city;
  
  /// المنطقة أو الحي
  final String area;
  
  /// الشارع
  final String street;
  
  /// رقم المبنى أو اسمه
  final String? building;
  
  /// رقم الشقة أو الوحدة
  final String? apartment;
  
  /// الرمز البريدي
  final String? postalCode;
  
  /// ملاحظات إضافية للعنوان
  final String? notes;
  
  /// خط العرض (للموقع الجغرافي)
  final double? latitude;
  
  /// خط الطول (للموقع الجغرافي)
  final double? longitude;
  
  /// ما إذا كان العنوان افتراضياً
  final bool isDefault;
  
  /// نوع العنوان (منزل، عمل، الخ)
  final AddressType type;
  
  /// تاريخ إنشاء العنوان
  final DateTime createdAt;
  
  /// تاريخ آخر تحديث للعنوان
  final DateTime updatedAt;

  /// منشئ النموذج
  const AddressModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.country,
    required this.city,
    required this.area,
    required this.street,
    this.building,
    this.apartment,
    this.postalCode,
    this.notes,
    this.latitude,
    this.longitude,
    this.isDefault = false,
    this.type = AddressType.home,
    required this.createdAt,
    required this.updatedAt,
  });

  /// إنشاء نسخة جديدة من النموذج مع تحديث بعض الحقول
  AddressModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? phone,
    String? country,
    String? city,
    String? area,
    String? street,
    String? building,
    String? apartment,
    String? postalCode,
    String? notes,
    double? latitude,
    double? longitude,
    bool? isDefault,
    AddressType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      country: country ?? this.country,
      city: city ?? this.city,
      area: area ?? this.area,
      street: street ?? this.street,
      building: building ?? this.building,
      apartment: apartment ?? this.apartment,
      postalCode: postalCode ?? this.postalCode,
      notes: notes ?? this.notes,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// الحصول على العنوان كاملاً كنص
  String get fullAddress {
    final List<String> parts = [
      street,
      if (building != null) 'مبنى: $building',
      if (apartment != null) 'شقة: $apartment',
      area,
      city,
      country,
      if (postalCode != null) 'الرمز البريدي: $postalCode',
    ];
    
    return parts.join('، ');
  }

  /// تحويل النموذج إلى Map
  Map<String, dynamic> toJson() => _$AddressModelToJson(this);

  /// إنشاء نموذج من Map
  factory AddressModel.fromJson(Map<String, dynamic> json) => _$AddressModelFromJson(json);

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        phone,
        country,
        city,
        area,
        street,
        building,
        apartment,
        postalCode,
        notes,
        latitude,
        longitude,
        isDefault,
        type,
        createdAt,
        updatedAt,
      ];
}

/// تعداد أنواع العناوين
enum AddressType {
  home,     // منزل
  work,     // عمل
  other,    // آخر
}
