part of 'item_bloc.dart';

class ItemState extends Equatable {
  final List<ItemEntity> items;
  final bool isLoading;
  final bool isSuccess;
  final String? error;

  final String? imageName; // ✅ New field for uploaded image

  const ItemState({
    required this.items,
    required this.isLoading,
    required this.isSuccess,
    this.error,
    this.imageName, // ✅ Initialize imageName (nullable)
  });

  factory ItemState.initial() {
    return const ItemState(
      items: [],
      isLoading: false,
      isSuccess: false,
      imageName: null, // ✅ Initial value for image
    );
  }

  ItemState copyWith({
    List<ItemEntity>? items,
    bool? isLoading,
    bool? isSuccess,
    String? error,
    String? imageName, // ✅ Allow updating image URL
  }) {
    return ItemState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
      imageName: imageName ?? this.imageName, // ✅ Preserve or update image URL
    );
  }

  @override
  List<Object?> get props => [
        items,
        isLoading,
        isSuccess,
        error,
        imageName
      ]; // ✅ Add imageUrl to props
}
