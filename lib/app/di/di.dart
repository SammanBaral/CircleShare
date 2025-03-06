import 'package:circle_share/app/shared_prefs/token_shared_prefs.dart';
import 'package:circle_share/core/common/internet_checker/connectivity_checker.dart';
import 'package:circle_share/core/network/api_service.dart';
import 'package:circle_share/core/network/hive_service.dart';
import 'package:circle_share/features/auth/data/data_source/local_data_source/auth_local_datasource.dart';
import 'package:circle_share/features/auth/data/data_source/remote_data_source/auth_remote_datasource.dart';
import 'package:circle_share/features/auth/data/repository/auth_local_repository.dart';
import 'package:circle_share/features/auth/data/repository/auth_remote_repository.dart';
import 'package:circle_share/features/auth/domain/use_case/login_usecase.dart';
import 'package:circle_share/features/auth/domain/use_case/register_usecase.dart';
import 'package:circle_share/features/auth/domain/use_case/upload_image_usecase.dart';
import 'package:circle_share/features/auth/presentation/view_model/login/login_bloc.dart';
import 'package:circle_share/features/auth/presentation/view_model/signup/register_bloc.dart';
import 'package:circle_share/features/category/data/data_source/local_data_source/category_local_datasource.dart';
import 'package:circle_share/features/category/data/data_source/remote_data_source/category_remote_datasource.dart';
import 'package:circle_share/features/category/data/repository/category_local_repository.dart';
import 'package:circle_share/features/category/data/repository/category_proxy_repository.dart';
import 'package:circle_share/features/category/data/repository/category_remote_repository.dart';
import 'package:circle_share/features/category/domain/repository/category_repository.dart';
import 'package:circle_share/features/category/domain/use_case/add_category_usecase.dart';
import 'package:circle_share/features/category/domain/use_case/delete_category_usecase.dart';
import 'package:circle_share/features/category/domain/use_case/get_all_categories_usecase.dart';
import 'package:circle_share/features/category/presentation/view_model/category/category_bloc.dart';
import 'package:circle_share/features/home/presentation/view_model/home_cubit.dart';
import 'package:circle_share/features/items/data/data_source/local_data_source/item_local_datasource.dart';
import 'package:circle_share/features/items/data/data_source/remote_data_source/item_remote_datasource.dart';
import 'package:circle_share/features/items/data/repository/item_local_repository.dart';
import 'package:circle_share/features/items/data/repository/item_remote_repository.dart'
    as repo;
import 'package:circle_share/features/items/data/repository/item_repository_proxy.dart';
import 'package:circle_share/features/items/domain/repository/item_repository.dart';
import 'package:circle_share/features/items/domain/use_case/add_item_usecase.dart';
import 'package:circle_share/features/items/domain/use_case/delete_item_usecase.dart';
import 'package:circle_share/features/items/domain/use_case/get_item_usecase.dart';
import 'package:circle_share/features/items/domain/use_case/get_user_item_usecase.dart';
import 'package:circle_share/features/items/domain/use_case/upload_item_image_usecase.dart';
import 'package:circle_share/features/items/presentation/view_model/item/item_bloc.dart';
import 'package:circle_share/features/location/data/data_source/local_data_source/location_local_datasource.dart';
import 'package:circle_share/features/location/data/data_source/remote_data_source/location_remote_datasource.dart';
import 'package:circle_share/features/location/data/repository/location_local_repository.dart';
import 'package:circle_share/features/location/data/repository/location_proxy_repository.dart';
import 'package:circle_share/features/location/data/repository/location_remote_repository.dart';
import 'package:circle_share/features/location/domain/repository/location_repository.dart';
import 'package:circle_share/features/location/domain/use_case/add_location_usecase.dart';
import 'package:circle_share/features/location/domain/use_case/delete_location_usecase.dart';
import 'package:circle_share/features/location/domain/use_case/get_all_location_usecase.dart';
import 'package:circle_share/features/location/presentation/view_model/location/location_bloc.dart';
import 'package:circle_share/features/splash/presentation/view_model/splash_cubit.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  // First initialize Hive and Shared Preferences
  await _initHiveService();
  await _initSharedPreferences();

  // Register core services (including ConnectivityListener)
  _initCoreServices();

  // Register TokenSharedPrefs early
  getIt.registerLazySingleton<TokenSharedPrefs>(
      () => TokenSharedPrefs(getIt<SharedPreferences>()));

  // Then initialize API service (which depends on TokenSharedPrefs)
  await _initApiService();

  // Auth Dependencies
  await _initHomeDependencies();
  await _initRegisterDependencies();
  await _initLoginDependencies();
  await _initSplashScreenDependencies();

  // New: Item, Category, and Location Dependencies
  _initItemDependencies();
  _initCategoryDependencies();
  _initLocationDependencies();
}

// New method to initialize core services
void _initCoreServices() {
  // Register ConnectivityChecker
  getIt.registerLazySingleton<ConnectivityListener>(
      () => ConnectivityListener());
}

Future<void> _initSharedPreferences() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
}

_initApiService() {
  // Create ApiService with token support
  getIt.registerLazySingleton<Dio>(
      () => ApiService(Dio(), tokenPrefs: getIt<TokenSharedPrefs>()).dio);
}

_initHiveService() {
  getIt.registerLazySingleton<HiveService>(() => HiveService());
}

_initRegisterDependencies() {
  // Local data source for Auth
  getIt.registerLazySingleton(() => AuthLocalDataSource(getIt<HiveService>()));

  // Remote data source for Auth - Updated to include TokenSharedPrefs
  getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(getIt<Dio>(), getIt<TokenSharedPrefs>()));

  // Repositories for Auth
  getIt.registerLazySingleton(
      () => AuthLocalRepository(getIt<AuthLocalDataSource>()));
  getIt.registerLazySingleton<AuthRemoteRepository>(
      () => AuthRemoteRepository(getIt<AuthRemoteDataSource>()));

  // Use Cases for Auth
  getIt.registerLazySingleton<RegisterUseCase>(
      () => RegisterUseCase(getIt<AuthRemoteRepository>()));
  getIt.registerLazySingleton<UploadImageUsecase>(
      () => UploadImageUsecase(getIt<AuthRemoteRepository>()));

  // Bloc for Auth
  getIt.registerFactory<RegisterBloc>(() => RegisterBloc(
        registerUseCase: getIt(),
        uploadImageUsecase: getIt(),
      ));
}

_initHomeDependencies() async {
  getIt.registerFactory<HomeCubit>(() => HomeCubit());
}

_initLoginDependencies() async {
  // getIt.registerLazySingleton<TokenSharedPrefs>(
  //     () => TokenSharedPrefs(getIt<SharedPreferences>()));
  getIt.registerLazySingleton<LoginUseCase>(() =>
      LoginUseCase(getIt<AuthRemoteRepository>(), getIt<TokenSharedPrefs>()));

  getIt.registerFactory<LoginBloc>(() => LoginBloc(
        registerBloc: getIt<RegisterBloc>(),
        homeCubit: getIt<HomeCubit>(),
        loginUseCase: getIt<LoginUseCase>(),
      ));
}

_initSplashScreenDependencies() async {
  getIt.registerFactory<SplashCubit>(() => SplashCubit(getIt<LoginBloc>()));
}

// -------------------- ITEM Dependencies --------------------
void _initItemDependencies() {
  // Local Data Source
  getIt.registerLazySingleton<ItemLocalDataSource>(
      () => ItemLocalDataSource(getIt<HiveService>()));

  // Remote Data Source
  getIt.registerLazySingleton<ItemRemoteDataSource>(() => ItemRemoteDataSource(
        dio: getIt<Dio>(),
        tokenPrefs: getIt<TokenSharedPrefs>(),
        userDataSource: getIt<AuthRemoteDataSource>(),
      ));

  // Register local repository
  getIt.registerLazySingleton<ItemLocalRepository>(() => ItemLocalRepository(
      getIt<ItemLocalDataSource>(), getIt<AuthLocalDataSource>()));

  // Register remote repository
  getIt.registerLazySingleton<repo.ItemRemoteRepository>(
    () => repo.ItemRemoteRepository(
      remoteDataSource: getIt<ItemRemoteDataSource>(),
      authDataSource: getIt<AuthRemoteDataSource>(),
    ),
  );

  // Register Repository Proxy as the implementation for IItemRepository
  getIt.registerLazySingleton<IItemRepository>(() => ItemRepositoryProxy(
        connectivityListener: getIt<ConnectivityListener>(),
        remoteRepository: getIt<repo.ItemRemoteRepository>(),
        localRepository: getIt<ItemLocalRepository>(),
      ));

  // Use Cases
  getIt.registerLazySingleton<AddItemUseCase>(
      () => AddItemUseCase(itemRepository: getIt<IItemRepository>()));
  getIt.registerLazySingleton<GetAllItemsUseCase>(
      () => GetAllItemsUseCase(itemRepository: getIt<IItemRepository>()));
  getIt.registerLazySingleton<DeleteItemUseCase>(
      () => DeleteItemUseCase(itemRepository: getIt<IItemRepository>()));
  getIt.registerLazySingleton<UploadItemImagesUseCase>(
      () => UploadItemImagesUseCase(getIt<IItemRepository>()));

  // Add new use cases for user-specific items
  getIt.registerLazySingleton<GetUserItemsUseCase>(
      () => GetUserItemsUseCase(itemRepository: getIt<IItemRepository>()));
  getIt.registerLazySingleton<GetBorrowedItemsUseCase>(
      () => GetBorrowedItemsUseCase(itemRepository: getIt<IItemRepository>()));

  // Bloc
  getIt.registerFactory<ItemBloc>(() => ItemBloc(
        addItemUseCase: getIt<AddItemUseCase>(),
        getAllItemUseCase: getIt<GetAllItemsUseCase>(),
        deleteItemUseCase: getIt<DeleteItemUseCase>(),
        uploadItemImageUseCase: getIt<UploadItemImagesUseCase>(),
      ));
}

// -------------------- CATEGORY Dependencies --------------------
void _initCategoryDependencies() {
  // Local data source for category
  getIt.registerLazySingleton<CategoryLocalDataSource>(
      () => CategoryLocalDataSource(getIt<HiveService>()));

  // Remote data source for category
  getIt.registerLazySingleton<CategoryRemoteDataSource>(
      () => CategoryRemoteDataSource(getIt<Dio>()));

  // Repository for category
  getIt.registerLazySingleton<CategoryRemoteRepository>(() =>
      CategoryRemoteRepository(
          remoteDataSource: getIt<CategoryRemoteDataSource>()));

  getIt.registerLazySingleton(
      () => CategoryLocalRepository(getIt<CategoryLocalDataSource>()));

  // THIS IS THE MISSING PART - Register one of your repositories as the ICategoryRepository
  // For Category
  getIt
      .registerLazySingleton<ICategoryRepository>(() => CategoryRepositoryProxy(
            connectivityListener: getIt<ConnectivityListener>(),
            remoteRepository: getIt<CategoryRemoteRepository>(),
            localRepository: getIt<CategoryLocalRepository>(),
          ));
  // Use cases for category
  getIt.registerLazySingleton<AddCategoryUseCase>(() =>
      AddCategoryUseCase(categoryRepository: getIt<ICategoryRepository>()));

  getIt.registerLazySingleton<GetAllCategoriesUseCase>(() =>
      GetAllCategoriesUseCase(
          categoryRepository: getIt<ICategoryRepository>()));

  getIt.registerLazySingleton<DeleteCategoryUseCase>(() =>
      DeleteCategoryUseCase(categoryRepository: getIt<ICategoryRepository>()));

  // Bloc for category
  getIt.registerFactory<CategoryBloc>(() => CategoryBloc(
        addCategoryUseCase: getIt<AddCategoryUseCase>(),
        getAllCategoryUseCase: getIt<GetAllCategoriesUseCase>(),
        deleteCategoryUseCase: getIt<DeleteCategoryUseCase>(),
      ));
}

// -------------------- LOCATION Dependencies --------------------
void _initLocationDependencies() {
  // Local data source for location
  getIt.registerLazySingleton<LocationLocalDataSource>(
      () => LocationLocalDataSource(getIt<HiveService>()));

  // Remote data source for location
  getIt.registerLazySingleton<LocationRemoteDataSource>(
      () => LocationRemoteDataSource(getIt<Dio>()));

  // Repository for location
  getIt.registerLazySingleton<LocationRemoteRepository>(() =>
      LocationRemoteRepository(
          remoteDataSource: getIt<LocationRemoteDataSource>()));

  getIt.registerLazySingleton(
      () => LocationLocalRepository(getIt<LocationLocalDataSource>()));

  // Register LocationRemoteRepository as the implementation for ILocationRepository
  // For Location
  getIt
      .registerLazySingleton<ILocationRepository>(() => LocationRepositoryProxy(
            connectivityListener: getIt<ConnectivityListener>(),
            remoteRepository: getIt<LocationRemoteRepository>(),
            localRepository: getIt<LocationLocalRepository>(),
          )); // Choose remote or local based on your needs

  // Use cases for location
  getIt.registerLazySingleton<AddLocationUseCase>(() =>
      AddLocationUseCase(locationRepository: getIt<ILocationRepository>()));

  getIt.registerLazySingleton<GetAllLocationUseCase>(() =>
      GetAllLocationUseCase(locationRepository: getIt<ILocationRepository>()));

  getIt.registerLazySingleton<DeleteLocationUseCase>(() =>
      DeleteLocationUseCase(locationRepository: getIt<ILocationRepository>()));

  // Bloc for location
  getIt.registerFactory<LocationBloc>(() => LocationBloc(
        addLocationUseCase: getIt<AddLocationUseCase>(),
        getAllLocationUseCase: getIt<GetAllLocationUseCase>(),
        deleteLocationUseCase: getIt<DeleteLocationUseCase>(),
      ));
}
