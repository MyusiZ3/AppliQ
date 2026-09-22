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
import 'utils/navigator_key.dart';
import 'utils/theme_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment & configuration
  await AppConfig.initialize();

  // Initialize ThemeManager from SharedPreferences
  await ThemeManager.init();

  // Initialize Supabase if configured
  if (AppConfig.isSupabaseConfigured) {
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        anonKey: AppConfig.supabaseAnonKey,
      );
    } catch (_) {}
  }

  final JobRepository repository = SupabaseJobRepository();

  runApp(AppliQApp(repository: repository));
}

class AppliQApp extends StatelessWidget {
  final JobRepository repository;

  const AppliQApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager.notifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'AppliQ',
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: AuthGate(repository: repository),
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
  bool _isCheckingOnboarding = true;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('has_seen_onboarding') ?? false;
    setState(() {
      _hasSeenOnboarding = seen;
      _isCheckingOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingOnboarding) {
      return const Scaffold(
        body: AppliqLoading.fullscreen(),
      );
    }

    if (!_hasSeenOnboarding) {
      return OnboardingScreen(repository: widget.repository);
    }

    if (!AppConfig.isSupabaseConfigured) {
      return LoginScreen(repository: widget.repository);
    }

    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = Supabase.instance.client.auth.currentSession;

        if (session != null) {
          // User terautentikasi -> Masuk ke MainNav
          return MainNav(repository: widget.repository);
        }

        // Belum login -> Login Screen
        return LoginScreen(repository: widget.repository);
      },
    );
  }
}
