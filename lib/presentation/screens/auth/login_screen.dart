import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_strings.dart';
import '../../../data/repositories/job_repository.dart';
import '../../../utils/ui_helper.dart';
import '../../widgets/animated_logo_mascot.dart';
import '../../widgets/google_logo.dart';
import '../main_nav.dart';

class LoginScreen extends StatefulWidget {
  final JobRepository repository;

  const LoginScreen({super.key, required this.repository});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    try {
      await widget.repository.signInWithGoogle();
      final user = await widget.repository.getCurrentUserProfile();
      if (user != null && mounted) {
        UIHelper.showSuccessSnackBar(
            context, AppStrings.welcomeUser(user.fullName));
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => MainNav(repository: widget.repository),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        UIHelper.handleError(context, e);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showPolicySheet(String title, String content) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    HapticFeedback.lightImpact();

    UIHelper.showPremiumBottomSheet(
      context: context,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.xmark_circle_fill, size: 22),
                  color: isDark ? AppColors.textHintDark : AppColors.textHint,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.55,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Google Sign in button colors matching official design
    final googleBtnBg = isDark ? const Color(0xFF131314) : Colors.white;
    final googleBtnBorder =
        isDark ? const Color(0xFF3C4043) : const Color(0xFF747775);
    final googleBtnText =
        isDark ? const Color(0xFFE3E3E3) : const Color(0xFF1F1F1F);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Mascot Animation (Video anim -> Fade to static logo for 4s -> Repeat)
                const Center(
                  child: AnimatedLogoMascot(
                    size: 150,
                  ),
                ),

                const SizedBox(height: 24),

                // App Brand Name
                Text(
                  'AppliQ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                    letterSpacing: -1.2,
                  ),
                ),
                const SizedBox(height: 8),

                // Tagline / Subtitle
                Text(
                  AppStrings.loginTagline,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.5,
                    height: 1.45,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    letterSpacing: -0.2,
                  ),
                ),

                const SizedBox(height: 48),

                // Official Google "Sign in with Google" Pill Button
                Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: googleBtnBg,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: googleBtnBorder, width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: isDark ? 0.35 : 0.06),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isLoading ? null : _handleGoogleSignIn,
                      borderRadius: BorderRadius.circular(100),
                      child: Center(
                        child: _isLoading
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: googleBtnText,
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const GoogleLogo(size: 22),
                                  const SizedBox(width: 12),
                                  Text(
                                    AppStrings.signInWithGoogle,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.2,
                                      color: googleBtnText,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // Clickable Terms of Service & Privacy Policy Note
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          AppStrings.termsPrefix,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textHintDark
                                : AppColors.textHint,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showPolicySheet(
                            AppStrings.termsOfService,
                            AppStrings.termsContent,
                          ),
                          child: Text(
                            AppStrings.termsOfService,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF18181B),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        Text(
                          AppStrings.andConjunction,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textHintDark
                                : AppColors.textHint,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showPolicySheet(
                            AppStrings.privacyPolicy,
                            AppStrings.privacyContent,
                          ),
                          child: Text(
                            AppStrings.privacyPolicy,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF18181B),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        Text(
                          '.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textHintDark
                                : AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
