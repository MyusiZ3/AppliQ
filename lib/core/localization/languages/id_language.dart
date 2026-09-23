import '../../constants/app_enums.dart';
import 'base_language.dart';

class IdLanguage implements BaseLanguage {
  // Navigation
  @override
  String get navHome => 'Home';
  @override
  String get navApplications => 'Lamaran';
  @override
  String get navAnalytics => 'Analitik';
  @override
  String get navProfile => 'Profil';

  // Common Actions & Labels
  @override
  String get cancel => 'Batal';
  @override
  String get save => 'Simpan';
  @override
  String get delete => 'Hapus';
  @override
  String get edit => 'Edit';
  @override
  String get close => 'Tutup';
  @override
  String get search => 'Cari...';
  @override
  String get filter => 'Filter';
  @override
  String get sort => 'Urutkan';
  @override
  String get reset => 'Reset';
  @override
  String get apply => 'Terapkan';
  @override
  String get confirm => 'Konfirmasi';
  @override
  String get done => 'Selesai';
  @override
  String get back => 'Kembali';
  @override
  String get retry => 'Coba Lagi';
  @override
  String get loading => 'Memuat...';
  @override
  String get empty => 'Tidak ada data';
  @override
  String get comingSoon => 'Segera Hadir';
  @override
  String get viewAll => 'Lihat Semua';
  @override
  String get openInDrive => 'Buka di Google Drive';
  @override
  String get scheduleDateLabel => 'Jadwal';

  // Home Screen
  @override
  String get greetingMorning => 'Selamat Pagi';
  @override
  String get greetingAfternoon => 'Selamat Siang';
  @override
  String get greetingEvening => 'Selamat Sore';
  @override
  String get greetingNight => 'Selamat Malam';
  @override
  String get homeSubtitle => 'Pantau perjalanan karirmu hari ini';
  @override
  String get homeSearchHint => 'Cari perusahaan atau posisi...';
  @override
  String get statTotal => 'Total Lamaran';
  @override
  String get statActive => 'Sedang Proses';
  @override
  String get statInterview => 'Interview';
  @override
  String get statOffering => 'Offering';
  @override
  String get recentApplications => 'Lamaran Terbaru';
  @override
  String get quickAddApplication => 'Lamaran';
  @override
  String get quickSchedule => 'Jadwal';
  @override
  String get quickTemplate => 'Template';
  @override
  String get quickExport => 'Ekspor';
  @override
  String get quickAddTooltip => 'Catat lamaran kerja baru';
  @override
  String get upcomingReminders => 'Pengingat Mendatang';
  @override
  String get noReminders => 'Tidak ada jadwal atau interview mendatang';
  @override
  String get emptyRecentApps => 'Belum ada lamaran tersimpan';
  @override
  String get emptyRecentAppsDesc => 'Mulai tambahkan lowongan pekerjaan yang sedang kamu ikuti.';
  @override
  String get addFirstApp => 'Catat Lamaran Pertama';
  @override
  String get applicationSummary => 'Ringkasan Lamaran';
  @override
  String get statsButton => 'Statistik';
  @override
  String get appliedLabel => 'Dilamar';
  @override
  String get nextSchedule => 'Jadwal Terdekat';
  @override
  String get openMeetingLink => 'Buka Link Meeting';
  @override
  String get viewDetails => 'Lihat Detail';
  @override
  String get followUpNeeded => 'Perlu Follow-up';
  @override
  String get sendFollowUpEmail => 'Kirim Email Follow-up';
  @override
  String get appliedCompanies => 'Perusahaan Dilamar';
  @override
  String get noAppliedCompanies => 'Belum ada daftar perusahaan yang dilamar.';
  @override
  String get salaryUndisclosed => 'Gaji Dirahasiakan';
  @override
  String get perMonth => '/ bln';
  @override
  String positionsCount(int count) => '$count Posisi';
  @override
  String applicationsCount(int count) => '$count Lamaran';
  @override
  String staleAppSingle(String company) => 'Lamaran di $company sudah > 7 hari tanpa kabar status.';
  @override
  String staleAppMulti(int count, String company) => '$count lamaran termasuk di $company sudah > 7 hari tanpa respon.';

  // Applications List Screen
  @override
  String get applicationsTitle => 'Daftar Lamaran';
  @override
  String get allStatusTab => 'Semua';
  @override
  String get searchApplicationPlaceholder => 'Cari posisi, perusahaan, lokasi...';
  @override
  String get filterStatus => 'Filter Status';
  @override
  String get filterPortal => 'Portal Lowongan';
  @override
  String get filterWorkSystem => 'Sistem Kerja';
  @override
  String get filterEmploymentType => 'Tipe Pekerjaan';
  @override
  String get sortNewest => 'Paling Baru Dilamar';
  @override
  String get sortOldest => 'Paling Lama Dilamar';
  @override
  String get sortCompanyAZ => 'Perusahaan (A - Z)';
  @override
  String get sortSalaryHighest => 'Gaji Tertinggi';
  @override
  String get sortStarredFirst => 'Ditandai Dahulu';
  @override
  String get noApplicationsFound => 'Tidak ada lamaran yang sesuai kriteria';
  @override
  String get clearFilters => 'Reset Filter';
  @override
  String get deleteApplicationConfirmTitle => 'Hapus Lamaran?';
  @override
  String get deleteApplicationConfirmMessage => 'Lamaran ini dan seluruh riwayat tahap interview akan dihapus permanen.';
  @override
  String get listView => 'Tampilan List';
  @override
  String get kanbanBoard => 'Papan Kanban';
  @override
  String get starred => 'Ditandai';
  @override
  String get emptyKanban => 'Kosong';
  @override
  String get noApplicationsYet => 'Belum Ada Lamaran';
  @override
  String get noApplicationsYetMsg => 'Mulai catat lowongan dan tahapan lamaran kerjamu dengan rapi.';
  @override
  String get newApplicationBtn => 'Catat Lamaran Baru';

  // Application Detail Screen
  @override
  String get applicationDetailTitle => 'Detail Lamaran';
  @override
  String get overviewTab => 'Ringkasan';
  @override
  String get timelineTab => 'Tahapan & Catatan';
  @override
  String get companyInfo => 'Informasi Perusahaan';
  @override
  String get salaryDetails => 'Ekspektasi & Penawaran Gaji';
  @override
  String get salaryExpectation => 'Ekspektasi Gaji';
  @override
  String get salaryOffered => 'Penawaran Gaji';
  @override
  String get appliedOn => 'Dilamar pada';
  @override
  String get notesTitle => 'Catatan Tambahan';
  @override
  String get noNotes => 'Belum ada catatan untuk lamaran ini.';
  @override
  String get jobUrlLabel => 'Tautan Lowongan Kerja';
  @override
  String get openJobUrl => 'Buka Link';
  @override
  String get updateStatus => 'Ubah Status';
  @override
  String get selectNewStatus => 'Pilih Status Lamaran';
  @override
  String get addTimelineStage => 'Tambah Catatan Tahap';
  @override
  String get editTimelineStage => 'Edit Catatan Tahap';
  @override
  String get deleteTimelineStage => 'Hapus Tahap';
  @override
  String get stageNameLabel => 'Nama Tahap (cth: HR Interview, User Test)';
  @override
  String get stageDateLabel => 'Tanggal / Jadwal';
  @override
  String get stageNotesLabel => 'Catatan / Pertanyaan / Feedback';
  @override
  String get cvAttachmentTitle => 'Lampiran CV / Portofolio';
  @override
  String get savedInDrive => 'Tersimpan di Google Drive';
  @override
  String get uploadCvToDrive => 'Upload CV / Berkas ke Google Drive';
  @override
  String get manageAttachment => 'Kelola Berkas Lampiran';
  @override
  String get deleteFromDrive => 'Hapus Permanen dari Google Drive';
  @override
  String get detachOnly => 'Lepas Lampiran Saja';
  @override
  String get updateStageStatusTitle => 'Update Status Tahap';
  @override
  String get stageOptionPassed => 'Lolos / Selesai';
  @override
  String get stageOptionNext => 'Lanjut Tahap Berikutnya';
  @override
  String get stageOptionOffering => 'Diterima / Offering';
  @override
  String get stageOptionWaiting => 'Menunggu (Waiting)';
  @override
  String get stageOptionFailed => 'Tidak Lolos (Gagal)';
  @override
  String get deleteStageConfirmTitle => 'Hapus Catatan Tahap?';
  @override
  String get deleteStageConfirmMessage => 'Catatan tahap wawancara ini akan dihapus.';
  @override
  String get noStagesRecorded => 'Belum ada catatan tahapan wawancara.';
  @override
  String get addStagePrompt => 'Tambahkan jadwal interview, tes teknikal, atau review berkas.';
  @override
  String get interviewerLabel => 'Pewawancara / Tim HR';
  @override
  String get interviewerHint => 'Cth: Budi (HR Lead)';
  @override
  String get meetingLinkLabel => 'Link Meeting / Video Call';
  @override
  String get meetingLinkHint => 'https://meet.google.com/...';
  @override
  String get openMeetingButton => 'Buka Link Pertemuan';
  @override
  String get quickStagesTitle => 'Pilihan Cepat Tahapan';
  @override
  String get stageStatusResult => 'Hasil / Status Tahap';
  @override
  String get stageNotesPlaceholder => 'Pertanyaan yang ditanyakan, kesan, kisi-kisi...';
  @override
  String get editApplicationTooltip => 'Edit Lamaran';
  @override
  String get deleteTooltip => 'Hapus';
  @override
  String get jobSourceLabel => 'Sumber Lowongan';
  @override
  String get openUrl => 'Buka URL';
  @override
  String get attachedDriveFiles => 'Berkas & CV (Google Drive)';
  @override
  String get noCvAttached => 'Belum ada berkas CV yang dilampirkan. Edit lamaran untuk mengupload ke Google Drive.';
  @override
  String get recruitmentStages => 'Tahapan Rekrutmen';
  @override
  String get addStageBtn => 'Tambah Tahap';
  @override
  String get noStagesMsg => 'Belum ada jadwal wawancara atau tahapan tes dicatat.';
  @override
  String get editStage => 'Edit Tahap';
  @override
  String get deleteStage => 'Hapus Tahap';
  @override
  String get deleteStageConfirm => 'Hapus Tahap?';
  @override
  String deleteStageMsg(String stageName) => 'Hapus tahap "$stageName" dari lamaran ini?';
  @override
  String get stageDeletedSuccess => 'Tahap berhasil dihapus';
  @override
  String get stageResultUpdated => 'Status tahap berhasil diperbarui';

  // Application Form Screen
  @override
  String get createApplicationTitle => 'Tambah Lamaran Baru';
  @override
  String get editApplicationTitle => 'Edit Data Lamaran';
  @override
  String get vacancyInfoSection => 'Informasi Lowongan';
  @override
  String get companyNameLabel => 'Nama Perusahaan *';
  @override
  String get companyNameHint => 'e.g. GoTo, Shopee, BCA, Telkom';
  @override
  String get companyNameRequired => 'Nama perusahaan wajib diisi';
  @override
  String get positionTitleLabel => 'Posisi / Role *';
  @override
  String get positionTitleHint => 'e.g. Flutter Developer, Product Manager';
  @override
  String get positionTitleRequired => 'Posisi pekerjaan wajib diisi';
  @override
  String get locationLabel => 'Lokasi Perusahaan';
  @override
  String get locationHint => 'e.g. Jakarta Selatan, Remote, Bandung';
  @override
  String get workTypeAndSystemSection => 'Tipe & Sistem Kerja';
  @override
  String get employmentTypeLabel => 'Tipe Pekerjaan';
  @override
  String get workSystemLabel => 'Sistem Kerja';
  @override
  String get jobPortalSection => 'Portal / Sumber Lowongan';
  @override
  String get otherPortalHint => 'Tuliskan nama portal atau sumber';
  @override
  String get jobUrlSection => 'Tautan Lowongan';
  @override
  String get jobUrlHint => 'https://linkedin.com/jobs/...';
  @override
  String get currentStatusSection => 'Status Saat Ini';
  @override
  String get appliedDateLabel => 'Tanggal Melamar';
  @override
  String get salarySection => 'Ekspektasi & Penawaran Gaji';
  @override
  String get salaryExpectationHint => 'Cth: 15.000.000 (Ekspektasi)';
  @override
  String get salaryOfferedHint => 'Cth: 16.500.000 (Ditawarkan)';
  @override
  String get notesSection => 'Catatan Tambahan';
  @override
  String get notesHint => 'Kebutuhan loker, kontak referral, poin penting...';
  @override
  String get saveApplicationButton => 'Simpan Lamaran';
  @override
  String get updateApplicationButton => 'Simpan Perubahan';

  // Dashboard / Analytics Screen
  @override
  String get analyticsTitle => 'Analitik Karir';
  @override
  String get pipelineFunnel => 'Kategori Status';
  @override
  String get systemsAndPortals => 'Sistem & Portal';
  @override
  String get successRateTitle => 'Tingkat Keberhasilan Lamaran';
  @override
  String get interviewCallsRate => 'Panggilan Interview';
  @override
  String get hiredRate => 'Diterima Kerja';
  @override
  String get topPortals => 'Portal Kerja Paling Efektif';
  @override
  String get monthlyApplications => 'Aktivitas Lamaran Bulanan';
  @override
  String get responseRate => 'Rasio Dipanggil Interview';
  @override
  String get offerRate => 'Rasio Diterima / Offer';
  @override
  String get totalApplicationsMetric => 'Total Lamaran';
  @override
  String get interviewStageMetric => 'Tahap Interview';
  @override
  String get offeringMetric => 'Offering';
  @override
  String get hiredMetric => 'Diterima Kerja';
  @override
  String get statusDistribution => 'Distribusi Status Lamaran';
  @override
  String get workSystemDistribution => 'Distribusi Sistem Kerja';
  @override
  String get noWorkSystemData => 'Belum ada data sistem kerja';
  @override
  String get portalSources => 'Sumber Portal Lowongan';
  @override
  String get noPortalData => 'Belum ada data portal lowongan';
  @override
  String get noAnalyticsDataTitle => 'Belum Ada Data Statistik';
  @override
  String get noAnalyticsDataMessage => 'Statistik, rasio panggilan interview, dan efektivitas portal loker akan dihitung otomatis saat kamu mulai mencatat lamaran.';

  // Schedule Screen
  @override
  String get scheduleTitle => 'Jadwal & Agenda';
  @override
  String get searchScheduleHint => 'Cari perusahaan, posisi, atau tahap...';
  @override
  String get upcomingTab => 'Mendatang';
  @override
  String get allAgendaTab => 'Semua Agenda';
  @override
  String get noScheduleTitle => 'Belum Ada Jadwal';
  @override
  String get noScheduleMessage => 'Belum ada tahapan interview atau deadline yang tersimpan. Jadwal akan otomatis muncul saat kamu mencatat agenda.';
  @override
  String get refreshSchedule => 'Perbarui Jadwal';
  @override
  String get noScheduleFoundTitle => 'Tidak Ada Jadwal Ditemukan';
  @override
  String noScheduleFoundMessage(String query) => 'Tidak ada agenda wawancara atau tahapan yang cocok dengan kata kunci "$query".';
  @override
  String get resetSearch => 'Reset Pencarian';
  @override
  String get noUpcomingScheduleTitle => 'Tidak Ada Jadwal Mendatang';
  @override
  String get noUpcomingScheduleMessage => 'Semua jadwal sudah terlewati atau belum ada agenda baru yang dijadwalkan.';
  @override
  String get noPastScheduleMessage => 'Belum ada catatan tahapan atau wawancara.';
  @override
  String get sectionOverdue => 'Terlewat';
  @override
  String get sectionOverdueSubtitle => 'Jadwal belum selesai/diupdate';
  @override
  String get sectionToday => 'Hari Ini';
  @override
  String get sectionTodaySubtitle => 'Agenda yang harus diikuti hari ini';
  @override
  String get sectionThisWeek => 'Minggu Ini';
  @override
  String get sectionThisWeekSubtitle => 'Agenda dalam 7 hari ke depan';
  @override
  String get sectionUpcoming => 'Mendatang';
  @override
  String get sectionUpcomingSubtitle => 'Agenda lebih dari 7 hari ke depan';
  @override
  String get sectionHistory => 'Riwayat Selesai';
  @override
  String get sectionHistorySubtitle => 'Agenda yang sudah selesai/terlewati';
  @override
  String get interviewerPrefix => 'Pewawancara: ';
  @override
  String get openMeetingRoom => 'Buka Link Pertemuan';

  // Profile & Settings Screen
  @override
  String get profileTitle => 'Profil & Pengaturan';
  @override
  String get accountSection => 'Akun';
  @override
  String get preferencesSection => 'Preferensi Aplikasi';
  @override
  String get dataSection => 'Data & Cadangan';
  @override
  String get aboutSection => 'Tentang AppliQ';
  @override
  String get themeSetting => 'Tema Tampilan';
  @override
  String get accentSetting => 'Gaya Warna Aksen';
  @override
  String get languageSetting => 'Pilih Bahasa';
  @override
  String get notificationsSetting => 'Notifikasi & Pengingat';
  @override
  String get exportDataSetting => 'Export Data (Excel / CSV / PDF)';
  @override
  String get googleDriveSetting => 'Integrasi Google Drive';
  @override
  String get connected => 'Terhubung';
  @override
  String get disconnected => 'Belum Terhubung';
  @override
  String get disconnectDriveConfirm => 'Putuskan Google Drive?';
  @override
  String get disconnectDriveMessage => 'Kamu bisa menghubungkan kembali akun kapan saja untuk upload berkas CV.';
  @override
  String get logoutButton => 'Keluar Akun';
  @override
  String get logoutConfirmTitle => 'Keluar dari AppliQ?';
  @override
  String get logoutConfirmMessage => 'Semua datamu tetap tersimpan aman di cloud dan dapat diakses kembali saat login.';
  @override
  String get appVersion => 'Versi AppliQ';

  // Edit Profile Screen
  @override
  String get editProfileTitle => 'Edit Profile';
  @override
  String get googleEmailLabel => 'Email Akun Google';
  @override
  String get googleEmailDesc => 'Email disinkronkan langsung dari autentikasi Google.';
  @override
  String get fullNameLabel => 'Nama Lengkap';
  @override
  String get fullNameHint => 'Masukkan nama lengkap';
  @override
  String get fullNameEmptyError => 'Nama lengkap tidak boleh kosong';
  @override
  String get usernameLabel => 'Username';
  @override
  String get phoneLabel => 'Nomor Telepon / WhatsApp';
  @override
  String get targetRoleLabel => 'Posisi Impian / Target Role';
  @override
  String get targetRoleHint => 'Contoh: Flutter Developer / UI Designer';
  @override
  String get saveChangesButton => 'Save Changes';
  @override
  String get deleteAccountButton => 'Delete Account';
  @override
  String get deleteAccountConfirmTitle => 'Hapus Akun Permanen?';
  @override
  String get deleteAccountConfirmMessage => 'Seluruh data lamaran, riwayat interview, dan catatan kamu akan dihapus secara permanen. Tindakan ini tidak dapat dibatalkan.';
  @override
  String get profileUpdatedSuccess => 'Profil berhasil diperbarui!';
  @override
  String get accountDeletedSuccess => 'Akun berhasil dihapus';

  // Notification Sheet
  @override
  String get notificationCenterTitle => 'Pusat Notifikasi';
  @override
  String get noUrgentReminders => 'Tidak ada pengingat mendesak';
  @override
  String activeRemindersCount(int count) => '$count pengingat aktif';
  @override
  String get pushNotificationTestTitle => 'Push Notification Popup';
  @override
  String get pushNotificationTestDesc => 'Tes pop-up alarm di status bar perangkat.';
  @override
  String get testNotificationButton => 'Tes Notif';
  @override
  String get testNotificationSentToast => 'Notifikasi uji coba berhasil dikirim ke perangkat!';
  @override
  String get interviewAgendaSection => 'AGENDA INTERVIEW & TES';
  @override
  String get followUpNeededSection => 'PERLU FOLLOW-UP (> 7 HARI)';
  @override
  String appliedDaysAgo(int days) => 'Dilamar $days hari lalu';
  @override
  String get emailHrButton => 'Email HR';
  @override
  String get allSchedulesSafeTitle => 'Semua Agenda Terjadwal Aman';
  @override
  String get allSchedulesSafeDesc => 'Belum ada wawancara mendesak atau lamaran tertunda.';

  // HR Templates Sheet
  @override
  String get hrTemplatesSheetTitle => 'Template Pesan HR';
  @override
  String get hrTemplatesSheetSubtitle => 'Format email profesional siap salin & pakai.';
  @override
  String get categoryAll => 'Semua';
  @override
  String get categoryFollowUp => 'Follow-up';
  @override
  String get categoryInterview => 'Interview';
  @override
  String get categoryOffering => 'Offering';
  @override
  String get copySubjectButton => 'Salin Subject';
  @override
  String get copyBodyButton => 'Salin Body Email';
  @override
  String copiedToast(String label) => '$label berhasil disalin ke clipboard!';

  // Language Modal
  @override
  String get languageModalTitle => 'Pilih Bahasa (Language)';
  @override
  String get languageModalSubtitle => 'Pilih bahasa antarmuka aplikasi';
  @override
  String get languageIdName => 'Bahasa Indonesia';
  @override
  String get languageIdSubtitle => 'Bahasa Indonesia (Standar)';
  @override
  String get languageEnName => 'English';
  @override
  String get languageEnSubtitle => 'English (United States)';
  @override
  String get languageJaName => '日本語';
  @override
  String get languageJaSubtitle => 'Japanese (Nihongo)';
  @override
  String get languageKoName => '한국어';
  @override
  String get languageKoSubtitle => 'Korean (Hangugeo)';
  @override
  String get languageComingSoonToast => 'Bahasa ini akan segera hadir pada update berikutnya!';

  // Export Sheet
  @override
  String get exportSheetTitle => 'Export Data Lamaran';
  @override
  String get exportSheetSubtitle => 'Unduh laporan data lamaran kerjamu';
  @override
  String get exportFormat => 'Format Berkas';
  @override
  String get exportDateRange => 'Rentang Waktu';
  @override
  String get exportAllTime => 'Semua Waktu';
  @override
  String get exportThisMonth => 'Bulan Ini';
  @override
  String get exportLast3Months => '3 Bulan Terakhir';
  @override
  String get exportThisYear => 'Tahun Ini';
  @override
  String get exportButton => 'Export & Bagikan Berkas';
  @override
  String get exportSuccess => 'Data berhasil diexport!';
  @override
  String get exportEmpty => 'Tidak ada data lamaran untuk diexport.';

  // Toasts & Snackbars
  @override
  String get errorOccurred => 'Terjadi kesalahan. Silakan coba lagi.';
  @override
  String get successSaved => 'Lamaran berhasil dicatat.';
  @override
  String get successUpdated => 'Lamaran berhasil diperbarui.';
  @override
  String get successDeleted => 'Lamaran berhasil dihapus.';
  @override
  String get fileUploadedDrive => 'Berkas berhasil diupload ke Google Drive.';
  @override
  String get fileDeletedDrive => 'Berkas berhasil dihapus dari Google Drive.';
  @override
  String get attachmentDetached => 'Lampiran berkas berhasil dilepaskan.';
  @override
  String get fillRequiredFields => 'Isi nama perusahaan dan posisi terlebih dahulu.';

  // Login Screen
  @override
  String get loginTagline => 'Kelola & pantau setiap tahapan\nlamaran kerjamu secara real-time.';
  @override
  String get signInWithGoogle => 'Sign in with Google';
  @override
  String get termsPrefix => 'Dengan masuk, kamu menyetujui ';
  @override
  String get termsOfService => 'Ketentuan Layanan';
  @override
  String get andConjunction => ' dan ';
  @override
  String get privacyPolicy => 'Kebijakan Privasi';
  @override
  String get termsContent => 'Dengan menggunakan AppliQ, kamu setuju untuk menggunakan aplikasi ini untuk keperluan pencatatan lamaran kerja secara bertanggung jawab. Data kamu disimpan secara aman menggunakan protokol enkripsi standar industri.';
  @override
  String get privacyContent => 'AppliQ menghormati dan menjaga privasi datamu. Seluruh data lamaran, profil, dan kontak hanya dapat diakses oleh pemilik akun dan tidak pernah dibagikan kepada pihak ketiga tanpa persetujuan eksplisit.';
  @override
  String welcomeUser(String name) => 'Selamat datang, $name!';

  // Enums & Dynamic Values
  @override
  String localizedEmploymentType(EmploymentType type) => type.label;

  @override
  String localizedWorkSystem(WorkSystem system) => system.label;

  @override
  String localizedJobPortal(JobPortal portal) => portal.label;

  @override
  String localizedStatus(ApplicationStatus status) => status.label;

  @override
  String localizedResult(String result) => result;
}
