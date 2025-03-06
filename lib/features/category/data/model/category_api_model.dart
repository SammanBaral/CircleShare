import 'package:circle_share/features/category/domain/entity/category_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'category_api_model.g.dart';

@JsonSerializable()
class CategoryApiModel extends Equatable {
  @JsonKey(name: '_id')
  final String? categoryId;
  final String name;

  const CategoryApiModel({
    this.categoryId,
    required this.name,
  });

  factory CategoryApiModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryApiModelToJson(this);

  CategoryEntity toEntity() {
    return CategoryEntity(
      categoryId: categoryId,
      name: name,
    );
  }

  factory CategoryApiModel.fromEntity(CategoryEntity entity) {
    return CategoryApiModel(
      categoryId: entity.categoryId,
      name: entity.name,
    );
  }

  @override
  List<Object?> get props => [categoryId, name];
}
