import 'package:circle_share/features/auth/presentation/view/login_view.dart';
import 'package:circle_share/features/on_board/presentation/view/onboard_screen_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('OnboardingView renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: OnboardingView(),
    ));

    expect(find.byType(OnboardingView), findsOneWidget);
  });

  testWidgets('First onboarding page displays correct content',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: OnboardingView(),
    ));

    expect(find.text('CircleShare'), findsOneWidget);
    expect(find.text('Share More, Own Less'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('Second onboarding page displays correct content',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: OnboardingView(),
    ));

    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('How It Works'), findsOneWidget);
    expect(find.text('Steps to Share & Borrow'), findsOneWidget);
  });

  testWidgets('Skip button skips onboarding and navigates to login',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: OnboardingView(),
    ));

    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);
  });

  testWidgets('Next button moves to the next page',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: OnboardingView(),
    ));

    expect(find.text('Next'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('How It Works'), findsOneWidget);
  });

  testWidgets('Finish button navigates to login on last page',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: OnboardingView(),
    ));

    await tester.pumpAndSettle();
    for (int i = 0; i < 4; i++) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }

    expect(find.text('Finish'), findsOneWidget);
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);
  });

  testWidgets('Finish button is displayed on the last page',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: OnboardingView(),
    ));

    await tester.pumpAndSettle();
    for (int i = 0; i < 4; i++) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }

    expect(find.text('Finish'), findsOneWidget);
  });

  testWidgets('Each onboarding page has a title and description',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: OnboardingView(),
    ));

    for (int i = 0; i < 5; i++) {
      expect(find.byType(Text), findsWidgets);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('PageView allows swiping between pages',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: OnboardingView(),
    ));

    expect(find.byType(PageView), findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(-300, 0));
    await tester.pumpAndSettle();

    expect(find.text('How It Works'), findsOneWidget);
  });

  testWidgets('Skip button navigates to login immediately',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: OnboardingView(),
    ));

    expect(find.text('Skip'), findsOneWidget);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);
  });
}
