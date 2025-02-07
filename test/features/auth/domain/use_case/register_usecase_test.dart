import 'package:circle_share/core/error/failure.dart';
import 'package:circle_share/features/auth/domain/entity/auth_entity.dart';
import 'package:circle_share/features/auth/domain/use_case/register_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'auth_repo.mock.dart';

void main() {
  late AuthRepoMock repository;
  late RegisterUseCase usecase;

  setUp(() {
    repository = AuthRepoMock();
    usecase = RegisterUseCase(repository);
    registerFallbackValue(AuthEntity(
      fName: 'John',
      lName: 'Doe',
      image: 'image_url',
      phone: '1234567890',
      username: 'johndoe',
      password: 'password123',
    ));
  });

  group('RegisterUseCase Tests', () {
    const params = RegisterUserParams(
      fname: 'John',
      lname: 'Doe',
      image: 'image_url',
      phone: '1234567890',
      username: 'johndoe',
      password: 'password123',
    );

    test('should register user successfully', () async {
      when(() => repository.registerUser(any())).thenAnswer(
        (_) async => const Right(null),
      );

      final result = await usecase(params);

      expect(result, const Right(null));
      verify(() => repository.registerUser(any())).called(1);
      verifyNoMoreInteractions(repository);
    });

    test('should return ApiFailure when user registration fails', () async {
      final failure = ApiFailure(message: "Registration failed");
      when(() => repository.registerUser(any())).thenAnswer(
        (_) async => Left(failure),
      );

      final result = await usecase(params);

      expect(result, Left(failure));

      verify(() => repository.registerUser(any())).called(1);
      verifyNoMoreInteractions(repository);
    });
  });
}
