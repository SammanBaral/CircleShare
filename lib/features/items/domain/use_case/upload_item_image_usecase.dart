import 'dart:io';

import 'package:circle_share/app/usecase/usecase.dart';
import 'package:circle_share/core/error/failure.dart';
import 'package:circle_share/features/items/domain/repository/item_repository.dart';
import 'package:dartz/dartz.dart';

class UploadItemImagesParams {
  final File image;

  const UploadItemImagesParams({
    required this.image,
  });
}

class UploadItemImagesUseCase
    implements UsecaseWithParams<String, UploadItemImagesParams> {
  final IItemRepository itemRepository;

  UploadItemImagesUseCase(this.itemRepository);

  @override
  Future<Either<Failure, String>> call(UploadItemImagesParams params) async {
    return await itemRepository.uploadItemImage(params.image);
  }
}
