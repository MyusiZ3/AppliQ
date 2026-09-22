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

  /// Cek apakah notifikasi diizinkan oleh user di pengaturan profil
  Future<bool> isEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isPaused = prefs.getBool('pause_notifications') ?? false;
      return !isPaused;
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
    required DateTime scheduledAt,
    int remindMinutesBefore = 60,
  }) async {
    if (!_isInitialized) return;
    if (!await isEnabled()) return;
    try {
      final reminderTime = scheduledAt.subtract(Duration(minutes: remindMinutesBefore));

      // Jika waktu reminder sudah lewat, tidak perlu dijadwalkan
      if (reminderTime.isBefore(DateTime.now())) return;

      try {
        tz.initializeTimeZones();
      } catch (_) {}

      tz.Location location;
      try {
        location = tz.local;
      } catch (_) {
        try {
          location = tz.getLocation('Asia/Jakarta');
        } catch (_) {
          location = tz.UTC;
        }
      }

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

      await _notificationsPlugin.zonedSchedule(
        id,
        'Pengingat Wawancara • $company',
        'Agenda $position kamu akan dimulai dalam $reminderLabel. Siapkan berkas dan koneksi kamu!',
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
