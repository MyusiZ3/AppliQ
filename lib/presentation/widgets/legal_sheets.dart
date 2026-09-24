import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_strings.dart';

class LegalSheets {
  static void showTermsOfService(BuildContext context) {
    HapticFeedback.lightImpact();
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

  static void showPrivacyPolicy(BuildContext context) {
    HapticFeedback.lightImpact();
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

  static Widget _buildLegalCard({
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
              fontSize: 13,
              height: 1.5,
              letterSpacing: -0.1,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
