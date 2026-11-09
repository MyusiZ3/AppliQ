import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/config/app_config.dart';
import '../core/constants/app_colors.dart';
import '../utils/language_manager.dart';
import '../utils/theme_manager.dart';
import '../utils/ui_helper.dart';

/// Model informasi pembaruan aplikasi
class AppUpdateInfo {
  final String latestVersion;
  final String currentVersion;
  final int versionGap;
  final bool isForceUpdate;
  final bool isUpdateAvailable;
  final String changelog;
  final String downloadUrl;
  final String releaseUrl;

  const AppUpdateInfo({
    required this.latestVersion,
    required this.currentVersion,
    required this.versionGap,
    required this.isForceUpdate,
    required this.isUpdateAvailable,
    required this.changelog,
    required this.downloadUrl,
    required this.releaseUrl,
  });
}

/// Helper lokalisasi multibahasa untuk fitur pembaruan (ID, EN, JA, KO)
class _UpdateLocalization {
  static AppLanguage get _lang => LanguageManager.current;

  static String title(bool isForce) {
    if (isForce) {
      switch (_lang) {
        case AppLanguage.en:
          return 'Mandatory App Update';
        case AppLanguage.ja:
          return '必須アプリアップデート';
        case AppLanguage.ko:
          return '필수 앱 업데이트';
        case AppLanguage.id:
          return 'Pembaruan Wajib Aplikasi';
      }
    } else {
      switch (_lang) {
        case AppLanguage.en:
          return 'Update Available';
        case AppLanguage.ja:
          return 'アップデートが利用可能';
        case AppLanguage.ko:
          return '업데이트 이용 가능';
        case AppLanguage.id:
          return 'Pembaruan Tersedia';
      }
    }
  }

  static String subtitle(bool isForce, int gap, String latestVer) {
    if (isForce) {
      switch (_lang) {
        case AppLanguage.en:
          return 'Your app is $gap versions behind. To maintain data stability and security, you must update before continuing.';
        case AppLanguage.ja:
          return 'アプリのバージョンが$gap件遅れています。データの安定性とセキュリティのため、続行するには更新が必要です。';
        case AppLanguage.ko:
          return '앱 버전이 $gap개 릴리스 지연되었습니다. 데이터 안정성과 보안을 위해 계속 진행하려면 업데이트해야 합니다.';
        case AppLanguage.id:
          return 'Versi aplikasi Anda tertinggal $gap rilis. Untuk menjaga stabilitas data dan keamanan, Anda wajib memperbarui aplikasi untuk melanjutkan.';
      }
    } else {
      switch (_lang) {
        case AppLanguage.en:
          return 'Version v$latestVer is ready to download with feature updates & performance improvements.';
        case AppLanguage.ja:
          return '新機能とパフォーマンス向上が含まれたバージョンv$latestVerがダウンロード可能です。';
        case AppLanguage.ko:
          return '기능 개선 및 성능 향상이 포함된 v$latestVer 버전을 다운로드할 수 있습니다.';
        case AppLanguage.id:
          return 'Versi v$latestVer siap diunduh dengan pembaruan fitur & peningkatan performa.';
      }
    }
  }

  static String get forceBanner {
    switch (_lang) {
      case AppLanguage.en:
        return 'Maximum lag tolerance (3 versions) exceeded. App access is locked until updated.';
      case AppLanguage.ja:
        return '許容制限（3バージョン）を超過しました。更新が完了するまでアプリの利用が制限されます。';
      case AppLanguage.ko:
        return '최대 허용 기준(3개 버전)이 초과되었습니다. 업데이트가 완료될 때까지 앱 이용이 제한됩니다.';
      case AppLanguage.id:
        return 'Batas toleransi maksimal (3 versi) telah terlewati. Akses aplikasi dikunci hingga versi diperbarui.';
    }
  }

  static String get changelogTitle {
    switch (_lang) {
      case AppLanguage.en:
        return 'Release Notes (Changelog):';
      case AppLanguage.ja:
        return 'リリースノート（更新履歴）:';
      case AppLanguage.ko:
        return '릴리스 노트 (변경 사항):';
      case AppLanguage.id:
        return 'Catatan Rilis (Changelog):';
    }
  }

  static String get defaultChangelog {
    switch (_lang) {
      case AppLanguage.en:
        return 'Stability improvements, bug fixes, and app performance optimizations.';
      case AppLanguage.ja:
        return '安定性の向上、バグ修正、およびアプリパフォーマンスの最適化。';
      case AppLanguage.ko:
        return '안정성 향상, 버그 수정 및 앱 성능 최적화.';
      case AppLanguage.id:
        return 'Peningkatan stabilitas, perbaikan bug, dan optimalisasi performa aplikasi.';
    }
  }

  static String get instructionNotice {
    switch (_lang) {
      case AppLanguage.en:
        return 'You can also access this update anytime via:\nProfile  →  Settings  →  About AppliQ';
      case AppLanguage.ja:
        return 'アップデートはいつでもこちらから利用できます:\nプロフィール  →  設定  →  AppliQについて';
      case AppLanguage.ko:
        return '언제든지 다음 메뉴에서 업데이트할 수 있습니다:\n프로필  →  설정  →  AppliQ 정보';
      case AppLanguage.id:
        return 'Pembaruan juga dapat diakses kapan saja di:\nProfil  →  Pengaturan  →  Tentang AppliQ';
    }
  }

  static String get downloadNotice {
    switch (_lang) {
      case AppLanguage.en:
        return 'Direct APK package download from GitHub Releases';
      case AppLanguage.ja:
        return 'GitHub ReleasesからAPKファイルを直接ダウンロード';
      case AppLanguage.ko:
        return 'GitHub Releases에서 APK 패키지 직접 다운로드';
      case AppLanguage.id:
        return 'Unduh langsung paket APK dari GitHub Releases';
    }
  }

  static String updateBtn(bool isForce) {
    if (isForce) {
      switch (_lang) {
        case AppLanguage.en:
          return 'Update Now (Required)';
        case AppLanguage.ja:
          return '今すぐ更新（必須）';
        case AppLanguage.ko:
          return '지금 업데이트 (필수)';
        case AppLanguage.id:
          return 'Perbarui Sekarang (Wajib)';
      }
    } else {
      switch (_lang) {
        case AppLanguage.en:
          return 'Update Now';
        case AppLanguage.ja:
          return '今すぐ更新';
        case AppLanguage.ko:
          return '지금 업데이트';
        case AppLanguage.id:
          return 'Perbarui Sekarang';
      }
    }
  }

  static String get laterBtn {
    switch (_lang) {
      case AppLanguage.en:
        return 'Later';
      case AppLanguage.ja:
        return '後で';
      case AppLanguage.ko:
        return '나중에';
      case AppLanguage.id:
        return 'Nanti Saja';
    }
  }

  static String upToDate(String ver) {
    switch (_lang) {
      case AppLanguage.en:
        return 'AppliQ is already on the latest version (v$ver).';
      case AppLanguage.ja:
        return 'AppliQは既に最新バージョンです (v$ver)。';
      case AppLanguage.ko:
        return 'AppliQ가 이미 최신 버전입니다 (v$ver).';
      case AppLanguage.id:
        return 'AppliQ sudah menggunakan versi terbaru (v$ver).';
    }
  }

  static String get checkError {
    switch (_lang) {
      case AppLanguage.en:
        return 'Unable to check for updates. Please check your internet connection.';
      case AppLanguage.ja:
        return 'アップデートを確認できません。インターネット接続を確認してください。';
      case AppLanguage.ko:
        return '업데이트를 확인할 수 없습니다. 인터넷 연결을 확인해 주세요.';
      case AppLanguage.id:
        return 'Tidak dapat memeriksa pembaruan. Silakan periksa koneksi internet Anda.';
    }
  }

  static String get downloadError {
    switch (_lang) {
      case AppLanguage.en:
        return 'Failed to open download link. Please visit GitHub Releases.';
      case AppLanguage.ja:
        return 'ダウンロードリンクを開けませんでした。GitHub Releasesをご覧ください。';
      case AppLanguage.ko:
        return '다운로드 링크를 열 수 없습니다. GitHub Releases를 방문해 주세요.';
      case AppLanguage.id:
        return 'Gagal membuka tautan unduhan. Kunjungi github.com/MyusiZ3/AppliQ/releases';
    }
  }
}

/// Layanan manajemen pembaruan aplikasi AppliQ dari GitHub Releases
class AppUpdateService {
  static const String _repoOwner = 'MyusiZ3';
  static const String _repoName = 'AppliQ';
  static const String _snoozeTimestampKey = 'update_snooze_timestamp';
  static const String _snoozeVersionKey = 'update_snooze_version';

  /// Notifier status pembaruan aplikasi yang dapat di-listen oleh UI (misal ProfileScreen)
  static final ValueNotifier<AppUpdateInfo?> updateInfoNotifier = ValueNotifier(null);

  /// Parse string versi SemVer (misal "v1.0.7" atau "1.0.7+1") menjadi `List<int>` [major, minor, patch]
  static List<int> parseSemVer(String raw) {
    try {
      var cleaned = raw.trim();
      if (cleaned.startsWith('v') || cleaned.startsWith('V')) {
        cleaned = cleaned.substring(1);
      }
      if (cleaned.contains('+')) {
        cleaned = cleaned.split('+')[0];
      }
      final parts = cleaned.split('.').map((p) => int.tryParse(p) ?? 0).toList();
      while (parts.length < 3) {
        parts.add(0);
      }
      return parts.take(3).toList();
    } catch (_) {
      return [0, 0, 0];
    }
  }

  /// Membandingkan dua versi SemVer: return > 0 jika v1 > v2, 0 jika sama, < 0 jika v1 < v2
  static int compareSemVer(String v1, String v2) {
    final p1 = parseSemVer(v1);
    final p2 = parseSemVer(v2);

    for (var i = 0; i < 3; i++) {
      if (p1[i] != p2[i]) {
        return p1[i].compareTo(p2[i]);
      }
    }
    return 0;
  }

  /// Menghitung selisih matematis versi
  static int calculateSemVerGap(List<int> current, List<int> latest) {
    if (latest[0] > current[0]) {
      return (latest[0] - current[0]) * 10;
    }
    if (latest[1] > current[1]) {
      return (latest[1] - current[1]) * 3 + (latest[2] - current[2]).clamp(0, 99);
    }
    return (latest[2] - current[2]).clamp(0, 99);
  }

  /// Mengambil data rilis dari GitHub Releases API
  static Future<AppUpdateInfo?> fetchUpdateInfo() async {
    try {
      final url = Uri.parse('https://api.github.com/repos/$_repoOwner/$_repoName/releases?per_page=15');
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'AppliQ-Mobile-App',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        return null;
      }

      final List<dynamic> releases = json.decode(response.body);
      if (releases.isEmpty) {
        return null;
      }

      final latest = releases.first as Map<String, dynamic>;
      final rawTag = latest['tag_name']?.toString() ?? '';
      final latestTag = rawTag.startsWith('v') || rawTag.startsWith('V')
          ? rawTag.substring(1)
          : rawTag;

      final currentVersion = AppConfig.appVersion;

      // 1. Hitung berapa banyak rilis yang ada di atas versi lokal
      int newerReleasesCount = 0;
      for (final rel in releases) {
        if (rel is Map<String, dynamic>) {
          final t = rel['tag_name']?.toString() ?? '';
          if (compareSemVer(t, currentVersion) > 0) {
            newerReleasesCount++;
          }
        }
      }

      // 2. Hitung jarak semver matematis
      final currentSemVer = parseSemVer(currentVersion);
      final latestSemVer = parseSemVer(latestTag);
      final semVerGap = calculateSemVerGap(currentSemVer, latestSemVer);

      // Ambil gap terbesar untuk keamanan
      final versionGap = math.max(newerReleasesCount, semVerGap);
      final isUpdateAvailable = compareSemVer(latestTag, currentVersion) > 0;
      final isForceUpdate = isUpdateAvailable && versionGap >= 3;

      // 3. Cari URL direct download APK dari assets
      String downloadUrl = '';
      final assets = latest['assets'] as List<dynamic>?;
      if (assets != null && assets.isNotEmpty) {
        for (final asset in assets) {
          final name = asset['name']?.toString().toLowerCase() ?? '';
          if (name.endsWith('.apk')) {
            downloadUrl = asset['browser_download_url']?.toString() ?? '';
            break;
          }
        }
      }

      if (downloadUrl.isEmpty) {
        // Fallback standar ke format GitHub Releases
        downloadUrl = 'https://github.com/$_repoOwner/$_repoName/releases/download/$rawTag/app-release.apk';
      }

      final releaseUrl = latest['html_url']?.toString() ??
          'https://github.com/$_repoOwner/$_repoName/releases';

      final changelog = (latest['body']?.toString() ?? '').trim();

      final info = AppUpdateInfo(
        latestVersion: latestTag,
        currentVersion: currentVersion,
        versionGap: versionGap,
        isForceUpdate: isForceUpdate,
        isUpdateAvailable: isUpdateAvailable,
        changelog: changelog.isNotEmpty
            ? changelog
            : _UpdateLocalization.defaultChangelog,
        downloadUrl: downloadUrl,
        releaseUrl: releaseUrl,
      );

      updateInfoNotifier.value = info;
      return info;
    } catch (_) {
      return null;
    }
  }

  /// Mengecek pembaruan aplikasi dan menampilkan dialog jika tersedia.
  /// [isManual]: true jika dipicu dari tombol user (misal di halaman Profil),
  /// false jika dipicu otomatis saat aplikasi dibuka.
  static Future<void> checkForUpdate(
    BuildContext context, {
    bool isManual = false,
  }) async {
    final info = await fetchUpdateInfo();

    if (!context.mounted) return;

    if (info == null) {
      if (isManual) {
        UIHelper.showErrorSnackBar(
          context,
          _UpdateLocalization.checkError,
        );
      }
      return;
    }

    if (!info.isUpdateAvailable) {
      if (isManual) {
        UIHelper.showSuccessSnackBar(
          context,
          _UpdateLocalization.upToDate(info.currentVersion),
        );
      }
      return;
    }

    // Jika bukan force update dan bukan pengecekan manual, periksa apakah pengguna sudah menunda (snooze)
    if (!info.isForceUpdate && !isManual) {
      final prefs = await SharedPreferences.getInstance();
      final snoozeTime = prefs.getInt(_snoozeTimestampKey);
      final snoozeVer = prefs.getString(_snoozeVersionKey);

      if (snoozeTime != null && snoozeVer == info.latestVersion) {
        final elapsed = DateTime.now().millisecondsSinceEpoch - snoozeTime;
        // Tunda selama 24 jam (24 * 60 * 60 * 1000 ms)
        if (elapsed < 86400000) {
          return;
        }
      }
    }

    if (!context.mounted) return;

    // Tampilkan dialog pembaruan
    _showUpdateDialog(context, info);
  }

  /// Menampilkan popup modal pembaruan (Neo-Pastel Design)
  static void _showUpdateDialog(BuildContext context, AppUpdateInfo info) {
    showGeneralDialog(
      context: context,
      barrierDismissible: !info.isForceUpdate,
      barrierLabel: 'AppUpdateDialog',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (dialogContext, anim1, anim2) {
        return PopScope(
          canPop: !info.isForceUpdate,
          child: _UpdateDialogContent(info: info),
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * anim1.value),
          child: Opacity(
            opacity: anim1.value,
            child: child,
          ),
        );
      },
    );
  }

  /// Simpan waktu penundaan pembaruan ke SharedPreferences
  static Future<void> snoozeUpdate(String latestVersion) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_snoozeTimestampKey, DateTime.now().millisecondsSinceEpoch);
    await prefs.setString(_snoozeVersionKey, latestVersion);
  }

  /// Memulai proses download APK langsung ke browser/download manager perangkat
  static Future<void> triggerDownload(BuildContext context, AppUpdateInfo info) async {
    try {
      final uri = Uri.parse(info.downloadUrl);
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        final fallbackUri = Uri.parse(info.releaseUrl);
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (context.mounted) {
        UIHelper.showErrorSnackBar(
          context,
          _UpdateLocalization.downloadError,
        );
      }
    }
  }
}

/// Widget konten pop-up dialog pembaruan
class _UpdateDialogContent extends StatelessWidget {
  final AppUpdateInfo info;

  const _UpdateDialogContent({required this.info});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMono = ThemeManager.accentNotifier.value == AccentThemeMode.monochrome;

    final bgColor = isDark ? const Color(0xFF1E1E22) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2E2E33) : const Color(0xFFE4E4E7);
    final cardBg = isDark ? const Color(0xFF26262B) : const Color(0xFFF4F4F6);

    final titleColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final subtitleColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.15),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon & Header
                Center(
                  child: Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: info.isForceUpdate
                          ? (isMono
                              ? (isDark ? const Color(0xFF3F3F46) : const Color(0xFFE4E4E7))
                              : (isDark ? const Color(0xFF451A1A) : const Color(0xFFFFECEB)))
                          : (isMono
                              ? (isDark ? const Color(0xFF3F3F46) : const Color(0xFFE4E4E7))
                              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFEDE9FE))),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      info.isForceUpdate
                          ? CupertinoIcons.exclamationmark_shield_fill
                          : CupertinoIcons.arrow_down_circle_fill,
                      size: 32,
                      color: info.isForceUpdate
                          ? (isMono
                              ? (isDark ? Colors.white : const Color(0xFF18181B))
                              : AppColors.expense)
                          : (isMono
                              ? (isDark ? Colors.white : const Color(0xFF18181B))
                              : AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Version Badge (Current -> Latest)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2A2A30) : const Color(0xFFE4E4E7),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      'v${info.currentVersion}  →  v${info.latestVersion}',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                        color: isDark ? Colors.white70 : const Color(0xFF3F3F46),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Dialog Title
                Text(
                  _UpdateLocalization.title(info.isForceUpdate),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 6),

                // Subtitle / Reason
                Text(
                  _UpdateLocalization.subtitle(info.isForceUpdate, info.versionGap, info.latestVersion),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: subtitleColor,
                  ),
                ),
                const SizedBox(height: 14),

                // Warning Banner Khusus Force Update
                if (info.isForceUpdate) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2D1616) : const Color(0xFFFFF1F0),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? const Color(0xFF5C2626) : const Color(0xFFFFCCC7),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          CupertinoIcons.info_circle_fill,
                          size: 16,
                          color: isMono ? (isDark ? Colors.white70 : const Color(0xFF18181B)) : AppColors.expense,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _UpdateLocalization.forceBanner,
                            style: TextStyle(
                              fontSize: 11.5,
                              height: 1.35,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFFFFB4AB) : const Color(0xFFCF1322),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Catatan Pembaruan (Changelog Box)
                Container(
                  padding: const EdgeInsets.all(12),
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
                            CupertinoIcons.doc_plaintext,
                            size: 13,
                            color: isDark ? AppColors.textHintDark : AppColors.textHint,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _UpdateLocalization.changelogTitle,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 110),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Text(
                            info.changelog,
                            style: TextStyle(
                              fontSize: 11.5,
                              height: 1.45,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Lokasi Pembaruan Mandiri (Instruksi jelas untuk user)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: 0.8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.location_fill,
                        size: 13,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _UpdateLocalization.instructionNotice,
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.35,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Note Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.cloud_download,
                      size: 13,
                      color: isDark ? AppColors.textHintDark : AppColors.textHint,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        _UpdateLocalization.downloadNotice,
                        style: TextStyle(
                          fontSize: 10.5,
                          color: isDark ? AppColors.textHintDark : AppColors.textHint,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action Buttons
                ElevatedButton(
                  onPressed: () {
                    AppUpdateService.triggerDownload(context, info);
                    if (!info.isForceUpdate) {
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isMono
                        ? (isDark ? Colors.white : const Color(0xFF18181B))
                        : (info.isForceUpdate ? AppColors.expense : AppColors.primary),
                    foregroundColor: isMono
                        ? (isDark ? const Color(0xFF18181B) : Colors.white)
                        : Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(CupertinoIcons.arrow_down_to_line_alt, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        _UpdateLocalization.updateBtn(info.isForceUpdate),
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                // Tombol Nanti Saja (Hanya jika bukan force update)
                if (!info.isForceUpdate) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () async {
                      await AppUpdateService.snoozeUpdate(info.latestVersion);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      _UpdateLocalization.laterBtn,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textHintDark : AppColors.textHint,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

