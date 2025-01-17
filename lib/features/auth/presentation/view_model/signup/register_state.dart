part of 'register_bloc.dart';

class RegisterState extends Equatable {
  final bool isLoading;

  final bool isSuccess;

  final String message;

  const RegisterState({
    required this.isLoading,
    required this.isSuccess,
    required this.message,
  });

  factory RegisterState.initial() {
    return RegisterState(
      isLoading: false,
      isSuccess: false,
      message: '',
    );
  }

  RegisterState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? message,
  }) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      message: message ?? this.message,
    );
  }

  @override
  List<Object> get props => [isLoading, isSuccess, message];
}
