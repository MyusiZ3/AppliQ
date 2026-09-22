import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/repositories/job_repository.dart';
import '../../../services/notification_service.dart';
import '../../../utils/theme_manager.dart';
import '../../../utils/ui_helper.dart';
import '../../widgets/appliq_loading.dart';
import '../auth/login_screen.dart';
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
      });
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    HapticFeedback.selectionClick();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pause_notifications', !value);
    if (mounted) {
      setState(() => _notificationsEnabled = value);
    }

    if (value) {
      final granted = await NotificationService.instance.requestPermissions();
      if (mounted) {
        if (granted) {
          UIHelper.showSuccessSnackBar(context, 'Notifikasi pengingat agenda diaktifkan.');
        } else {
          UIHelper.showInfoSnackBar(context, 'Notifikasi diaktifkan.');
        }
      }
    } else {
      await NotificationService.instance.cancelAll();
      if (mounted) {
        UIHelper.showInfoSnackBar(context, 'Notifikasi pengingat dinonaktifkan.');
      }
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
    final languages = [
      {'name': 'Bahasa Indonesia', 'code': 'id', 'subtitle': 'Indonesian'},
      {'name': 'English', 'code': 'en', 'subtitle': 'United States'},
      {'name': '日本語', 'code': 'ja', 'subtitle': 'Japanese (Segera Hadir)'},
      {'name': '한국어', 'code': 'ko', 'subtitle': 'Korean (Segera Hadir)'},
    ];

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
                  'Pilih Bahasa (Language)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.xmark_circle_fill, size: 22),
                  color: isDark ? AppColors.textHintDark : AppColors.textHint,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Dukungan multilanguage penuh akan hadir pada pembaruan mendatang.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ...languages.map((lang) {
              final isSelected = _selectedLanguage == lang['name'];
              return InkWell(
                onTap: () async {
                  HapticFeedback.selectionClick();
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('app_language', lang['name']!);
                  setState(() => _selectedLanguage = lang['name']!);
                  if (mounted) Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          CupertinoIcons.globe,
                          size: 18,
                          color: isDark ? Colors.white : const Color(0xFF18181B),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lang['name']!,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected
                                    ? (isDark ? Colors.white : const Color(0xFF18181B))
                                    : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                              ),
                            ),
                            Text(
                              lang['subtitle']!,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.textHintDark : AppColors.textHint,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          CupertinoIcons.checkmark,
                          size: 16,
                          color: isDark ? Colors.white : const Color(0xFF18181B),
                        ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showGeneralSettings() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  'General Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.xmark_circle_fill, size: 22),
                  color: isDark ? AppColors.textHintDark : AppColors.textHint,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                CupertinoIcons.arrow_2_circlepath,
                color: isDark ? Colors.white : const Color(0xFF18181B),
              ),
              title: const Text('Sinkronisasi Otomatis'),
              subtitle: const Text('Perbarui status lamaran di latar belakang'),
              trailing: Icon(
                CupertinoIcons.checkmark,
                size: 16,
                color: isDark ? Colors.white : const Color(0xFF18181B),
              ),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(CupertinoIcons.trash, color: AppColors.expense),
              title: const Text('Hapus Cache Lokal'),
              subtitle: const Text('Mengosongkan cache gambar & temporary files'),
              onTap: () {
                Navigator.pop(context);
                UIHelper.showSuccessSnackBar(context, 'Cache lokal berhasil dibersihkan');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showContactInfo() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  'My Contact & Portfolio',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
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
            _buildContactRow('Email', _profile?.email ?? 'contact@appliq.id', CupertinoIcons.mail_solid, isDark),
            const Divider(),
            _buildContactRow('Nomor Telepon', _profile?.phoneNumber ?? 'Belum diisi', CupertinoIcons.phone_fill, isDark),
            const Divider(),
            _buildContactRow('Username', _profile?.username ?? '@pengguna', CupertinoIcons.person_crop_circle_fill, isDark),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(String label, String val, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDark ? Colors.white70 : const Color(0xFF18181B),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: isDark ? AppColors.textHintDark : AppColors.textHint)),
              Text(val, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF18181B))),
            ],
          ),
        ],
      ),
    );
  }

  void _showInfoSheet(String title, String content) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
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
                fontSize: 14,
                height: 1.5,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSignOut() async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Keluar dari Akun?'),
        content: const Text('Kamu perlu masuk kembali untuk mengakses riwayat lamaran kerjamu.'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await widget.repository.signOut();
        if (mounted) {
          UIHelper.showSuccessSnackBar(context, 'Berhasil keluar');
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
    final cardBg = isDark ? const Color(0xFF18181B) : AppColors.surface;
    final borderColor = isDark ? const Color(0xFF27272A) : AppColors.borderLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
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
          'Settings',
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
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              children: [
                // Profile Header Card (Clickable to Edit Profile)
                GestureDetector(
                  onTap: () async {
                    if (_profile == null) return;
                    HapticFeedback.lightImpact();
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: borderColor, width: 0.8),
                    ),
                    child: Row(
                      children: [
                        _buildAvatar(_profile?.avatarUrl, 26, isDark),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _profile?.fullName.isNotEmpty == true ? _profile!.fullName : 'Your Name',
                                style: TextStyle(
                                  fontSize: 16,
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
                                  fontSize: 13,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          CupertinoIcons.chevron_right,
                          size: 16,
                          color: isDark ? AppColors.textHintDark : AppColors.textHint,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Grouped Settings Section 1
                Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: borderColor, width: 0.8),
                  ),
                  child: Column(
                    children: [
                      // Notifications Toggle Tile
                      _buildTile(
                        icon: CupertinoIcons.bell_fill,
                        title: 'Notifikasi Pengingat',
                        isDark: isDark,
                        trailing: _buildCustomSwitch(
                          value: _notificationsEnabled,
                          isDark: isDark,
                          onChanged: _toggleNotifications,
                        ),
                      ),
                      _buildDivider(borderColor),

                      // General Settings Tile
                      _buildTile(
                        icon: CupertinoIcons.slider_horizontal_3,
                        title: 'General settings',
                        isDark: isDark,
                        showChevron: true,
                        onTap: _showGeneralSettings,
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
                            title: 'Dark mode',
                            isDark: isDark,
                            trailing: _buildCustomSwitch(
                              value: isDarkModeActive,
                              isDark: isDark,
                              onChanged: (val) async {
                                HapticFeedback.selectionClick();
                                await ThemeManager.setThemeMode(
                                  val ? ThemeMode.dark : ThemeMode.light,
                                );
                              },
                            ),
                          );
                        },
                      ),
                      _buildDivider(borderColor),

                      // Monochrome Mode Switch Tile (Monochrome vs Color)
                      ValueListenableBuilder<AccentThemeMode>(
                        valueListenable: ThemeManager.accentNotifier,
                        builder: (context, accentMode, _) {
                          final isMonochrome = accentMode == AccentThemeMode.monochrome;
                          return _buildTile(
                            icon: CupertinoIcons.circle_righthalf_fill,
                            title: 'Monochrome mode',
                            isDark: isDark,
                            trailing: _buildCustomSwitch(
                              value: isMonochrome,
                              isDark: isDark,
                              onChanged: (val) async {
                                HapticFeedback.selectionClick();
                                await ThemeManager.setAccentThemeMode(
                                  val ? AccentThemeMode.monochrome : AccentThemeMode.color,
                                );
                              },
                            ),
                          );
                        },
                      ),
                      _buildDivider(borderColor),

                      // Language Tile (Multilanguage placeholder ready)
                      _buildTile(
                        icon: CupertinoIcons.globe,
                        title: 'Language',
                        isDark: isDark,
                        subtitle: _selectedLanguage,
                        showChevron: true,
                        onTap: _showLanguageSelector,
                      ),
                      _buildDivider(borderColor),

                      // My Contact Tile
                      _buildTile(
                        icon: CupertinoIcons.person_2,
                        title: 'My Contact',
                        isDark: isDark,
                        showChevron: true,
                        onTap: _showContactInfo,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Grouped Settings Section 2 (FAQ & Policies)
                Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: borderColor, width: 0.8),
                  ),
                  child: Column(
                    children: [
                      _buildTile(
                        icon: CupertinoIcons.question_circle,
                        title: 'FAQ',
                        isDark: isDark,
                        showChevron: true,
                        onTap: () => _showInfoSheet(
                          'Pertanyaan Umum (FAQ)',
                          'AppliQ adalah platform pelacak lamaran kerja terpadu. Kamu dapat mencatat tahapan interview, mengatur reminder jadwal, dan menganalisis tingkat konversi lamaran kerjamu secara real-time.',
                        ),
                      ),
                      _buildDivider(borderColor),
                      _buildTile(
                        icon: CupertinoIcons.info_circle,
                        title: 'Terms of service',
                        isDark: isDark,
                        showChevron: true,
                        onTap: () => _showInfoSheet(
                          'Ketentuan Layanan',
                          'Dengan menggunakan AppliQ, seluruh data disimpan dengan aman sesuai dengan ketentuan privasi dan standar enkripsi industri.',
                        ),
                      ),
                      _buildDivider(borderColor),
                      _buildTile(
                        icon: CupertinoIcons.shield,
                        title: 'User policy',
                        isDark: isDark,
                        showChevron: true,
                        onTap: () => _showInfoSheet(
                          'Kebijakan Privasi Pengguna',
                          'AppliQ menghormati privasi datamu. Data profil dan lamaran hanya dapat diakses oleh pemilik akun dan tidak pernah dibagikan kepada pihak ketiga tanpa persetujuan.',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Log Out Pill Button
                GestureDetector(
                  onTap: _handleSignOut,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          CupertinoIcons.square_arrow_right,
                          color: Color(0xFFEF4444),
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Log Out',
                          style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
    if (url == null || url.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
        child: Icon(
          CupertinoIcons.person_fill,
          size: radius * 0.9,
          color: isDark ? AppColors.textHintDark : AppColors.textHint,
        ),
      );
    }
    return ClipOval(
      child: Image.network(
        url,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => CircleAvatar(
          radius: radius,
          backgroundColor: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
          child: Icon(
            CupertinoIcons.person_fill,
            size: radius * 0.9,
            color: isDark ? AppColors.textHintDark : AppColors.textHint,
          ),
        ),
      ),
    );
  }
}
