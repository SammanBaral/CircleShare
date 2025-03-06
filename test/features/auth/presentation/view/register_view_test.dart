import 'dart:io';

import 'package:circle_share/features/auth/presentation/view/register_view.dart';
import 'package:circle_share/features/auth/presentation/view_model/signup/register_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:image_picker/image_picker.dart';

// Mock RegisterBloc to avoid real business logic execution
class MockRegisterBloc extends Mock implements RegisterBloc {}

void main() {
  late MockRegisterBloc mockRegisterBloc;

  setUp(() {
    mockRegisterBloc = MockRegisterBloc();
  });

  testWidgets('RegisterView renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: mockRegisterBloc,
          child: const RegisterView(),
        ),
      ),
    );

    // Check if the logo is displayed
    expect(find.byType(Image), findsOneWidget);

    // Check for the "Share and borrow items in your community" text
    expect(find.text("Share and borrow items in your community"), findsOneWidget);

    // Check if the "Create Account" button is displayed
    expect(find.text("Create Account"), findsOneWidget);
  });

  testWidgets('Form validation shows error when fields are empty', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: mockRegisterBloc,
          child: const RegisterView(),
        ),
      ),
    );

    // Tap the "Create Account" button
    await tester.tap(find.text("Create Account"));
    await tester.pump();

    // Check for error messages
    expect(find.text("First Name is required"), findsOneWidget);
    expect(find.text("Last Name is required"), findsOneWidget);
    expect(find.text("Phone number is required"), findsOneWidget);
    expect(find.text("Username is required"), findsOneWidget);
    expect(find.text("Password is required"), findsOneWidget);
    expect(find.text("Confirm Password is required"), findsOneWidget);
  });

  testWidgets('Form validation passes with valid data', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: mockRegisterBloc,
          child: const RegisterView(),
        ),
      ),
    );

    // Fill the form with valid data
    await tester.enterText(find.byType(TextFormField).at(0), 'John');
    await tester.enterText(find.byType(TextFormField).at(1), 'Doe');
    await tester.enterText(find.byType(TextFormField).at(2), '1234567890');
    await tester.enterText(find.byType(TextFormField).at(3), 'johndoe');
    await tester.enterText(find.byType(TextFormField).at(4), 'password123');
    await tester.enterText(find.byType(TextFormField).at(5), 'password123');

    // Tap the "Create Account" button
    await tester.tap(find.text("Create Account"));
    await tester.pump();

    // Check if form submission logic is triggered (e.g., RegisterBloc event)
    verify(() => mockRegisterBloc.add(any())).called(1);
  });

  // testWidgets('Image picker triggers the bottom sheet and picks an image', (WidgetTester tester) async {
  //   await tester.pumpWidget(
  //     MaterialApp(
  //       home: BlocProvider.value(
  //         value: mockRegisterBloc,
  //         child: const RegisterView(),
  //       ),
  //     ),
  //   );

  //   // Tap the profile image to open the bottom sheet
  //   await tester.tap(find.byType(CircleAvatar));
  //   await tester.pumpAndSettle();

  //   // Check if the bottom sheet is shown
  //   expect(find.byType(BottomSheet), findsOneWidget);

  //   // Tap on the "Camera" option
  //   await tester.tap(find.text('Camera'));
  //   await tester.pump();

  //   // Simulate image selection (you would mock this in your tests)
  //   final pickedImage = File('path/to/image.jpg');
  //   context.read<RegisterBloc>().add(UploadImage(file: pickedImage));

  //   // Check if the selected image is set
  //   expect(find.byType(CircleAvatar), findsOneWidget);
  // });

  testWidgets('Shows a snack bar when form validation fails', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: mockRegisterBloc,
          child: const RegisterView(),
        ),
      ),
    );

    // Tap the "Create Account" button
    await tester.tap(find.text("Create Account"));
    await tester.pump();

    // Check for snack bar showing a message
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
