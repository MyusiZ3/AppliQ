import '../models/job_application.dart';
import '../models/application_log.dart';
import '../models/user_profile.dart';
import '../models/user_resume.dart';

abstract class JobRepository {
  // Auth & Profile
  Future<UserProfile?> getCurrentUserProfile({bool forceRefresh = false});
  Future<UserProfile> updateUserProfile(UserProfile profile);
  Future<void> deleteAccount();
  Future<void> signInWithGoogle();
  Future<void> signOut();
  Stream<UserProfile?> get authStateChanges;

  // Applications
  Future<List<JobApplication>> getApplications({bool forceRefresh = false});
  Future<JobApplication> createApplication(JobApplication application);
  Future<JobApplication> updateApplication(JobApplication application);
  Future<void> deleteApplication(String id);
  Future<void> toggleFavorite(String id);

  // Application Logs (Stages)
  Future<List<ApplicationLog>> getApplicationLogs(String applicationId, {bool forceRefresh = false});
  Future<List<ApplicationLog>> getAllApplicationLogs({bool forceRefresh = false});
  Future<ApplicationLog> createApplicationLog(ApplicationLog log);
  Future<ApplicationLog> updateApplicationLog(ApplicationLog log);
  Future<void> deleteApplicationLog(String id);

  // Stats / Dashboard
  Future<Map<String, dynamic>> getDashboardStats({bool forceRefresh = false});

  // User Resume / CV & Cover Letter Data
  Future<UserResume?> getUserResume({bool forceRefresh = false});
  Future<UserResume> saveUserResume(UserResume resume);

  // Reactive Data Stream
  Stream<void> get dataChanges;
  void notifyDataChanged();
}
