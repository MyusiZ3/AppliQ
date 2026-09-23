import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/app_config.dart';
import 'core/constants/app_theme.dart';
import 'data/repositories/job_repository.dart';
import 'data/repositories/supabase_job_repository.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/main_nav.dart';
import 'presentation/screens/onboarding_screen.dart';
import 'presentation/widgets/appliq_loading.dart';
import 'services/notification_service.dart';
import 'utils/language_manager.dart';
import 'utils/navigator_key.dart';
import 'utils/theme_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment & configuration
  await AppConfig.initialize();

  // Parallel asynchronous initialization (Theme, Language, Notifications, Supabase)
  await Future.wait([
    ThemeManager.init(),
    LanguageManager.init(),
    NotificationService.instance.init(),
    if (AppConfig.isSupabaseConfigured)
      () async {
        try {
          await Supabase.initialize(
            url: AppConfig.supabaseUrl,
            anonKey: AppConfig.supabaseAnonKey,
          );
        } catch (_) {}
      }(),
  ]);

  final JobRepository repository = SupabaseJobRepository();

  runApp(AppliQApp(repository: repository));
}

class AppliQApp extends StatelessWidget {
  final JobRepository repository;

  const AppliQApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: LanguageManager.notifier,
      builder: (context, currentLanguage, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: ThemeManager.notifier,
          builder: (context, themeMode, _) {
            return ValueListenableBuilder<AccentThemeMode>(
              valueListenable: ThemeManager.accentNotifier,
              builder: (context, accentMode, _) {
                return MaterialApp(
                  title: 'AppliQ',
                  navigatorKey: navigatorKey,
                  debugShowCheckedModeBanner: false,
                  themeMode: themeMode,
                  theme: AppTheme.buildLightTheme(accentMode),
                  darkTheme: AppTheme.buildDarkTheme(accentMode),
                  home: AuthGate(repository: repository),
                );
              },
            );
          },
        );
      },
    );
  }
}

/// AuthGate memastikan Onboarding -> Login -> Main Navigation berjalan teratur
class AuthGate extends StatefulWidget {
  final JobRepository repository;

  const AuthGate({super.key, required this.repository});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _hasSeenOnboarding = false;
  bool _isChecking = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkInitialState();
  }

  Future<void> _checkInitialState() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('has_seen_onboarding') ?? false;
    final user = await widget.repository.getCurrentUserProfile();

    if (mounted) {
      setState(() {
        _hasSeenOnboarding = seen;
        _isLoggedIn = user != null;
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(
          child: AppliqLoading(isFullScreen: true),
        ),
      );
    }

    // 1. Jika sudah login -> Langsung ke Dashboard Utama (MainNav)
    if (_isLoggedIn) {
      return MainNav(repository: widget.repository);
    }

    // 2. Jika baru pertama install -> Tampilkan Onboarding
    if (!_hasSeenOnboarding) {
      return OnboardingScreen(repository: widget.repository);
    }

    // 3. Jika sudah pernah onboarding -> Tampilkan LoginScreen
    return LoginScreen(repository: widget.repository);
  }
}
