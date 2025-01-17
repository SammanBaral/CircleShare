import 'package:circle_share/core/network/hive_service.dart';
import 'package:circle_share/features/auth/data/data_source/local_data_source/auth_local_datasource.dart';
import 'package:circle_share/features/auth/data/repository/auth_local_repository.dart';
import 'package:circle_share/features/auth/domain/use_case/login_usecase.dart';
import 'package:circle_share/features/auth/domain/use_case/register_usecase.dart';
import 'package:circle_share/features/auth/presentation/view_model/login/login_bloc.dart';
import 'package:circle_share/features/auth/presentation/view_model/signup/register_bloc.dart';
import 'package:circle_share/features/home/presentation/view_model/home_cubit.dart';
import 'package:circle_share/features/splash/presentation/view_model/splash_cubit.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  // First initialize hive service
  await _initHiveService();

  await _initHomeDependencies();
  await _initRegisterDependencies();
  await _initLoginDependencies();

  await _initSplashScreenDependencies();
}

_initHiveService() {
  getIt.registerLazySingleton<HiveService>(() => HiveService());
}

_initRegisterDependencies() {
  // init local data source
  getIt.registerLazySingleton(
    () => AuthLocalDataSource(getIt<HiveService>()),
  );

  // init local repository
  getIt.registerLazySingleton(
    () => AuthLocalRepository(getIt<AuthLocalDataSource>()),
  );

  // register use usecase
  getIt.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(
      getIt<AuthLocalRepository>(),
    ),
  );

  getIt.registerFactory<RegisterBloc>(
    () => RegisterBloc(
      registerUseCase: getIt(),
    ),
  );
}

// _initCourseDependencies() {
//   // Data Source
//   getIt.registerFactory<CourseLocalDataSource>(
//       () => CourseLocalDataSource(hiveService: getIt<HiveService>()));

//   // Repository
//   getIt.registerLazySingleton<CourseLocalRepository>(() =>
//       CourseLocalRepository(
//           courseLocalDataSource: getIt<CourseLocalDataSource>()));

//   // Usecases
// getIt.registerLazySingleton<CreateCourseUsecase>(
//   () => CreateCourseUsecase(
//     courseRepository: getIt<CourseLocalRepository>(),
//   ),
// );

// getIt.registerLazySingleton<GetAllCourseUsecase>(
//   () => GetAllCourseUsecase(
//     courseRepository: getIt<CourseLocalRepository>(),
//   ),
// );

// getIt.registerLazySingleton<DeleteCourseUsecase>(
//   () => DeleteCourseUsecase(
//     courseRepository: getIt<CourseLocalRepository>(),
//   ),
// );

// Bloc

//   getIt.registerFactory<CourseBloc>(
//     () => CourseBloc(
//       getAllCourseUsecase: getIt<GetAllCourseUsecase>(),
//       createCourseUsecase: getIt<CreateCourseUsecase>(),
//       deleteCourseUsecase: getIt<DeleteCourseUsecase>(),
//     ),
//   );
// }

// _initBatchDependencies() async {
//   // Data Source
//   getIt.registerFactory<BatchLocalDataSource>(
//       () => BatchLocalDataSource(hiveService: getIt<HiveService>()));

//   // Repository
//   getIt.registerLazySingleton<BatchLocalRepository>(() => BatchLocalRepository(
//       batchLocalDataSource: getIt<BatchLocalDataSource>()));

//   // Usecases
//   getIt.registerLazySingleton<CreateBatchUseCase>(
//     () => CreateBatchUseCase(batchRepository: getIt<BatchLocalRepository>()),
//   );

//   getIt.registerLazySingleton<GetAllBatchUseCase>(
//     () => GetAllBatchUseCase(batchRepository: getIt<BatchLocalRepository>()),
//   );

//   getIt.registerLazySingleton<DeleteBatchUsecase>(
//     () => DeleteBatchUsecase(batchRepository: getIt<BatchLocalRepository>()),
//   );

//   // Bloc
//   getIt.registerFactory<BatchBloc>(
//     () => BatchBloc(
//       createBatchUseCase: getIt<CreateBatchUseCase>(),
//       getAllBatchUseCase: getIt<GetAllBatchUseCase>(),
//       deleteBatchUsecase: getIt<DeleteBatchUsecase>(),
//     ),
//   );
// }

_initHomeDependencies() async {
  getIt.registerFactory<HomeCubit>(
    () => HomeCubit(),
  );
}

_initLoginDependencies() async {
  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(
      getIt<AuthLocalRepository>(),
    ),
  );

  getIt.registerFactory<LoginBloc>(
    () => LoginBloc(
      registerBloc: getIt<RegisterBloc>(),
      homeCubit: getIt<HomeCubit>(),
      loginUseCase: getIt<LoginUseCase>(),
    ),
  );
}

_initSplashScreenDependencies() async {
  getIt.registerFactory<SplashCubit>(
    () => SplashCubit(getIt<LoginBloc>()),
  );
}
