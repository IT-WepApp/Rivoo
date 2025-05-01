import 'package:json_annotation/json_annotation.dart';
import 'package:shared_libs/entities/user_entity.dart';
import 'package:shared_libs/enums/user_role.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // لاستخدام Timestamp

part 'delivery_person_model.g.dart';

@JsonSerializable(explicitToJson: true)
class DeliveryPersonModel extends UserEntity {
  // الحقول الموروثة من UserEntity:
  // id, name, email, role (يجب أن يكون UserRole.driver)
  // phone, address, avatarUrl, createdAt, updatedAt, lastLoginAt
  // isEmailVerified, isPhoneVerified

  // الحقول الخاصة بمندوب التوصيل:
  final double? currentLat;
  final double? currentLng;
  final bool isAvailable;
  final String? vehicleDetails;
  // يمكن إضافة حقول أخرى مثل رقم الهاتف، التقييم، معرف الطلب الحالي

  const DeliveryPersonModel({
    required String id,
    required String name,
    String? email,
    String? phone,
    String? address,
    String? avatarUrl,
    this.currentLat,
    this.currentLng,
    required this.isAvailable,
    this.vehicleDetails,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? lastLoginAt,
    bool isEmailVerified = false,
    bool isPhoneVerified = false,
  }) : super(
          id: id,
          name: name,
          email: email,
          role: UserRole.driver, // تعيين الدور تلقائياً
          phone: phone,
          address: address,
          avatarUrl: avatarUrl,
          // storeId لا ينطبق على المندوب
          createdAt: createdAt,
          updatedAt: updatedAt,
          lastLoginAt: lastLoginAt,
          isEmailVerified: isEmailVerified,
          isPhoneVerified: isPhoneVerified,
        );

  factory DeliveryPersonModel.fromJson(Map<String, dynamic> json) =>
      _$DeliveryPersonModelFromJson(json);

  Map<String, dynamic> toJson() => _$DeliveryPersonModelToJson(this);

  @override
  DeliveryPersonModel copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role, // يتم تجاهله، الدور دائماً driver
    String? phone,
    String? address,
    String? avatarUrl,
    String? storeId, // يتم تجاهله
    double? currentLat, // حقل إضافي لـ copyWith
    double? currentLng, // حقل إضافي لـ copyWith
    bool? isAvailable, // حقل إضافي لـ copyWith
    String? vehicleDetails, // حقل إضافي لـ copyWith
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    bool? isEmailVerified,
    bool? isPhoneVerified,
  }) {
    return DeliveryPersonModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      currentLat: currentLat ?? this.currentLat,
      currentLng: currentLng ?? this.currentLng,
      isAvailable: isAvailable ?? this.isAvailable,
      vehicleDetails: vehicleDetails ?? this.vehicleDetails,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
    );
  }

  // props موروثة من UserEntity، لكن يمكن إضافة الحقول الخاصة هنا إذا أردنا
  @override
  List<Object?> get props => [
        ...super.props,
        currentLat,
        currentLng,
        isAvailable,
        vehicleDetails,
      ];
}

// --- Json Converters (توضع عادة في ملف منفصل أو في نفس الملف) ---

// محول Timestamp (إذا لم يكن موجوداً بالفعل في مكان مشترك)
DateTime? _dateTimeFromTimestamp(Timestamp? timestamp) => timestamp?.toDate();
Timestamp? _dateTimeToTimestamp(DateTime? dateTime) =>
    dateTime == null ? null : Timestamp.fromDate(dateTime);

// محول UserRole (إذا لم يكن موجوداً بالفعل في مكان مشترك)
UserRole _userRoleFromString(String? roleString) {
  if (roleString == null) return UserRole.user;
  try {
    return UserRole.values.byName(roleString);
  } catch (_) {
    return UserRole.user;
  }
}

String _userRoleToString(UserRole role) => role.name;

