import 'dart:io';

import 'package:circle_share/core/error/failure.dart';
import 'package:circle_share/features/auth/domain/use_case/upload_image_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'auth_repo.mock.dart';

class MockFile extends Fake implements File {}

void main() {
  late AuthRepoMock repository;
  late UploadImageUsecase usecase;

  setUpAll(() {
    registerFallbackValue(MockFile());
  });

  setUp(() {
    repository = AuthRepoMock();
    usecase = UploadImageUsecase(repository);
  });

  final file = MockFile();

  group('UploadImageUsecase Tests', () {
    test(
      'should call the [AuthRepo.uploadProfilePicture] with the correct file',
      () async {
        when(() => repository.uploadProfilePicture(any())).thenAnswer(
          (_) async => const Right('Image uploaded successfully'),
        );

        final result = await usecase(UploadImageParams(file: file));

        expect(result, const Right('Image uploaded successfully'));

        verify(() => repository.uploadProfilePicture(any())).called(1);
        verifyNoMoreInteractions(repository);
      },
    );

    test('should return ApiFailure when image upload fails', () async {
      final failure = ApiFailure(message: "Image upload failed");
      when(() => repository.uploadProfilePicture(any())).thenAnswer(
        (_) async => Left(failure),
      );

      final params = UploadImageParams(file: file);
      final result = await usecase(params);

      expect(result, Left(failure));
      verify(() => repository.uploadProfilePicture(file)).called(1);
      verifyNoMoreInteractions(repository);
    });
  });

  tearDown(() {
    reset(repository);
  });
}
