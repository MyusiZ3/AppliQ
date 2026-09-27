import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Helper tangguh untuk menangani batas waktu (timeout), percobaan ulang otomatis (auto-retry),
/// dan klasifikasi gangguan koneksi jaringan.
class NetworkHelper {
  /// Default batas waktu untuk query standar
  static const Duration defaultTimeout = Duration(seconds: 10);

  /// Default batas waktu untuk unggahan berkas / dokumen
  static const Duration uploadTimeout = Duration(seconds: 30);

  /// Mengeksekusi [action] dengan perlindungan timeout dan auto-retry saat koneksi bermasalah.
  static Future<T> runWithRetry<T>(
    Future<T> Function() action, {
    Duration timeout = defaultTimeout,
    int maxRetries = 2,
    Duration retryDelay = const Duration(milliseconds: 1200),
    bool Function(dynamic error)? shouldRetry,
  }) async {
    int attempts = 0;

    while (true) {
      try {
        attempts++;
        return await action().timeout(
          timeout,
          onTimeout: () {
            throw TimeoutException(
              'Waktu tunggu koneksi habis (${timeout.inSeconds} detik). Periksa sinyal internet Anda.',
              timeout,
            );
          },
        );
      } catch (error) {
        final canRetry = shouldRetry != null
            ? shouldRetry(error)
            : isNetworkError(error);

        if (attempts <= maxRetries && canRetry) {
          final backoffDelay = retryDelay * attempts;
          if (kDebugMode) {
            debugPrint(
              'NetworkHelper: Percobaan ke-$attempts gagal karena ${error.runtimeType}. '
              'Mencoba kembali dalam ${backoffDelay.inMilliseconds}ms...',
            );
          }
          await Future.delayed(backoffDelay);
          continue;
        }

        // Jika kuota retry habis atau error bukan terkait jaringan, lempar kembali error
        rethrow;
      }
    }
  }

  /// Menentukan apakah [error] disebabkan oleh koneksi jaringan, timeout, atau DNS lookup.
  static bool isNetworkError(dynamic error) {
    if (error == null) return false;

    if (error is SocketException ||
        error is TimeoutException ||
        error is http.ClientException) {
      return true;
    }

    // Jangan coba ulang jika error otentikasi atau izin akses
    if (error is AuthException) {
      return false;
    }

    if (error is PostgrestException) {
      final code = error.code ?? '';
      // 503 Service Unavailable, 504 Gateway Timeout, PGRST000 (connection failed)
      if (code == '503' || code == '504' || code == 'PGRST000' || code == '08006' || code == '08001') {
        return true;
      }
      return false;
    }

    final message = error.toString().toLowerCase();
    return message.contains('socketexception') ||
        message.contains('failed host lookup') ||
        message.contains('connection closed') ||
        message.contains('connection refused') ||
        message.contains('connection timed out') ||
        message.contains('network is unreachable') ||
        message.contains('clientexception') ||
        message.contains('handshakeexception') ||
        message.contains('timed out');
  }
}
