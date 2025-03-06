part of 'item_bloc.dart';

@immutable
sealed class ItemEvent extends Equatable {
  const ItemEvent();

  @override
  List<Object> get props => [];
}

final class LoadItems extends ItemEvent {}

final class AddItem extends ItemEvent {
  final BuildContext context;
  final String name;
  final String categoryId;
  final String description;
  final String availabilityStatus;
  final String locationId;
  final String? borrowerId;
  final String? imageName; // ✅ Ensure this is set from state in Bloc
  final String? rulesNotes;
  final double price;
  final String condition;
  final int? maxBorrowDuration;

  const AddItem({
    required this.context,
    required this.name,
    required this.categoryId,
    required this.description,
    required this.availabilityStatus,
    required this.locationId,
    this.borrowerId,
    required this.imageName,
    this.rulesNotes,
    required this.price,
    required this.condition,
    this.maxBorrowDuration,
  });

  @override
  List<Object> get props => [
        name,
        categoryId,
        description,
        availabilityStatus,
        locationId,
        borrowerId ?? '',
        imageName ?? '',
        rulesNotes ?? '',
        price,
        condition,
        maxBorrowDuration ?? 0,
      ];
}

final class DeleteItem extends ItemEvent {
  final String itemId;

  const DeleteItem(this.itemId);

  @override
  List<Object> get props => [itemId];
}

final class UploadItemImage extends ItemEvent {
  // ✅ Added props override
  final File file;

  const UploadItemImage({required this.file});

  @override
  List<Object> get props => [file]; // ✅ Ensures correct event comparison
}
