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

  static const String _scheduleChannelId = 'appliq_schedules_v2';
  static const String _scheduleChannelName = 'Pengingat Jadwal & Interview';
  static const String _scheduleChannelDescription =
      'Notifikasi pengingat jadwal wawancara, tes kerja, dan agenda lamaran.';

  static const String _followUpChannelId = 'appliq_followup_v2';
  static const String _followUpChannelName = 'Pengingat Follow-up Lamaran';
  static const String _followUpChannelDescription =
      'Notifikasi pengingat follow-up lamaran (> 7 hari) dengan nada dering khusus.';

  static const String _soundResourceName = 'followup_alert';

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
        requestSoundPermission: true,
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

      // Buat Notifikasi Channel Khusus Android dengan Prioritas Tertinggi & Suara
      if (Platform.isAndroid) {
        final androidImplementation = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        if (androidImplementation != null) {
          // Bersihkan channel lama jika ada
          try {
            await androidImplementation.deleteNotificationChannel('appliq_reminders');
          } catch (_) {}

          // Channel 1: Pengingat Jadwal Wawancara & Tes Kerja
          const scheduleChannel = AndroidNotificationChannel(
            _scheduleChannelId,
            _scheduleChannelName,
            description: _scheduleChannelDescription,
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
            showBadge: true,
            audioAttributesUsage: AudioAttributesUsage.notification,
          );
          await androidImplementation.createNotificationChannel(scheduleChannel);

          // Channel 2: Pengingat Khusus Follow-up dengan Suara Nada Khusus
          const followUpChannel = AndroidNotificationChannel(
            _followUpChannelId,
            _followUpChannelName,
            description: _followUpChannelDescription,
            importance: Importance.max,
            playSound: true,
            sound: RawResourceAndroidNotificationSound(_soundResourceName),
            enableVibration: true,
            showBadge: true,
            audioAttributesUsage: AudioAttributesUsage.notification,
          );
          await androidImplementation.createNotificationChannel(followUpChannel);
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

  /// Cek apakah izin notifikasi saat ini aktif di tingkat sistem operasi (OS level)
  Future<bool> hasPermission() async {
    try {
      if (Platform.isAndroid) {
        final androidImplementation = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        if (androidImplementation != null) {
          final granted = await androidImplementation.areNotificationsEnabled();
          return granted ?? false;
        }
      } else if (Platform.isIOS) {
        final iosImplementation = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        if (iosImplementation != null) {
          final settings = await iosImplementation.checkPermissions();
          return settings?.isEnabled ?? false;
        }
      }
    } catch (e) {
      debugPrint('Error checking notification permission: $e');
    }
    return false;
  }

  /// Detail notifikasi khusus Follow-up dengan suara dan getaran unik
  NotificationDetails _getFollowUpNotificationDetails() {
    const androidDetails = AndroidNotificationDetails(
      _followUpChannelId,
      _followUpChannelName,
      channelDescription: _followUpChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@drawable/ic_notification',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      color: Color(0xFF18181B),
      enableVibration: true,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(_soundResourceName),
      audioAttributesUsage: AudioAttributesUsage.notification,
      category: AndroidNotificationCategory.reminder,
      styleInformation: BigTextStyleInformation(''),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: '$_soundResourceName.wav',
    );

    return const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
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
        _scheduleChannelId,
        _scheduleChannelName,
        channelDescription: _scheduleChannelDescription,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@drawable/ic_notification',
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        color: Color(0xFF18181B),
        enableVibration: true,
        playSound: true,
        fullScreenIntent: true,
        audioAttributesUsage: AudioAttributesUsage.notification,
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

  /// Tampilkan notifikasi follow-up langsung dengan suara khusus
  Future<void> showFollowUpNotification({
    int id = 8888,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) return;
    if (!await isEnabled()) return;
    try {
      final notificationDetails = _getFollowUpNotificationDetails();

      await _notificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error showing follow-up notification with sound: $e');
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
        _scheduleChannelId,
        _scheduleChannelName,
        channelDescription: _scheduleChannelDescription,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@drawable/ic_notification',
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        color: Color(0xFF18181B),
        enableVibration: true,
        playSound: true,
        audioAttributesUsage: AudioAttributesUsage.notification,
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

  /// Jadwalkan Notifikasi Pengingat Follow-up Lamaran (H+7 setelah melamar) dengan Suara Khusus
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

      final notificationDetails = _getFollowUpNotificationDetails();

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
      debugPrint('Error scheduling follow-up reminder with sound: $e');
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

      await showFollowUpNotification(
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
