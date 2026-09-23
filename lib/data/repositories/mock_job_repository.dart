import 'dart:async';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_enums.dart';
import '../models/application_log.dart';
import '../models/job_application.dart';
import '../models/user_profile.dart';
import '../models/user_resume.dart';
import 'job_repository.dart';

class MockJobRepository implements JobRepository {
  final _uuid = const Uuid();
  final _authController = StreamController<UserProfile?>.broadcast();
  final _dataChangeController = StreamController<void>.broadcast();

  @override
  Stream<void> get dataChanges => _dataChangeController.stream;

  @override
  void notifyDataChanged() {
    if (!_dataChangeController.isClosed) {
      _dataChangeController.add(null);
    }
  }

  UserProfile? _currentUser = UserProfile(
    id: 'mock-user-1',
    email: 'user.demo@appliq.id',
    fullName: 'Fajar Pratama',
    avatarUrl: '',
    username: '@fajarpratama',
    phoneNumber: '0812-3456-7890',
    targetRole: 'Software Engineer / Product Specialist',
  );

  final List<JobApplication> _applications = [];
  final List<ApplicationLog> _logs = [];
  UserResume? _userResume;

  MockJobRepository() {
    _seedInitialData();
  }

  void _seedInitialData() {
    final now = DateTime.now();

    _userResume = UserResume(
      id: 'mock-resume-1',
      userId: 'mock-user-1',
      fullName: 'Fajar Pratama',
      cityCountry: 'Bandung, Indonesia',
      phoneNumber: '0812-3456-7890',
      email: 'user.demo@appliq.id',
      linkedinUrl: 'https://linkedin.com/in/fajarpratama',
      portfolioUrl: 'https://fajarpratama.dev',
      summary:
          'Lulusan Teknologi Rekayasa Multimedia dengan fokus pada Mobile & Frontend Development. Berpengalaman membangun aplikasi Flutter berskala produksi dengan arsitektur bersih (Clean Architecture) dan integrasi Cloud Backend.',
      educations: [
        EducationItem(
          id: 'edu-1',
          institution: 'Universitas Telkom',
          degreeAndMajor: 'D4 Teknologi Rekayasa Multimedia',
          cityCountry: 'Bandung, Indonesia',
          period: '2020 - 2024',
          gpa: '3.79 / 4.00',
          bulletPoints: [
            'Fokus pada Rekayasa Perangkat Lunak Mobile, Grafika Komputer, dan UI/UX Design.',
            'Menyelesaikan tugas akhir implementasi Job Application Tracking System berbasis Flutter.',
          ],
        ),
      ],
      experiences: [
        ExperienceItem(
          id: 'exp-1',
          position: 'Mobile Application Developer (Intern)',
          companyOrProject: 'PT Inovasi Teknologi Nusantara',
          cityCountry: 'Jakarta Selatan',
          period: 'Feb 2023 - Agu 2023',
          bulletPoints: [
            'Mengembangkan fitur autentikasi dan sinkronisasi data offline-first menggunakan Supabase & SQLite.',
            'Meningkatkan performa rendering aplikasi hingga 25% melalui optimasi state management.',
          ],
        ),
        ExperienceItem(
          id: 'exp-2',
          position: 'Full Stack & Mobile Freelancer',
          companyOrProject: 'AppliQ Job Tracker Project',
          cityCountry: 'Remote',
          period: 'Sep 2023 - Sekarang',
          bulletPoints: [
            'Merancang dan membangun aplikasi tracking lamaran kerja multi-platform dengan ekspor dokumen PDF otomatis.',
          ],
        ),
      ],
      certifications: [
        CertificationItem(
          id: 'cert-1',
          title: 'Google Associate Android Developer',
          organization: 'Google Developers',
          year: '2023',
        ),
        CertificationItem(
          id: 'cert-2',
          title: 'Flutter & Dart Complete Development Suite',
          organization: 'Dicoding Indonesia',
          year: '2023',
        ),
      ],
      technicalSkills: [
        'Flutter',
        'Dart',
        'Supabase',
        'Firebase',
        'RESTful API',
        'Git & GitHub',
        'State Management (Provider/BLoC)',
        'Clean Architecture',
        'Figma',
      ],
      softSkills: [
        'Problem Solving',
        'Team Collaboration',
        'Attention to Detail',
        'Time Management',
        'Adaptability',
        'Effective Communication',
      ],
      birthPlaceDate: 'Bandung, 12 Januari 2002',
      fullAddress: 'Jl. Sukabirus No. 45, Dayeuhkolot, Kab. Bandung, Jawa Barat 40257',
      maritalStatus: 'Belum Menikah',
      citizenship: 'Indonesia',
      lastEducation: 'D4 Teknologi Rekayasa Multimedia - Universitas Telkom',
      targetJobPosition: 'Mobile Developer / Software Engineer',
    );
    _applications.addAll([
      JobApplication(
        id: _uuid.v4(),
        userId: 'mock-user-1',
        companyName: 'PT Pahala Bahari Nusantara',
        positionTitle: 'IE Staf',
        location: 'Jakarta',
        workSystem: WorkSystem.onSite,
        jobPortal: JobPortal.jobStreet,
        jobUrl: 'https://id.jobstreet.com',
        status: ApplicationStatus.noResponse,
        appliedDate: now.subtract(const Duration(days: 35)),
        notes: 'Semangat, masih ada kesempatan lainnya',
      ),
      JobApplication(
        id: _uuid.v4(),
        userId: 'mock-user-1',
        companyName: 'PT Madusari Nusaperdana',
        positionTitle: 'Staf Accounting',
        location: 'Boyolali',
        workSystem: WorkSystem.onSite,
        jobPortal: JobPortal.jobStreet,
        jobUrl: 'https://id.jobstreet.com',
        status: ApplicationStatus.interview,
        appliedDate: now.subtract(const Duration(days: 12)),
        notes: 'Jadwal User Interview hari Kamis jam 10:00',
        isFavorite: true,
      ),
      JobApplication(
        id: _uuid.v4(),
        userId: 'mock-user-1',
        companyName: 'The Flex Global',
        positionTitle: 'Virtual Assistant',
        location: 'Jakarta',
        workSystem: WorkSystem.wfh,
        jobPortal: JobPortal.linkedIn,
        jobUrl: 'https://linkedin.com',
        status: ApplicationStatus.offering,
        appliedDate: now.subtract(const Duration(days: 18)),
        notes: 'Offering letter diterima, review benefit dan kontrak',
        isFavorite: true,
      ),
      JobApplication(
        id: _uuid.v4(),
        userId: 'mock-user-1',
        companyName: 'Perusahaan 1',
        positionTitle: 'Admin Pajak',
        location: 'Madiun',
        workSystem: WorkSystem.onSite,
        jobPortal: JobPortal.website,
        status: ApplicationStatus.interview,
        appliedDate: now.subtract(const Duration(days: 8)),
        notes: 'Tahap tes teknis perpajakan',
      ),
      JobApplication(
        id: _uuid.v4(),
        userId: 'mock-user-1',
        companyName: 'Perusahaan 2',
        positionTitle: 'Account Payable',
        location: 'Surabaya',
        workSystem: WorkSystem.onSite,
        jobPortal: JobPortal.website,
        status: ApplicationStatus.offering,
        appliedDate: now.subtract(const Duration(days: 15)),
        notes: 'Negosiasi paket relokasi',
      ),
      JobApplication(
        id: _uuid.v4(),
        userId: 'mock-user-1',
        companyName: 'Perusahaan 3',
        positionTitle: 'General Admin',
        location: 'Jakarta',
        workSystem: WorkSystem.hybrid,
        jobPortal: JobPortal.kitaLulus,
        status: ApplicationStatus.interview,
        appliedDate: now.subtract(const Duration(days: 5)),
        notes: 'Wawancara dengan HR Manager via Google Meet',
      ),
      JobApplication(
        id: _uuid.v4(),
        userId: 'mock-user-1',
        companyName: 'Perusahaan 4',
        positionTitle: 'Project Manager',
        location: 'Solo',
        workSystem: WorkSystem.onSite,
        jobPortal: JobPortal.instagram,
        status: ApplicationStatus.applied,
        appliedDate: now.subtract(const Duration(days: 32)),
        notes: 'Tidak ada respon lebih dari 30 hari',
      ),
      JobApplication(
        id: _uuid.v4(),
        userId: 'mock-user-1',
        companyName: 'Perusahaan 5',
        positionTitle: 'Virtual Assistant',
        location: 'London',
        workSystem: WorkSystem.wfh,
        jobPortal: JobPortal.lainnya,
        jobPortalCustom: 'Upwork',
        status: ApplicationStatus.noResponse,
        appliedDate: now.subtract(const Duration(days: 40)),
        notes: 'Semangat, masih ada kesempatan lainnya',
      ),
      JobApplication(
        id: _uuid.v4(),
        userId: 'mock-user-1',
        companyName: 'Perusahaan 6',
        positionTitle: 'KOL Specialist',
        location: 'Bekasi',
        workSystem: WorkSystem.hybrid,
        jobPortal: JobPortal.glints,
        status: ApplicationStatus.rejected,
        appliedDate: now.subtract(const Duration(days: 22)),
        notes: 'Semangat, masih ada kesempatan lainnya',
      ),
    ]);

    // Sample interview log
    _logs.add(
      ApplicationLog(
        id: _uuid.v4(),
        applicationId: _applications[1].id,
        userId: 'mock-user-1',
        stageName: 'User & Technical Interview',
        scheduledAt: now.add(const Duration(days: 2, hours: 3)),
        interviewerName: 'Bapak Hartono (Finance Head)',
        meetingLink: 'https://meet.google.com/abc-defg-hij',
        notes: 'Siapkan materi rekonsiliasi bank dan PSAK',
      ),
    );
  }

  @override
  Future<UserProfile?> getCurrentUserProfile({bool forceRefresh = false}) async {
    return _currentUser;
  }

  @override
  Future<void> signInWithGoogle() async {
    _currentUser = UserProfile(
      id: 'mock-user-1',
      email: 'user.demo@appliq.id',
      fullName: 'Fajar Pratama',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      targetRole: 'Software Engineer / Product Specialist',
    );
    _authController.add(_currentUser);
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _authController.add(null);
  }

  @override
  Stream<UserProfile?> get authStateChanges => _authController.stream;

  @override
  Future<List<JobApplication>> getApplications({bool forceRefresh = false}) async {
    // Sort by applied date descending
    _applications.sort((a, b) => b.appliedDate.compareTo(a.appliedDate));
    return List.unmodifiable(_applications);
  }

  @override
  Future<JobApplication> createApplication(JobApplication application) async {
    final newApp = application.copyWith(
      id: application.id.isEmpty ? _uuid.v4() : application.id,
      userId: _currentUser?.id ?? 'mock-user-1',
    );
    _applications.insert(0, newApp);
    notifyDataChanged();
    return newApp;
  }

  @override
  Future<JobApplication> updateApplication(JobApplication application) async {
    final index = _applications.indexWhere((a) => a.id == application.id);
    if (index != -1) {
      _applications[index] = application.copyWith(updatedAt: DateTime.now());
      notifyDataChanged();
      return _applications[index];
    }
    throw Exception('Lamaran tidak ditemukan');
  }

  @override
  Future<void> deleteApplication(String id) async {
    _applications.removeWhere((a) => a.id == id);
    _logs.removeWhere((l) => l.applicationId == id);
    notifyDataChanged();
  }

  @override
  Future<void> toggleFavorite(String id) async {
    final index = _applications.indexWhere((a) => a.id == id);
    if (index != -1) {
      final current = _applications[index];
      _applications[index] = current.copyWith(isFavorite: !current.isFavorite);
      notifyDataChanged();
    }
  }

  @override
  Future<List<ApplicationLog>> getApplicationLogs(String applicationId, {bool forceRefresh = false}) async {
    return _logs.where((l) => l.applicationId == applicationId).toList();
  }

  @override
  Future<List<ApplicationLog>> getAllApplicationLogs({bool forceRefresh = false}) async {
    return List.unmodifiable(_logs);
  }

  @override
  Future<ApplicationLog> createApplicationLog(ApplicationLog log) async {
    final newLog = ApplicationLog(
      id: log.id.isEmpty ? _uuid.v4() : log.id,
      applicationId: log.applicationId,
      userId: _currentUser?.id ?? 'mock-user-1',
      stageName: log.stageName,
      scheduledAt: log.scheduledAt,
      interviewerName: log.interviewerName,
      meetingLink: log.meetingLink,
      notes: log.notes,
      result: log.result,
    );
    _logs.add(newLog);
    notifyDataChanged();
    return newLog;
  }

  @override
  Future<ApplicationLog> updateApplicationLog(ApplicationLog log) async {
    final index = _logs.indexWhere((l) => l.id == log.id);
    if (index != -1) {
      _logs[index] = log;
      notifyDataChanged();
      return log;
    }
    return log;
  }

  @override
  Future<void> deleteApplicationLog(String id) async {
    _logs.removeWhere((l) => l.id == id);
    notifyDataChanged();
  }

  @override
  Future<Map<String, dynamic>> getDashboardStats({bool forceRefresh = false}) async {
    final total = _applications.length;
    final applied = _applications.where((a) => a.status == ApplicationStatus.applied).length;
    final interview = _applications.where((a) => a.status == ApplicationStatus.interview).length;
    final offering = _applications.where((a) => a.status == ApplicationStatus.offering).length;
    final accepted = _applications.where((a) => a.status == ApplicationStatus.accepted).length;
    final rejected = _applications.where((a) => a.status == ApplicationStatus.rejected).length;
    final noResponse = _applications.where((a) => a.status == ApplicationStatus.noResponse).length;

    final byWorkSystem = <String, int>{};
    for (var app in _applications) {
      byWorkSystem[app.workSystem.label] = (byWorkSystem[app.workSystem.label] ?? 0) + 1;
    }

    final byPortal = <String, int>{};
    for (var app in _applications) {
      final portalName = app.jobPortal == JobPortal.lainnya && app.jobPortalCustom != null
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

  @override
  Future<UserProfile> updateUserProfile(UserProfile profile) async {
    _currentUser = profile;
    _authController.add(profile);
    notifyDataChanged();
    return profile;
  }

  @override
  Future<UserResume?> getUserResume({bool forceRefresh = false}) async {
    if (_userResume != null) return _userResume;
    return UserResume.empty(
      _currentUser?.id ?? 'mock-user-1',
      fullName: _currentUser?.fullName ?? 'Fajar Pratama',
      email: _currentUser?.email ?? 'user.demo@appliq.id',
      phone: _currentUser?.phoneNumber ?? '0812-3456-7890',
    );
  }

  @override
  Future<UserResume> saveUserResume(UserResume resume) async {
    _userResume = resume.copyWith(
      id: resume.id.isEmpty ? _uuid.v4() : resume.id,
      userId: _currentUser?.id ?? 'mock-user-1',
      updatedAt: DateTime.now(),
    );
    notifyDataChanged();
    return _userResume!;
  }

  @override
  Future<void> deleteAccount() async {
    _currentUser = null;
    _applications.clear();
    _logs.clear();
    _authController.add(null);
    notifyDataChanged();
  }
}
