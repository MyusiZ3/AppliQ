import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/application_log.dart';
import '../data/models/job_application.dart';
import '../data/models/user_profile.dart';

/// Service penyimpanan cache lokal di perangkat (Offline-First persistence).
/// Menggunakan SharedPreferences untuk menyimpan snapshot data terakhir agar
/// aplikasi tetap dapat dibuka instan dan menampilkan data saat tanpa koneksi internet.
class LocalCacheService {
  static const String _prefixApps = 'appliq_cache_apps_';
  static const String _prefixProfile = 'appliq_cache_profile_';
  static const String _prefixLogs = 'appliq_cache_logs_';
  static const String _prefixStats = 'appliq_cache_stats_';
  static const String _keyDraftForm = 'appliq_draft_application_form';

  // --- JOB APPLICATIONS CACHE ---
  static Future<void> saveApplications(String userId, List<JobApplication> apps) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = apps.map((app) => app.toJson()).toList();
      await prefs.setString('$_prefixApps$userId', jsonEncode(jsonList));
    } catch (e) {
      if (kDebugMode) debugPrint('LocalCacheService.saveApplications error: $e');
    }
  }

  static Future<List<JobApplication>?> getApplications(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_prefixApps$userId');
      if (raw == null || raw.isEmpty) return null;

      final dynamic decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .map((item) => JobApplication.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('LocalCacheService.getApplications error: $e');
    }
    return null;
  }

  // --- USER PROFILE CACHE ---
  static Future<void> saveUserProfile(String userId, UserProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_prefixProfile$userId', jsonEncode(profile.toJson()));
    } catch (e) {
      if (kDebugMode) debugPrint('LocalCacheService.saveUserProfile error: $e');
    }
  }

  static Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_prefixProfile$userId');
      if (raw == null || raw.isEmpty) return null;

      final dynamic decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return UserProfile.fromJson(decoded);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('LocalCacheService.getUserProfile error: $e');
    }
    return null;
  }

  // --- APPLICATION LOGS CACHE ---
  static Future<void> saveLogs(String userId, List<ApplicationLog> logs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = logs.map((log) => log.toJson()).toList();
      await prefs.setString('$_prefixLogs$userId', jsonEncode(jsonList));
    } catch (e) {
      if (kDebugMode) debugPrint('LocalCacheService.saveLogs error: $e');
    }
  }

  static Future<List<ApplicationLog>?> getLogs(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_prefixLogs$userId');
      if (raw == null || raw.isEmpty) return null;

      final dynamic decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .map((item) => ApplicationLog.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('LocalCacheService.getLogs error: $e');
    }
    return null;
  }

  // --- DASHBOARD STATS CACHE ---
  static Future<void> saveStats(String userId, Map<String, dynamic> stats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_prefixStats$userId', jsonEncode(stats));
    } catch (e) {
      if (kDebugMode) debugPrint('LocalCacheService.saveStats error: $e');
    }
  }

  static Future<Map<String, dynamic>?> getStats(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_prefixStats$userId');
      if (raw == null || raw.isEmpty) return null;

      final dynamic decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('LocalCacheService.getStats error: $e');
    }
    return null;
  }

  // --- FORM DRAFT (Proteksi ketikan formulir) ---
  static Future<void> saveFormDraft(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyDraftForm, jsonEncode(data));
    } catch (e) {
      if (kDebugMode) debugPrint('LocalCacheService.saveFormDraft error: $e');
    }
  }

  static Future<Map<String, dynamic>?> getFormDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyDraftForm);
      if (raw == null || raw.isEmpty) return null;

      final dynamic decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('LocalCacheService.getFormDraft error: $e');
    }
    return null;
  }

  static Future<void> clearFormDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyDraftForm);
    } catch (e) {
      if (kDebugMode) debugPrint('LocalCacheService.clearFormDraft error: $e');
    }
  }

  // --- CLEAR USER CACHE (Saat Logout) ---
  static Future<void> clearUserCache(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_prefixApps$userId');
      await prefs.remove('$_prefixProfile$userId');
      await prefs.remove('$_prefixLogs$userId');
      await prefs.remove('$_prefixStats$userId');
      await prefs.remove('appliq_cache_milestones_$userId');
    } catch (e) {
      if (kDebugMode) debugPrint('LocalCacheService.clearUserCache error: $e');
    }
  }
}
