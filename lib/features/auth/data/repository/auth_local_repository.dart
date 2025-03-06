import 'dart:io';

import 'package:circle_share/core/error/failure.dart';
import 'package:circle_share/features/auth/data/data_source/local_data_source/auth_local_datasource.dart';
import 'package:circle_share/features/auth/domain/entity/auth_entity.dart';
import 'package:circle_share/features/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';

class AuthLocalRepository implements IAuthRepository {
  final AuthLocalDataSource _authLocalDataSource;

  AuthLocalRepository(this._authLocalDataSource);

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final currentUser = await _authLocalDataSource.getCurrentUser();
      return Right(currentUser);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> loginUser(
    String username,
    String password,
  ) async {
    try {
      final token = await _authLocalDataSource.loginUser(username, password);
      return Right(token);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> registerUser(AuthEntity user) async {
    try {
      return Right(_authLocalDataSource.registerUser(user));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfilePicture(File file) async {
    // TODO: implement uploadProfilePicture
    throw UnimplementedError();
  }

  //update user
  @override
  Future<Either<Failure, void>> updateUser(AuthEntity user) async {
    try {
      return Right(_authLocalDataSource.updateUser(user));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }   

  }

}
