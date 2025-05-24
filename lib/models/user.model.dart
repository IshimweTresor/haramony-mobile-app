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

  final String? mentorSpecialty;

  
  @JsonKey(includeIfNull: false)
  final String? password; 

  User({
    this.id,
    required this.usernames,
    required this.idNumber,
    required this.phoneNumber,
    this.mentorSpecialty,
    this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
  
  @override
  String toString() {
    return 'User(id: $id,usernames: $usernames, idNumber: $idNumber, phoneNumber: $phoneNumber, mentorSpecialty: $mentorSpecialty,)';
  }
}