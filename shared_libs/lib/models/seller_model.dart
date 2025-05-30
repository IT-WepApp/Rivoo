import 'package:json_annotation/json_annotation.dart';
import 'package:shared_libs/entities/user_entity.dart';
import 'package:shared_libs/enums/user_role.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // لاستخدام Timestamp

part 'seller_model.g.dart';

@JsonSerializable(explicitToJson: true)
class SellerModel extends UserEntity {
  // الحقول الموروثة من UserEntity:
  // id, name, email, role (يجب أن يكون UserRole.seller)
  // phone, address, avatarUrl, createdAt, updatedAt, lastLoginAt
  // isEmailVerified, isPhoneVerified

  // الحقول الخاصة بالبائع:
  @override
  final String? storeId;
  final String? storeName;

  const SellerModel({
    required String id,
    required String name,
    required String email,
    String? phone,
    String? address,
    String? avatarUrl,
    this.storeId,
    this.storeName,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? lastLoginAt,
    bool isEmailVerified = false,
    bool isPhoneVerified = false,
  }) : super(
          id: id,
          name: name,
          email: email,
          role: UserRole.seller, // تعيين الدور تلقائياً
          phone: phone,
          address: address,
          avatarUrl: avatarUrl,
          storeId: storeId,
          createdAt: createdAt,
          updatedAt: updatedAt,
          lastLoginAt: lastLoginAt,
          isEmailVerified: isEmailVerified,
          isPhoneVerified: isPhoneVerified,
        );

  factory SellerModel.fromJson(Map<String, dynamic> json) =>
      _$SellerModelFromJson(json);

  Map<String, dynamic> toJson() => _$SellerModelToJson(this);

  @override
  SellerModel copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role, // يتم تجاهله، الدور دائماً seller
    String? phone,
    String? address,
    String? avatarUrl,
    String? storeId,
    String? storeName, // حقل إضافي لـ copyWith
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    bool? isEmailVerified,
    bool? isPhoneVerified,
  }) {
    return SellerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
    );
  }

  // props موروثة من UserEntity، لكن يمكن إضافة الحقول الخاصة هنا إذا أردنا
  @override
  List<Object?> get props => [...super.props, storeName];
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

