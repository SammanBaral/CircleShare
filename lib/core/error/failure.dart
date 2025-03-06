import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

class LocalDatabaseFailure extends Failure {
  const LocalDatabaseFailure({required super.message});
}

class ApiFailure extends Failure {
  final int? statusCode;
  const ApiFailure({
    this.statusCode,
    required super.message,
  });
}

class SharedPrefsFailure extends Failure {
  const SharedPrefsFailure({
    required super.message,
  });
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}

class UnsupportedOperationFailure extends Failure {
  const UnsupportedOperationFailure({required super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}