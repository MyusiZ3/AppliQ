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
import '../../widgets/legal_sheets.dart';
import '../auth/login_screen.dart';
import 'career_screen.dart';
import 'edit_profile_screen.dart';

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
    LegalSheets.showTermsOfService(context);
  }

  void _showPrivacyPolicy() {
    LegalSheets.showPrivacyPolicy(context);
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
                              AppStrings.faqSheetTitle,
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppStrings.faqSheetSubtitle,
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

  void _showAboutAppSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF202024) : const Color(0xFFF4F4F5);
    final borderColor = isDark ? const Color(0xFF27272A) : AppColors.borderLight;
    final lang = LanguageManager.current;

    final sheetTitle = lang == AppLanguage.en
        ? 'About AppliQ'
        : (lang == AppLanguage.ja
            ? 'AppliQについて'
            : (lang == AppLanguage.ko ? 'AppliQ 정보' : 'Tentang AppliQ'));

    final sheetSubtitle = lang == AppLanguage.en
        ? 'A calm space designed for modern job seekers'
        : (lang == AppLanguage.ja
            ? '転職・就職活動を支えるパートナー'
            : (lang == AppLanguage.ko
                ? '구직자의 마음으로 만든 커리어 플랫폼'
                : 'Ruang tenang untuk menemani perjalanan karirmu'));

    final tagLine = lang == AppLanguage.en
        ? 'A calm, thoughtful space for your career journey'
        : (lang == AppLanguage.ja
            ? 'あなたのキャリアに寄り添う、スマートな就活パートナー'
            : (lang == AppLanguage.ko
                ? '당신의 소중한 도전을 응원하는 스마트 구직 파트너'
                : 'Teman setia yang tenang dan teratur untuk perjalanan karirmu'));

    final storyTitle = lang == AppLanguage.en
        ? 'The Story Behind AppliQ'
        : (lang == AppLanguage.ja
            ? '開発の背景'
            : (lang == AppLanguage.ko ? '만들게 된 이야기' : 'Cerita di Balik AppliQ'));

    final storySubtitle = lang == AppLanguage.en
        ? 'Born from real job hunting journeys'
        : (lang == AppLanguage.ja
            ? '就活生のリアルな課題から'
            : (lang == AppLanguage.ko ? '구직 과정의 생생한 경험에서 출발' : 'Dari pengalaman nyata mencari kerja'));

    final storyBody = lang == AppLanguage.en
        ? "Job searching can be deeply exhausting — dozens of applications sent, overlapping interviews, and the quiet anxiety of waiting for updates.\n\nAppliQ was created to offer a calm, grounded, and dignified space for your journey. We believe keeping your opportunities organized shouldn't feel like a chore, but an empowering step forward."
        : (lang == AppLanguage.ja
            ? "就職活動や転職活動は、時に不安とプレッシャーの連続です。何十通もの応募、重なる面接日程、そして結果を待つ日々の焦り。\n\nAppliQは、そんな活動期間を少しでも前向きに、整理された気持ちで進められるように生まれました。あなたの努力が実を結ぶその日まで、静かに力強く寄り添う存在でありたいと願っています。"
            : (lang == AppLanguage.ko
                ? "구직과 이직은 수많은 지원서 작성, 겹치는 면접 일정, 기약 없는 기다림으로 지치기 쉬운 여정입니다.\n\nAppliQ는 이러한 구직자의 마음에 깊이 공감하며, 차분하고 체계적으로 커리어를 관리할 수 있는 공간을 제공하고자 탄생했습니다. 당신의 소중한 도전이 결실을 맺을 때까지 든든한 동반자가 되어 드립니다."
                : "Mencari kerja seringkali melelahkan: puluhan formulir terkirim, jadwal interview yang berbenturan, hingga rasa cemas menunggu kabar tanpa kepastian.\n\nAppliQ diciptakan sebagai ruang yang tenang dan rapi untuk menemani perjalananmu. Kami ingin setiap pencari kerja merasa lebih percaya diri, terorganisir, dan dihargai di setiap langkah proses seleksi."));

    final devTitle = lang == AppLanguage.en
        ? 'Creator & Independent Craft'
        : (lang == AppLanguage.ja
            ? 'クリエイター & 開発'
            : (lang == AppLanguage.ko ? '제작 및 개발' : 'Kreator & Pengembang'));

    final devBody = lang == AppLanguage.en
        ? "Crafted, designed, and independently engineered with heart by Muhamad Sidik at Arch. Every detail, pastel accent, and interaction was designed to make job seeking feel a little lighter, calmer, and more human."
        : (lang == AppLanguage.ja
            ? "ArchのMuhamad Sidikによって、心を込めて企画・デザイン・開発された個人開発プロジェクトです。柔らかなパステルカラーや直感的な操作感を通じて、日々の就職活動が少しでも心地よくなるよう細部までこだわっています。"
            : (lang == AppLanguage.ko
                ? "Arch의 Muhamad Sidik이 진심을 담아 기획, 디자인, 개발한 독립 프로젝트입니다. 부드러운 파스텔 톤과 직관적인 사용성을 통해 구직 과정의 스트레스를 덜고 따뜻한 힘을 전하고자 합니다."
                : "Dikonsep, didesain, dan dibangun dengan sepenuh hati oleh Muhamad Sidik di bawah bendera Arch. Setiap fitur, sentuhan warna pastel, hingga interaksi dirancang khusus agar proses mencari kerja terasa lebih ringan, tenang, dan bersahabat."));

    final privacyTitle = lang == AppLanguage.en
        ? 'Privacy First & Respect'
        : (lang == AppLanguage.ja
            ? 'プライバシーと権利'
            : (lang == AppLanguage.ko ? '개인정보 원칙 및 저작권' : 'Komitmen Privasi & Hak Cipta'));

    final privacyBody = lang == AppLanguage.en
        ? "Your job search records, resumes, interview notes, and salary figures belong entirely to you. AppliQ does not sell your personal data or embed third-party ad trackers.\n\nAll visual design, branding, and codebase are protected intellectual property of Muhamad Sidik / Arch."
        : (lang == AppLanguage.ja
            ? "応募履歴や職務経歴、希望給与などの情報は完全にあなただけのものです。AppliQが個人情報を販売したり、不要なトラッカーを埋め込むことは一切ありません。\n\nアプリのビジュアルデザイン、ブランド、コードはMuhamad Sidik / Archの著作権により保護されています。"
            : (lang == AppLanguage.ko
                ? "지원 이력, 이력서, 면접 메모, 연봉 정보는 오직 사용자 본인의 소중한 데이터입니다. AppliQ는 어떠한 경우에도 개인 데이터를 판매하거나 상업적 추적기를 사용하지 않습니다.\n\n앱의 모든 시각 디자인, 브랜드 및 소스 코드는 Muhamad Sidik / Arch의 고유한 저작권으로 보호됩니다."
                : "Data karir, dokumen resume, catatan lamaran, dan target gajimu sepenuhnya adalah milikmu pribadi. AppliQ tidak pernah menjual data pengguna atau menyisipkan pelacak pihak ketiga.\n\nSeluruh desain antarmuka, identitas merek, dan kode sumber dilindungi hak cipta independen milik Muhamad Sidik / Arch."));

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
                              sheetTitle,
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              sheetSubtitle,
                              style: TextStyle(
                                fontSize: 11.5,
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
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    children: [
                      // Branding Header (Clean App Icon, No 3D Mascot)
                      Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            Container(
                              width: 68,
                              height: 68,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF27272A) : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF3F3F46) : AppColors.borderLight,
                                  width: 0.8,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/images/appliq_logo.png',
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Icon(
                                  CupertinoIcons.briefcase_fill,
                                  size: 34,
                                  color: AppColors.pastelLavender,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'AppliQ',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tagLine,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                'v1.0.5 (Build 1) • com.arch.appliq',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white70 : const Color(0xFF3F3F46),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Card 1: Cerita & Visi (The Story)
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: borderColor, width: 0.8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.pastelCoral.withValues(alpha: 0.25),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    CupertinoIcons.heart_fill,
                                    size: 18,
                                    color: AppColors.pastelCoral,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        storyTitle,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        storySubtitle,
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w500,
                                          color: isDark ? AppColors.textHintDark : AppColors.textHint,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              storyBody,
                              style: TextStyle(
                                fontSize: 12.5,
                                height: 1.55,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Card 2: Creator & Studio Info
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: borderColor, width: 0.8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.pastelMint.withValues(alpha: 0.25),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    CupertinoIcons.person_crop_circle_fill,
                                    size: 18,
                                    color: AppColors.pastelMint,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        devTitle,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        'Muhamad Sidik (@Imyusi_) • Arch',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? AppColors.pastelLavender : const Color(0xFF7C3AED),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              devBody,
                              style: TextStyle(
                                fontSize: 12.5,
                                height: 1.55,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Card 3: Privacy & Copyright Commitment
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: borderColor, width: 0.8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.pastelLavender.withValues(alpha: 0.25),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    CupertinoIcons.lock_shield_fill,
                                    size: 18,
                                    color: AppColors.pastelLavender,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        privacyTitle,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        '© 2026 Arch. All rights reserved.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: isDark ? AppColors.textHintDark : AppColors.textHint,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              privacyBody,
                              style: TextStyle(
                                fontSize: 12.5,
                                height: 1.55,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  Future<void> _handleSignOut() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(AppStrings.logoutConfirmTitle),
        content: Text(AppStrings.logoutConfirmMessage),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              AppStrings.cancel,
              style: TextStyle(
                color: isDark ? Colors.white70 : const Color(0xFF18181B),
                fontWeight: FontWeight.w600,
              ),
            ),
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

    return ValueListenableBuilder<AccentThemeMode>(
      valueListenable: ThemeManager.accentNotifier,
      builder: (context, accentMode, _) {
        final isMono = accentMode == AccentThemeMode.monochrome;
        final cardBg = AppColors.getSurface(isDark: isDark, isMonochrome: isMono);
        final borderColor = AppColors.getBorder(isDark: isDark, isMonochrome: isMono);

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
                            color: isDark
                                ? (isMono ? const Color(0xFF27272A) : AppColors.darkSurfaceVariantPastel)
                                : const Color(0xFFF4F4F5),
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
                                iconColor: AppColors.pastelSky,
                                title: AppStrings.notificationsSetting,
                                isDark: isDark,
                                trailing: _buildCustomSwitch(
                                  value: _notificationsEnabled,
                                  isDark: isDark,
                                  isMonochrome: isMono,
                                  onChanged: _toggleNotifications,
                                ),
                              ),
                              _buildDivider(borderColor),

                              // Career & Currently Working Hub
                              _buildTile(
                                icon: CupertinoIcons.briefcase_fill,
                                iconColor: isMono ? null : AppColors.pastelLime,
                                title: AppStrings.menuCareerTitle,
                                isDark: isDark,
                                showChevron: true,
                                onTap: () {
                                  _triggerHaptic();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CareerScreen(
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
                                    iconColor: AppColors.pastelAmber,
                                    title: AppStrings.darkModeTitle,
                                    isDark: isDark,
                                    trailing: _buildCustomSwitch(
                                      value: isDarkModeActive,
                                      isDark: isDark,
                                      isMonochrome: isMono,
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
                              _buildTile(
                                icon: CupertinoIcons.circle_righthalf_fill,
                                iconColor: AppColors.pastelLime,
                                title: AppStrings.monochromeTitle,
                                isDark: isDark,
                                trailing: _buildCustomSwitch(
                                  value: isMono,
                                  isDark: isDark,
                                  isMonochrome: isMono,
                                  onChanged: (val) async {
                                    _triggerHaptic();
                                    await ThemeManager.setAccentThemeMode(
                                      val ? AccentThemeMode.monochrome : AccentThemeMode.color,
                                    );
                                  },
                                ),
                              ),
                              _buildDivider(borderColor),

                              // Language Tile
                              _buildTile(
                                icon: CupertinoIcons.globe,
                                iconColor: AppColors.pastelMint,
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
                                iconColor: AppColors.pastelLavender,
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
                                icon: CupertinoIcons.doc_text,
                                iconColor: AppColors.pastelSky,
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
                                iconColor: AppColors.pastelMint,
                                title: AppStrings.privacyPolicy,
                                isDark: isDark,
                                showChevron: true,
                                onTap: () {
                                  _triggerHaptic();
                                  _showPrivacyPolicy();
                                },
                              ),
                              _buildDivider(borderColor),
                              _buildTile(
                                icon: CupertinoIcons.info_circle,
                                iconColor: AppColors.pastelLime,
                                title: LanguageManager.isEnglish
                                    ? 'About AppliQ'
                                    : (LanguageManager.isJapanese
                                        ? 'AppliQについて'
                                        : (LanguageManager.isKorean ? 'AppliQ 정보' : 'Tentang AppliQ')),
                                isDark: isDark,
                                showChevron: true,
                                onTap: () {
                                  _triggerHaptic();
                                  _showAboutAppSheet();
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
                              color: isDark
                                  ? (isMono ? const Color(0xFF27272A) : AppColors.darkSurfaceVariantPastel)
                                  : const Color(0xFF18181B),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: isDark
                                    ? (isMono ? const Color(0xFF3F3F46) : AppColors.darkBorderPastel)
                                    : Colors.transparent,
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

                        const SizedBox(height: 24),

                        // App Version & Copyright Footer
                        Center(
                          child: Column(
                            children: [
                              Text(
                                'AppliQ v1.0.4',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '© 2026 Arch Studio. All rights reserved.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? AppColors.textHintDark
                                      : AppColors.textHint,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Dev by Muhamad Sidik.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.textHintDark
                                      : AppColors.textHint,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required bool isDark,
    Color? iconColor,
    String? subtitle,
    Widget? trailing,
    bool showChevron = false,
    VoidCallback? onTap,
  }) {
    final isMono = ThemeManager.isMonochrome;
    final defaultMuted = isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final effectiveIconColor = isMono ? defaultMuted : (iconColor ?? defaultMuted);

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
              color: effectiveIconColor,
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
    bool isMonochrome = true,
  }) {
    return Transform.scale(
      scale: 0.85,
      child: CupertinoSwitch(
        value: value,
        activeTrackColor: isMonochrome
            ? (isDark ? Colors.white : const Color(0xFF18181B))
            : AppColors.pastelLime,
        inactiveTrackColor: isDark
            ? (isMonochrome ? const Color(0xFF27272A) : AppColors.darkSurfaceVariantPastel)
            : const Color(0xFFE4E4E7),
        thumbColor: isMonochrome
            ? (isDark
                ? (value ? const Color(0xFF18181B) : Colors.white)
                : (value ? Colors.white : const Color(0xFF71717A)))
            : (value ? AppColors.textOnPastel : (isDark ? Colors.white70 : const Color(0xFF71717A))),
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
