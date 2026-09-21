import 'package:flutter_test/flutter_test.dart';
import 'package:appliq/presentation/screens/auth/login_screen.dart';
import 'package:appliq/presentation/screens/onboarding_screen.dart';
import 'package:appliq/presentation/screens/main_nav.dart';
import 'package:appliq/data/repositories/mock_job_repository.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('OnboardingScreen renders initial onboarding page', (WidgetTester tester) async {
    final mockRepo = MockJobRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingScreen(repository: mockRepo),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('AppliQ'), findsOneWidget);
    expect(find.text('Lewati'), findsOneWidget);
  });

  testWidgets('LoginScreen renders Google sign-in when unauthenticated', (WidgetTester tester) async {
    final mockRepo = MockJobRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(repository: mockRepo),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('AppliQ'), findsOneWidget);
    expect(find.text('Lanjutkan dengan Google'), findsOneWidget);
  });

  testWidgets('MainNav renders application tracker with capsule bar', (WidgetTester tester) async {
    final mockRepo = MockJobRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: MainNav(repository: mockRepo),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ringkasan Lamaran'), findsOneWidget);
  });
}
