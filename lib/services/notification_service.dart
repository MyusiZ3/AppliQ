import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'appliq_reminders';
  static const String _channelName = 'Pengingat & Agenda AppliQ';
  static const String _channelDescription =
      'Notifikasi pengingat jadwal wawancara, tes kerja, dan follow-up lamaran.';

  bool _isInitialized = false;
  bool? _cachedIsEnabled;
  tz.Location? _cachedLocation;

  tz.Location _getLocation() {
    if (_cachedLocation != null) return _cachedLocation!;
    try {
      _cachedLocation = tz.local;
    } catch (_) {
      try {
        _cachedLocation = tz.getLocation('Asia/Jakarta');
      } catch (_) {
        _cachedLocation = tz.UTC;
      }
    }
    return _cachedLocation!;
  }

  /// Invalidate cache status pengingat saat user mengubah di profil
  void invalidateEnabledCache() {
    _cachedIsEnabled = null;
  }

  /// Cek apakah notifikasi diizinkan oleh user di pengaturan profil
  Future<bool> isEnabled() async {
    if (_cachedIsEnabled != null) return _cachedIsEnabled!;
    try {
      final prefs = await SharedPreferences.getInstance();
      final isPaused = prefs.getBool('pause_notifications') ?? false;
      _cachedIsEnabled = !isPaused;
      return _cachedIsEnabled!;
    } catch (_) {
      return true;
    }
  }

  /// Inisialisasi Service Notifikasi
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Inisialisasi Database Zona Waktu
      tz.initializeTimeZones();

      const androidSettings =
          AndroidInitializationSettings('@drawable/ic_notification');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          debugPrint('Notification clicked with payload: ${details.payload}');
        },
      );

      // Buat Notifikasi Channel Khusus Android dengan Prioritas Tertinggi (Popup Heads-up)
      if (Platform.isAndroid) {
        final androidImplementation = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        if (androidImplementation != null) {
          const androidChannel = AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDescription,
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
            showBadge: true,
          );

          await androidImplementation.createNotificationChannel(androidChannel);
        }
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing NotificationService: $e');
    }
  }

  /// Meminta Izin Notifikasi (Android 13+ & iOS)
  Future<bool> requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        final androidImplementation = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        if (androidImplementation != null) {
          final granted =
              await androidImplementation.requestNotificationsPermission();
          return granted ?? false;
        }
      } else if (Platform.isIOS) {
        final iosImplementation = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        if (iosImplementation != null) {
          final granted = await iosImplementation.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
          return granted ?? false;
        }
      }
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
    }
    return false;
  }

  /// Tampilkan notifikasi instan / uji coba popup
  Future<void> showInstantNotification({
    int id = 1001,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) return;
    if (!await isEnabled()) return;
    try {
      const androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@drawable/ic_notification',
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        color: Color(0xFF18181B),
        enableVibration: true,
        playSound: true,
        fullScreenIntent: true,
        styleInformation: BigTextStyleInformation(''),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error showing instant notification: $e');
    }
  }

  /// Jadwalkan Notifikasi Pengingat Interview / Tes Kerja
  Future<void> scheduleInterviewReminder({
    required int id,
    required String company,
    required String position,
    String? stageName,
    required DateTime scheduledAt,
    int remindMinutesBefore = 60,
  }) async {
    if (!_isInitialized) return;
    if (!await isEnabled()) return;
    try {
      final reminderTime = scheduledAt.subtract(Duration(minutes: remindMinutesBefore));

      // Jika waktu reminder sudah lewat, tidak perlu dijadwalkan
      if (reminderTime.isBefore(DateTime.now())) return;

      final location = _getLocation();
      final tzReminderTime = tz.TZDateTime.from(reminderTime, location);

      const androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@drawable/ic_notification',
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        color: Color(0xFF18181B),
        enableVibration: true,
        playSound: true,
        styleInformation: BigTextStyleInformation(''),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final reminderLabel = remindMinutesBefore >= 60
          ? '${remindMinutesBefore ~/ 60} jam'
          : '$remindMinutesBefore menit';

      final stage = (stageName != null && stageName.trim().isNotEmpty)
          ? stageName.trim()
          : 'Wawancara';

      final title = 'Pengingat $stage • $company';
      final body = 'Agenda $stage untuk posisi $position akan dimulai dalam $reminderLabel. Siapkan berkas dan performa terbaikmu!';

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzReminderTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('Error scheduling interview reminder: $e');
    }
  }

  /// Jadwalkan Notifikasi Pengingat Follow-up Lamaran (H+7 setelah melamar)
  Future<void> scheduleFollowUpReminder({
    required int id,
    required String company,
    required String position,
    required DateTime targetDate,
  }) async {
    if (!_isInitialized) return;
    if (!await isEnabled()) return;
    try {
      if (targetDate.isBefore(DateTime.now())) return;

      final location = _getLocation();
      final tzTargetTime = tz.TZDateTime.from(targetDate, location);

      const androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@drawable/ic_notification',
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        color: Color(0xFF18181B),
        enableVibration: true,
        playSound: true,
        styleInformation: BigTextStyleInformation(''),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final title = 'Perlu Follow-up • $company';
      final body = 'Lamaran untuk posisi $position sudah 7 hari tanpa kabar. Yuk buka AppliQ untuk template pesan HR!';

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzTargetTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('Error scheduling follow-up reminder: $e');
    }
  }

  /// Tampilkan notifikasi berkala otomatis jika ada lamaran yang sudah butuh follow-up (> 7 hari)
  Future<void> checkAndShowFollowUpNotification(List<dynamic> staleApps) async {
    if (staleApps.isEmpty) return;
    if (!_isInitialized) return;
    if (!await isEnabled()) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final lastDate = prefs.getString('last_followup_notif_date');

      if (lastDate == todayStr) return; // Maksimal 1 notifikasi rangkuman per hari agar tidak mengganggu

      final count = staleApps.length;
      final dynamic firstApp = staleApps.first;
      final company = (firstApp is Map) ? (firstApp['company'] ?? 'perusahaan') : firstApp.companyName;

      final title = 'Perlu Follow-up ($count Lamaran)';
      final body = count == 1
          ? 'Lamaran di $company sudah > 7 hari tanpa kabar. Yuk kirim pesan follow-up ke HR!'
          : '$count lamaran termasuk di $company sudah > 7 hari tanpa kabar. Buka AppliQ untuk template pesan!';

      await showInstantNotification(
        id: 8888,
        title: title,
        body: body,
      );

      await prefs.setString('last_followup_notif_date', todayStr);
    } catch (e) {
      debugPrint('Error triggering follow-up notification: $e');
    }
  }

  /// Batalkan notifikasi tertentu berdasarkan ID
  Future<void> cancelNotification(int id) async {
    if (!_isInitialized) return;
    try {
      await _notificationsPlugin.cancel(id);
    } catch (e) {
      debugPrint('Error cancelling notification: $e');
    }
  }

  /// Batalkan seluruh notifikasi terjadwal
  Future<void> cancelAll() async {
    if (!_isInitialized) return;
    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('Error cancelling all notifications: $e');
    }
  }
}
