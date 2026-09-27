import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_strings.dart';

/// Widget tampilan status error/gangguan jaringan yang ramah pengguna, humanis,
/// dan dilengkapi tombol aksi "Coba Lagi" (Retry).
class AppErrorStateWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final IconData? icon;
  final VoidCallback? onRetry;
  final bool isRetrying;
  final String? retryLabel;
  final bool compact;
  final EdgeInsetsGeometry padding;

  const AppErrorStateWidget({
    super.key,
    this.title,
    this.message,
    this.icon,
    this.onRetry,
    this.isRetrying = false,
    this.retryLabel,
    this.compact = false,
    this.padding = const EdgeInsets.all(24.0),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayTitle = title ?? AppStrings.connectionIssueTitle;
    final displayMessage = message ?? AppStrings.connectionIssueDesc;
    final displayIcon = icon ?? CupertinoIcons.wifi_exclamationmark;
    final displayRetryLabel = retryLabel ?? AppStrings.retry;

    if (compact) {
      return Padding(
        padding: padding,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E22) : const Color(0xFFF9F9FA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF2A2A30) : AppColors.borderLight,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.pastelCoral : AppColors.pastelCoral)
                      .withAlpha(isDark ? 40 : 35),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  displayIcon,
                  size: 18,
                  color: isDark ? AppColors.pastelCoral : const Color(0xFFD9534F),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayTitle,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayMessage,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(width: 8),
                _buildRetryButton(
                  context,
                  isDark: isDark,
                  isCompact: true,
                  label: displayRetryLabel,
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Soft rounded squircle icon container
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: (isDark ? AppColors.pastelCoral : AppColors.pastelCoral)
                    .withAlpha(isDark ? 40 : 35),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: (isDark ? AppColors.pastelCoral : AppColors.pastelCoral)
                      .withAlpha(isDark ? 80 : 70),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Icon(
                  displayIcon,
                  size: 34,
                  color: isDark ? AppColors.pastelCoral : const Color(0xFFD9534F),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              displayTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                displayMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              _buildRetryButton(
                context,
                isDark: isDark,
                isCompact: false,
                label: displayRetryLabel,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRetryButton(
    BuildContext context, {
    required bool isDark,
    required bool isCompact,
    required String label,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isRetrying
            ? null
            : () {
                HapticFeedback.lightImpact();
                onRetry?.call();
              },
        borderRadius: BorderRadius.circular(isCompact ? 10 : 14),
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 12 : 20,
            vertical: isCompact ? 8 : 11,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2C32) : const Color(0xFFEBEBF0),
            borderRadius: BorderRadius.circular(isCompact ? 10 : 14),
            border: Border.all(
              color: isDark ? const Color(0xFF383842) : const Color(0xFFDCDCE2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isRetrying) ...[
                SizedBox(
                  width: isCompact ? 12 : 14,
                  height: isCompact ? 12 : 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ] else ...[
                Icon(
                  CupertinoIcons.arrow_clockwise,
                  size: isCompact ? 13 : 15,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: isCompact ? 12 : 13.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Banner Pill mengambang yang halus untuk memberi tahu pengguna
/// bahwa data yang ditampilkan berasal dari cache lokal perangkat saat offline.
class OfflinePillIndicator extends StatelessWidget {
  final VoidCallback? onSync;
  final bool isSyncing;
  final EdgeInsetsGeometry margin;

  const OfflinePillIndicator({
    super.key,
    this.onSync,
    this.isSyncing = false,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: margin,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.pastelAmber : AppColors.pastelAmber)
            .withAlpha(isDark ? 30 : 25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isDark ? AppColors.pastelAmber : AppColors.pastelAmber)
              .withAlpha(isDark ? 80 : 70),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSyncing ? CupertinoIcons.arrow_2_circlepath : CupertinoIcons.wifi_slash,
            size: 14,
            color: isDark ? AppColors.pastelAmber : const Color(0xFFC07000),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              isSyncing ? AppStrings.syncingData : AppStrings.offlineModeBanner,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.pastelAmber : const Color(0xFF8A5000),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onSync != null && !isSyncing) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onSync?.call();
              },
              child: Text(
                AppStrings.retry,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
