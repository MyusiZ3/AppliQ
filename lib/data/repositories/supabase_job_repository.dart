import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/app_config.dart';
import '../models/application_log.dart';
import '../models/job_application.dart';
import '../models/user_profile.dart';
import '../models/user_resume.dart';
import 'job_repository.dart';

class SupabaseJobRepository implements JobRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final _dataChangeController = StreamController<void>.broadcast();

  // In-Memory Cache
  List<JobApplication>? _cachedApplications;
  UserProfile? _cachedProfile;
  UserResume? _cachedResume;
  final Map<String, List<ApplicationLog>> _cachedLogs = {};
  List<ApplicationLog>? _cachedAllLogs;
  Map<String, dynamic>? _cachedStats;

  @override
  Stream<void> get dataChanges => _dataChangeController.stream;

  @override
  void notifyDataChanged() {
    if (!_dataChangeController.isClosed) {
      _dataChangeController.add(null);
    }
  }

  @override
  Future<UserProfile?> getCurrentUserProfile({bool forceRefresh = false}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    if (!forceRefresh && _cachedProfile != null) {
      return _cachedProfile;
    }

    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data != null) {
        final profile = UserProfile.fromJson(data);
        final googleAvatar = user.userMetadata?['avatar_url'] ?? user.userMetadata?['picture'] ?? '';
        _cachedProfile = profile.copyWith(
          avatarUrl: profile.avatarUrl.isNotEmpty ? profile.avatarUrl : googleAvatar,
        );
        return _cachedProfile;
      }
      
      _cachedProfile = UserProfile(
        id: user.id,
        email: user.email ?? '',
        fullName: user.userMetadata?['full_name'] ?? user.userMetadata?['name'] ?? 'Pengguna AppliQ',
        avatarUrl: user.userMetadata?['avatar_url'] ?? user.userMetadata?['picture'] ?? '',
      );
      return _cachedProfile;
    } catch (_) {
      _cachedProfile = UserProfile(
        id: user.id,
        email: user.email ?? '',
        fullName: user.userMetadata?['full_name'] ?? user.userMetadata?['name'] ?? 'Pengguna AppliQ',
        avatarUrl: user.userMetadata?['avatar_url'] ?? user.userMetadata?['picture'] ?? '',
      );
      return _cachedProfile;
    }
  }

  @override
  Future<UserProfile> updateUserProfile(UserProfile profile) async {
    _cachedProfile = profile;
    try {
      await _supabase.from('profiles').upsert(profile.toJson());
    } catch (_) {}
    notifyDataChanged();
    return profile;
  }

  @override
  Future<void> deleteAccount() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        await _supabase.from('user_resumes').delete().eq('user_id', user.id);
        await _supabase.from('application_logs').delete().eq('user_id', user.id);
        await _supabase.from('job_applications').delete().eq('user_id', user.id);
        await _supabase.from('profiles').delete().eq('id', user.id);
      } catch (e) {
        debugPrint('Error during account deletion: $e');
      }
    }
    _cachedApplications = null;
    _cachedResume = null;
    _cachedLogs.clear();
    _cachedAllLogs = null;
    _cachedStats = null;
    await signOut();
  }

  @override
  Future<void> signInWithGoogle() async {
    final webClientId = AppConfig.googleWebClientId;
    final googleSignIn = GoogleSignIn(
      serverClientId: webClientId.isNotEmpty ? webClientId : null,
      scopes: ['email', 'profile', 'openid'],
    );

    // Reset session GoogleSignIn lokal agar selalu menampilkan dialog pilih akun (Account Picker)
    try {
      await googleSignIn.signOut();
    } catch (_) {}

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      // Pengguna membatalkan dialog login
      return;
    }

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;

    if (idToken == null) {
      // Jika idToken null (karena webClientId belum dikonfigurasi), fallback ke OAuth web
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: AppConfig.isSupabaseConfigured
            ? '${AppConfig.supabaseUrl}/auth/v1/callback'
            : null,
      );
      return;
    }

    await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  @override
  Future<void> signOut() async {
    _cachedApplications = null;
    _cachedProfile = null;
    _cachedResume = null;
    _cachedLogs.clear();
    _cachedAllLogs = null;
    _cachedStats = null;
    try {
      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      await googleSignIn.disconnect();
    } catch (_) {}
    await _supabase.auth.signOut();
    notifyDataChanged();
  }

  @override
  Stream<UserProfile?> get authStateChanges {
    return _supabase.auth.onAuthStateChange.asyncMap((event) async {
      final user = event.session?.user;
      if (user == null) {
        _cachedProfile = null;
        _cachedApplications = null;
        _cachedStats = null;
        _cachedLogs.clear();
        _cachedAllLogs = null;
        return null;
      }
      return getCurrentUserProfile(forceRefresh: true);
    });
  }

  @override
  Future<List<JobApplication>> getApplications({bool forceRefresh = false}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    if (!forceRefresh && _cachedApplications != null) {
      return _cachedApplications!;
    }

    final response = await _supabase
        .from('job_applications')
        .select()
        .eq('user_id', userId)
        .order('applied_date', ascending: false);

    _cachedApplications = (response as List).map((json) => JobApplication.fromJson(json)).toList();
    return _cachedApplications!;
  }

  @override
  Future<JobApplication> createApplication(JobApplication application) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Pengguna belum terautentikasi');

    final insertData = {
      'user_id': userId,
      'company_name': application.companyName,
      'position_title': application.positionTitle,
      'location': application.location,
      'work_system': application.workSystem.label,
      'job_portal': application.jobPortal.label,
      'job_portal_custom': application.jobPortalCustom,
      'job_url': application.jobUrl,
      'status': application.status.label,
      'applied_date': application.appliedDate.toIso8601String().split('T')[0],
      'salary_expectation': application.salaryExpectation,
      'salary_offered': application.salaryOffered,
      'notes': application.notes,
      'cv_file_url': application.cvFileUrl,
      'cv_file_name': application.cvFileName,
      'is_favorite': application.isFavorite,
    };

    final response = await _supabase
        .from('job_applications')
        .insert(insertData)
        .select()
        .single();

    final result = JobApplication.fromJson(response);
    
    // Update local cache directly
    if (_cachedApplications != null) {
      _cachedApplications!.removeWhere((a) => a.id == result.id);
      _cachedApplications!.insert(0, result);
    }
    _cachedStats = null;
    notifyDataChanged();
    return result;
  }

  @override
  Future<JobApplication> updateApplication(JobApplication application) async {
    final updateData = <String, dynamic>{
      'company_name': application.companyName,
      'position_title': application.positionTitle,
      'location': application.location,
      'work_system': application.workSystem.label,
      'job_portal': application.jobPortal.label,
      'job_portal_custom': application.jobPortalCustom,
      'job_url': application.jobUrl,
      'status': application.status.label,
      'applied_date': application.appliedDate.toIso8601String().split('T')[0],
      'salary_expectation': application.salaryExpectation,
      'salary_offered': application.salaryOffered,
      'notes': application.notes,
      'cv_file_url': application.cvFileUrl,
      'cv_file_name': application.cvFileName,
      'is_favorite': application.isFavorite,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Pengguna belum terautentikasi');

    final response = await _supabase
        .from('job_applications')
        .update(updateData)
        .eq('id', application.id)
        .eq('user_id', userId)
        .select()
        .maybeSingle();

    final result = response != null ? JobApplication.fromJson(response) : application;
    
    // Update local cache directly
    if (_cachedApplications != null) {
      final index = _cachedApplications!.indexWhere((a) => a.id == result.id);
      if (index != -1) {
        _cachedApplications![index] = result;
      }
    }
    _cachedStats = null;
    notifyDataChanged();
    return result;
  }

  @override
  Future<void> deleteApplication(String id) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase
        .from('job_applications')
        .delete()
        .eq('id', id)
        .eq('user_id', userId);

    _cachedApplications?.removeWhere((a) => a.id == id);
    _cachedLogs.remove(id);
    _cachedStats = null;
    notifyDataChanged();
  }

  @override
  Future<void> toggleFavorite(String id) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final app = await _supabase
        .from('job_applications')
        .select('is_favorite')
        .eq('id', id)
        .eq('user_id', userId)
        .single();
    final current = app['is_favorite'] as bool? ?? false;
    await _supabase
        .from('job_applications')
        .update({'is_favorite': !current})
        .eq('id', id)
        .eq('user_id', userId);

    // Update in local cache
    if (_cachedApplications != null) {
      final index = _cachedApplications!.indexWhere((a) => a.id == id);
      if (index != -1) {
        final existing = _cachedApplications![index];
        _cachedApplications![index] = existing.copyWith(isFavorite: !current);
      }
    }
    notifyDataChanged();
  }

  @override
  Future<List<ApplicationLog>> getApplicationLogs(String applicationId, {bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedLogs.containsKey(applicationId)) {
      return _cachedLogs[applicationId]!;
    }

    final response = await _supabase
        .from('application_logs')
        .select()
        .eq('application_id', applicationId)
        .order('created_at', ascending: true);

    final list = (response as List).map((json) => ApplicationLog.fromJson(json)).toList();
    _cachedLogs[applicationId] = list;
    return list;
  }

  @override
  Future<List<ApplicationLog>> getAllApplicationLogs({bool forceRefresh = false}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    if (!forceRefresh && _cachedAllLogs != null) {
      return _cachedAllLogs!;
    }

    try {
      final response = await _supabase
          .from('application_logs')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: true);

      final list = (response as List).map((json) => ApplicationLog.fromJson(json)).toList();
      _cachedAllLogs = list;

      // Populate individual application logs cache for instantaneous subsequent lookups
      _cachedLogs.clear();
      for (var log in list) {
        _cachedLogs.putIfAbsent(log.applicationId, () => []).add(log);
      }
      return list;
    } catch (_) {
      return _cachedAllLogs ?? [];
    }
  }

  @override
  Future<ApplicationLog> createApplicationLog(ApplicationLog log) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Pengguna belum terautentikasi');

    final json = log.toJson()..['user_id'] = userId;
    json.remove('id');

    final response = await _supabase
        .from('application_logs')
        .insert(json)
        .select()
        .maybeSingle();

    final result = response != null ? ApplicationLog.fromJson(response) : log;
    _cachedLogs.putIfAbsent(log.applicationId, () => []).add(result);
    _cachedAllLogs?.add(result);
    notifyDataChanged();
    return result;
  }

  @override
  Future<ApplicationLog> updateApplicationLog(ApplicationLog log) async {
    final updateData = <String, dynamic>{
      'stage_name': log.stageName,
      'scheduled_at': log.scheduledAt?.toIso8601String(),
      'interviewer_name': log.interviewerName,
      'meeting_link': log.meetingLink,
      'notes': log.notes,
      'result': log.result,
    };

    final response = await _supabase
        .from('application_logs')
        .update(updateData)
        .eq('id', log.id)
        .select()
        .maybeSingle();

    final result = response != null ? ApplicationLog.fromJson(response) : log;
    if (_cachedLogs.containsKey(log.applicationId)) {
      final index = _cachedLogs[log.applicationId]!.indexWhere((l) => l.id == log.id);
      if (index != -1) {
        _cachedLogs[log.applicationId]![index] = result;
      }
    }
    if (_cachedAllLogs != null) {
      final index = _cachedAllLogs!.indexWhere((l) => l.id == log.id);
      if (index != -1) {
        _cachedAllLogs![index] = result;
      }
    }
    notifyDataChanged();
    return result;
  }

  @override
  Future<void> deleteApplicationLog(String id) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase
        .from('application_logs')
        .delete()
        .eq('id', id)
        .eq('user_id', userId);

    for (var list in _cachedLogs.values) {
      list.removeWhere((l) => l.id == id);
    }
    _cachedAllLogs?.removeWhere((l) => l.id == id);
    notifyDataChanged();
  }

  @override
  Future<Map<String, dynamic>> getDashboardStats({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedStats != null) {
      return _cachedStats!;
    }

    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return {};

    final apps = await getApplications(forceRefresh: forceRefresh);
    final total = apps.length;
    final applied = apps.where((a) => a.status.name == 'applied').length;
    final interview = apps.where((a) => a.status.name == 'interview').length;
    final offering = apps.where((a) => a.status.name == 'offering').length;
    final accepted = apps.where((a) => a.status.name == 'accepted').length;
    final rejected = apps.where((a) => a.status.name == 'rejected').length;
    final noResponse = apps.where((a) => a.status.name == 'noResponse').length;

    final byWorkSystem = <String, int>{};
    for (var app in apps) {
      byWorkSystem[app.workSystem.label] = (byWorkSystem[app.workSystem.label] ?? 0) + 1;
    }

    final byPortal = <String, int>{};
    for (var app in apps) {
      final portalName = app.jobPortal.label == 'Lainnya' && app.jobPortalCustom != null
          ? app.jobPortalCustom!
          : app.jobPortal.label;
      byPortal[portalName] = (byPortal[portalName] ?? 0) + 1;
    }

    _cachedStats = {
      'total_applications': total,
      'applied_count': applied,
      'interview_count': interview,
      'offering_count': offering,
      'accepted_count': accepted,
      'rejected_count': rejected,
      'no_response_count': noResponse,
      'by_work_system': byWorkSystem,
      'by_portal': byPortal,
    };

    return _cachedStats!;
  }

  @override
  Future<UserResume?> getUserResume({bool forceRefresh = false}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    if (!forceRefresh && _cachedResume != null) {
      return _cachedResume;
    }

    try {
      final data = await _supabase
          .from('user_resumes')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (data != null) {
        _cachedResume = UserResume.fromJson(data);
        return _cachedResume;
      }

      // If no resume in Supabase yet, populate initial template with user's profile info
      final profile = await getCurrentUserProfile();
      _cachedResume = UserResume.empty(
        user.id,
        fullName: profile?.fullName ?? user.userMetadata?['full_name'] ?? user.userMetadata?['name'] ?? '',
        email: user.email ?? profile?.email ?? '',
        phone: profile?.phoneNumber ?? '',
      );
      return _cachedResume;
    } catch (_) {
      // Fallback
      final profile = await getCurrentUserProfile();
      _cachedResume = UserResume.empty(
        user.id,
        fullName: profile?.fullName ?? '',
        email: user.email ?? '',
        phone: profile?.phoneNumber ?? '',
      );
      return _cachedResume;
    }
  }

  @override
  Future<UserResume> saveUserResume(UserResume resume) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Pengguna belum terautentikasi');

    final json = resume.toJson();
    json['user_id'] = user.id;
    if (json['id'] == null || (json['id'] as String).isEmpty) {
      json.remove('id');
    }

    try {
      final response = await _supabase
          .from('user_resumes')
          .upsert(json, onConflict: 'user_id')
          .select()
          .single();

      _cachedResume = UserResume.fromJson(response);
    } catch (e) {
      // Offline fallback: keep in memory so input isn't lost during session
      _cachedResume = resume.copyWith(userId: user.id);
      debugPrint('Error saving resume to Supabase: $e');
      rethrow;
    }

    notifyDataChanged();
    return _cachedResume!;
  }
}
