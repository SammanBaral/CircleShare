import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String? categoryId;
  final String name;

  const CategoryEntity({
    this.categoryId,
    required this.name,
  });

  // Add this factory constructor
  factory CategoryEntity.fromJson(Map<String, dynamic> json) {
    return CategoryEntity(
      categoryId: json['_id'],
      name: json['name'],
    );
  }

  @override
  List<Object?> get props => [categoryId, name];
}
