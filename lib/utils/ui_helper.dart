import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/app_colors.dart';
import 'navigator_key.dart';

class UIHelper {
  static void showSuccessSnackBar(BuildContext context, String message) {
    _showTopToast(context, message, AppColors.income, CupertinoIcons.check_mark_circled_solid);
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    _showTopToast(context, message, AppColors.expense, CupertinoIcons.exclamationmark_circle_fill);
  }

  static void showInfoSnackBar(BuildContext context, String message) {
    _showTopToast(context, message, AppColors.primary, CupertinoIcons.info_circle_fill);
  }

  static void showGlobalErrorToast(String message) {
    final ctx = navigatorKey.currentContext;
    if (ctx != null) {
      _showTopToast(ctx, message, AppColors.expense, CupertinoIcons.exclamationmark_circle_fill);
    }
  }

  static void showGlobalSuccessToast(String message) {
    final ctx = navigatorKey.currentContext;
    if (ctx != null) {
      _showTopToast(ctx, message, AppColors.income, CupertinoIcons.check_mark_circled_solid);
    }
  }

  static void _showTopToast(BuildContext context, String message, Color color, IconData icon) {
    try {
      OverlayState? overlay;
      if (context.mounted) {
        overlay = Overlay.maybeOf(context);
      }
      overlay ??= navigatorKey.currentState?.overlay;

      if (overlay == null) return;

      HapticFeedback.lightImpact();

      late OverlayEntry overlayEntry;

      overlayEntry = OverlayEntry(
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final toastBg = isDark ? const Color(0xCC1C1C1E) : const Color(0xEEFFFFFF);
          final textColor = isDark ? Colors.white : const Color(0xFF18181B);
          final borderColor = isDark
              ? Colors.white.withValues(alpha: 0.14)
              : Colors.black.withValues(alpha: 0.08);

          return Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 20,
            right: 20,
            child: Material(
              color: Colors.transparent,
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutBack,
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, -30 * (1 - value)),
                    child: Transform.scale(
                      scale: 0.95 + (0.05 * value),
                      child: Opacity(
                        opacity: value.clamp(0.0, 1.0),
                        child: child,
                      ),
                    ),
                  );
                },
                child: Align(
                  alignment: Alignment.topCenter,
                  child: GestureDetector(
                    onTap: () {
                      if (overlayEntry.mounted) overlayEntry.remove();
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: toastBg,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: borderColor, width: 1.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(icon, color: color, size: 14),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  message,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );

      overlay.insert(overlayEntry);
      Future.delayed(const Duration(milliseconds: 3200), () {
        if (overlayEntry.mounted) {
          overlayEntry.remove();
        }
      });
    } catch (e) {
      debugPrint('UIHelper: Error showing toast: $e');
    }
  }

  static Future<T?> showPremiumBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: isScrollControlled,
      elevation: 0,
      showDragHandle: false,
      builder: (ctx) {
        final keyboardInset = MediaQuery.of(ctx).viewInsets.bottom;
        final bottomPadding = MediaQuery.of(ctx).padding.bottom;
        final isDark = Theme.of(ctx).brightness == Brightness.dark;

        return BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: AnimatedPadding(
            padding: EdgeInsets.only(bottom: keyboardInset),
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutQuad,
            child: SafeArea(
              top: false,
              bottom: true,
              child: Container(
                margin: EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  bottomPadding > 0 ? 8 : 16,
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF18181B) : Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.black.withValues(alpha: 0.08),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
                      blurRadius: 32,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Global Error Handler untuk menangani berbagai jenis exception secara ramah pengguna
  static String parseErrorMessage(dynamic error) {
    if (error is AuthException) {
      if (error.message.contains('Invalid login credentials')) {
        return 'Email atau kata sandi tidak sesuai.';
      } else if (error.message.contains('User cancelled') || error.message.contains('canceled')) {
        return 'Proses masuk dibatalkan.';
      }
      return 'Gagal masuk akun. Silakan coba lagi.';
    } else if (error is PostgrestException) {
      debugPrint('PostgrestException details: code=${error.code}, message=${error.message}, details=${error.details}, hint=${error.hint}');
      if (error.code == '42P01') {
        return 'Tabel database belum ditemukan. Silakan jalankan script SQL di Supabase.';
      } else if (error.code == '42501' || error.message.toLowerCase().contains('row-level security') || error.message.toLowerCase().contains('permission denied')) {
        return 'Akses ditolak oleh RLS Supabase. Pastikan RLS policy telah dibuat untuk tabel ini.';
      } else if (error.code == '42703') {
        return 'Struktur kolom database belum sesuai: ${error.message}';
      } else if (error.code == 'PGRST301') {
        return 'Sesi masuk telah berakhir. Silakan masuk kembali.';
      }
      return error.message.isNotEmpty ? error.message : 'Gagal memproses data. Silakan coba beberapa saat lagi.';
    } else if (error is SocketException) {
      return 'Koneksi internet terputus. Periksa jaringan Anda.';
    } else if (error is TimeoutException) {
      return 'Waktu koneksi habis. Silakan coba kembali.';
    } else if (error is PlatformException) {
      if (error.code == 'sign_in_failed' || error.code == '10' || error.code == '12500') {
        return 'Gagal masuk dengan Google. Silakan periksa koneksi dan coba lagi.';
      }
      return error.message ?? 'Terjadi kendala pada sistem. Silakan coba lagi.';
    }
    return error.toString().replaceFirst('Exception: ', '');
  }

  static void handleError(BuildContext context, dynamic error) {
    final message = parseErrorMessage(error);
    showErrorSnackBar(context, message);
  }
}
