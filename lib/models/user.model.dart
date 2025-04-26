import 'package:json_annotation/json_annotation.dart';

part 'user.model.g.dart';

@JsonSerializable()
class User {
  final String usernames;
  
  @JsonKey(name: 'ID_number', defaultValue: 0)
  final int idNumber;
  
  final String phoneNumber;
  
  @JsonKey(includeIfNull: false)
  final String? password; // Make password nullable since it might not be returned

  User({
    required this.usernames,
    required this.idNumber,
    required this.phoneNumber,
    this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
  
  @override
  String toString() {
    return 'User(usernames: $usernames, idNumber: $idNumber, phoneNumber: $phoneNumber)';
  }
}