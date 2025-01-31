import 'package:circle_share/app/usecase/usecase.dart';
import 'package:circle_share/core/error/failure.dart';
import 'package:circle_share/features/auth/domain/entity/auth_entity.dart';
import 'package:circle_share/features/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class RegisterUserParams extends Equatable {
  final String fname;
  final String lname;
  final String? image;
  final String phone;
  final String username;
  final String password;

  const RegisterUserParams({
    required this.fname,
    required this.lname,
    required this.image,
    required this.phone,
    required this.username,
    required this.password,
  });

  //intial constructor
  const RegisterUserParams.initial({
    required this.fname,
    required this.lname,
    required this.image,
    required this.phone,
    required this.username,
    required this.password,
  });

  @override
  List<Object?> get props => [fname, lname, image, phone, username, password];
}

class RegisterUseCase implements UsecaseWithParams<void, RegisterUserParams> {
  final IAuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RegisterUserParams params) {
    final authEntity = AuthEntity(
      fName: params.fname,
      lName: params.lname,
      image: params.image,
      phone: params.phone,
      username: params.username,
      password: params.password,
    );
    return repository.registerUser(authEntity);
  }
}
