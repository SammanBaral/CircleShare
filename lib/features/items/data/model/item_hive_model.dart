import 'package:circle_share/app/constants/hive_table_constant.dart';
import 'package:circle_share/features/items/domain/entity/item_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:uuid/uuid.dart';

part 'item_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.itemTableId)
class ItemHiveModel extends Equatable {
  @HiveField(0)
  final String? id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String? categoryId;  // Changed to nullable
  @HiveField(3)
  final String? locationId;  // Changed to nullable
  @HiveField(4)
  final String? description;
  @HiveField(5)
  final String? availabilityStatus;  // Changed to nullable
  @HiveField(6)
  final String? borrowerId;
  @HiveField(7)
  final String? imageName;
  @HiveField(8)
  final String? rulesNotes;
  @HiveField(9)
  final double price;
  @HiveField(10)
  final String? condition;
  @HiveField(11)
  final int maxBorrowDuration;  // Changed to non-nullable with default
  @HiveField(12)
  final String? userId;  // Changed to nullable

  ItemHiveModel({
    String? id,
    required this.name,
    this.categoryId,  // Now optional
    this.locationId,  // Now optional
    this.description,
    this.availabilityStatus = 'available',  // Default value
    this.borrowerId,
    this.imageName,
    this.rulesNotes,
    required this.price,
    this.condition,
    this.maxBorrowDuration = 0,  // Default value
    this.userId,  // Now optional
  }) : id = id ?? const Uuid().v4();

  const ItemHiveModel.initial()
      : id = '',
        name = '',
        categoryId = '',
        locationId = '',
        description = '',
        availabilityStatus = 'available',  // Default value
        borrowerId = '',
        imageName = '',
        rulesNotes = '',
        price = 0.0,
        condition = '',
        maxBorrowDuration = 0,
        userId = '';

  factory ItemHiveModel.fromEntity(ItemEntity entity) {
    return ItemHiveModel(
      id: entity.id,
      name: entity.name,
      categoryId: entity.categoryId,
      locationId: entity.locationId,
      description: entity.description,
      availabilityStatus: entity.availabilityStatus ?? 'available',
      borrowerId: entity.borrowerId,
      imageName: entity.imageName,
      rulesNotes: entity.rulesNotes,
      price: entity.price,
      condition: entity.condition,
      maxBorrowDuration: entity.maxBorrowDuration ?? 0,
      userId: entity.userId,
    );
  }

  ItemEntity toEntity() {
    return ItemEntity(
      id: id,
      name: name,
      categoryId: categoryId ?? '',  // Provide empty string as fallback
      locationId: locationId ?? '',  // Provide empty string as fallback
      description: description,
      availabilityStatus: availabilityStatus ?? 'available',
      borrowerId: borrowerId,
      imageName: imageName,
      rulesNotes: rulesNotes,
      price: price,
      condition: condition,
      maxBorrowDuration: maxBorrowDuration,
      userId: userId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        categoryId,
        locationId,
        description,
        availabilityStatus,
        borrowerId,
        imageName,
        rulesNotes,
        price,
        condition,
        maxBorrowDuration,
        userId,
      ];
}