import 'package:circle_share/features/items/domain/entity/item_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'item_api_model.g.dart';

@JsonSerializable(explicitToJson: true, createToJson: true)
class ItemApiModel extends Equatable {
  @JsonKey(name: '_id')
  final String? id;
  final String name;

  @JsonKey(name: 'categoryId', fromJson: _parseIdField)
  final String? categoryId;

  @JsonKey(name: 'locationId', fromJson: _parseIdField)
  final String? locationId;

  @JsonKey(name: 'userId', fromJson: _parseIdField)
  final String? userId;

  final String? description;

  @JsonKey(defaultValue: 'available')
  final String? availabilityStatus;

  @JsonKey(fromJson: _parseIdField)
  final String? borrowerId;

  final String? imageName;
  final String? rulesNotes;

  @JsonKey(fromJson: _parsePrice, defaultValue: 0.0)
  final double price;

  final String? condition;

  @JsonKey(fromJson: _parseInt, defaultValue: 0)
  final int maxBorrowDuration;

  const ItemApiModel({
    this.id,
    required this.name,
    this.categoryId,
    this.locationId,
    this.userId,
    this.description,
    this.availabilityStatus = 'available',
    this.borrowerId,
    this.imageName,
    this.rulesNotes,
    required this.price,
    this.condition,
    this.maxBorrowDuration = 0,
  });

  // Custom JSON parsers
  static String? _parseIdField(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map<String, dynamic>) {
      return value['_id']?.toString();
    }
    return null;
  }

  static double _parsePrice(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {
        return 0.0;
      }
    }
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (_) {
        return 0;
      }
    }
    return 0;
  }

  factory ItemApiModel.fromJson(Map<String, dynamic> json) =>
      _$ItemApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$ItemApiModelToJson(this);

  ItemEntity toEntity() {
    return ItemEntity(
      id: id,
      name: name,
      categoryId: categoryId,
      locationId: locationId,
      userId: userId,
      description: description,
      availabilityStatus: availabilityStatus ?? 'available',
      borrowerId: borrowerId,
      imageName: imageName,
      rulesNotes: rulesNotes,
      price: price,
      condition: condition,
      maxBorrowDuration: maxBorrowDuration,
    );
  }

  factory ItemApiModel.fromEntity(ItemEntity entity) {
    return ItemApiModel(
      id: entity.id,
      name: entity.name,
      categoryId: entity.categoryId,
      locationId: entity.locationId,
      userId: entity.userId,
      description: entity.description,
      availabilityStatus: entity.availabilityStatus ?? 'available',
      borrowerId: entity.borrowerId,
      imageName: entity.imageName,
      rulesNotes: entity.rulesNotes,
      price: entity.price,
      condition: entity.condition,
      maxBorrowDuration: entity.maxBorrowDuration ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        categoryId,
        locationId,
        userId,
        description,
        availabilityStatus,
        borrowerId,
        imageName,
        rulesNotes,
        price,
        condition,
        maxBorrowDuration,
      ];
}
