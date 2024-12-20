import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String message, {Color? color}) {
  final snackBar = SnackBar(
    content: Text(
      message,
      style: TextStyle(color: Colors.white),
    ),
    backgroundColor: color ?? Colors.black,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    margin: EdgeInsets.all(16),
    duration: Duration(seconds: 3),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
