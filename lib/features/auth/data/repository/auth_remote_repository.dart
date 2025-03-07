import 'dart:io';

import 'package:circle_share/core/error/failure.dart';
import 'package:circle_share/features/auth/data/data_source/remote_data_source/auth_remote_datasource.dart';
import 'package:circle_share/features/auth/domain/entity/auth_entity.dart';
import 'package:circle_share/features/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';

class AuthRemoteRepository implements IAuthRepository {
  final AuthRemoteDataSource _authRemoteDataSource;

  AuthRemoteRepository(this._authRemoteDataSource);

  @override
  Future<Either<Failure, void>> registerUser(AuthEntity user) async {
    try {
      await _authRemoteDataSource.registerUser(user);
      return Right(null);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() {
    // TODO: implement getCurrentUser
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, String>> loginUser(
      String username, String password) async {
    try {
      final token = await _authRemoteDataSource.loginUser(username, password);
      return Right(token);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfilePicture(File file) async {
    try {
      final imageName = await _authRemoteDataSource.uploadProfilePicture(file);
      return Right(imageName);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  //update user
  @override
  Future<Either<Failure, void>> updateUser(AuthEntity user) async {
    try {
      // If AuthRemoteDataSource.updateUser expects a String (likely userId)
      // then we need to extract the userId from the AuthEntity
      if (user.userId == null) {
        return Left(ApiFailure(message: "User ID is required for update"));
      }

      // This assumes your datasource expects the userId and then the user data separately
      await _authRemoteDataSource.updateUser(user.userId!, user);
      return Right(null);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
