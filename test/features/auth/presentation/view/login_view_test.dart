import 'package:circle_share/features/auth/presentation/view/login_view.dart';
import 'package:circle_share/features/auth/presentation/view_model/login/login_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock the LoginBloc to avoid actual login logic during tests
class MockLoginBloc extends Mock implements LoginBloc {}

void main() {
  late MockLoginBloc mockLoginBloc;

  setUp(() {
    mockLoginBloc = MockLoginBloc();
  });

  testWidgets('LoginView renders correctly and contains all required elements', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<LoginBloc>(
          create: (_) => mockLoginBloc,
          child: LoginView(),
        ),
      ),
    );

    // Check if the logo is displayed
    expect(find.byType(Image), findsOneWidget);

    // Check if the login form fields are rendered
    expect(find.byType(TextFormField), findsNWidgets(2)); // Username and Password fields
    expect(find.byType(ElevatedButton), findsOneWidget); // Login button
    expect(find.byType(TextButton), findsOneWidget); // Forgot Password button
    expect(find.byType(OutlinedButton), findsOneWidget); // Sign Up button
  });

  testWidgets('Form validation fails when username or password is empty', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<LoginBloc>(
          create: (_) => mockLoginBloc,
          child: LoginView(),
        ),
      ),
    );

    // Tap on the login button without filling in the form
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Check if error messages are shown
    expect(find.text('Username cannot be empty'), findsOneWidget);
    expect(find.text('Password cannot be empty'), findsOneWidget);
  });

  // testWidgets('Login button triggers LoginUserEvent when form is valid', (WidgetTester tester) async {
  //   // Setup mock response for the login event
  //   when(() => mockLoginBloc.add(any())).thenReturn(null);

  //   await tester.pumpWidget(
  //     MaterialApp(
  //       home: BlocProvider<LoginBloc>(
  //         create: (_) => mockLoginBloc,
  //         child: LoginView(),
  //       ),
  //     ),
  //   );

  //   // Enter valid credentials
  //   await tester.enterText(find.byType(TextFormField).first, 'testuser');
  //   await tester.enterText(find.byType(TextFormField).last, 'password123');

  //   // Tap on the login button
  //   await tester.tap(find.byType(ElevatedButton));
  //   await tester.pump();

  //   // Check if the LoginUserEvent was triggered
  //   verify(() => mockLoginBloc.add(LoginUserEvent(
  //     context: any(named: 'context'),
  //     username: 'testuser',
  //     password: 'password123',
  //   ))).called(1);
  // });

  testWidgets('SnackBar is shown when form is invalid', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<LoginBloc>(
          create: (_) => mockLoginBloc,
          child: LoginView(),
        ),
      ),
    );

    // Tap on the login button without filling in the form
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Verify that a snack bar is shown with the expected message
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Please correct errors in the form'), findsOneWidget);
  });
}
