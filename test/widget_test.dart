import 'package:flutter_test/flutter_test.dart';
import 'package:appliq/presentation/screens/auth/login_screen.dart';
import 'package:appliq/presentation/screens/onboarding_screen.dart';
import 'package:appliq/presentation/screens/main_nav.dart';
import 'package:appliq/presentation/screens/applications/application_detail_screen.dart';
import 'package:appliq/presentation/screens/applications/application_form_screen.dart';
import 'package:appliq/presentation/screens/profile/profile_screen.dart';
import 'package:appliq/data/repositories/mock_job_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('OnboardingScreen renders initial onboarding page', (WidgetTester tester) async {
    final mockRepo = MockJobRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingScreen(repository: mockRepo),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

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
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('AppliQ'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
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

  testWidgets('ApplicationDetailScreen renders and navigates to edit form', (WidgetTester tester) async {
    final mockRepo = MockJobRepository();
    final apps = await mockRepo.getApplications();
    final firstApp = apps.first;

    await tester.pumpWidget(
      MaterialApp(
        home: ApplicationDetailScreen(
          applicationId: firstApp.id,
          repository: mockRepo,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(CupertinoIcons.pencil), findsOneWidget);

    await tester.tap(find.byIcon(CupertinoIcons.pencil));
    await tester.pumpAndSettle();

    expect(find.text('Edit Lamaran'), findsOneWidget);
  });

  testWidgets('ProfileScreen renders Settings and navigates to EditProfileScreen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final mockRepo = MockJobRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: ProfileScreen(repository: mockRepo),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Notifikasi Pengingat'), findsOneWidget);
    expect(find.text('Dark mode'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Log Out'), findsOneWidget);

    // Tap Profile card to open EditProfileScreen
    await tester.tap(find.text('Fajar Pratama'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
    expect(find.text('Delete Account'), findsOneWidget);
  });
}
