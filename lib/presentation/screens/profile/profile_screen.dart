import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_strings.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/repositories/job_repository.dart';
import '../../../services/notification_service.dart';
import '../../../utils/language_manager.dart';
import '../../../utils/theme_manager.dart';
import '../../../utils/ui_helper.dart';
import '../../widgets/app_avatar.dart';
import '../../widgets/appliq_loading.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';
import 'resume_builder_screen.dart';

class ProfileScreen extends StatefulWidget {
  final JobRepository repository;

  const ProfileScreen({super.key, required this.repository});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _profile;
  bool _isLoading = true;
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'Bahasa Indonesia';
  bool _hapticFeedbackEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadProfile();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final isPaused = prefs.getBool('pause_notifications') ?? false;
    if (mounted) {
      setState(() {
        _notificationsEnabled = !isPaused;
        _selectedLanguage = prefs.getString('app_language') ?? 'Bahasa Indonesia';
        _hapticFeedbackEnabled = prefs.getBool('general_haptic') ?? true;
      });
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    _triggerHaptic();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pause_notifications', !value);
    if (mounted) {
      setState(() => _notificationsEnabled = value);
    }

    if (value) {
      final granted = await NotificationService.instance.requestPermissions();
      if (mounted) {
        if (granted) {
          UIHelper.showSuccessSnackBar(context, 
              LanguageManager.isEnglish 
                  ? 'Agenda reminder notifications enabled.' 
                  : 'Notifikasi pengingat agenda diaktifkan.');
        } else {
          UIHelper.showInfoSnackBar(context, 
              LanguageManager.isEnglish ? 'Notifications enabled.' : 'Notifikasi diaktifkan.');
        }
      }
    } else {
      await NotificationService.instance.cancelAll();
      if (mounted) {
        UIHelper.showInfoSnackBar(context, 
            LanguageManager.isEnglish 
                ? 'Reminder notifications disabled.' 
                : 'Notifikasi pengingat dinonaktifkan.');
      }
    }
  }

  void _triggerHaptic() {
    if (_hapticFeedbackEnabled) {
      HapticFeedback.selectionClick();
    }
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = await widget.repository.getCurrentUserProfile();
      if (mounted) {
        setState(() {
          _profile = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        UIHelper.handleError(context, e);
      }
    }
  }

  void _showLanguageSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF202024) : const Color(0xFFF4F4F5);
    final borderColor = isDark ? const Color(0xFF27272A) : AppColors.borderLight;

    final languages = [
      {
        'name': 'Bahasa Indonesia',
        'code': 'id',
        'subtitle': AppStrings.languageIdSubtitle,
        'badge': LanguageManager.isIndonesian ? 'Aktif' : 'Default',
        'icon': '🇮🇩',
        'locked': false,
      },
      {
        'name': 'English',
        'code': 'en',
        'subtitle': AppStrings.languageEnSubtitle,
        'badge': 'Global',
        'icon': '🇺🇸',
        'locked': false,
      },
      {
        'name': '日本語',
        'code': 'ja',
        'subtitle': AppStrings.languageJaSubtitle,
        'badge': 'Nihongo',
        'icon': '🇯🇵',
        'locked': false,
      },
      {
        'name': '한국어',
        'code': 'ko',
        'subtitle': AppStrings.languageKoSubtitle,
        'badge': 'Hangugeo',
        'icon': '🇰🇷',
        'locked': false,
      },
    ];

    final currentLang = LanguageManager.current;

    UIHelper.showPremiumBottomSheet(
      context: context,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.languageModalTitle,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppStrings.languageModalSubtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark ? AppColors.textHintDark : AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.xmark_circle_fill, size: 22),
                  color: isDark ? AppColors.textHintDark : AppColors.textHint,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...languages.map((lang) {
              final isLocked = lang['locked'] == true;
              final isSelected = currentLang.name == lang['code'];

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () async {
                    _triggerHaptic();
                    if (isLocked) {
                      UIHelper.showInfoSnackBar(context, AppStrings.languageComingSoonToast);
                      return;
                    }

                    AppLanguage targetLang = AppLanguage.id;
                    if (lang['code'] == 'en') targetLang = AppLanguage.en;
                    if (lang['code'] == 'ja') targetLang = AppLanguage.ja;
                    if (lang['code'] == 'ko') targetLang = AppLanguage.ko;

                    await LanguageManager.setLanguage(targetLang);
                    setState(() => _selectedLanguage = lang['name'] as String);
                    if (mounted) Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7))
                          : (isLocked ? (isDark ? const Color(0xFF18181B) : const Color(0xFFFAFAFA)) : cardBg),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? (isDark ? Colors.white : const Color(0xFF18181B))
                            : borderColor,
                        width: isSelected ? 1.5 : 0.8,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          lang['icon'] as String,
                          style: TextStyle(
                            fontSize: 22,
                            color: isLocked ? Colors.grey.withValues(alpha: 0.6) : null,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      lang['name'] as String,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                        color: isLocked
                                            ? (isDark ? AppColors.textHintDark : AppColors.textHint)
                                            : (isDark ? Colors.white : const Color(0xFF18181B)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isLocked
                                          ? (isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5))
                                          : (isDark ? const Color(0xFF3F3F46) : const Color(0xFFE4E4E7)),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (isLocked) ...[
                                          Icon(
                                            CupertinoIcons.lock_fill,
                                            size: 9,
                                            color: isDark ? AppColors.textHintDark : AppColors.textHint,
                                          ),
                                          const SizedBox(width: 3),
                                        ],
                                        Text(
                                          lang['badge'] as String,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: isLocked
                                                ? (isDark ? AppColors.textHintDark : AppColors.textHint)
                                                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                lang['subtitle'] as String,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppColors.textHintDark : AppColors.textHint,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isLocked)
                          Icon(
                            CupertinoIcons.lock,
                            size: 16,
                            color: isDark ? const Color(0xFF52525B) : const Color(0xFFA1A1AA),
                          )
                        else
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? (isDark ? Colors.white : const Color(0xFF18181B))
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : (isDark ? AppColors.textHintDark : AppColors.textHint),
                                width: 1.5,
                              ),
                            ),
                            child: isSelected
                                ? Icon(
                                    CupertinoIcons.checkmark_alt,
                                    size: 14,
                                    color: isDark ? const Color(0xFF18181B) : Colors.white,
                                  )
                                : null,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showTermsOfService() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF202024) : const Color(0xFFF4F4F5);
    final borderColor = isDark ? const Color(0xFF27272A) : AppColors.borderLight;
    final icons = [
      CupertinoIcons.checkmark_shield_fill,
      CupertinoIcons.lock_shield_fill,
      CupertinoIcons.briefcase_fill,
      CupertinoIcons.star_circle_fill,
      CupertinoIcons.exclamationmark_triangle_fill,
      CupertinoIcons.arrow_2_circlepath_circle_fill,
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.backgroundDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            bottom: true,
            child: Column(
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFD4D4D8),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.termsModalTitle,
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4285F4).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'Versi 2.0 • 2026',
                                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF4285F4)),
                                  ),
                                ),
                                Text(
                                  AppStrings.termsModalSubtitle,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: isDark ? AppColors.textHintDark : AppColors.textHint,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(CupertinoIcons.xmark_circle_fill, size: 22),
                        color: isDark ? AppColors.textHintDark : AppColors.textHint,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    itemCount: AppStrings.termsCards.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final card = AppStrings.termsCards[index];
                      return _buildLegalCard(
                        title: card['title'] ?? '',
                        content: card['content'] ?? '',
                        icon: icons[index % icons.length],
                        cardBg: cardBg,
                        borderColor: borderColor,
                        isDark: isDark,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPrivacyPolicy() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF202024) : const Color(0xFFF4F4F5);
    final borderColor = isDark ? const Color(0xFF27272A) : AppColors.borderLight;
    final icons = [
      CupertinoIcons.person_badge_plus_fill,
      CupertinoIcons.gear_alt_fill,
      CupertinoIcons.lock_shield_fill,
      CupertinoIcons.hand_raised_fill,
      CupertinoIcons.trash_circle_fill,
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.backgroundDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            bottom: true,
            child: Column(
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFD4D4D8),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.privacyModalTitle,
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'GDPR & PDP Compliant',
                                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF10B981)),
                                  ),
                                ),
                                Text(
                                  AppStrings.privacyModalSubtitle,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: isDark ? AppColors.textHintDark : AppColors.textHint,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(CupertinoIcons.xmark_circle_fill, size: 22),
                        color: isDark ? AppColors.textHintDark : AppColors.textHint,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    itemCount: AppStrings.privacyCards.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final card = AppStrings.privacyCards[index];
                      return _buildLegalCard(
                        title: card['title'] ?? '',
                        content: card['content'] ?? '',
                        icon: icons[index % icons.length],
                        cardBg: cardBg,
                        borderColor: borderColor,
                        isDark: isDark,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFaqSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF202024) : const Color(0xFFF4F4F5);
    final borderColor = isDark ? const Color(0xFF27272A) : AppColors.borderLight;
    final faqs = AppStrings.faqList;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.backgroundDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            bottom: true,
            child: Column(
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFD4D4D8),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Frequently Asked Questions',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppStrings.generalSettingsSubtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: isDark ? AppColors.textHintDark : AppColors.textHint,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(CupertinoIcons.xmark_circle_fill, size: 22),
                        color: isDark ? AppColors.textHintDark : AppColors.textHint,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    itemCount: faqs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = faqs[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor, width: 0.8),
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            iconColor: isDark ? Colors.white : const Color(0xFF18181B),
                            collapsedIconColor: isDark ? AppColors.textHintDark : AppColors.textHint,
                            title: Text(
                              item['q']!,
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: Text(
                                  item['a']!,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    height: 1.5,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegalCard({
    required String title,
    required String content,
    required IconData icon,
    required Color cardBg,
    required Color borderColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: const Color(0xFF4285F4),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.55,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignOut() async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(AppStrings.logoutConfirmTitle),
        content: Text(AppStrings.logoutConfirmMessage),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppStrings.cancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(AppStrings.logoutButton),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await widget.repository.signOut();
        if (mounted) {
          UIHelper.showSuccessSnackBar(
            context,
            LanguageManager.isEnglish ? 'Signed out successfully' : 'Berhasil keluar',
          );
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => LoginScreen(repository: widget.repository),
            ),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) UIHelper.handleError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = Theme.of(context).cardTheme.color ??
        (isDark ? const Color(0xFF18181B) : AppColors.surface);
    final borderColor = Theme.of(context).dividerTheme.color ??
        (isDark ? const Color(0xFF27272A) : AppColors.borderLight);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? Padding(
                padding: const EdgeInsets.only(left: 14),
                child: Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        CupertinoIcons.arrow_left,
                        size: 18,
                        color: isDark ? Colors.white : const Color(0xFF18181B),
                      ),
                    ),
                  ),
                ),
              )
            : null,
        centerTitle: true,
        title: Text(
          AppStrings.profileTitle,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 60),
                child: AppliqLoading(),
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Header Card (Clickable to Edit Profile)
                    GestureDetector(
                      onTap: () async {
                        if (_profile == null) return;
                        _triggerHaptic();
                        final updated = await Navigator.push<UserProfile>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditProfileScreen(
                              profile: _profile!,
                              repository: widget.repository,
                            ),
                          ),
                        );
                        if (updated != null) {
                          setState(() => _profile = updated);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: borderColor, width: 0.8),
                        ),
                        child: Row(
                          children: [
                            _buildAvatar(_profile?.avatarUrl, 24, isDark),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _profile?.fullName.isNotEmpty == true ? _profile!.fullName : 'Your Name',
                                    style: TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.3,
                                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _profile?.username != null && _profile!.username!.isNotEmpty
                                        ? _profile!.username!
                                        : (_profile?.email.contains('@') == true
                                            ? '@${_profile!.email.split('@')[0]}'
                                            : '@yourname'),
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              CupertinoIcons.chevron_right,
                              size: 15,
                              color: isDark ? AppColors.textHintDark : AppColors.textHint,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Grouped Settings Section 1
                    Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor, width: 0.8),
                      ),
                      child: Column(
                        children: [
                          // Notifications Toggle Tile
                          _buildTile(
                            icon: CupertinoIcons.bell_fill,
                            title: AppStrings.notificationsSetting,
                            isDark: isDark,
                            trailing: _buildCustomSwitch(
                              value: _notificationsEnabled,
                              isDark: isDark,
                              onChanged: _toggleNotifications,
                            ),
                          ),
                          _buildDivider(borderColor),

                          // Experience (CV ATS & Cover Letter)
                          _buildTile(
                            icon: CupertinoIcons.doc_person,
                            title: AppStrings.menuExperienceTitle,
                            subtitle: AppStrings.menuExperienceSubtitle,
                            isDark: isDark,
                            showChevron: true,
                            onTap: () {
                              _triggerHaptic();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ResumeBuilderScreen(
                                    repository: widget.repository,
                                  ),
                                ),
                              );
                            },
                          ),
                          _buildDivider(borderColor),

                          // Dark Mode Switch Tile
                          ValueListenableBuilder<ThemeMode>(
                            valueListenable: ThemeManager.notifier,
                            builder: (context, themeMode, _) {
                              final isDarkModeActive = themeMode == ThemeMode.dark ||
                                  (themeMode == ThemeMode.system && isDark);

                              return _buildTile(
                                icon: CupertinoIcons.moon,
                                title: AppStrings.darkModeTitle,
                                isDark: isDark,
                                trailing: _buildCustomSwitch(
                                  value: isDarkModeActive,
                                  isDark: isDark,
                                  onChanged: (val) async {
                                    _triggerHaptic();
                                    await ThemeManager.setThemeMode(
                                      val ? ThemeMode.dark : ThemeMode.light,
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                          _buildDivider(borderColor),

                          // Monochrome Mode Switch Tile
                          ValueListenableBuilder<AccentThemeMode>(
                            valueListenable: ThemeManager.accentNotifier,
                            builder: (context, accentMode, _) {
                              final isMonochrome = accentMode == AccentThemeMode.monochrome;
                              return _buildTile(
                                icon: CupertinoIcons.circle_righthalf_fill,
                                title: AppStrings.monochromeTitle,
                                isDark: isDark,
                                trailing: _buildCustomSwitch(
                                  value: isMonochrome,
                                  isDark: isDark,
                                  onChanged: (val) async {
                                    _triggerHaptic();
                                    await ThemeManager.setAccentThemeMode(
                                      val ? AccentThemeMode.monochrome : AccentThemeMode.color,
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                          _buildDivider(borderColor),

                          // Language Tile
                          _buildTile(
                            icon: CupertinoIcons.globe,
                            title: AppStrings.languageSetting,
                            isDark: isDark,
                            subtitle: _selectedLanguage,
                            showChevron: true,
                            onTap: () {
                              _triggerHaptic();
                              _showLanguageSelector();
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Grouped Settings Section 2 (FAQ & Policies)
                    Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor, width: 0.8),
                      ),
                      child: Column(
                        children: [
                          _buildTile(
                            icon: CupertinoIcons.question_circle,
                            title: 'FAQ',
                            isDark: isDark,
                            showChevron: true,
                            onTap: () {
                              _triggerHaptic();
                              _showFaqSheet();
                            },
                          ),
                          _buildDivider(borderColor),
                          _buildTile(
                            icon: CupertinoIcons.info_circle,
                            title: AppStrings.termsOfService,
                            isDark: isDark,
                            showChevron: true,
                            onTap: () {
                              _triggerHaptic();
                              _showTermsOfService();
                            },
                          ),
                          _buildDivider(borderColor),
                          _buildTile(
                            icon: CupertinoIcons.shield,
                            title: AppStrings.privacyPolicy,
                            isDark: isDark,
                            showChevron: true,
                            onTap: () {
                              _triggerHaptic();
                              _showPrivacyPolicy();
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Log Out Pill Button
                    GestureDetector(
                      onTap: () {
                        _triggerHaptic();
                        _handleSignOut();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF27272A) : const Color(0xFF18181B),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: isDark ? const Color(0xFF3F3F46) : Colors.transparent,
                            width: 0.8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              CupertinoIcons.square_arrow_right,
                              color: Color(0xFFEF4444),
                              size: 17,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppStrings.logoutButton,
                              style: const TextStyle(
                                color: Color(0xFFEF4444),
                                fontWeight: FontWeight.w700,
                                fontSize: 14.5,
                                letterSpacing: -0.2,
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
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required bool isDark,
    String? subtitle,
    Widget? trailing,
    bool showChevron = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
            ),
            if (subtitle != null) ...[
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.textHintDark : AppColors.textHint,
                ),
              ),
              const SizedBox(width: 6),
            ],
            if (trailing != null) trailing,
            if (showChevron)
              Icon(
                CupertinoIcons.chevron_right,
                size: 16,
                color: isDark ? const Color(0xFF52525B) : const Color(0xFFA1A1AA),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomSwitch({
    required bool value,
    required bool isDark,
    required ValueChanged<bool> onChanged,
  }) {
    return Transform.scale(
      scale: 0.85,
      child: CupertinoSwitch(
        value: value,
        activeTrackColor: isDark ? Colors.white : const Color(0xFF18181B),
        inactiveTrackColor: isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
        thumbColor: isDark
            ? (value ? const Color(0xFF18181B) : Colors.white)
            : (value ? Colors.white : const Color(0xFF71717A)),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDivider(Color color) {
    return Divider(height: 1, thickness: 0.8, indent: 48, color: color);
  }

  Widget _buildAvatar(String? url, double radius, bool isDark) {
    return AppAvatar(
      url: url,
      radius: radius,
      isDark: isDark,
      fallbackName: _profile?.fullName,
    );
  }
}
