import 'package:equatable/equatable.dart';

class ItemEntity extends Equatable {
  final String? id;
  final String name;
  final String? categoryId;  // Changed to nullable
  final String? locationId;  // Changed to nullable
  final String? userId;
  final String? description;
  final String? availabilityStatus;  // Changed to nullable for better error handling
  final String? borrowerId;
  final String? imageName;
  final String? rulesNotes;
  final double price;
  final String? condition;
  final int maxBorrowDuration;

  const ItemEntity({
    this.id,
    required this.name,
    this.categoryId,  // Now optional
    this.locationId,  // Now optional
    this.userId,
    this.description,
    this.availabilityStatus = 'available',  // Default value
    this.borrowerId,
    this.imageName,
    this.rulesNotes,
    required this.price,
    this.condition,
    this.maxBorrowDuration = 0,  // Default value
  });

  ItemEntity copyWith({
    String? id,
    String? name,
    String? categoryId,
    String? locationId,
    String? userId,
    String? description,
    String? availabilityStatus,
    String? borrowerId,
    String? imageName,
    String? rulesNotes,
    double? price,
    String? condition,
    int? maxBorrowDuration,
  }) {
    return ItemEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      locationId: locationId ?? this.locationId,
      userId: userId ?? this.userId,
      description: description ?? this.description,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      borrowerId: borrowerId ?? this.borrowerId,
      imageName: imageName ?? this.imageName,
      rulesNotes: rulesNotes ?? this.rulesNotes,
      price: price ?? this.price,
      condition: condition ?? this.condition,
      maxBorrowDuration: maxBorrowDuration ?? this.maxBorrowDuration,
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