import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/repositories/job_repository.dart';
import '../../../utils/ui_helper.dart';
import '../../widgets/app_avatar.dart';
import '../auth/login_screen.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile profile;
  final JobRepository repository;

  const EditProfileScreen({
    super.key,
    required this.profile,
    required this.repository,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _usernameController;
  late final TextEditingController _targetRoleController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.profile.fullName);
    _phoneController = TextEditingController(text: widget.profile.phoneNumber ?? '');
    _emailController = TextEditingController(text: widget.profile.email);
    _usernameController = TextEditingController(
      text: widget.profile.username ?? (widget.profile.email.contains('@') ? '@${widget.profile.email.split('@')[0]}' : '@user'),
    );
    _targetRoleController = TextEditingController(text: widget.profile.targetRole ?? '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _targetRoleController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final fullName = _fullNameController.text.trim();
    if (fullName.isEmpty) {
      UIHelper.showErrorSnackBar(context, 'Nama lengkap tidak boleh kosong');
      return;
    }

    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    try {
      final updatedProfile = widget.profile.copyWith(
        fullName: fullName,
        phoneNumber: _phoneController.text.trim(),
        username: _usernameController.text.trim(),
        targetRole: _targetRoleController.text.trim(),
        avatarUrl: widget.profile.avatarUrl,
      );

      await widget.repository.updateUserProfile(updatedProfile);

      if (mounted) {
        UIHelper.showSuccessSnackBar(context, 'Profil berhasil diperbarui!');
        Navigator.pop(context, updatedProfile);
      }
    } catch (e) {
      if (mounted) UIHelper.handleError(context, e);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _handleDeleteAccount() async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Hapus Akun Permanen?'),
        content: const Text(
          'Seluruh data lamaran, riwayat interview, dan catatan kamu akan dihapus secara permanen. Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus Akun'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await widget.repository.deleteAccount();
        if (mounted) {
          UIHelper.showSuccessSnackBar(context, 'Akun berhasil dihapus');
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
    final inputBg = isDark ? const Color(0xFF202024) : const Color(0xFFF4F4F5);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: Padding(
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
        ),
        centerTitle: true,
        title: Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),

              // Google Synchronized Avatar (Read-Only)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE4E4E7),
                      width: 2,
                    ),
                  ),
                  child: _buildAvatar(widget.profile.avatarUrl, 50, isDark),
                ),
              ),

              const SizedBox(height: 24),

              // Google Account Banner (Email - Read Only with Connected Badge)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor, width: 0.8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            CupertinoIcons.lock_shield_fill,
                            size: 15,
                            color: isDark ? Colors.white : const Color(0xFF18181B),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Email Akun Google',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Terhubung',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : const Color(0xFF18181B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.profile.email,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: isDark ? Colors.white : const Color(0xFF18181B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Email disinkronkan langsung dari autentikasi Google.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? AppColors.textHintDark : AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Form Inputs (Spacious Stacked Layout)
              _buildModernInputField(
                label: 'Nama Lengkap',
                controller: _fullNameController,
                hint: 'Masukkan nama lengkap',
                icon: CupertinoIcons.person,
                isDark: isDark,
                inputBg: inputBg,
                borderColor: borderColor,
              ),

              const SizedBox(height: 14),

              _buildModernInputField(
                label: 'Username',
                controller: _usernameController,
                hint: '@username',
                icon: CupertinoIcons.at,
                isDark: isDark,
                inputBg: inputBg,
                borderColor: borderColor,
              ),

              const SizedBox(height: 14),

              _buildModernInputField(
                label: 'Nomor Telepon / WhatsApp',
                controller: _phoneController,
                hint: '0812-3456-7890',
                icon: CupertinoIcons.phone,
                keyboardType: TextInputType.phone,
                isDark: isDark,
                inputBg: inputBg,
                borderColor: borderColor,
              ),

              const SizedBox(height: 14),

              _buildModernInputField(
                label: 'Posisi Impian / Target Role',
                controller: _targetRoleController,
                hint: 'Contoh: Flutter Developer / UI Designer',
                icon: CupertinoIcons.briefcase,
                isDark: isDark,
                inputBg: inputBg,
                borderColor: borderColor,
              ),

              const SizedBox(height: 32),

              // Save Changes Action Button
              ElevatedButton(
                onPressed: _isSaving ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white : const Color(0xFF18181B),
                  foregroundColor: isDark ? const Color(0xFF18181B) : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: _isSaving
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: isDark ? const Color(0xFF18181B) : Colors.white,
                        ),
                      )
                    : Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: isDark ? const Color(0xFF18181B) : Colors.white,
                        ),
                      ),
              ),

              const SizedBox(height: 14),

              // Delete Account Ghost Button
              Center(
                child: TextButton(
                  onPressed: _handleDeleteAccount,
                  child: const Text(
                    'Delete Account',
                    style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    required Color inputBg,
    required Color borderColor,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              letterSpacing: -0.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: inputBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 0.8),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF18181B),
              letterSpacing: -0.2,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                size: 18,
                color: isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
              ),
              hintText: hint,
              hintStyle: TextStyle(
                color: isDark ? const Color(0xFF52525B) : const Color(0xFFA1A1AA),
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(String? url, double radius, bool isDark) {
    return AppAvatar(
      url: url,
      radius: radius,
      isDark: isDark,
      fallbackName: _fullNameController.text,
    );
  }
}
