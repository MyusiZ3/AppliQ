import '../models/job_application.dart';
import '../models/application_log.dart';
import '../models/user_profile.dart';

abstract class JobRepository {
  // Auth & Profile
  Future<UserProfile?> getCurrentUserProfile();
  Future<void> signInWithGoogle();
  Future<void> signOut();
  Stream<UserProfile?> get authStateChanges;

  // Applications
  Future<List<JobApplication>> getApplications();
  Future<JobApplication> createApplication(JobApplication application);
  Future<JobApplication> updateApplication(JobApplication application);
  Future<void> deleteApplication(String id);
  Future<void> toggleFavorite(String id);

  // Application Logs (Stages)
  Future<List<ApplicationLog>> getApplicationLogs(String applicationId);
  Future<ApplicationLog> createApplicationLog(ApplicationLog log);
  Future<void> deleteApplicationLog(String id);

  // Stats / Dashboard
  Future<Map<String, dynamic>> getDashboardStats();
}
