import '../../constants/app_enums.dart';
import 'base_language.dart';

class EnLanguage implements BaseLanguage {
  // Navigation
  @override
  String get navHome => 'Home';
  @override
  String get navApplications => 'Apply';
  @override
  String get navSchedule => 'Schedule';
  @override
  String get navStats => 'Stats';
  @override
  String get navAnalytics => 'Analytics';
  @override
  String get navProfile => 'Profile';

  // Common Actions & Labels
  @override
  String get cancel => 'Cancel';
  @override
  String get save => 'Save';
  @override
  String get delete => 'Delete';
  @override
  String get edit => 'Edit';
  @override
  String get close => 'Close';
  @override
  String get search => 'Search...';
  @override
  String get filter => 'Filter';
  @override
  String get sort => 'Sort';
  @override
  String get reset => 'Reset';
  @override
  String get apply => 'Apply';
  @override
  String get confirm => 'Confirm';
  @override
  String get done => 'Done';
  @override
  String get back => 'Back';
  @override
  String get retry => 'Retry';
  @override
  String get loading => 'Loading...';
  @override
  String get empty => 'No data';
  @override
  String get comingSoon => 'Coming Soon';
  @override
  String get viewAll => 'View All';
  @override
  String get openInDrive => 'Open in Google Drive';
  @override
  String get scheduleDateLabel => 'Schedule';

  // Home Screen
  @override
  String get greetingMorning => 'Good Morning';
  @override
  String get greetingAfternoon => 'Good Afternoon';
  @override
  String get greetingEvening => 'Good Evening';
  @override
  String get greetingNight => 'Good Night';
  @override
  String get homeSubtitle => 'Track your career journey seamlessly';
  @override
  String get homeSearchHint => 'Search company or position...';
  @override
  String get statTotal => 'Total Apply';
  @override
  String get statActive => 'In Progress';
  @override
  String get statInterview => 'Interview';
  @override
  String get statOffering => 'Offering';
  @override
  String get recentApplications => 'Recent Applications';
  @override
  String get quickAddApplication => 'Add';
  @override
  String get quickSchedule => 'Schedule';
  @override
  String get quickTemplate => 'Template';
  @override
  String get quickExport => 'Export';
  @override
  String get quickAddTooltip => 'Record new job application';
  @override
  String get upcomingReminders => 'Upcoming Reminders';
  @override
  String get noReminders => 'No upcoming interview or schedule';
  @override
  String get emptyRecentApps => 'No applications recorded yet';
  @override
  String get emptyRecentAppsDesc => 'Start adding job openings you are pursuing.';
  @override
  String get addFirstApp => 'Add First Application';
  @override
  String get applicationSummary => 'Application Summary';
  @override
  String get statsButton => 'Stats';
  @override
  String get appliedLabel => 'Applied';
  @override
  String get nextSchedule => 'Next Schedule';
  @override
  String get openMeetingLink => 'Open Meeting Link';
  @override
  String get viewDetails => 'View Details';
  @override
  String get followUpNeeded => 'Follow-up Needed';
  @override
  String get sendFollowUpEmail => 'Send Follow-up Email';
  @override
  String get appliedCompanies => 'Applied Companies';
  @override
  String get noAppliedCompanies => 'No companies recorded yet.';
  @override
  String get salaryUndisclosed => 'Salary Undisclosed';
  @override
  String get perMonth => '/ mo';
  @override
  String positionsCount(int count) => '$count Position${count == 1 ? '' : 's'}';
  @override
  String applicationsCount(int count) => '$count Application${count == 1 ? '' : 's'}';
  @override
  String staleAppSingle(String company) => 'Application at $company has had no status update for > 7 days.';
  @override
  String staleAppMulti(int count, String company) => '$count applications including $company have had no response for > 7 days.';

  // Applications List Screen
  @override
  String get applicationsTitle => 'Applications';
  @override
  String get allStatusTab => 'All';
  @override
  String get searchApplicationPlaceholder => 'Search position, company, location...';
  @override
  String get filterStatus => 'Filter Status';
  @override
  String get filterPortal => 'Job Portal';
  @override
  String get filterWorkSystem => 'Work System';
  @override
  String get filterEmploymentType => 'Job Type';
  @override
  String get sortNewest => 'Newest Applied';
  @override
  String get sortOldest => 'Oldest Applied';
  @override
  String get sortCompanyAZ => 'Company (A to Z)';
  @override
  String get sortSalaryHighest => 'Highest Salary';
  @override
  String get sortStarredFirst => 'Starred First';
  @override
  String get noApplicationsFound => 'No applications match your criteria';
  @override
  String get clearFilters => 'Reset Filter';
  @override
  String get deleteApplicationConfirmTitle => 'Delete Application?';
  @override
  String get deleteApplicationConfirmMessage => 'This application and all associated interview logs will be permanently deleted.';
  @override
  String get listView => 'List View';
  @override
  String get kanbanBoard => 'Kanban Board';
  @override
  String get starred => 'Starred';
  @override
  String get emptyKanban => 'Empty';
  @override
  String get noApplicationsYet => 'No Applications Yet';
  @override
  String get noApplicationsYetMsg => 'Start tracking your job applications and interview stages neatly.';
  @override
  String get newApplicationBtn => 'New Application';

  // Application Detail Screen
  @override
  String get applicationDetailTitle => 'Application Details';
  @override
  String get overviewTab => 'Overview';
  @override
  String get timelineTab => 'Timeline & Logs';
  @override
  String get companyInfo => 'Company Information';
  @override
  String get salaryDetails => 'Salary Expectation & Offer';
  @override
  String get salaryExpectation => 'Expectation';
  @override
  String get salaryOffered => 'Offered';
  @override
  String get appliedOn => 'Applied on';
  @override
  String get notesTitle => 'Notes & Details';
  @override
  String get noNotes => 'No notes added for this application.';
  @override
  String get jobUrlLabel => 'Job Posting Link';
  @override
  String get openJobUrl => 'Open Link';
  @override
  String get updateStatus => 'Update Status';
  @override
  String get selectNewStatus => 'Select Application Status';
  @override
  String get addTimelineStage => 'Add Stage Log';
  @override
  String get editTimelineStage => 'Edit Stage Log';
  @override
  String get deleteTimelineStage => 'Delete Stage';
  @override
  String get stageNameLabel => 'Stage Name (e.g., HR Interview, Technical Test)';
  @override
  String get stageDateLabel => 'Schedule / Date';
  @override
  String get stageNotesLabel => 'Notes / Feedback / Questions Asked';
  @override
  String get cvAttachmentTitle => 'Attached Document';
  @override
  String get savedInDrive => 'Saved in Google Drive';
  @override
  String get uploadCvToDrive => 'Upload Document';
  @override
  String get manageAttachment => 'Manage Document Attachment';
  @override
  String get deleteFromDrive => 'Permanently Delete from Google Drive';
  @override
  String get detachOnly => 'Detach Attachment Only';
  @override
  String get updateStageStatusTitle => 'Update Stage Status';
  @override
  String get stageOptionPassed => 'Passed / Completed';
  @override
  String get stageOptionNext => 'Advance to Next Stage';
  @override
  String get stageOptionOffering => 'Accepted / Offering';
  @override
  String get stageOptionWaiting => 'Waiting';
  @override
  String get stageOptionFailed => 'Not Passed (Failed)';
  @override
  String get deleteStageConfirmTitle => 'Delete Stage Log?';
  @override
  String get deleteStageConfirmMessage => 'This interview stage record will be removed.';
  @override
  String get noStagesRecorded => 'No interview stages added yet.';
  @override
  String get addStagePrompt => 'Add interview, test, or review milestones for this application.';
  @override
  String get interviewerLabel => 'Interviewer / HR Team';
  @override
  String get interviewerHint => 'e.g. John Doe (Engineering Lead)';
  @override
  String get meetingLinkLabel => 'Meeting / Video Call Link';
  @override
  String get meetingLinkHint => 'https://meet.google.com/...';
  @override
  String get openMeetingButton => 'Open Meeting Link';
  @override
  String get quickStagesTitle => 'Quick Stage Suggestions';
  @override
  String get stageStatusResult => 'Stage Status / Result';
  @override
  String get stageNotesPlaceholder => 'Questions asked, interview impressions, feedback...';
  @override
  String get editApplicationTooltip => 'Edit Application';
  @override
  String get deleteTooltip => 'Delete';
  @override
  String get jobSourceLabel => 'Job Source';
  @override
  String get openUrl => 'Open URL';
  @override
  String get attachedDriveFiles => 'Files & CV (Google Drive)';
  @override
  String get noCvAttached => 'No CV or resume attached. Edit application to upload to Google Drive.';
  @override
  String get recruitmentStages => 'Recruitment Stages';
  @override
  String get addStageBtn => 'Add Stage';
  @override
  String get noStagesMsg => 'No interview schedules or tests recorded yet.';
  @override
  String get editStage => 'Edit Stage';
  @override
  String get deleteStage => 'Delete Stage';
  @override
  String get deleteStageConfirm => 'Delete Stage?';
  @override
  String deleteStageMsg(String stageName) => 'Delete stage "$stageName" from this application?';
  @override
  String get stageDeletedSuccess => 'Stage deleted successfully';
  @override
  String get stageResultUpdated => 'Stage status updated';

  // Application Form Screen
  @override
  String get createApplicationTitle => 'New Application';
  @override
  String get editApplicationTitle => 'Edit Application';
  @override
  String get vacancyInfoSection => 'Vacancy Information';
  @override
  String get companyNameLabel => 'Company Name *';
  @override
  String get companyNameHint => 'e.g. Google, Apple, Microsoft';
  @override
  String get companyNameRequired => 'Please enter company name';
  @override
  String get positionTitleLabel => 'Position / Role *';
  @override
  String get positionTitleHint => 'e.g. Senior Flutter Developer';
  @override
  String get positionTitleRequired => 'Please enter position title';
  @override
  String get locationLabel => 'Company Location';
  @override
  String get locationHint => 'e.g. Jakarta, Remote, Singapore';
  @override
  String get workTypeAndSystemSection => 'Work Type & System';
  @override
  String get employmentTypeLabel => 'Employment Type';
  @override
  String get workSystemLabel => 'Work System';
  @override
  String get jobPortalSection => 'Job Portal / Source';
  @override
  String get otherPortalHint => 'Specify job portal or platform';
  @override
  String get jobUrlSection => 'Job Posting Link / URL';
  @override
  String get jobUrlHint => 'https://linkedin.com/jobs/...';
  @override
  String get currentStatusSection => 'Current Status';
  @override
  String get appliedDateLabel => 'Application Date';
  @override
  String get salarySection => 'Salary & Compensation';
  @override
  String get salaryExpectationHint => 'e.g. 15,000,000 (Expected)';
  @override
  String get salaryOfferedHint => 'e.g. 16,500,000 (Offered)';
  @override
  String get notesSection => 'Additional Notes';
  @override
  String get notesHint => 'Job requirements, referral contacts, key highlights...';
  @override
  String get saveApplicationButton => 'Save Application';
  @override
  String get updateApplicationButton => 'Save Changes';

  // Dashboard / Analytics Screen
  @override
  String get analyticsTitle => 'Career Analytics';
  @override
  String get pipelineFunnel => 'Pipeline Funnel';
  @override
  String get systemsAndPortals => 'Systems & Portals';
  @override
  String get successRateTitle => 'Application Success Rate';
  @override
  String get interviewCallsRate => 'Interview Calls';
  @override
  String get hiredRate => 'Hired / Accepted';
  @override
  String get topPortals => 'Top Job Portals';
  @override
  String get monthlyApplications => 'Monthly Activity';
  @override
  String get responseRate => 'Interview Conversion';
  @override
  String get offerRate => 'Offer Success Rate';
  @override
  String get totalApplicationsMetric => 'Total Apply';
  @override
  String get interviewStageMetric => 'Interview Stage';
  @override
  String get offeringMetric => 'Offering';
  @override
  String get hiredMetric => 'Hired';
  @override
  String get statusDistribution => 'Application Status Distribution';
  @override
  String get workSystemDistribution => 'Work System Distribution';
  @override
  String get noWorkSystemData => 'No work system data yet';
  @override
  String get portalSources => 'Job Portal Sources';
  @override
  String get noPortalData => 'No job portal data yet';
  @override
  String get noAnalyticsDataTitle => 'No Analytics Data';
  @override
  String get noAnalyticsDataMessage => 'Career analytics, interview conversion rates, and portal performance will be calculated once you start tracking applications.';

  // Schedule Screen
  @override
  String get scheduleTitle => 'Schedule & Agenda';
  @override
  String get searchScheduleHint => 'Search company, position, or stage...';
  @override
  String get upcomingTab => 'Upcoming';
  @override
  String get allAgendaTab => 'All Agenda';
  @override
  String get noScheduleTitle => 'No Schedule Yet';
  @override
  String get noScheduleMessage => 'No interview stages or deadlines recorded. Schedules appear automatically as you add stage logs.';
  @override
  String get refreshSchedule => 'Refresh Schedule';
  @override
  String get noScheduleFoundTitle => 'No Schedules Found';
  @override
  String noScheduleFoundMessage(String query) => 'No interview agenda matches "$query".';
  @override
  String get resetSearch => 'Reset Search';
  @override
  String get noUpcomingScheduleTitle => 'No Upcoming Schedules';
  @override
  String get noUpcomingScheduleMessage => 'All schedules have passed or no upcoming events are planned.';
  @override
  String get noPastScheduleMessage => 'No stage or interview history recorded yet.';
  @override
  String get sectionOverdue => 'Overdue';
  @override
  String get sectionOverdueSubtitle => 'Pending action / update';
  @override
  String get sectionToday => 'Today';
  @override
  String get sectionTodaySubtitle => 'Agenda scheduled for today';
  @override
  String get sectionThisWeek => 'This Week';
  @override
  String get sectionThisWeekSubtitle => 'Agenda within the next 7 days';
  @override
  String get sectionUpcoming => 'Upcoming';
  @override
  String get sectionUpcomingSubtitle => 'Agenda further than 7 days ahead';
  @override
  String get sectionHistory => 'Completed History';
  @override
  String get sectionHistorySubtitle => 'Past or completed agenda';
  @override
  String get interviewerPrefix => 'Interviewer: ';
  @override
  String get openMeetingRoom => 'Open Meeting Link';
  @override
  String get syncToCalendar => 'Sync to Calendar';
  @override
  String get calendarSyncSuccess => 'Opening Google Calendar...';
  @override
  String statusUpdatedTo(String status) => 'Status updated to $status';
  @override
  String get dragToMove => 'Hold & drag to change status';

  // Profile & Settings Screen
  @override
  String get profileTitle => 'Profile & Settings';
  @override
  String get accountSection => 'Account';
  @override
  String get preferencesSection => 'Preferences';
  @override
  String get dataSection => 'Data & Backup';
  @override
  String get aboutSection => 'About AppliQ';
  @override
  String get themeSetting => 'Theme';
  @override
  String get accentSetting => 'Accent Style';
  @override
  String get languageSetting => 'Language';
  @override
  String get notificationsSetting => 'Notifications & Reminders';
  @override
  String get exportDataSetting => 'Export Data (Excel / CSV / PDF)';
  @override
  String get googleDriveSetting => 'Google Drive Integration';
  @override
  String get connected => 'Connected';
  @override
  String get disconnected => 'Not Connected';
  @override
  String get disconnectDriveConfirm => 'Disconnect Google Drive?';
  @override
  String get disconnectDriveMessage => 'You can reconnect anytime to manage and attach your resume files.';
  @override
  String get logoutButton => 'Log Out';
  @override
  String get logoutConfirmTitle => 'Sign Out of AppliQ?';
  @override
  String get logoutConfirmMessage => 'Your data is securely stored in the cloud and will be restored upon sign in.';
  @override
  String get appVersion => 'AppliQ Version';

  // Edit Profile Screen
  @override
  String get editProfileTitle => 'Edit Profile';
  @override
  String get googleEmailLabel => 'Google Account Email';
  @override
  String get googleEmailDesc => 'Synced from Google';
  @override
  String get fullNameLabel => 'Full Name';
  @override
  String get fullNameHint => 'Enter your full name';
  @override
  String get fullNameEmptyError => 'Full name cannot be empty';
  @override
  String get usernameLabel => 'Username';
  @override
  String get phoneLabel => 'Phone / WhatsApp Number';
  @override
  String get targetRoleLabel => 'Target Role / Dream Position';
  @override
  String get targetRoleHint => 'e.g. Senior Flutter Developer / UI Designer';
  @override
  String get saveChangesButton => 'Save Changes';
  @override
  String get deleteAccountButton => 'Delete Account';
  @override
  String get deleteAccountConfirmTitle => 'Permanently Delete Account?';
  @override
  String get deleteAccountConfirmMessage => 'All application records, interview history, and notes will be permanently deleted. This action cannot be undone.';
  @override
  String get profileUpdatedSuccess => 'Profile updated successfully!';
  @override
  String get accountDeletedSuccess => 'Account deleted successfully';

  // Notification Sheet
  @override
  String get notificationCenterTitle => 'Notification Center';
  @override
  String get noUrgentReminders => 'No urgent reminders';
  @override
  String activeRemindersCount(int count) => '$count active reminder${count == 1 ? '' : 's'}';
  @override
  String get pushNotificationTestTitle => 'Push Notification Popup';
  @override
  String get pushNotificationTestDesc => 'Test alarm pop-up in device status bar.';
  @override
  String get testNotificationButton => 'Test Notif';
  @override
  String get testNotificationSentToast => 'Test notification sent to device!';
  @override
  String get interviewAgendaSection => 'INTERVIEW & TEST AGENDA';
  @override
  String get followUpNeededSection => 'FOLLOW-UP NEEDED (> 7 DAYS)';
  @override
  String appliedDaysAgo(int days) => 'Applied $days day${days == 1 ? '' : 's'} ago';
  @override
  String get emailHrButton => 'Email HR';
  @override
  String get allSchedulesSafeTitle => 'All Schedules on Track';
  @override
  String get allSchedulesSafeDesc => 'No urgent interviews or pending follow-ups.';

  // HR Templates Sheet
  @override
  String get hrTemplatesSheetTitle => 'HR Email Templates';
  @override
  String get hrTemplatesSheetSubtitle => 'Professional email templates ready to copy & use.';
  @override
  String get categoryAll => 'All';
  @override
  String get categoryFollowUp => 'Follow-up';
  @override
  String get categoryInterview => 'Interview';
  @override
  String get categoryOffering => 'Offering';
  @override
  String get copySubjectButton => 'Copy Subject';
  @override
  String get copyBodyButton => 'Copy Email Body';
  @override
  String copiedToast(String label) => '$label copied to clipboard!';

  // Language Modal
  @override
  String get languageModalTitle => 'Select Language';
  @override
  String get languageModalSubtitle => 'Choose application interface language';
  @override
  String get languageIdName => 'Bahasa Indonesia';
  @override
  String get languageIdSubtitle => 'Bahasa Indonesia (Standar)';
  @override
  String get languageEnName => 'English';
  @override
  String get languageEnSubtitle => 'English (Global)';
  @override
  String get languageJaName => '日本語';
  @override
  String get languageJaSubtitle => 'Japanese (Nihongo)';
  @override
  String get languageKoName => '한국어';
  @override
  String get languageKoSubtitle => 'Korean (Hangugeo)';
  @override
  String get languageComingSoonToast => 'This language will be available in an upcoming update!';

  // Export Sheet
  @override
  String get exportSheetTitle => 'Export Application Data';
  @override
  String get exportSheetSubtitle => 'Download report in your preferred format';
  @override
  String get exportFormat => 'File Format';
  @override
  String get exportDateRange => 'Date Range';
  @override
  String get exportAllTime => 'All Time';
  @override
  String get exportThisMonth => 'This Month';
  @override
  String get exportLast3Months => 'Last 3 Months';
  @override
  String get exportThisYear => 'This Year';
  @override
  String get exportButton => 'Export & Share File';
  @override
  String get exportSuccess => 'Data exported successfully!';
  @override
  String get exportEmpty => 'No application records to export.';

  // Toasts & Snackbars
  @override
  String get errorOccurred => 'An error occurred. Please try again.';
  @override
  String get successSaved => 'Application saved successfully.';
  @override
  String get successUpdated => 'Application updated successfully.';
  @override
  String get successDeleted => 'Application deleted.';
  @override
  String get fileUploadedDrive => 'File uploaded to Google Drive successfully.';
  @override
  String get fileDeletedDrive => 'File deleted from Google Drive.';
  @override
  String get attachmentDetached => 'Attachment detached from application.';
  @override
  String get fillRequiredFields => 'Please fill in company name and position first.';

  // Login Screen
  @override
  String get loginTagline => 'Manage & track every step of your\njob applications in real-time.';
  @override
  String get signInWithGoogle => 'Sign in with Google';
  @override
  String get termsPrefix => 'By signing in, you agree to AppliQ\'s ';
  @override
  String get termsOfService => 'Terms of Service';
  @override
  String get andConjunction => ' and ';
  @override
  String get privacyPolicy => 'Privacy Policy';
  @override
  String get termsContent => 'By using AppliQ, you agree to use this application for tracking job applications responsibly. Your data is securely stored using industry-standard encryption protocols.';
  @override
  String get privacyContent => 'AppliQ respects and protects your data privacy. All application records, profile details, and contacts are only accessible by you and never shared with third parties without your explicit consent.';
  @override
  String welcomeUser(String name) => 'Welcome, $name!';

  // Status Feedback Text
  @override
  String get feedbackSubmittedToday => 'Submitted today';
  @override
  String feedbackSubmittedDaysAgo(int days) => 'Submitted $days day${days == 1 ? '' : 's'} ago';
  @override
  String get feedbackNoResponse30Days => 'No response > 30 days';
  @override
  String get feedbackStayMotivated => 'Keep going, more opportunities ahead';
  @override
  String feedbackCurrentStage(String stageName) => 'You are currently in the $stageName stage';

  // Legal (Terms of Service & Privacy Policy Modals)
  @override
  String get termsModalTitle => 'Terms of Service';
  @override
  String get termsModalSubtitle => 'Official AppliQ Terms';
  @override
  List<Map<String, String>> get termsCards => [
    {
      'title': '1. Acceptance of Terms',
      'content': 'By signing in, accessing, or utilizing the AppliQ application platform, you agree to be bound by these Terms of Service. If you do not agree with any clause in these terms, please refrain from continuing use of our services.',
    },
    {
      'title': '2. User Accounts & Security',
      'content': 'You are solely responsible for maintaining the confidentiality of your Google account authentication credentials. All activities occurring under your account are your personal responsibility. AppliQ is not liable for losses arising from compromised access.',
    },
    {
      'title': '3. Job Tracking & Management Services',
      'content': 'AppliQ provides an integrated job application tracking tool (Job Tracker), interview scheduling, conversion rate statistics calculation, and career management records. This service is provided "as is" to assist your job hunting productivity.',
    },
    {
      'title': '4. Intellectual Property Rights',
      'content': 'All interface elements, graphic designs, AppliQ logos, source code, and associated documentation are protected by copyright and intellectual property laws. Reproduction, redistribution, or reverse engineering without prior written consent is strictly prohibited.',
    },
    {
      'title': '5. Limitation of Liability & Warranties',
      'content': 'AppliQ does not guarantee employment offers or hiring outcomes at any target companies. We make every effort to maintain server reliability and data synchronization, but are not liable for third-party network disruptions.',
    },
    {
      'title': '6. Modifications to Terms',
      'content': 'We reserve the right to revise these Terms of Service at any time to comply with regulatory standards or when introducing new features. Updates will be published on this page with the corresponding effective date.',
    },
  ];

  @override
  String get privacyModalTitle => 'User Privacy Policy';
  @override
  String get privacyModalSubtitle => 'Encrypted Privacy';
  @override
  List<Map<String, String>> get privacyCards => [
    {
      'title': '1. Information We Collect',
      'content': 'We collect information you provide directly while using AppliQ, including: Google profile details (name, email address, avatar photo URL), job application entries (company name, position, status, compensation, interview notes), and local preference settings.',
    },
    {
      'title': '2. How We Use Your Information',
      'content': 'Your information is used strictly to power job tracking features: syncing with Supabase cloud database, scheduling interview reminders, generating personal analytics, and optimizing your user interface experience.',
    },
    {
      'title': '3. Encryption & Database Security',
      'content': 'All data transmissions are protected via TLS/HTTPS encryption and stored in Supabase with Row-Level Security (RLS). Only your authenticated account has permissions to read and modify your application records.',
    },
    {
      'title': '4. No Third-Party Data Selling',
      'content': 'AppliQ pledges never to sell, rent, or share your application history or personal information with advertisers or any third parties without your explicit authorization.',
    },
    {
      'title': '5. Total Account Control & Deletion',
      'content': 'You retain full rights to update your profile, export your career data records, or permanently delete your account along with all associated database records via the "Delete Account" option in Edit Profile.',
    },
  ];

  @override
  List<Map<String, String>> get faqList => [
    {
      'q': 'What is AppliQ and how does it work?',
      'a': 'AppliQ is a smart job application tracker designed to help you log applications, organize interview stages, set reminders, and analyze career conversion rates in real-time.',
    },
    {
      'q': 'How do I set up interview reminder notifications?',
      'a': 'When adding or editing an interview stage in Application Details, specify the date and time. Ensure the "Notifications & Reminders" toggle in Settings is enabled so you receive timely alerts.',
    },
    {
      'q': 'Are my salary figures and application records secure?',
      'a': 'Extremely secure. AppliQ enforces Row-Level Security (RLS) on Supabase with TLS encryption. No other user or external entity can view your private application history.',
    },
    {
      'q': 'How do I search and filter through my applications?',
      'a': 'Go to the Applications or Schedule tab. Use the search bar at the top to filter by company name or role, or tap status filters (Applied, Interview, Offering, Rejected).',
    },
    {
      'q': 'Can I export my job application records?',
      'a': 'Yes. The Export feature lets you download your career history summaries in clean PDF reports or CSV spreadsheets anytime.',
    },
  ];

  // Settings & Bottom Sheets
  @override
  String get generalSettingsTitle => 'General Settings';
  @override
  String get generalSettingsSubtitle => 'Customize application appearance & preferences';
  @override
  String get appearanceSection => 'APPEARANCE';
  @override
  String get darkModeTitle => 'Dark Mode';
  @override
  String get darkModeDesc => 'Switch between dark and light themes';
  @override
  String get monochromeTitle => 'Monochrome Mode';
  @override
  String get monochromeDesc => 'Use minimalist black and white theme';
  @override
  String get preferencesFormatSection => 'PREFERENCES & FORMAT';
  @override
  String get appLanguageTitle => 'App Language';
  @override
  String get appLanguageDesc => 'Choose interface language';
  @override
  String get defaultCurrencyTitle => 'Default Currency';
  @override
  String get defaultCurrencyDesc => 'Currency format for compensation';
  @override
  String get dateFormatTitle => 'Date Format';
  @override
  String get dateFormatDesc => 'Date format displayed throughout app';
  @override
  String get feedbackHapticSection => 'INTERACTION & SORTING';
  @override
  String get hapticTitle => 'Haptic Feedback';
  @override
  String get hapticDesc => 'Vibrate upon tapping buttons and actions';
  @override
  String get defaultSortTitle => 'Default Application Sort';
  @override
  String get defaultSortDesc => 'Automatic sorting for application list';
  @override
  String get sortPickerTitle => 'Default Sort Order';
  @override
  String get sortPickerSubtitle => 'Choose default order for job applications';
  @override
  String get sortOptionNewest => 'Newest Applied';
  @override
  String get sortOptionNewestDesc => 'Displays most recently added applications on top';
  @override
  String get sortOptionClosest => 'Nearest Deadline';
  @override
  String get sortOptionClosestDesc => 'Prioritizes applications with upcoming deadlines';
  @override
  String get sortOptionCompanyAZ => 'Company Name A-Z';
  @override
  String get sortOptionCompanyAZDesc => 'Sorts alphabetically by company name';
  @override
  String get sortOptionSalary => 'Highest Salary';
  @override
  String get sortOptionSalaryDesc => 'Displays applications with highest compensation first';
  @override
  String get securitySettingsTitle => 'Security & Authentication';
  @override
  String get securitySettingsSubtitle => 'Protect your Google account and cloud database';
  @override
  String get cloudSyncTitle => 'Google Drive Cloud Sync';
  @override
  String get cloudSyncSubtitle => 'Storage for attached resumes and portfolio files';

  @override
  String get quickResume => 'ATS Resume';

  @override
  String get menuExperienceTitle => 'Experience';
  @override
  String get menuExperienceSubtitle => 'ATS Resume & Cover Letter';
  @override
  String get resumeBuilderTitle => 'Experience & Resume';
  @override
  String get previewCvAts => 'Preview ATS CV';
  @override
  String get coverLetterTitle => 'Cover Letter';
  @override
  String get documentPreviewTitle => 'Document Preview';
  @override
  String get customizeCoverLetter => 'Customize Cover Letter';
  @override
  String get digitalSignature => 'Digital Signature';
  @override
  String get uploadSignature => 'Upload Signature';
  @override
  String get changeSignature => 'Change Signature';
  @override
  String get signatureActive => 'Signature active';
  @override
  String get applyChanges => 'Apply Changes';
  @override
  String get saveResume => 'Save Data';

  // Resume Builder Sections
  @override
  String get rbSectionContactTitle => 'Contact & Header';
  @override
  String get rbSectionContactSubtitle => 'Full name, email, phone & social links';
  @override
  String get rbSectionSummaryTitle => 'Professional Summary';
  @override
  String get rbSectionSummarySubtitle => 'Brief overview of your background';
  @override
  String get rbSectionEducationTitle => 'Education History';
  @override
  String rbSectionEducationSubtitle(int count) => '$count recorded degrees';
  @override
  String get rbSectionExperienceTitle => 'Work & Project Experience';
  @override
  String rbSectionExperienceSubtitle(int count) => '$count experiences listed';
  @override
  String get rbSectionCertificationTitle => 'Certifications & Licenses';
  @override
  String rbSectionCertificationSubtitle(int count) => '$count certificates';
  @override
  String get rbSectionTechSkillsTitle => 'Technical Skills';
  @override
  String rbSectionTechSkillsSubtitle(int count) => '$count skills listed';
  @override
  String get rbSectionSoftSkillsTitle => 'Personal & Soft Skills';
  @override
  String rbSectionSoftSkillsSubtitle(int count) => '$count soft skills (3-column layout)';
  @override
  String get rbSectionCoverLetterTitle => 'Cover Letter Extra Data';
  @override
  String get rbSectionCoverLetterSubtitle => 'Birth date, address, attachments checklist';

  // Resume Builder Form Labels & Hints
  @override
  String get cityCountryLabel => 'City, Country';
  @override
  String get cityCountryHint => 'e.g. San Francisco, USA';
  @override
  String get phoneNumberLabel => 'Phone Number / WhatsApp';
  @override
  String get phoneNumberHint => '+1 234 567 890';
  @override
  String get emailLabel => 'Email Address';
  @override
  String get emailHint => 'john.doe@email.com';
  @override
  String get linkedinLabel => 'LinkedIn URL (Optional)';
  @override
  String get linkedinHint => 'linkedin.com/in/johndoe';
  @override
  String get portfolioLabel => 'Portfolio / GitHub URL (Optional)';
  @override
  String get portfolioHint => 'github.com/johndoe';

  @override
  String get summaryLabel => 'Professional Summary';
  @override
  String get summaryHint => 'Brief overview of your background, core strengths, and achievements...';

  @override
  String get addEducationButton => '+ Add Education';
  @override
  String get addExperienceButton => '+ Add Experience';
  @override
  String get addCertificationButton => '+ Add Certification';

  @override
  String get addTechSkillLabel => 'Add Technical Skill';
  @override
  String get addTechSkillHint => 'e.g. Flutter, Python, SQL...';
  @override
  String get addSoftSkillLabel => 'Add Soft Skill';
  @override
  String get addSoftSkillHint => 'e.g. Problem Solving, Teamwork...';

  @override
  String get birthPlaceDateLabel => 'Place, Date of Birth';
  @override
  String get birthPlaceDateHint => 'e.g. New York, Jan 12, 2000';
  @override
  String get fullAddressLabel => 'Full Address / Domicile';
  @override
  String get fullAddressHint => 'e.g. 123 Main St, New York';
  @override
  String get lastEducationLabel => 'Highest Education (Complete)';
  @override
  String get lastEducationHint => 'e.g. B.S. in Computer Science - Tech University';
  @override
  String get targetJobPositionLabel => 'Target Job Position';
  @override
  String get targetJobPositionHint => 'e.g. Mobile Developer / Software Engineer';
  @override
  String get maritalStatusLabel => 'Marital Status';
  @override
  String get citizenshipLabel => 'Citizenship';
  @override
  String get attachmentListLabel => 'Enclosed Documents Checklist:';

  // Resume Builder Dialogs
  @override
  String get addEducation => 'Add Education History';
  @override
  String get editEducation => 'Edit Education History';
  @override
  String get institutionName => 'Institution / University Name';
  @override
  String get institutionHint => 'e.g. Stanford University';
  @override
  String get degreeAndMajor => 'Degree & Major';
  @override
  String get degreeHint => 'e.g. B.S. in Computer Science';
  @override
  String get educationPeriod => 'Study Period';
  @override
  String get educationPeriodHint => 'e.g. 2020 - 2024';
  @override
  String get gpaLabel => 'GPA / Score (Optional)';
  @override
  String get gpaHint => 'e.g. 3.85 / 4.00';
  @override
  String get institutionLocation => 'Institution Location';
  @override
  String get institutionLocationHint => 'e.g. California, USA';
  @override
  String get educationActivities => 'Key Achievements / Activities (1 line per point)';
  @override
  String get educationActivitiesHint => 'e.g. 1st Place UI/UX Competition\nPresident of Student Association';
  @override
  String get resumeSavedSuccess => 'Resume & profile saved to cloud successfully!';

  @override
  String get addExperience => 'Add Work Experience';
  @override
  String get editExperience => 'Edit Work Experience';
  @override
  String get positionLabel => 'Position / Job Title';
  @override
  String get positionHint => 'e.g. Mobile Developer / Product Designer';
  @override
  String get workPeriod => 'Work Period';
  @override
  String get workPeriodHint => 'e.g. Sep 2023 - Present';
  @override
  String get responsibilitiesLabel => 'Key Responsibilities & Achievements (1 per line)';
  @override
  String get responsibilitiesHint => 'e.g. Developed 5 core features with Flutter\nBoosted user retention by 20%';

  @override
  String get addCertification => 'Add Certificate & License';
  @override
  String get editCertification => 'Edit Certificate & License';
  @override
  String get certificateName => 'Certificate / License Name';
  @override
  String get certificateHint => 'e.g. Google Cloud Associate Engineer';
  @override
  String get issuerOrg => 'Issuer / Organization';
  @override
  String get issuerHint => 'e.g. Google / Coursera / AWS';
  @override
  String get obtainedYear => 'Year Obtained';
  @override
  String get yearHint => 'e.g. 2024';

  // Smart Job Parser
  @override
  String get smartParserTitle => 'Smart Parser';
  @override
  String get smartParserSubtitle => 'Paste job description to auto-fill form.';
  @override
  String get smartParserPasteHint => 'Paste job vacancy description here...';
  @override
  String get smartParserButton => 'Extract & Fill';
  @override
  String get smartParserPasteClipboard => 'Paste Clipboard';
  @override
  String get smartParserClear => 'Clear';
  @override
  String get smartParserSuccess => 'Job details extracted successfully!';
  @override
  String get smartParserNoText => 'Job description text is empty.';
  @override
  String get smartParserDetectedBadge => 'Detected';
  @override
  String get smartParserApplyToForm => 'Apply to Form';
  @override
  String get smartParserAutoFillBanner => 'Auto-Fill from Job Text';

  // Career & Currently Working Hub
  @override
  String get menuCareerTitle => 'Career & Experience';
  @override
  String get menuCareerSubtitle => 'Active Role, History & ATS CV';
  @override
  String get careerScreenTitle => 'Career Journey';
  @override
  String get currentlyWorkingHeader => 'Currently Working';
  @override
  String get currentlyWorkingSubtitle => 'Your active position & workplace';
  @override
  String get noCurrentlyWorking => 'No active job set';
  @override
  String get noCurrentlyWorkingDesc => 'Set your current position or link an accepted application.';
  @override
  String get setCurrentlyWorkingBtn => 'Set Active Role';
  @override
  String get workHistoryHeader => 'Work History';
  @override
  String get workHistorySubtitle => 'Past roles & career milestones';
  @override
  String get noWorkHistory => 'No past work history';
  @override
  String get noWorkHistoryDesc => 'Document past roles to build a complete ATS CV.';
  @override
  String get addExperienceBtn => 'Add Experience';
  @override
  String get isCurrentlyWorkingCheckbox => 'I currently work in this role';
  @override
  String get startDateLabel => 'Start Date';
  @override
  String get endDateLabel => 'End Date';
  @override
  String get presentLabel => 'Present';
  @override
  String get endJobConfirmTitle => 'End This Position?';
  @override
  String get endJobConfirmMessage => 'Set the end date to move this role to past work history.';
  @override
  String get deleteExperienceConfirmTitle => 'Delete Experience?';
  @override
  String get deleteExperienceConfirmMessage => 'This experience entry will be permanently removed.';
  @override
  String get acceptedPromptTitle => 'Congratulations on the Job!';
  @override
  String get acceptedPromptMessage => 'Would you like to set this role as your Currently Working position in Career?';
  @override
  String get acceptedPromptConfirm => 'Set as Active Role';
  @override
  String get acceptedPromptLater => 'Maybe Later';
  @override
  String get activeRoleBadge => 'Active Role';
  @override
  String get careerMonthlySalary => 'Monthly Salary';
  @override
  String get careerAtsCardTitle => 'ATS Resume & CV Generator';
  @override
  String get careerAtsCardDesc => 'Generate professional ATS-friendly CV from your career data.';

  // Enums & Dynamic Values
  @override
  String localizedEmploymentType(EmploymentType type) {
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

  @override
  String localizedWorkSystem(WorkSystem system) {
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

  @override
  String localizedJobPortal(JobPortal portal) {
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

  @override
  String localizedStatus(ApplicationStatus status) {
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

  @override
  String localizedResult(String result) {
    switch (result.trim().toLowerCase()) {
      case 'lolos':
      case 'selesai':
      case 'passed':
      case 'done':
        return 'Passed';
      case 'diterima':
      case 'offering':
      case 'accepted':
        return 'Accepted';
      case 'gagal':
      case 'ditolak':
      case 'failed':
      case 'rejected':
      case 'tidak lolos':
        return 'Rejected';
      case 'waiting':
      case 'menunggu':
      default:
        return 'Waiting';
    }
  }
}
