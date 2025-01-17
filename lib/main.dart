import 'package:circle_share/app/app.dart';
import 'package:circle_share/app/di/di.dart';
import 'package:circle_share/core/network/hive_service.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();

  // await HiveService().clearuserBox();

  await initDependencies();

  runApp(
    MyApp(),
  );
}
