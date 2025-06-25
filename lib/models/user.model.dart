import 'package:json_annotation/json_annotation.dart';

part 'user.model.g.dart';

@JsonSerializable()
class User {
  @JsonKey(name: '_id')
  final String? id;

  final String usernames;
  
  @JsonKey(name: 'ID_number', defaultValue: 0)
  final int idNumber;
  
  final String phoneNumber;

  @JsonKey(defaultValue: 'user')
  final String? role;

  final String? mentorSpecialty;
  
  @JsonKey(defaultValue: true)
  final bool? isAvailable;
  
  @JsonKey(defaultValue: true)
  final bool? isActive;
  
  final DateTime? deactivatedAt;
  
  final String? deactivationReason;
  
  final UserLocation? location;
  
  final String? profileImage;

  @JsonKey(includeIfNull: false)
  final String? password;
  
  @JsonKey(includeIfNull: false)
  final int? verificationCodevalidation;
  
  @JsonKey(includeIfNull: false)
  final String? verificationCode;
  
  @JsonKey(includeIfNull: false)
  final String? resetPasswordOTP;
  
  @JsonKey(includeIfNull: false)
  final DateTime? resetPasswordExpires;
  
  @JsonKey(name: 'createdAt')
  final DateTime? createdAt;
  
  @JsonKey(name: 'updatedAt')
  final DateTime? updatedAt;

  User({
    this.id,
    required this.usernames,
    required this.idNumber,
    required this.phoneNumber,
    this.role = 'user',
    this.mentorSpecialty,
    this.isAvailable,
    this.isActive,
    this.deactivatedAt,
    this.deactivationReason,
    this.location,
    this.profileImage,
    this.password,
    this.verificationCodevalidation,
    this.verificationCode,
    this.resetPasswordOTP,
    this.resetPasswordExpires,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
  
  // Helper to check if user is a mentor
  bool isMentor() => role == 'mentor';
  
  // Helper to check if user is an admin
  bool isAdmin() => role == 'admin';
  
  @override
  String toString() {
    return 'User(id: $id, usernames: $usernames, idNumber: $idNumber, phoneNumber: $phoneNumber, role: $role, mentorSpecialty: $mentorSpecialty)';
  }
}

@JsonSerializable()
class UserLocation {
  final String? sector;
  final String? cell;
  final String? village;
  final String? isibo;

  UserLocation({
    this.sector,
    this.cell,
    this.village,
    this.isibo,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) => _$UserLocationFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserLocationToJson(this);
  
  // Add a helper method to get formatted location string
  String getFormattedLocation() {
    final parts = <String>[];
    if (sector != null && sector!.isNotEmpty) parts.add(sector!);
    if (cell != null && cell!.isNotEmpty) parts.add(cell!);
    if (village != null && village!.isNotEmpty) parts.add(village!);
    if (isibo != null && isibo!.isNotEmpty) parts.add(isibo!);
    
    return parts.isEmpty ? 'No location provided' : parts.join(', ');
  }
}