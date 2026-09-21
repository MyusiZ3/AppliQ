import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/app_config.dart';
import '../models/application_log.dart';
import '../models/job_application.dart';
import '../models/user_profile.dart';
import 'job_repository.dart';

class SupabaseJobRepository implements JobRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<UserProfile?> getCurrentUserProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data != null) {
        return UserProfile.fromJson(data);
      }
      
      return UserProfile(
        id: user.id,
        email: user.email ?? '',
        fullName: user.userMetadata?['full_name'] ?? user.userMetadata?['name'] ?? '',
        avatarUrl: user.userMetadata?['avatar_url'] ?? user.userMetadata?['picture'] ?? '',
      );
    } catch (_) {
      return UserProfile(
        id: user.id,
        email: user.email ?? '',
        fullName: user.userMetadata?['full_name'] ?? user.userMetadata?['name'] ?? '',
        avatarUrl: user.userMetadata?['avatar_url'] ?? user.userMetadata?['picture'] ?? '',
      );
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: AppConfig.isSupabaseConfigured
          ? '${AppConfig.supabaseUrl}/auth/v1/callback'
          : null,
    );
  }

  @override
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  @override
  Stream<UserProfile?> get authStateChanges {
    return _supabase.auth.onAuthStateChange.asyncMap((event) async {
      final user = event.session?.user;
      if (user == null) return null;
      return getCurrentUserProfile();
    });
  }

  @override
  Future<List<JobApplication>> getApplications() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('job_applications')
        .select()
        .eq('user_id', userId)
        .order('applied_date', ascending: false);

    return (response as List).map((json) => JobApplication.fromJson(json)).toList();
  }

  @override
  Future<JobApplication> createApplication(JobApplication application) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final json = application.toJson()..['user_id'] = userId;
    json.remove('id'); // Biarkan Supabase generate UUID jika baru

    final response = await _supabase
        .from('job_applications')
        .insert(json)
        .select()
        .single();

    return JobApplication.fromJson(response);
  }

  @override
  Future<JobApplication> updateApplication(JobApplication application) async {
    final response = await _supabase
        .from('job_applications')
        .update(application.toJson())
        .eq('id', application.id)
        .select()
        .single();

    return JobApplication.fromJson(response);
  }

  @override
  Future<void> deleteApplication(String id) async {
    await _supabase.from('job_applications').delete().eq('id', id);
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
  }

  @override
  Future<List<ApplicationLog>> getApplicationLogs(String applicationId) async {
    final response = await _supabase
        .from('application_logs')
        .select()
        .eq('application_id', applicationId)
        .order('created_at', ascending: true);

    return (response as List).map((json) => ApplicationLog.fromJson(json)).toList();
  }

  @override
  Future<ApplicationLog> createApplicationLog(ApplicationLog log) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final json = log.toJson()..['user_id'] = userId;
    json.remove('id');

    final response = await _supabase
        .from('application_logs')
        .insert(json)
        .select()
        .single();

    return ApplicationLog.fromJson(response);
  }

  @override
  Future<void> deleteApplicationLog(String id) async {
    await _supabase.from('application_logs').delete().eq('id', id);
  }

  @override
  Future<Map<String, dynamic>> getDashboardStats() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return {};

    try {
      final response = await _supabase.rpc(
        'get_job_tracker_stats',
        params: {'p_user_id': userId},
      );
      if (response != null) {
        return Map<String, dynamic>.from(response as Map);
      }
    } catch (_) {
      // Fallback jika RPC belum dibuat di Supabase
    }

    // Client-side fallback aggregation
    final apps = await getApplications();
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

    return {
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
  }
}
