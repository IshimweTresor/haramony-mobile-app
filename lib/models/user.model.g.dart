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
  mentorSpecialty: json['mentorSpecialty'] as String?,
  password: json['password'] as String?,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  '_id': instance.id,
  'usernames': instance.usernames,
  'ID_number': instance.idNumber,
  'phoneNumber': instance.phoneNumber,
  'mentorSpecialty': instance.mentorSpecialty,
  if (instance.password case final value?) 'password': value,
};
