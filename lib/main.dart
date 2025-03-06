import 'package:circle_share/app/app.dart';
import 'package:circle_share/app/di/di.dart';
import 'package:circle_share/core/network/hive_service.dart';
import 'package:circle_share/features/category/presentation/view_model/category/category_bloc.dart';
import 'package:circle_share/features/items/presentation/view_model/item/item_bloc.dart';
import 'package:circle_share/features/location/presentation/view_model/location/location_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();

  // await HiveService().clearuserBox();

  await initDependencies();

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider<CategoryBloc>(
        create: (context) => getIt<CategoryBloc>()..add(LoadCategories()),
      ),
      BlocProvider<LocationBloc>(
        create: (context) => getIt<LocationBloc>()..add(LoadLocations()),
      ),
      BlocProvider<ItemBloc>(
        create: (context) => getIt<ItemBloc>(),
      ),
      // Add other BLoCs here
    ],
    child: MyApp(),
  ));
}
