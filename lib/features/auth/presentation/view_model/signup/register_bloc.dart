import 'package:bloc/bloc.dart';
import 'package:circle_share/core/common/snackbar/my_snackbar.dart';
import 'package:circle_share/features/auth/domain/use_case/register_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'register_event.dart';
part 'register_state.dart';

// RegisterBloc (updated)
class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final RegisterUseCase _registerUseCase;

  RegisterBloc({
    required RegisterUseCase registerUseCase,
  })  : _registerUseCase = registerUseCase,
        super(RegisterState.initial()) {
    on<RegisterUser>(_onRegisterEvent);
  }

  void _onRegisterEvent(
    RegisterUser event,
    Emitter<RegisterState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final result = await _registerUseCase.call(RegisterUserParams(
      fname: event.fName,
      lname: event.lName,
      phone: event.phone,
      username: event.username,
      password: event.password,
    ));

    result.fold(
      (l) => emit(state.copyWith(
          isLoading: false, isSuccess: false, message: "Registration Failed")),
      (r) {
        emit(state.copyWith(
            isLoading: false,
            isSuccess: true,
            message: "Registration Successful"));
        showMySnackBar(context: event.context, message: "Register Successful");
      },
    );
  }
}
