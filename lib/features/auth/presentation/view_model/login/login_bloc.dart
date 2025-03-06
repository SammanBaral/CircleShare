import 'package:circle_share/core/common/snackbar/my_snackbar.dart';
import 'package:circle_share/features/auth/domain/use_case/login_usecase.dart';
import 'package:circle_share/features/auth/presentation/view_model/signup/register_bloc.dart';
import 'package:circle_share/features/home/presentation/view/admin_page_view.dart';
import 'package:circle_share/features/home/presentation/view/dashboard_view.dart';
import 'package:circle_share/features/home/presentation/view_model/home_cubit.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final RegisterBloc _registerBloc;
  final LoginUseCase _loginUseCase;
  final HomeCubit _homeCubit;

  LoginBloc({
    required RegisterBloc registerBloc,
    required HomeCubit homeCubit,
    required LoginUseCase loginUseCase,
  })  : _registerBloc = registerBloc,
        _homeCubit = homeCubit,
        _loginUseCase = loginUseCase,
        super(LoginState.initial()) {
    on<NavigateRegisterScreenEvent>(
      (event, emit) {
        Navigator.push(
          event.context,
          MaterialPageRoute(
            builder: (context) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: _homeCubit),
              ],
              child: event.destination,
            ),
          ),
        );
      },
    );

    on<NavigateHomeScreenEvent>(
      (event, emit) {
        Navigator.pushReplacement(
          event.context,
          MaterialPageRoute(
            builder: (context) => BlocProvider.value(
              value: _registerBloc,
              child: event.destination,
            ),
          ),
        );
      },
    );

    // New event handler for navigating to admin page
    on<NavigateAdminScreenEvent>(
      (event, emit) {
        Navigator.push(
          event.context,
          MaterialPageRoute(
            builder: (context) => const AdminPage(),
          ),
        );
      },
    );

    // New event handler for logout
    on<LogoutRequested>(
      (event, emit) {
        print("LoginBloc: Logout requested");
        // Reset the state to initial (logged out state)
        emit(LoginState.initial());
        print("LoginBloc: State reset to initial");
      },
    );

    on<LoginUserEvent>(
      (event, emit) async {
        emit(state.copyWith(isLoading: true));

        // Directly check for hardcoded admin credentials
        if (event.username == "sir" && event.password == "sir@123") {
          print("Hardcoded admin detected! Redirecting to Admin Page...");
          emit(state.copyWith(isLoading: false, isSuccess: true));

          add(NavigateAdminScreenEvent(context: event.context));

          showMySnackBar(
            context: event.context,
            message: "Admin Login Successful",
          );
          return;
        }

        // Proceed with normal login flow
        final result = await _loginUseCase(
          LoginParams(
            username: event.username,
            password: event.password,
          ),
        );

        result.fold(
          (failure) {
            emit(state.copyWith(isLoading: false, isSuccess: false));
            showMySnackBar(
              context: event.context,
              message: "Invalid Credentials",
              color: Colors.red,
            );
          },
          (loginResponse) {
            emit(state.copyWith(isLoading: false, isSuccess: true));
            print("Login Response: $loginResponse");

            // Navigate regular users to the dashboard
            add(NavigateHomeScreenEvent(
              context: event.context,
              destination: DashboardView(),
            ));

            showMySnackBar(
              context: event.context,
              message: "Login Successful",
            );
          },
        );
      },
    );
  }

  bool _checkIfAdmin(String token) {
    try {
      // Decode the JWT token
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

      print("Decoded Token: $decodedToken"); // Debugging

      // Check if the role exists and is 'admin'
      if (decodedToken.containsKey('role')) {
        return decodedToken['role'] == 'admin';
      }
    } catch (e) {
      print("Error decoding token: $e");
    }
    return false; // Default to non-admin if role is not found
  }
}
