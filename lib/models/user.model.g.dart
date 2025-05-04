// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  usernames: json['usernames'] as String,
  idNumber: (json['ID_number'] as num?)?.toInt() ?? 0,
  phoneNumber: json['phoneNumber'] as String,
  password: json['password'] as String?,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'usernames': instance.usernames,
  'ID_number': instance.idNumber,
  'phoneNumber': instance.phoneNumber,
  if (instance.password case final value?) 'password': value,
};
