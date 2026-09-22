import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/repositories/job_repository.dart';
import '../../../utils/theme_manager.dart';
import '../../../utils/ui_helper.dart';
import '../../widgets/appliq_loading.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final JobRepository repository;

  const ProfileScreen({super.key, required this.repository});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = await widget.repository.getCurrentUserProfile();
      setState(() {
        _profile = user;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        UIHelper.handleError(context, e);
      }
    }
  }

  void _showThemeSelector() {
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
                  'Pilihan Tema Tampilan',
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
            const SizedBox(height: 16),
            _buildThemeOption('Ikuti Sistem Perangkat', ThemeMode.system, CupertinoIcons.device_phone_portrait, isDark),
            const Divider(height: 16),
            _buildThemeOption('Mode Terang (Light Mode)', ThemeMode.light, CupertinoIcons.sun_max_fill, isDark),
            const Divider(height: 16),
            _buildThemeOption('Mode Gelap (Dark Mode)', ThemeMode.dark, CupertinoIcons.moon_stars_fill, isDark),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(String label, ThemeMode mode, IconData icon, bool isDark) {
    final isSelected = ThemeManager.notifier.value == mode;

    return InkWell(
      onTap: () async {
        HapticFeedback.selectionClick();
        await ThemeManager.setThemeMode(mode);
        if (mounted) Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.primary : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: -0.2,
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                CupertinoIcons.checkmark_alt,
                color: AppColors.primary,
                size: 20,
              ),
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

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
        elevation: 0,
        title: Text(
          'Profil & Pengaturan',
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
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              children: [
                // User Header Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      width: 0.8,
                    ),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 38,
                        backgroundColor: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
                        backgroundImage: _profile?.avatarUrl.isNotEmpty == true
                            ? NetworkImage(_profile!.avatarUrl)
                            : null,
                        child: _profile?.avatarUrl.isEmpty == true
                            ? Icon(
                                CupertinoIcons.person_fill,
                                size: 36,
                                color: isDark ? AppColors.textHintDark : AppColors.textHint,
                              )
                            : null,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _profile?.fullName.isNotEmpty == true ? _profile!.fullName : 'Pengguna AppliQ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _profile?.email ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Settings Group Card
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      width: 0.8,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Theme Switcher Tile
                      ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(CupertinoIcons.moon_stars, color: AppColors.primary, size: 20),
                        ),
                        title: Text(
                          'Tema Tampilan',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          ),
                        ),
                        subtitle: ValueListenableBuilder<ThemeMode>(
                          valueListenable: ThemeManager.notifier,
                          builder: (context, mode, _) {
                            String modeName = 'Sistem Default';
                            if (mode == ThemeMode.light) modeName = 'Mode Terang';
                            if (mode == ThemeMode.dark) modeName = 'Mode Gelap';
                            return Text(
                              modeName,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: isDark ? AppColors.textHintDark : AppColors.textHint,
                              ),
                            );
                          },
                        ),
                        trailing: Icon(
                          CupertinoIcons.chevron_right,
                          size: 16,
                          color: isDark ? AppColors.textHintDark : AppColors.textHint,
                        ),
                        onTap: _showThemeSelector,
                      ),
                      Divider(height: 1, indent: 60, color: isDark ? AppColors.borderDark : AppColors.borderLight),
                      // Cloud Storage & Security Tile
                      ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.income.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(CupertinoIcons.shield_lefthalf_fill, color: AppColors.income, size: 20),
                        ),
                        title: Text(
                          'Privasi & Keamanan Data',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          'Enkripsi akun aktif & terlindungi',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isDark ? AppColors.textHintDark : AppColors.textHint,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Sign Out Button
                OutlinedButton.icon(
                  onPressed: _handleSignOut,
                  icon: const Icon(CupertinoIcons.square_arrow_right, color: AppColors.expense, size: 18),
                  label: const Text(
                    'Keluar dari Akun',
                    style: TextStyle(
                      color: AppColors.expense,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.expense, width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ],
            ),
    );
  }
}
