import 'package:circle_share/core/error/failure.dart';
import 'package:circle_share/features/auth/domain/use_case/login_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'auth_repo.mock.dart';
import 'token.mock.dart';

void main() {
  late AuthRepoMock repository;
  late MockTokenSharedPrefs tokenSharedPrefs;
  late LoginUseCase usecase;

  setUp(() {
    repository = AuthRepoMock();
    tokenSharedPrefs = MockTokenSharedPrefs();
    usecase = LoginUseCase(repository, tokenSharedPrefs);

    // Register fallback values
    registerFallbackValue(LoginParams(username: '', password: ''));
  });

  group('LoginUseCase Tests', () {
    test(
      'should call the [AuthRepo.loginUser] with correct username and password (exampleUser, examplePass)',
      () async {
        when(() => repository.loginUser(any(), any())).thenAnswer(
          (invocation) async {
            final username = invocation.positionalArguments[0] as String;
            final password = invocation.positionalArguments[1] as String;
            if (username == 'johndoe' && password == 'password123') {
              return const Right('token');
            } else {
              return const Left(
                  ApiFailure(message: 'Invalid username or password'));
            }
          },
        );

        when(() => tokenSharedPrefs.saveToken(any()))
            .thenAnswer((_) async => const Right<Failure, void>(null));

        when(() => tokenSharedPrefs.getToken())
            .thenAnswer((_) async => const Right<Failure, String>('token'));

        final result = await usecase(LoginParams(
          username: 'johndoe',
          password: 'password123',
        ));

        expect(result, const Right('token'));

        verify(() => repository.loginUser(any(), any())).called(1);
        verify(() => tokenSharedPrefs.saveToken(any())).called(1);
        verify(() => tokenSharedPrefs.getToken())
            .called(1); // Verify the getToken call

        verifyNoMoreInteractions(repository);
        verifyNoMoreInteractions(tokenSharedPrefs);
      },
    );

    test("should return ApiFailure when credentials are invalid", () async {
      when(() => repository.loginUser(any(), any()))
          .thenAnswer((invocation) async {
        final username = invocation.positionalArguments[0] as String;
        final password = invocation.positionalArguments[1] as String;

        if (username != "exampleUser" || password != "examplePass") {
          return Left(ApiFailure(message: "invalid username or password"));
        } else {
          return const Right('token');
        }
      });

      final result = await usecase(
          const LoginParams(username: "wrongUser", password: "wrongpass"));

      expect(
        result,
        isA<Left<Failure, String>>().having(
          (l) => (l as Left).value.message,
          'message',
          equals("invalid username or password"),
        ),
      );

      verify(() => repository.loginUser("wrongUser", "wrongpass")).called(1);
      verifyNever(() => tokenSharedPrefs.saveToken(any()));
      verifyNever(() => tokenSharedPrefs.getToken());

      verifyNoMoreInteractions(repository);
      verifyNoMoreInteractions(tokenSharedPrefs);
    });
  });

  tearDown(() {
    reset(repository);
    reset(tokenSharedPrefs);
  });
}
