import 'package:json_annotation/json_annotation.dart';

part 'category.model.g.dart';

@JsonSerializable()
class Category {
  @JsonKey(name: '_id')
  final String? id;
  
  final String name;
  
  @JsonKey(name: 'createdAt')
  final DateTime? createdAt;
  
  @JsonKey(name: 'updatedAt')
  final DateTime? updatedAt;

  Category({
    this.id,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
  
  Map<String, dynamic> toJson() => _$CategoryToJson(this);
  
  // Create a copy with updated fields
  Category copyWith({
    String? name,
  }) {
    return Category(
      id: id,
      name: name ?? this.name,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
  
  @override
  String toString() {
    return 'Category(id: $id, name: $name)';
  }
}