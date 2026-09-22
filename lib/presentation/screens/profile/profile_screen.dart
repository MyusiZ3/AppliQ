import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/repositories/job_repository.dart';
import '../../../services/notification_service.dart';
import '../../../utils/theme_manager.dart';
import '../../../utils/ui_helper.dart';
import '../../widgets/app_avatar.dart';
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
  String _defaultCurrency = 'IDR (Rp)';
  String _dateFormat = 'DD MMMM YYYY';
  bool _hapticFeedbackEnabled = true;
  bool _confirmBeforeDelete = true;
  String _defaultSortOption = 'Terbaru Ditambahkan';

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
        _defaultCurrency = prefs.getString('general_currency') ?? 'IDR (Rp)';
        _dateFormat = prefs.getString('general_date_format') ?? 'DD MMMM YYYY';
        _hapticFeedbackEnabled = prefs.getBool('general_haptic') ?? true;
        _confirmBeforeDelete = prefs.getBool('general_confirm_delete') ?? true;
        _defaultSortOption = prefs.getString('general_default_sort') ?? 'Terbaru Ditambahkan';
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
      {'name': 'Bahasa Indonesia', 'code': 'id', 'subtitle': 'Bahasa Indonesia (Standar)', 'badge': 'Utama', 'icon': '🇮🇩'},
      {'name': 'English', 'code': 'en', 'subtitle': 'English (United States)', 'badge': 'Global', 'icon': '🇺🇸'},
      {'name': '日本語', 'code': 'ja', 'subtitle': 'Japanese (Nihongo)', 'badge': 'Segera Hadir', 'icon': '🇯🇵'},
      {'name': '한국어', 'code': 'ko', 'subtitle': 'Korean (Hangugeo)', 'badge': 'Segera Hadir', 'icon': '🇰🇷'},
    ];

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
                        'Pilih Bahasa (Language)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Pilih bahasa antarmuka aplikasi',
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
              final isSelected = _selectedLanguage == lang['name'];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () async {
                    _triggerHaptic();
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('app_language', lang['name']!);
                    setState(() => _selectedLanguage = lang['name']!);
                    if (mounted) Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7))
                          : cardBg,
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
                        Text(lang['icon']!, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      lang['name']!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                        color: isDark ? Colors.white : const Color(0xFF18181B),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE4E4E7),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      lang['badge']!,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                lang['subtitle']!,
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

  void _showGeneralSettings() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF202024) : const Color(0xFFF4F4F5);
    final borderColor = isDark ? const Color(0xFF27272A) : AppColors.borderLight;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.backgroundDark : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SafeArea(
              top: false,
              bottom: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
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
                                'General Settings',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.4,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Kustomisasi pengalaman & preferensi pelacakan',
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
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      children: [
                        // Section 1: Preferensi Format
                        _buildSectionHeader('PREFERENSI FORMAT & NILAI', isDark),
                        Container(
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: borderColor, width: 0.8),
                          ),
                          child: Column(
                            children: [
                              // Mata Uang Default
                              ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF27272A) : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    CupertinoIcons.money_dollar_circle_fill,
                                    size: 18,
                                    color: isDark ? Colors.white : const Color(0xFF18181B),
                                  ),
                                ),
                                title: const Text('Mata Uang Default', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
                                subtitle: Text(_defaultCurrency, style: TextStyle(fontSize: 12.5, color: isDark ? AppColors.textHintDark : AppColors.textHint)),
                                trailing: Icon(CupertinoIcons.chevron_right, size: 15, color: isDark ? AppColors.textHintDark : AppColors.textHint),
                                onTap: () => _showCurrencyPicker(setModalState),
                              ),
                              Divider(height: 1, indent: 56, color: borderColor),
                              // Format Tanggal
                              ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF27272A) : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    CupertinoIcons.calendar,
                                    size: 18,
                                    color: isDark ? Colors.white : const Color(0xFF18181B),
                                  ),
                                ),
                                title: const Text('Format Tanggal', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
                                subtitle: Text(_dateFormat, style: TextStyle(fontSize: 12.5, color: isDark ? AppColors.textHintDark : AppColors.textHint)),
                                trailing: Icon(CupertinoIcons.chevron_right, size: 15, color: isDark ? AppColors.textHintDark : AppColors.textHint),
                                onTap: () => _showDateFormatPicker(setModalState),
                              ),
                              Divider(height: 1, indent: 56, color: borderColor),
                              // Urutan Default Lamaran
                              ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF27272A) : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    CupertinoIcons.sort_down,
                                    size: 18,
                                    color: isDark ? Colors.white : const Color(0xFF18181B),
                                  ),
                                ),
                                title: const Text('Urutan Lamaran Default', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
                                subtitle: Text(_defaultSortOption, style: TextStyle(fontSize: 12.5, color: isDark ? AppColors.textHintDark : AppColors.textHint)),
                                trailing: Icon(CupertinoIcons.chevron_right, size: 15, color: isDark ? AppColors.textHintDark : AppColors.textHint),
                                onTap: () => _showSortOptionPicker(setModalState),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Section: Penyimpanan & Cache
                        _buildSectionHeader('PENYIMPANAN & CACHE', isDark),
                        Container(
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: borderColor, width: 0.8),
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    CupertinoIcons.trash_fill,
                                    size: 18,
                                    color: Color(0xFFEF4444),
                                  ),
                                ),
                                title: const Text('Bersihkan Cache Lokal', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: Color(0xFFEF4444))),
                                subtitle: const Text('Mengosongkan cache gambar & temporary memory files', style: TextStyle(fontSize: 12)),
                                onTap: () async {
                                  _triggerHaptic();
                                  PaintingBinding.instance.imageCache.clear();
                                  PaintingBinding.instance.imageCache.clearLiveImages();
                                  if (mounted) {
                                    Navigator.pop(context);
                                    UIHelper.showSuccessSnackBar(context, 'Cache gambar dan data sementara berhasil dibersihkan!');
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: isDark ? AppColors.textHintDark : AppColors.textHint,
        ),
      ),
    );
  }

  void _showCurrencyPicker(StateSetter setModalState) {
    final currencies = [
      {'code': 'IDR (Rp)', 'name': 'Rupiah Indonesia', 'symbol': 'Rp', 'flag': '🇮🇩', 'preview': 'Rp 15.000.000 / bulan'},
      {'code': 'USD (\$)', 'name': 'US Dollar', 'symbol': '\$', 'flag': '🇺🇸', 'preview': '\$ 3,500 / month'},
      {'code': 'EUR (€)', 'name': 'Euro', 'symbol': '€', 'flag': '🇪🇺', 'preview': '€ 3,200 / month'},
      {'code': 'SGD (S\$)', 'name': 'Singapore Dollar', 'symbol': 'S\$', 'flag': '🇸🇬', 'preview': 'S\$ 4,800 / month'},
      {'code': 'MYR (RM)', 'name': 'Ringgit Malaysia', 'symbol': 'RM', 'flag': '🇲🇾', 'preview': 'RM 5,500 / month'},
      {'code': 'JPY (¥)', 'name': 'Japanese Yen', 'symbol': '¥', 'flag': '🇯🇵', 'preview': '¥ 450,000 / month'},
    ];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF202024) : const Color(0xFFF4F4F5);
    final borderColor = isDark ? const Color(0xFF27272A) : AppColors.borderLight;

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
                        'Pilih Mata Uang Default',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Digunakan untuk input ekspektasi gaji lamaran',
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
            ...currencies.map((c) {
              final isSelected = _defaultCurrency == c['code'];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () async {
                    _triggerHaptic();
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('general_currency', c['code']!);
                    setState(() => _defaultCurrency = c['code']!);
                    setModalState(() {});
                    if (mounted) Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7))
                          : cardBg,
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
                        Text(c['flag']!, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      c['code']!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                        color: isDark ? Colors.white : const Color(0xFF18181B),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      c['name']!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Contoh: ${c['preview']}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: isDark ? AppColors.textHintDark : AppColors.textHint,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
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

  void _showDateFormatPicker(StateSetter setModalState) {
    final now = DateTime.now();
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final previewId = '${now.day} ${months[now.month - 1]} ${now.year}';
    final formats = [
      {
        'id': 'DD MMMM YYYY',
        'title': 'DD MMMM YYYY',
        'badge': 'Direkomendasikan',
        'preview': previewId,
        'desc': 'Format panjang standar formal (contoh: $previewId)',
      },
      {
        'id': 'DD/MM/YYYY',
        'title': 'DD/MM/YYYY',
        'badge': 'Standar ID & UK',
        'preview': DateFormat('dd/MM/yyyy').format(now),
        'desc': 'Format numerik hari-bulan-tahun',
      },
      {
        'id': 'YYYY-MM-DD',
        'title': 'YYYY-MM-DD',
        'badge': 'Format ISO',
        'preview': DateFormat('yyyy-MM-dd').format(now),
        'desc': 'Format teknis standar internasional',
      },
      {
        'id': 'MM/DD/YYYY',
        'title': 'MM/DD/YYYY',
        'badge': 'Standar US',
        'preview': DateFormat('MM/dd/yyyy').format(now),
        'desc': 'Format numerik bulan-hari-tahun',
      },
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF202024) : const Color(0xFFF4F4F5);
    final borderColor = isDark ? const Color(0xFF27272A) : AppColors.borderLight;

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
                        'Pilih Format Tanggal',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tampilan tanggal pada kartu lamaran & agenda',
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
            ...formats.map((f) {
              final isSelected = _dateFormat == f['id'];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () async {
                    _triggerHaptic();
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('general_date_format', f['id']!);
                    setState(() => _dateFormat = f['id']!);
                    setModalState(() {});
                    if (mounted) Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7))
                          : cardBg,
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
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF3F3F46) : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            CupertinoIcons.calendar_today,
                            size: 18,
                            color: isDark ? Colors.white : const Color(0xFF18181B),
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
                                      f['title']!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                        color: isDark ? Colors.white : const Color(0xFF18181B),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE4E4E7),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      f['badge']!,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Contoh: ${f['preview']}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
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

  void _showSortOptionPicker(StateSetter setModalState) {
    final options = [
      {
        'id': 'Terbaru Ditambahkan',
        'desc': 'Menampilkan lamaran yang paling baru Anda tambahkan di posisi paling atas',
        'icon': CupertinoIcons.sparkles,
      },
      {
        'id': 'Deadline Terdekat',
        'desc': 'Memprioritaskan lamaran dengan batas waktu & jadwal terdekat',
        'icon': CupertinoIcons.clock_fill,
      },
      {
        'id': 'Nama Perusahaan A-Z',
        'desc': 'Mengurutkan seluruh lamaran secara alfabetis nama perusahaan',
        'icon': CupertinoIcons.textformat_abc,
      },
      {
        'id': 'Gaji Tertinggi',
        'desc': 'Menampilkan peluang karir dengan penawaran gaji tertinggi lebih dulu',
        'icon': CupertinoIcons.money_dollar_circle_fill,
      },
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF202024) : const Color(0xFFF4F4F5);
    final borderColor = isDark ? const Color(0xFF27272A) : AppColors.borderLight;

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
                        'Urutan Lamaran Default',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Metode pengurutan otomatis daftar lamaran',
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
            ...options.map((opt) {
              final isSelected = _defaultSortOption == opt['id'];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () async {
                    _triggerHaptic();
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('general_default_sort', opt['id'] as String);
                    setState(() => _defaultSortOption = opt['id'] as String);
                    setModalState(() {});
                    if (mounted) Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7))
                          : cardBg,
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
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF3F3F46) : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            opt['icon'] as IconData,
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
                                opt['id'] as String,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  color: isDark ? Colors.white : const Color(0xFF18181B),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                opt['desc'] as String,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: isDark ? AppColors.textHintDark : AppColors.textHint,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
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
                              'Terms of Service',
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
                                  'Ketentuan Resmi AppliQ',
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
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    children: [
                      _buildLegalCard(
                        title: '1. Penerimaan Ketentuan (Acceptance of Terms)',
                        content:
                            'Dengan mendaftar, mengakses, atau menggunakan platform aplikasi AppliQ, Anda menyatakan setuju untuk terikat oleh Ketentuan Layanan ini. Jika Anda tidak menyetujui salah satu klausul dalam ketentuan ini, Anda disarankan untuk tidak melanjutkan penggunaan layanan kami.',
                        icon: CupertinoIcons.checkmark_shield_fill,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildLegalCard(
                        title: '2. Akun & Keamanan Data Pengguna',
                        content:
                            'Anda bertanggung jawab penuh untuk menjaga kerahasiaan kredensial autentikasi akun Google Anda. Seluruh aktivitas yang terjadi di bawah akun Anda merupakan tanggung jawab Anda pribadi. AppliQ tidak bertanggung jawab atas kerugian yang timbul akibat kelalaian dalam menjaga akses akun.',
                        icon: CupertinoIcons.lock_shield_fill,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildLegalCard(
                        title: '3. Layanan Pelacak & Manajemen Lamaran',
                        content:
                            'AppliQ menyediakan perangkat lunak pelacak lamaran kerja terpadu (Job Tracker), pencatatan jadwal interview, kalkulasi statistik tingkat konversi, serta penyimpanan data pendukung karir. Layanan ini disediakan sebagaimana adanya ("as is") untuk membantu produktivitas pencarian kerja Anda.',
                        icon: CupertinoIcons.briefcase_fill,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildLegalCard(
                        title: '4. Hak Kekayaan Intelektual (Intellectual Property)',
                        content:
                            'Seluruh elemen antarmuka, desain grafis, logo AppliQ, kode sumber, dan dokumentasi terkait dilindungi oleh hak cipta dan hukum kekayaan intelektual. Anda dilarang mereproduksi, mendistribusikan ulang, atau merekayasa balik (reverse-engineer) tanpa izin tertulis.',
                        icon: CupertinoIcons.star_circle_fill,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildLegalCard(
                        title: '5. Batasan Tanggung Jawab & Jaminan',
                        content:
                            'AppliQ tidak menjamin hasil penerimaan kerja atau proses rekrutmen di perusahaan target mana pun. Kami berupaya maksimal menjaga keandalan server dan sinkronisasi data, namun tidak bertanggung jawab atas gangguan konektivitas jaringan pihak ketiga atau kendala teknis di luar kendali kami.',
                        icon: CupertinoIcons.exclamationmark_triangle_fill,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildLegalCard(
                        title: '6. Perubahan Ketentuan Layanan',
                        content:
                            'Kami berhak memperbarui Ketentuan Layanan ini sewaktu-waktu guna mematuhi perkembangan regulasi atau penambahan fitur baru. Pembaruan akan ditampilkan melalui halaman ini dengan tanggal efektif yang tertera.',
                        icon: CupertinoIcons.arrow_2_circlepath_circle_fill,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        isDark: isDark,
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

  void _showPrivacyPolicy() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF202024) : const Color(0xFFF4F4F5);
    final borderColor = isDark ? const Color(0xFF27272A) : AppColors.borderLight;

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
                              'User Privacy Policy',
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
                                  'Privasi Terenkripsi',
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
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    children: [
                      _buildLegalCard(
                        title: '1. Informasi yang Kami Kumpulkan',
                        content:
                            'Kami mengumpulkan informasi yang Anda berikan secara langsung saat menggunakan AppliQ, meliputi: data profil Google (nama, alamat email, URL foto avatar), data entri lamaran kerja (nama perusahaan, posisi, status, gaji, catatan tahapan interview), serta preferensi pengaturan lokal.',
                        icon: CupertinoIcons.person_badge_plus_fill,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildLegalCard(
                        title: '2. Cara Kami Menggunakan Informasi Anda',
                        content:
                            'Informasi Anda hanya digunakan untuk memfungsikan fitur pelacak lamaran: sinkronisasi database cloud Supabase, penjadwalan reminder interview, pembuatan statistik analitik pribadi, serta pengoptimalan pengalaman antarmuka aplikasi.',
                        icon: CupertinoIcons.gear_alt_fill,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildLegalCard(
                        title: '3. Enkripsi & Keamanan Database',
                        content:
                            'Seluruh data ditransmisikan menggunakan enkripsi TLS/HTTPS dan disimpan di database Supabase dengan pengamanan Row-Level Security (RLS). Hanya akun terautentikasi Anda yang memiliki izin membaca dan mengubah data lamaran Anda sendiri.',
                        icon: CupertinoIcons.lock_shield_fill,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildLegalCard(
                        title: '4. Tidak Ada Penjualan Data ke Pihak Ketiga',
                        content:
                            'AppliQ berjanji tidak akan pernah menjual, menyewakan, atau membagikan data riwayat lamaran dan data pribadi Anda kepada pengiklan atau pihak ketiga mana pun tanpa persetujuan eksplisit dari Anda.',
                        icon: CupertinoIcons.hand_raised_fill,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildLegalCard(
                        title: '5. Hak Kontrol & Penghapusan Akun Total',
                        content:
                            'Anda berhak setiap saat untuk memperbarui informasi profil, mengekspor riwayat lamaran, atau menghapus seluruh akun beserta database terkait secara permanen melalui tombol "Delete Account" di menu Edit Profil.',
                        icon: CupertinoIcons.trash_circle_fill,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        isDark: isDark,
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

  void _showFaqSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF202024) : const Color(0xFFF4F4F5);
    final borderColor = isDark ? const Color(0xFF27272A) : AppColors.borderLight;

    final List<Map<String, String>> faqs = [
      {
        'q': 'Apa itu AppliQ dan bagaimana cara kerjanya?',
        'a':
            'AppliQ adalah aplikasi pelacak lamaran kerja (Job Tracker) pintar yang membantu Anda mencatat setiap lamaran, menjadwalkan interview, melacak tahapan rekrutmen, hingga menganalisis konversi peluang karir secara real-time.',
      },
      {
        'q': 'Bagaimana cara menjadwalkan notifikasi reminder interview?',
        'a':
            'Saat menambahkan atau mengedit tahapan interview pada detail lamaran, tentukan tanggal dan waktu jadwal. Pastikan tombol toggle "Notifikasi Pengingat" di menu Settings aktif agar aplikasi dapat mengirimkan reminder tepat waktu.',
      },
      {
        'q': 'Apakah data lamaran dan riwayat gaji saya aman?',
        'a':
            'Sangat aman. AppliQ menerapkan standar Row-Level Security (RLS) di Supabase dan transmisi TLS terenkripsi. Tidak ada pengguna lain yang dapat melihat data posisi, gaji, maupun catatan interview Anda.',
      },
      {
        'q': 'Bagaimana cara mencari dan memfilter lamaran yang sudah ada?',
        'a':
            'Buka menu Pelacak Lamaran atau Jadwal Agenda. Anda dapat menggunakan Search Bar di bagian atas untuk mencari berdasarkan nama perusahaan atau posisi, serta memfilter berdasarkan status (Terkirim, Interview, Diterima, Ditolak).',
      },
      {
        'q': 'Apakah saya bisa mengekspor data riwayat lamaran?',
        'a':
            'Bisa. Fitur ekspor laporan tersedia untuk mengunduh rekapitulasi data lamaran kerja ke dalam format PDF profesional atau spreadsheet Excel.',
      },
      {
        'q': 'Bagaimana cara mengubah tema aplikasi dan foto profil?',
        'a':
            'Anda dapat mengaktifkan Dark Mode atau Monochrome Mode langsung dari halaman Settings ini. Foto profil Anda disinkronkan secara otomatis dan elegan dari akun Google Anda.',
      },
      {
        'q': 'Bagaimana cara menghapus akun secara permanen?',
        'a':
            'Masuk ke Edit Profile (klik kartu profil paling atas) lalu pilih "Delete Account" di bagian bawah. Seluruh data lamaran, riwayat interview, dan preferensi akun Anda akan dihapus permanen dari server.',
      },
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
                              'Pertanyaan umum & panduan penggunaan AppliQ',
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
                            onTap: () {
                              _triggerHaptic();
                              _showGeneralSettings();
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
                                title: 'Dark mode',
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
                                title: 'Monochrome mode',
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
                            title: 'Language',
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
                            title: 'Terms of service',
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
                            title: 'User policy',
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
                              size: 17,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Log Out',
                              style: TextStyle(
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
