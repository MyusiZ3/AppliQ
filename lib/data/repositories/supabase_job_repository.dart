import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/app_config.dart';
import '../models/application_log.dart';
import '../models/job_application.dart';
import '../models/user_profile.dart';
import 'job_repository.dart';

class SupabaseJobRepository implements JobRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final _dataChangeController = StreamController<void>.broadcast();

  // In-Memory Cache
  List<JobApplication>? _cachedApplications;
  UserProfile? _cachedProfile;
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
        _cachedProfile = UserProfile.fromJson(data);
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
  Future<void> signInWithGoogle() async {
    final webClientId = AppConfig.googleWebClientId;
    final googleSignIn = GoogleSignIn(
      serverClientId: webClientId.isNotEmpty ? webClientId : null,
      scopes: ['email', 'profile', 'openid'],
    );

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
    _cachedLogs.clear();
    _cachedAllLogs = null;
    _cachedStats = null;
    try {
      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
    } catch (_) {}
    await _supabase.auth.signOut();
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

    final json = application.toJson()..['user_id'] = userId;
    json.remove('id');

    final response = await _supabase
        .from('job_applications')
        .insert(json)
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
    final response = await _supabase
        .from('job_applications')
        .update(application.toJson())
        .eq('id', application.id)
        .select()
        .single();

    final result = JobApplication.fromJson(response);
    
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
    await _supabase.from('job_applications').delete().eq('id', id);
    _cachedApplications?.removeWhere((a) => a.id == id);
    _cachedLogs.remove(id);
    _cachedStats = null;
    notifyDataChanged();
  }

  @override
  Future<void> toggleFavorite(String id) async {
    final app = await _supabase
        .from('job_applications')
        .select('is_favorite')
        .eq('id', id)
        .single();
    final current = app['is_favorite'] as bool? ?? false;
    await _supabase
        .from('job_applications')
        .update({'is_favorite': !current})
        .eq('id', id);

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
        .single();

    final result = ApplicationLog.fromJson(response);
    _cachedLogs[log.applicationId]?.add(result);
    _cachedAllLogs?.add(result);
    notifyDataChanged();
    return result;
  }

  @override
  Future<void> deleteApplicationLog(String id) async {
    await _supabase.from('application_logs').delete().eq('id', id);
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
}
