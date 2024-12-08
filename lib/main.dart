import 'package:circle_share/view/login_view.dart';
import 'package:flutter/material.dart';
// import 'package:first_flutter_apps/app.dart';
void main() {
  runApp(
    MaterialApp(
      initialRoute: '//',
      routes: {
        '//': (context) =>  LoginView(),

      },
    ),
  );
}

