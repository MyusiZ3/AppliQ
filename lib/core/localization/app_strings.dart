import '../../utils/language_manager.dart';
import '../constants/app_enums.dart';

class AppStrings {
  static bool get _isEn => LanguageManager.isEnglish;

  // Navigation
  static String get navHome => _isEn ? 'Home' : 'Home';
  static String get navApplications => _isEn ? 'Applications' : 'Lamaran';
  static String get navAnalytics => _isEn ? 'Analytics' : 'Analitik';
  static String get navProfile => _isEn ? 'Profile' : 'Profil';

  // Common Actions & Labels
  static String get cancel => _isEn ? 'Cancel' : 'Batal';
  static String get save => _isEn ? 'Save' : 'Simpan';
  static String get delete => _isEn ? 'Delete' : 'Hapus';
  static String get edit => _isEn ? 'Edit' : 'Edit';
  static String get close => _isEn ? 'Close' : 'Tutup';
  static String get search => _isEn ? 'Search...' : 'Cari...';
  static String get filter => _isEn ? 'Filter' : 'Filter';
  static String get sort => _isEn ? 'Sort' : 'Urutkan';
  static String get reset => _isEn ? 'Reset' : 'Reset';
  static String get apply => _isEn ? 'Apply' : 'Terapkan';
  static String get confirm => _isEn ? 'Confirm' : 'Konfirmasi';
  static String get done => _isEn ? 'Done' : 'Selesai';
  static String get back => _isEn ? 'Back' : 'Kembali';
  static String get retry => _isEn ? 'Retry' : 'Coba Lagi';
  static String get loading => _isEn ? 'Loading...' : 'Memuat...';
  static String get empty => _isEn ? 'No data' : 'Tidak ada data';
  static String get comingSoon => _isEn ? 'Coming Soon' : 'Segera Hadir';
  static String get viewAll => _isEn ? 'View All' : 'Lihat Semua';
  static String get openInDrive => _isEn ? 'Open in Google Drive' : 'Buka di Google Drive';

  // Home Screen
  static String get greetingMorning => _isEn ? 'Good Morning' : 'Selamat Pagi';
  static String get greetingAfternoon => _isEn ? 'Good Afternoon' : 'Selamat Siang';
  static String get greetingEvening => _isEn ? 'Good Evening' : 'Selamat Sore';
  static String get greetingNight => _isEn ? 'Good Night' : 'Selamat Malam';
  static String get homeSubtitle => _isEn ? 'Track your career journey seamlessly' : 'Pantau perjalanan karirmu hari ini';
  static String get homeSearchHint => _isEn ? 'Search company or position...' : 'Cari perusahaan atau posisi...';
  static String get statTotal => _isEn ? 'Total Applied' : 'Total Lamaran';
  static String get statActive => _isEn ? 'In Progress' : 'Sedang Proses';
  static String get statInterview => _isEn ? 'Interview' : 'Interview';
  static String get statOffering => _isEn ? 'Offer / Accepted' : 'Offer / Diterima';
  static String get recentApplications => _isEn ? 'Recent Applications' : 'Lamaran Terbaru';
  static String get quickAddApplication => _isEn ? 'Add Application' : 'Tambah Lamaran';
  static String get quickAddTooltip => _isEn ? 'Record new job application' : 'Catat lamaran kerja baru';
  static String get upcomingReminders => _isEn ? 'Upcoming Reminders' : 'Pengingat Mendatang';
  static String get noReminders => _isEn ? 'No upcoming interview or schedule' : 'Tidak ada jadwal atau interview mendatang';
  static String get emptyRecentApps => _isEn ? 'No job applications recorded yet' : 'Belum ada lamaran kerja yang dicatat';
  static String get addFirstApp => _isEn ? 'Add Your First Job' : 'Tambah Lamaran Pertama';

  // Applications List Screen
  static String get applicationsTitle => _isEn ? 'Applications' : 'Daftar Lamaran';
  static String get allStatusTab => _isEn ? 'All' : 'Semua';
  static String get searchApplicationPlaceholder => _isEn ? 'Search position, company, location...' : 'Cari posisi, perusahaan, lokasi...';
  static String get filterStatus => _isEn ? 'Filter Status' : 'Filter Status';
  static String get filterPortal => _isEn ? 'Job Portal' : 'Portal Lowongan';
  static String get filterWorkSystem => _isEn ? 'Work System' : 'Sistem Kerja';
  static String get filterEmploymentType => _isEn ? 'Job Type' : 'Tipe Pekerjaan';
  static String get sortNewest => _isEn ? 'Newest Applied' : 'Paling Baru Dilamar';
  static String get sortOldest => _isEn ? 'Oldest Applied' : 'Paling Lama Dilamar';
  static String get sortCompanyAZ => _isEn ? 'Company (A to Z)' : 'Perusahaan (A - Z)';
  static String get sortSalaryHighest => _isEn ? 'Highest Salary' : 'Gaji Tertinggi';
  static String get noApplicationsFound => _isEn ? 'No applications match your criteria' : 'Tidak ada lamaran yang sesuai kriteria';
  static String get clearFilters => _isEn ? 'Reset Filter' : 'Reset Filter';
  static String get deleteApplicationConfirmTitle => _isEn ? 'Delete Application?' : 'Hapus Lamaran?';
  static String get deleteApplicationConfirmMessage => _isEn 
      ? 'This application and all associated interview logs will be permanently deleted.' 
      : 'Lamaran ini dan seluruh riwayat tahap interview akan dihapus permanen.';

  // Application Detail Screen
  static String get applicationDetailTitle => _isEn ? 'Application Details' : 'Detail Lamaran';
  static String get overviewTab => _isEn ? 'Overview' : 'Ringkasan';
  static String get timelineTab => _isEn ? 'Timeline & Logs' : 'Tahapan & Catatan';
  static String get companyInfo => _isEn ? 'Company Information' : 'Informasi Perusahaan';
  static String get salaryDetails => _isEn ? 'Salary Expectation & Offer' : 'Ekspektasi & Penawaran Gaji';
  static String get salaryExpectation => _isEn ? 'Expectation' : 'Ekspektasi Gaji';
  static String get salaryOffered => _isEn ? 'Offered' : 'Penawaran Gaji';
  static String get appliedOn => _isEn ? 'Applied on' : 'Dilamar pada';
  static String get notesTitle => _isEn ? 'Notes & Details' : 'Catatan Tambahan';
  static String get noNotes => _isEn ? 'No notes added for this application.' : 'Belum ada catatan untuk lamaran ini.';
  static String get jobUrlLabel => _isEn ? 'Job Posting Link' : 'Tautan Lowongan Kerja';
  static String get openJobUrl => _isEn ? 'Open Link' : 'Buka Link';
  static String get updateStatus => _isEn ? 'Update Status' : 'Ubah Status';
  static String get selectNewStatus => _isEn ? 'Select Application Status' : 'Pilih Status Lamaran';
  static String get addTimelineStage => _isEn ? 'Add Stage Log' : 'Tambah Catatan Tahap';
  static String get editTimelineStage => _isEn ? 'Edit Stage Log' : 'Edit Catatan Tahap';
  static String get deleteTimelineStage => _isEn ? 'Delete Stage' : 'Hapus Tahap';
  static String get stageNameLabel => _isEn ? 'Stage Name (e.g., HR Interview, Technical Test)' : 'Nama Tahap (cth: HR Interview, User Test)';
  static String get stageDateLabel => _isEn ? 'Schedule / Date' : 'Tanggal / Jadwal';
  static String get stageNotesLabel => _isEn ? 'Notes / Feedback / Questions Asked' : 'Catatan / Pertanyaan / Feedback';
  static String get cvAttachmentTitle => _isEn ? 'Attached CV / Portfolio' : 'Lampiran CV / Portofolio';
  static String get savedInDrive => _isEn ? 'Saved in Google Drive' : 'Tersimpan di Google Drive';
  static String get uploadCvToDrive => _isEn ? 'Upload CV / Resume to Google Drive' : 'Upload CV / Berkas ke Google Drive';
  static String get manageAttachment => _isEn ? 'Manage Document Attachment' : 'Kelola Berkas Lampiran';
  static String get deleteFromDrive => _isEn ? 'Permanently Delete from Google Drive' : 'Hapus Permanen dari Google Drive';
  static String get detachOnly => _isEn ? 'Detach Attachment Only' : 'Lepas Lampiran Saja';

  // Application Form Screen
  static String get createApplicationTitle => _isEn ? 'New Application' : 'Tambah Lamaran Baru';
  static String get editApplicationTitle => _isEn ? 'Edit Application' : 'Edit Data Lamaran';
  static String get companyNameLabel => _isEn ? 'Company Name' : 'Nama Perusahaan';
  static String get companyNameHint => _isEn ? 'e.g. Google, GoTo, Tokopedia' : 'Cth: GoTo, Shopee, BCA';
  static String get companyNameRequired => _isEn ? 'Please enter company name' : 'Nama perusahaan wajib diisi';
  static String get positionTitleLabel => _isEn ? 'Position Title' : 'Posisi Pekerjaan';
  static String get positionTitleHint => _isEn ? 'e.g. Senior Flutter Developer' : 'Cth: Flutter Developer, Product Manager';
  static String get positionTitleRequired => _isEn ? 'Please enter position title' : 'Posisi pekerjaan wajib diisi';
  static String get locationLabel => _isEn ? 'Location' : 'Lokasi / Kota';
  static String get locationHint => _isEn ? 'e.g. Jakarta Selatan, Remote' : 'Cth: Jakarta Selatan, Remote';
  static String get appliedDateLabel => _isEn ? 'Application Date' : 'Tanggal Melamar';
  static String get saveApplicationButton => _isEn ? 'Save Application' : 'Simpan Lamaran';
  static String get updateApplicationButton => _isEn ? 'Save Changes' : 'Simpan Perubahan';

  // Dashboard / Analytics Screen
  static String get analyticsTitle => _isEn ? 'Career Analytics' : 'Analitik Karir';
  static String get pipelineFunnel => _isEn ? 'Application Funnel' : 'Tahapan & Konversi Lamaran';
  static String get topPortals => _isEn ? 'Top Job Portals' : 'Portal Kerja Paling Efektif';
  static String get monthlyApplications => _isEn ? 'Monthly Activity' : 'Aktivitas Lamaran Bulanan';
  static String get responseRate => _isEn ? 'Interview Conversion' : 'Rasio Dipanggil Interview';
  static String get offerRate => _isEn ? 'Offer Success Rate' : 'Rasio Diterima / Offer';
  static String get totalApplicationsMetric => _isEn ? 'Total Tracked' : 'Total Lamaran';
  static String get activeApplicationsMetric => _isEn ? 'Active Pipeline' : 'Sedang Berjalan';

  // Profile & Settings Screen
  static String get profileTitle => _isEn ? 'Profile & Settings' : 'Profil & Pengaturan';
  static String get accountSection => _isEn ? 'Account' : 'Akun';
  static String get preferencesSection => _isEn ? 'Preferences' : 'Preferensi Aplikasi';
  static String get dataSection => _isEn ? 'Data & Backup' : 'Data & Cadangan';
  static String get aboutSection => _isEn ? 'About AppliQ' : 'Tentang AppliQ';
  static String get themeSetting => _isEn ? 'Theme' : 'Tema Tampilan';
  static String get accentSetting => _isEn ? 'Accent Style' : 'Gaya Warna Aksen';
  static String get languageSetting => _isEn ? 'Language' : 'Pilih Bahasa';
  static String get notificationsSetting => _isEn ? 'Notifications & Reminders' : 'Notifikasi & Pengingat';
  static String get exportDataSetting => _isEn ? 'Export Data (Excel / CSV / PDF)' : 'Export Data (Excel / CSV / PDF)';
  static String get googleDriveSetting => _isEn ? 'Google Drive Integration' : 'Integrasi Google Drive';
  static String get connected => _isEn ? 'Connected' : 'Terhubung';
  static String get disconnected => _isEn ? 'Not Connected' : 'Belum Terhubung';
  static String get disconnectDriveConfirm => _isEn ? 'Disconnect Google Drive?' : 'Putuskan Google Drive?';
  static String get disconnectDriveMessage => _isEn 
      ? 'You can reconnect anytime to manage and attach your resume files.' 
      : 'Kamu bisa menghubungkan kembali akun kapan saja untuk upload berkas CV.';
  static String get logoutButton => _isEn ? 'Log Out' : 'Keluar Akun';
  static String get logoutConfirmTitle => _isEn ? 'Sign Out of AppliQ?' : 'Keluar dari AppliQ?';
  static String get logoutConfirmMessage => _isEn 
      ? 'Your data is securely stored in the cloud and will be restored upon sign in.' 
      : 'Semua datamu tetap tersimpan aman di cloud dan dapat diakses kembali saat login.';
  static String get appVersion => _isEn ? 'AppliQ Version' : 'Versi AppliQ';

  // Language Modal
  static String get languageModalTitle => _isEn ? 'Select Language' : 'Pilih Bahasa (Language)';
  static String get languageModalSubtitle => _isEn ? 'Choose application interface language' : 'Pilih bahasa antarmuka aplikasi';
  static String get languageIdName => 'Bahasa Indonesia';
  static String get languageIdSubtitle => _isEn ? 'Indonesian (Standard)' : 'Bahasa Indonesia (Standar)';
  static String get languageEnName => 'English';
  static String get languageEnSubtitle => _isEn ? 'English (Global)' : 'English (United States)';
  static String get languageJaName => '日本語';
  static String get languageJaSubtitle => 'Japanese (Nihongo)';
  static String get languageKoName => '한국어';
  static String get languageKoSubtitle => 'Korean (Hangugeo)';
  static String get languageComingSoonToast => _isEn 
      ? 'This language will be available in an upcoming update!' 
      : 'Bahasa ini akan segera hadir pada update berikutnya!';

  // Export Sheet
  static String get exportSheetTitle => _isEn ? 'Export Application Data' : 'Export Data Lamaran';
  static String get exportSheetSubtitle => _isEn ? 'Download report in your preferred format' : 'Unduh laporan data lamaran kerjamu';
  static String get exportFormat => _isEn ? 'File Format' : 'Format Berkas';
  static String get exportDateRange => _isEn ? 'Date Range' : 'Rentang Waktu';
  static String get exportAllTime => _isEn ? 'All Time' : 'Semua Waktu';
  static String get exportThisMonth => _isEn ? 'This Month' : 'Bulan Ini';
  static String get exportLast3Months => _isEn ? 'Last 3 Months' : '3 Bulan Terakhir';
  static String get exportThisYear => _isEn ? 'This Year' : 'Tahun Ini';
  static String get exportButton => _isEn ? 'Export & Share File' : 'Export & Bagikan Berkas';
  static String get exportSuccess => _isEn ? 'Data exported successfully!' : 'Data berhasil diexport!';
  static String get exportEmpty => _isEn ? 'No application records to export.' : 'Tidak ada data lamaran untuk diexport.';

  // Toasts & Snackbars
  static String get errorOccurred => _isEn ? 'An error occurred. Please try again.' : 'Terjadi kesalahan. Silakan coba lagi.';
  static String get successSaved => _isEn ? 'Application saved successfully.' : 'Lamaran berhasil dicatat.';
  static String get successUpdated => _isEn ? 'Application updated successfully.' : 'Lamaran berhasil diperbarui.';
  static String get successDeleted => _isEn ? 'Application deleted.' : 'Lamaran berhasil dihapus.';
  static String get fileUploadedDrive => _isEn ? 'File uploaded to Google Drive successfully.' : 'Berkas berhasil diupload ke Google Drive.';
  static String get fileDeletedDrive => _isEn ? 'File deleted from Google Drive.' : 'Berkas berhasil dihapus dari Google Drive.';
  static String get attachmentDetached => _isEn ? 'Attachment detached from application.' : 'Lampiran berkas berhasil dilepaskan.';
  static String get fillRequiredFields => _isEn ? 'Please fill in company name and position first.' : 'Isi nama perusahaan dan posisi terlebih dahulu.';

  // Helper methods for enums
  static String localizedEmploymentType(EmploymentType type) {
    if (!_isEn) return type.label;
    switch (type) {
      case EmploymentType.fullTime:
        return 'Full-time';
      case EmploymentType.internship:
        return 'Internship';
      case EmploymentType.contract:
        return 'Contract';
      case EmploymentType.partTime:
        return 'Part-time';
      case EmploymentType.freelance:
        return 'Freelance';
    }
  }

  static String localizedWorkSystem(WorkSystem system) {
    if (!_isEn) return system.label;
    switch (system) {
      case WorkSystem.onSite:
        return 'On-site';
      case WorkSystem.hybrid:
        return 'Hybrid';
      case WorkSystem.wfh:
        return 'Remote (WFH)';
      case WorkSystem.remoteOverseas:
        return 'Global Remote';
      case WorkSystem.flexible:
        return 'Flexible';
    }
  }

  static String localizedJobPortal(JobPortal portal) {
    if (!_isEn) return portal.label;
    switch (portal) {
      case JobPortal.linkedIn:
        return 'LinkedIn';
      case JobPortal.jobStreet:
        return 'JobStreet';
      case JobPortal.glints:
        return 'Glints';
      case JobPortal.kalibrr:
        return 'Kalibrr';
      case JobPortal.dealls:
        return 'Dealls';
      case JobPortal.techInAsia:
        return 'Tech in Asia';
      case JobPortal.referral:
        return 'Referral / Colleague';
      case JobPortal.directEmail:
        return 'Direct Email / HR Outreach';
      case JobPortal.kitaLulus:
        return 'KitaLulus';
      case JobPortal.jobFair:
        return 'Job Fair / Campus';
      case JobPortal.website:
        return 'Company Website';
      case JobPortal.instagram:
        return 'Social Media';
      case JobPortal.komunitas:
        return 'Community / Group';
      case JobPortal.freelance:
        return 'Freelance Platform';
      case JobPortal.lainnya:
        return 'Other';
    }
  }

  static String localizedStatus(ApplicationStatus status) {
    // Both English and Indonesian use clean labels (e.g. Applied, Interview, Offering, Accepted, Rejected, No Response)
    switch (status) {
      case ApplicationStatus.applied:
        return 'Applied';
      case ApplicationStatus.interview:
        return 'Interview';
      case ApplicationStatus.offering:
        return 'Offering';
      case ApplicationStatus.accepted:
        return 'Accepted';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.noResponse:
        return 'No Response';
    }
  }
}
