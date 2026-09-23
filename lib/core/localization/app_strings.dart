import '../../utils/language_manager.dart';
import '../constants/app_enums.dart';
import 'languages/base_language.dart';
import 'languages/en_language.dart';
import 'languages/id_language.dart';
import 'languages/ja_language.dart';
import 'languages/ko_language.dart';

/// Central localization facade for AppliQ.
/// Dynamically resolves strings to the active [BaseLanguage] instance
/// without any string-map lookup overhead.
class AppStrings {
  static final BaseLanguage _id = IdLanguage();
  static final BaseLanguage _en = EnLanguage();
  static final BaseLanguage _ja = JaLanguage();
  static final BaseLanguage _ko = KoLanguage();

  /// Returns the active language instance.
  static BaseLanguage get current {
    switch (LanguageManager.current) {
      case AppLanguage.id:
        return _id;
      case AppLanguage.en:
        return _en;
      case AppLanguage.ja:
        return _ja;
      case AppLanguage.ko:
        return _ko;
    }
  }

  static bool get isEn => LanguageManager.isEnglish;

  // Navigation
  static String get navHome => current.navHome;
  static String get navApplications => current.navApplications;
  static String get navSchedule => current.navSchedule;
  static String get navStats => current.navStats;
  static String get navAnalytics => current.navAnalytics;
  static String get navProfile => current.navProfile;

  // Common Actions & Labels
  static String get cancel => current.cancel;
  static String get save => current.save;
  static String get delete => current.delete;
  static String get edit => current.edit;
  static String get close => current.close;
  static String get search => current.search;
  static String get filter => current.filter;
  static String get sort => current.sort;
  static String get reset => current.reset;
  static String get apply => current.apply;
  static String get confirm => current.confirm;
  static String get done => current.done;
  static String get back => current.back;
  static String get retry => current.retry;
  static String get loading => current.loading;
  static String get empty => current.empty;
  static String get comingSoon => current.comingSoon;
  static String get viewAll => current.viewAll;
  static String get openInDrive => current.openInDrive;
  static String get scheduleDateLabel => current.scheduleDateLabel;

  // Home Screen
  static String get greetingMorning => current.greetingMorning;
  static String get greetingAfternoon => current.greetingAfternoon;
  static String get greetingEvening => current.greetingEvening;
  static String get greetingNight => current.greetingNight;
  static String get homeSubtitle => current.homeSubtitle;
  static String get homeSearchHint => current.homeSearchHint;
  static String get statTotal => current.statTotal;
  static String get statActive => current.statActive;
  static String get statInterview => current.statInterview;
  static String get statOffering => current.statOffering;
  static String get recentApplications => current.recentApplications;
  static String get quickAddApplication => current.quickAddApplication;
  static String get quickSchedule => current.quickSchedule;
  static String get quickTemplate => current.quickTemplate;
  static String get quickExport => current.quickExport;
  static String get quickAddTooltip => current.quickAddTooltip;
  static String get upcomingReminders => current.upcomingReminders;
  static String get noReminders => current.noReminders;
  static String get emptyRecentApps => current.emptyRecentApps;
  static String get emptyRecentAppsDesc => current.emptyRecentAppsDesc;
  static String get addFirstApp => current.addFirstApp;
  static String get applicationSummary => current.applicationSummary;
  static String get statsButton => current.statsButton;
  static String get appliedLabel => current.appliedLabel;
  static String get nextSchedule => current.nextSchedule;
  static String get openMeetingLink => current.openMeetingLink;
  static String get viewDetails => current.viewDetails;
  static String get followUpNeeded => current.followUpNeeded;
  static String get sendFollowUpEmail => current.sendFollowUpEmail;
  static String get appliedCompanies => current.appliedCompanies;
  static String get noAppliedCompanies => current.noAppliedCompanies;
  static String get salaryUndisclosed => current.salaryUndisclosed;
  static String get perMonth => current.perMonth;
  static String positionsCount(int count) => current.positionsCount(count);
  static String applicationsCount(int count) => current.applicationsCount(count);
  static String staleAppSingle(String company) => current.staleAppSingle(company);
  static String staleAppMulti(int count, String company) => current.staleAppMulti(count, company);

  // Applications List Screen
  static String get applicationsTitle => current.applicationsTitle;
  static String get allStatusTab => current.allStatusTab;
  static String get searchApplicationPlaceholder => current.searchApplicationPlaceholder;
  static String get filterStatus => current.filterStatus;
  static String get filterPortal => current.filterPortal;
  static String get filterWorkSystem => current.filterWorkSystem;
  static String get filterEmploymentType => current.filterEmploymentType;
  static String get sortNewest => current.sortNewest;
  static String get sortOldest => current.sortOldest;
  static String get sortCompanyAZ => current.sortCompanyAZ;
  static String get sortSalaryHighest => current.sortSalaryHighest;
  static String get sortStarredFirst => current.sortStarredFirst;
  static String get noApplicationsFound => current.noApplicationsFound;
  static String get clearFilters => current.clearFilters;
  static String get deleteApplicationConfirmTitle => current.deleteApplicationConfirmTitle;
  static String get deleteApplicationConfirmMessage => current.deleteApplicationConfirmMessage;
  static String get listView => current.listView;
  static String get kanbanBoard => current.kanbanBoard;
  static String get starred => current.starred;
  static String get emptyKanban => current.emptyKanban;
  static String get noApplicationsYet => current.noApplicationsYet;
  static String get noApplicationsYetMsg => current.noApplicationsYetMsg;
  static String get newApplicationBtn => current.newApplicationBtn;

  // Application Detail Screen
  static String get applicationDetailTitle => current.applicationDetailTitle;
  static String get overviewTab => current.overviewTab;
  static String get timelineTab => current.timelineTab;
  static String get companyInfo => current.companyInfo;
  static String get salaryDetails => current.salaryDetails;
  static String get salaryExpectation => current.salaryExpectation;
  static String get salaryOffered => current.salaryOffered;
  static String get appliedOn => current.appliedOn;
  static String get notesTitle => current.notesTitle;
  static String get noNotes => current.noNotes;
  static String get jobUrlLabel => current.jobUrlLabel;
  static String get openJobUrl => current.openJobUrl;
  static String get updateStatus => current.updateStatus;
  static String get selectNewStatus => current.selectNewStatus;
  static String get addTimelineStage => current.addTimelineStage;
  static String get editTimelineStage => current.editTimelineStage;
  static String get deleteTimelineStage => current.deleteTimelineStage;
  static String get stageNameLabel => current.stageNameLabel;
  static String get stageDateLabel => current.stageDateLabel;
  static String get stageNotesLabel => current.stageNotesLabel;
  static String get cvAttachmentTitle => current.cvAttachmentTitle;
  static String get savedInDrive => current.savedInDrive;
  static String get uploadCvToDrive => current.uploadCvToDrive;
  static String get manageAttachment => current.manageAttachment;
  static String get deleteFromDrive => current.deleteFromDrive;
  static String get detachOnly => current.detachOnly;
  static String get updateStageStatusTitle => current.updateStageStatusTitle;
  static String get stageOptionPassed => current.stageOptionPassed;
  static String get stageOptionNext => current.stageOptionNext;
  static String get stageOptionOffering => current.stageOptionOffering;
  static String get stageOptionWaiting => current.stageOptionWaiting;
  static String get stageOptionFailed => current.stageOptionFailed;
  static String get deleteStageConfirmTitle => current.deleteStageConfirmTitle;
  static String get deleteStageConfirmMessage => current.deleteStageConfirmMessage;
  static String get noStagesRecorded => current.noStagesRecorded;
  static String get addStagePrompt => current.addStagePrompt;
  static String get interviewerLabel => current.interviewerLabel;
  static String get interviewerHint => current.interviewerHint;
  static String get meetingLinkLabel => current.meetingLinkLabel;
  static String get meetingLinkHint => current.meetingLinkHint;
  static String get openMeetingButton => current.openMeetingButton;
  static String get quickStagesTitle => current.quickStagesTitle;
  static String get stageStatusResult => current.stageStatusResult;
  static String get stageNotesPlaceholder => current.stageNotesPlaceholder;
  static String get editApplicationTooltip => current.editApplicationTooltip;
  static String get deleteTooltip => current.deleteTooltip;
  static String get jobSourceLabel => current.jobSourceLabel;
  static String get openUrl => current.openUrl;
  static String get attachedDriveFiles => current.attachedDriveFiles;
  static String get noCvAttached => current.noCvAttached;
  static String get recruitmentStages => current.recruitmentStages;
  static String get addStageBtn => current.addStageBtn;
  static String get noStagesMsg => current.noStagesMsg;
  static String get editStage => current.editStage;
  static String get deleteStage => current.deleteStage;
  static String get deleteStageConfirm => current.deleteStageConfirm;
  static String deleteStageMsg(String stageName) => current.deleteStageMsg(stageName);
  static String get stageDeletedSuccess => current.stageDeletedSuccess;
  static String get stageResultUpdated => current.stageResultUpdated;

  // Application Form Screen
  static String get createApplicationTitle => current.createApplicationTitle;
  static String get editApplicationTitle => current.editApplicationTitle;
  static String get vacancyInfoSection => current.vacancyInfoSection;
  static String get companyNameLabel => current.companyNameLabel;
  static String get companyNameHint => current.companyNameHint;
  static String get companyNameRequired => current.companyNameRequired;
  static String get positionTitleLabel => current.positionTitleLabel;
  static String get positionTitleHint => current.positionTitleHint;
  static String get positionTitleRequired => current.positionTitleRequired;
  static String get locationLabel => current.locationLabel;
  static String get locationHint => current.locationHint;
  static String get workTypeAndSystemSection => current.workTypeAndSystemSection;
  static String get employmentTypeLabel => current.employmentTypeLabel;
  static String get workSystemLabel => current.workSystemLabel;
  static String get jobPortalSection => current.jobPortalSection;
  static String get otherPortalHint => current.otherPortalHint;
  static String get jobUrlSection => current.jobUrlSection;
  static String get jobUrlHint => current.jobUrlHint;
  static String get currentStatusSection => current.currentStatusSection;
  static String get appliedDateLabel => current.appliedDateLabel;
  static String get salarySection => current.salarySection;
  static String get salaryExpectationHint => current.salaryExpectationHint;
  static String get salaryOfferedHint => current.salaryOfferedHint;
  static String get notesSection => current.notesSection;
  static String get notesHint => current.notesHint;
  static String get saveApplicationButton => current.saveApplicationButton;
  static String get updateApplicationButton => current.updateApplicationButton;

  // Dashboard / Analytics Screen
  static String get analyticsTitle => current.analyticsTitle;
  static String get pipelineFunnel => current.pipelineFunnel;
  static String get systemsAndPortals => current.systemsAndPortals;
  static String get successRateTitle => current.successRateTitle;
  static String get interviewCallsRate => current.interviewCallsRate;
  static String get hiredRate => current.hiredRate;
  static String get topPortals => current.topPortals;
  static String get monthlyApplications => current.monthlyApplications;
  static String get responseRate => current.responseRate;
  static String get offerRate => current.offerRate;
  static String get totalApplicationsMetric => current.totalApplicationsMetric;
  static String get interviewStageMetric => current.interviewStageMetric;
  static String get offeringMetric => current.offeringMetric;
  static String get hiredMetric => current.hiredMetric;
  static String get statusDistribution => current.statusDistribution;
  static String get workSystemDistribution => current.workSystemDistribution;
  static String get noWorkSystemData => current.noWorkSystemData;
  static String get portalSources => current.portalSources;
  static String get noPortalData => current.noPortalData;
  static String get noAnalyticsDataTitle => current.noAnalyticsDataTitle;
  static String get noAnalyticsDataMessage => current.noAnalyticsDataMessage;

  // Schedule Screen
  static String get scheduleTitle => current.scheduleTitle;
  static String get searchScheduleHint => current.searchScheduleHint;
  static String get upcomingTab => current.upcomingTab;
  static String get allAgendaTab => current.allAgendaTab;
  static String get noScheduleTitle => current.noScheduleTitle;
  static String get noScheduleMessage => current.noScheduleMessage;
  static String get refreshSchedule => current.refreshSchedule;
  static String get noScheduleFoundTitle => current.noScheduleFoundTitle;
  static String noScheduleFoundMessage(String query) => current.noScheduleFoundMessage(query);
  static String get resetSearch => current.resetSearch;
  static String get noUpcomingScheduleTitle => current.noUpcomingScheduleTitle;
  static String get noUpcomingScheduleMessage => current.noUpcomingScheduleMessage;
  static String get noPastScheduleMessage => current.noPastScheduleMessage;
  static String get sectionOverdue => current.sectionOverdue;
  static String get sectionOverdueSubtitle => current.sectionOverdueSubtitle;
  static String get sectionToday => current.sectionToday;
  static String get sectionTodaySubtitle => current.sectionTodaySubtitle;
  static String get sectionThisWeek => current.sectionThisWeek;
  static String get sectionThisWeekSubtitle => current.sectionThisWeekSubtitle;
  static String get sectionUpcoming => current.sectionUpcoming;
  static String get sectionUpcomingSubtitle => current.sectionUpcomingSubtitle;
  static String get sectionHistory => current.sectionHistory;
  static String get sectionHistorySubtitle => current.sectionHistorySubtitle;
  static String get interviewerPrefix => current.interviewerPrefix;
  static String get openMeetingRoom => current.openMeetingRoom;

  // Profile & Settings Screen
  static String get profileTitle => current.profileTitle;
  static String get accountSection => current.accountSection;
  static String get preferencesSection => current.preferencesSection;
  static String get dataSection => current.dataSection;
  static String get aboutSection => current.aboutSection;
  static String get themeSetting => current.themeSetting;
  static String get accentSetting => current.accentSetting;
  static String get languageSetting => current.languageSetting;
  static String get notificationsSetting => current.notificationsSetting;
  static String get exportDataSetting => current.exportDataSetting;
  static String get googleDriveSetting => current.googleDriveSetting;
  static String get connected => current.connected;
  static String get disconnected => current.disconnected;
  static String get disconnectDriveConfirm => current.disconnectDriveConfirm;
  static String get disconnectDriveMessage => current.disconnectDriveMessage;
  static String get logoutButton => current.logoutButton;
  static String get logoutConfirmTitle => current.logoutConfirmTitle;
  static String get logoutConfirmMessage => current.logoutConfirmMessage;
  static String get appVersion => current.appVersion;

  // Edit Profile Screen
  static String get editProfileTitle => current.editProfileTitle;
  static String get googleEmailLabel => current.googleEmailLabel;
  static String get googleEmailDesc => current.googleEmailDesc;
  static String get fullNameLabel => current.fullNameLabel;
  static String get fullNameHint => current.fullNameHint;
  static String get fullNameEmptyError => current.fullNameEmptyError;
  static String get usernameLabel => current.usernameLabel;
  static String get phoneLabel => current.phoneLabel;
  static String get targetRoleLabel => current.targetRoleLabel;
  static String get targetRoleHint => current.targetRoleHint;
  static String get saveChangesButton => current.saveChangesButton;
  static String get deleteAccountButton => current.deleteAccountButton;
  static String get deleteAccountConfirmTitle => current.deleteAccountConfirmTitle;
  static String get deleteAccountConfirmMessage => current.deleteAccountConfirmMessage;
  static String get profileUpdatedSuccess => current.profileUpdatedSuccess;
  static String get accountDeletedSuccess => current.accountDeletedSuccess;

  // Notification Sheet
  static String get notificationCenterTitle => current.notificationCenterTitle;
  static String get noUrgentReminders => current.noUrgentReminders;
  static String activeRemindersCount(int count) => current.activeRemindersCount(count);
  static String get pushNotificationTestTitle => current.pushNotificationTestTitle;
  static String get pushNotificationTestDesc => current.pushNotificationTestDesc;
  static String get testNotificationButton => current.testNotificationButton;
  static String get testNotificationSentToast => current.testNotificationSentToast;
  static String get interviewAgendaSection => current.interviewAgendaSection;
  static String get followUpNeededSection => current.followUpNeededSection;
  static String appliedDaysAgo(int days) => current.appliedDaysAgo(days);
  static String get emailHrButton => current.emailHrButton;
  static String get allSchedulesSafeTitle => current.allSchedulesSafeTitle;
  static String get allSchedulesSafeDesc => current.allSchedulesSafeDesc;

  // HR Templates Sheet
  static String get hrTemplatesSheetTitle => current.hrTemplatesSheetTitle;
  static String get hrTemplatesSheetSubtitle => current.hrTemplatesSheetSubtitle;
  static String get categoryAll => current.categoryAll;
  static String get categoryFollowUp => current.categoryFollowUp;
  static String get categoryInterview => current.categoryInterview;
  static String get categoryOffering => current.categoryOffering;
  static String get copySubjectButton => current.copySubjectButton;
  static String get copyBodyButton => current.copyBodyButton;
  static String copiedToast(String label) => current.copiedToast(label);

  // Language Modal
  static String get languageModalTitle => current.languageModalTitle;
  static String get languageModalSubtitle => current.languageModalSubtitle;
  static String get languageIdName => current.languageIdName;
  static String get languageIdSubtitle => current.languageIdSubtitle;
  static String get languageEnName => current.languageEnName;
  static String get languageEnSubtitle => current.languageEnSubtitle;
  static String get languageJaName => current.languageJaName;
  static String get languageJaSubtitle => current.languageJaSubtitle;
  static String get languageKoName => current.languageKoName;
  static String get languageKoSubtitle => current.languageKoSubtitle;
  static String get languageComingSoonToast => current.languageComingSoonToast;

  // Export Sheet
  static String get exportSheetTitle => current.exportSheetTitle;
  static String get exportSheetSubtitle => current.exportSheetSubtitle;
  static String get exportFormat => current.exportFormat;
  static String get exportDateRange => current.exportDateRange;
  static String get exportAllTime => current.exportAllTime;
  static String get exportThisMonth => current.exportThisMonth;
  static String get exportLast3Months => current.exportLast3Months;
  static String get exportThisYear => current.exportThisYear;
  static String get exportButton => current.exportButton;
  static String get exportSuccess => current.exportSuccess;
  static String get exportEmpty => current.exportEmpty;

  // Toasts & Snackbars
  static String get errorOccurred => current.errorOccurred;
  static String get successSaved => current.successSaved;
  static String get successUpdated => current.successUpdated;
  static String get successDeleted => current.successDeleted;
  static String get fileUploadedDrive => current.fileUploadedDrive;
  static String get fileDeletedDrive => current.fileDeletedDrive;
  static String get attachmentDetached => current.attachmentDetached;
  static String get fillRequiredFields => current.fillRequiredFields;

  // Login Screen
  static String get loginTagline => current.loginTagline;
  static String get signInWithGoogle => current.signInWithGoogle;
  static String get termsPrefix => current.termsPrefix;
  static String get termsOfService => current.termsOfService;
  static String get andConjunction => current.andConjunction;
  static String get privacyPolicy => current.privacyPolicy;
  static String get termsContent => current.termsContent;
  static String get privacyContent => current.privacyContent;
  static String welcomeUser(String name) => current.welcomeUser(name);

  // Status Feedback Text
  static String get feedbackSubmittedToday => current.feedbackSubmittedToday;
  static String feedbackSubmittedDaysAgo(int days) => current.feedbackSubmittedDaysAgo(days);
  static String get feedbackNoResponse30Days => current.feedbackNoResponse30Days;
  static String get feedbackStayMotivated => current.feedbackStayMotivated;
  static String feedbackCurrentStage(String stageName) => current.feedbackCurrentStage(stageName);

  // Legal (Terms of Service & Privacy Policy Modals)
  static String get termsModalTitle => current.termsModalTitle;
  static String get termsModalSubtitle => current.termsModalSubtitle;
  static List<Map<String, String>> get termsCards => current.termsCards;
  static String get privacyModalTitle => current.privacyModalTitle;
  static String get privacyModalSubtitle => current.privacyModalSubtitle;
  static List<Map<String, String>> get privacyCards => current.privacyCards;
  static List<Map<String, String>> get faqList => current.faqList;

  // Settings & Bottom Sheets
  static String get generalSettingsTitle => current.generalSettingsTitle;
  static String get generalSettingsSubtitle => current.generalSettingsSubtitle;
  static String get appearanceSection => current.appearanceSection;
  static String get darkModeTitle => current.darkModeTitle;
  static String get darkModeDesc => current.darkModeDesc;
  static String get monochromeTitle => current.monochromeTitle;
  static String get monochromeDesc => current.monochromeDesc;
  static String get preferencesFormatSection => current.preferencesFormatSection;
  static String get appLanguageTitle => current.appLanguageTitle;
  static String get appLanguageDesc => current.appLanguageDesc;
  static String get defaultCurrencyTitle => current.defaultCurrencyTitle;
  static String get defaultCurrencyDesc => current.defaultCurrencyDesc;
  static String get dateFormatTitle => current.dateFormatTitle;
  static String get dateFormatDesc => current.dateFormatDesc;
  static String get feedbackHapticSection => current.feedbackHapticSection;
  static String get hapticTitle => current.hapticTitle;
  static String get hapticDesc => current.hapticDesc;
  static String get defaultSortTitle => current.defaultSortTitle;
  static String get defaultSortDesc => current.defaultSortDesc;
  static String get sortPickerTitle => current.sortPickerTitle;
  static String get sortPickerSubtitle => current.sortPickerSubtitle;
  static String get sortOptionNewest => current.sortOptionNewest;
  static String get sortOptionNewestDesc => current.sortOptionNewestDesc;
  static String get sortOptionClosest => current.sortOptionClosest;
  static String get sortOptionClosestDesc => current.sortOptionClosestDesc;
  static String get sortOptionCompanyAZ => current.sortOptionCompanyAZ;
  static String get sortOptionCompanyAZDesc => current.sortOptionCompanyAZDesc;
  static String get sortOptionSalary => current.sortOptionSalary;
  static String get sortOptionSalaryDesc => current.sortOptionSalaryDesc;
  static String get securitySettingsTitle => current.securitySettingsTitle;
  static String get securitySettingsSubtitle => current.securitySettingsSubtitle;
  static String get cloudSyncTitle => current.cloudSyncTitle;
  static String get cloudSyncSubtitle => current.cloudSyncSubtitle;

  // Helper methods for enums
  static String localizedEmploymentType(EmploymentType type) => current.localizedEmploymentType(type);
  static String localizedWorkSystem(WorkSystem system) => current.localizedWorkSystem(system);
  static String localizedJobPortal(JobPortal portal) => current.localizedJobPortal(portal);
  static String localizedStatus(ApplicationStatus status) => current.localizedStatus(status);
  static String localizedResult(String result) => current.localizedResult(result);
}
