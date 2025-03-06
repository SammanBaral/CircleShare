import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:circle_share/core/error/failure.dart';
import 'package:circle_share/features/auth/domain/use_case/register_usecase.dart';
import 'package:circle_share/features/auth/domain/use_case/upload_image_usecase.dart';
import 'package:circle_share/features/auth/presentation/view_model/signup/register_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockUploadImageUsecase extends Mock implements UploadImageUsecase {}

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  late RegisterBloc registerBloc;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockUploadImageUsecase mockUploadImageUsecase;
  late MockBuildContext mockContext;

  setUpAll(() {
    registerFallbackValue(const RegisterUserParams(
      fname: 'Test',
      lname: 'User',
      image: 'path/to/image',
      phone: '1234567890',
      username: 'testuser',
      password: 'password123',
    ));
    registerFallbackValue(UploadImageParams(file: File('path/to/image')));
  });

  setUp(() {
    mockRegisterUseCase = MockRegisterUseCase();
    mockUploadImageUsecase = MockUploadImageUsecase();
    mockContext = MockBuildContext();

    registerBloc = RegisterBloc(
      registerUseCase: mockRegisterUseCase,
      uploadImageUsecase: mockUploadImageUsecase,
    );
  });

  tearDown(() {
    registerBloc.close();
  });

  // // Test case for successful user registration
  // blocTest<RegisterBloc, RegisterState>(
  //   'emits [loading, success] when registration is successful',
  //   build: () {
  //     when(() => mockRegisterUseCase.call(any()))
  //         .thenAnswer((_) async => Right(null)); // Hardcode success response
  //     return registerBloc;
  //   },
  //   act: (bloc) => bloc.add(RegisterUser(
  //     context: mockContext,
  //     fName: 'Test',
  //     lName: 'User',
  //     image: 'path/to/image',
  //     phone: '1234567890',
  //     username: 'testuser',
  //     password: 'password123',
  //   )),
  //   expect: () => [
  //     RegisterState(isLoading: true, isSuccess: false),
  //     RegisterState(
  //         isLoading: false, isSuccess: true), // Hardcoded success state
  //   ],
  //   verify: (_) {
  //     verify(() => mockRegisterUseCase.call(any())).called(1);
  //   },
  // );

  // // Test case for failed user registration
  // blocTest<RegisterBloc, RegisterState>(
  //   'emits [loading, failure] when registration fails',
  //   build: () {
  //     when(() => mockRegisterUseCase.call(any())).thenAnswer(
  //         (_) async => Left(AuthFailure(message: 'Registration failed')));
  //     return registerBloc;
  //   },
  //   act: (bloc) => bloc.add(RegisterUser(
  //     context: mockContext,
  //     fName: 'Test',
  //     lName: 'User',
  //     image: 'path/to/image',
  //     phone: '1234567890',
  //     username: 'testuser',
  //     password: 'password123',
  //   )),
  //   expect: () => [
  //     RegisterState(isLoading: true, isSuccess: false),
  //     RegisterState(isLoading: false, isSuccess: false),
  //   ],
  //   verify: (_) {
  //     verify(() => mockRegisterUseCase.call(any())).called(1);
  //   },
  // );

  // Test case for successful image upload
  blocTest<RegisterBloc, RegisterState>(
    'emits [loading, success] when image upload is successful',
    build: () {
      when(() => mockUploadImageUsecase.call(any()))
          .thenAnswer((_) async => Right('uploaded_image.png'));
      return registerBloc;
    },
    act: (bloc) => bloc.add(UploadImage(
      file: File('path/to/image'),
    )),
    expect: () => [
      RegisterState(isLoading: true, isSuccess: false),
      RegisterState(
          isLoading: false, isSuccess: true, imageName: 'uploaded_image.png'),
    ],
    verify: (_) {
      verify(() => mockUploadImageUsecase.call(any())).called(1);
    },
  );

  // Test case for failed image upload
  blocTest<RegisterBloc, RegisterState>(
    'emits [loading, failure] when image upload fails',
    build: () {
      when(() => mockUploadImageUsecase.call(any())).thenAnswer(
          (_) async => Left(NetworkFailure(message: 'Image upload failed')));
      return registerBloc;
    },
    act: (bloc) => bloc.add(UploadImage(
      file: File('path/to/image'),
    )),
    expect: () => [
      RegisterState(isLoading: true, isSuccess: false),
      RegisterState(isLoading: false, isSuccess: false),
    ],
    verify: (_) {
      verify(() => mockUploadImageUsecase.call(any())).called(1);
    },
  );
}
