import 'package:circle_share/app/constants/hive_table_constant.dart';
import 'package:circle_share/features/category/domain/entity/category_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:uuid/uuid.dart';

part 'category_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.categoryTableId)
class CategoryHiveModel extends Equatable {
  @HiveField(0)
  final String? categoryId;
  @HiveField(1)
  final String name;

  CategoryHiveModel({
    String? categoryId,
    required this.name,
  }) : categoryId = categoryId ?? const Uuid().v4();

  const CategoryHiveModel.initial()
      : categoryId = '',
        name = '';

  factory CategoryHiveModel.fromEntity(CategoryEntity entity) {
    return CategoryHiveModel(
      categoryId: entity.categoryId,
      name: entity.name,
    );
  }

  CategoryEntity toEntity() {
    return CategoryEntity(
      categoryId: categoryId,
      name: name,
    );
  }

  @override
  List<Object?> get props => [categoryId, name];
}
