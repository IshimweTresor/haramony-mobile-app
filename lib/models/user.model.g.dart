// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['_id'] as String?,
  usernames: json['usernames'] as String,
  idNumber: (json['ID_number'] as num?)?.toInt() ?? 0,
  phoneNumber: json['phoneNumber'] as String,
  role: json['role'] as String? ?? 'user',
  mentorSpecialty: json['mentorSpecialty'] as String?,
  isAvailable: json['isAvailable'] as bool? ?? true,
  isActive: json['isActive'] as bool? ?? true,
  deactivatedAt:
      json['deactivatedAt'] == null
          ? null
          : DateTime.parse(json['deactivatedAt'] as String),
  deactivationReason: json['deactivationReason'] as String?,
  location:
      json['location'] == null
          ? null
          : UserLocation.fromJson(json['location'] as Map<String, dynamic>),
  profileImage: json['profileImage'] as String?,
  password: json['password'] as String?,
  verificationCodevalidation:
      (json['verificationCodevalidation'] as num?)?.toInt(),
  verificationCode: json['verificationCode'] as String?,
  resetPasswordOTP: json['resetPasswordOTP'] as String?,
  resetPasswordExpires:
      json['resetPasswordExpires'] == null
          ? null
          : DateTime.parse(json['resetPasswordExpires'] as String),
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  '_id': instance.id,
  'usernames': instance.usernames,
  'ID_number': instance.idNumber,
  'phoneNumber': instance.phoneNumber,
  'role': instance.role,
  'mentorSpecialty': instance.mentorSpecialty,
  'isAvailable': instance.isAvailable,
  'isActive': instance.isActive,
  'deactivatedAt': instance.deactivatedAt?.toIso8601String(),
  'deactivationReason': instance.deactivationReason,
  'location': instance.location,
  'profileImage': instance.profileImage,
  if (instance.password case final value?) 'password': value,
  if (instance.verificationCodevalidation case final value?)
    'verificationCodevalidation': value,
  if (instance.verificationCode case final value?) 'verificationCode': value,
  if (instance.resetPasswordOTP case final value?) 'resetPasswordOTP': value,
  if (instance.resetPasswordExpires?.toIso8601String() case final value?)
    'resetPasswordExpires': value,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

UserLocation _$UserLocationFromJson(Map<String, dynamic> json) => UserLocation(
  sector: json['sector'] as String?,
  cell: json['cell'] as String?,
  village: json['village'] as String?,
  isibo: json['isibo'] as String?,
);

Map<String, dynamic> _$UserLocationToJson(UserLocation instance) =>
    <String, dynamic>{
      'sector': instance.sector,
      'cell': instance.cell,
      'village': instance.village,
      'isibo': instance.isibo,
    };
