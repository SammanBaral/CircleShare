// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemApiModel _$ItemApiModelFromJson(Map<String, dynamic> json) => ItemApiModel(
      id: json['_id'] as String?,
      name: json['name'] as String,
      categoryId: ItemApiModel._parseIdField(json['categoryId']),
      locationId: ItemApiModel._parseIdField(json['locationId']),
      userId: ItemApiModel._parseIdField(json['userId']),
      description: json['description'] as String?,
      availabilityStatus: json['availabilityStatus'] as String? ?? 'available',
      borrowerId: ItemApiModel._parseIdField(json['borrowerId']),
      imageName: json['imageName'] as String?,
      rulesNotes: json['rulesNotes'] as String?,
      price:
          json['price'] == null ? 0.0 : ItemApiModel._parsePrice(json['price']),
      condition: json['condition'] as String?,
      maxBorrowDuration: json['maxBorrowDuration'] == null
          ? 0
          : ItemApiModel._parseInt(json['maxBorrowDuration']),
    );

Map<String, dynamic> _$ItemApiModelToJson(ItemApiModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'categoryId': instance.categoryId,
      'locationId': instance.locationId,
      'userId': instance.userId,
      'description': instance.description,
      'availabilityStatus': instance.availabilityStatus,
      'borrowerId': instance.borrowerId,
      'imageName': instance.imageName,
      'rulesNotes': instance.rulesNotes,
      'price': instance.price,
      'condition': instance.condition,
      'maxBorrowDuration': instance.maxBorrowDuration,
    };
