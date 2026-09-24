import '../../constants/app_enums.dart';

/// Abstract contract defining all localized string keys across AppliQ.
/// Every supported language must implement this interface to guarantee completeness.
abstract class BaseLanguage {
  // Navigation
  String get navHome;
  String get navApplications;
  String get navSchedule;
  String get navStats;
  String get navAnalytics;
  String get navProfile;

  // Common Actions & Labels
  String get cancel;
  String get save;
  String get delete;
  String get edit;
  String get close;
  String get search;
  String get filter;
  String get sort;
  String get reset;
  String get apply;
  String get confirm;
  String get done;
  String get back;
  String get retry;
  String get loading;
  String get empty;
  String get comingSoon;
  String get viewAll;
  String get openInDrive;
  String get scheduleDateLabel;

  // Home Screen
  String get greetingMorning;
  String get greetingAfternoon;
  String get greetingEvening;
  String get greetingNight;
  String get homeSubtitle;
  String get homeSearchHint;
  String get statTotal;
  String get statActive;
  String get statInterview;
  String get statOffering;
  String get recentApplications;
  String get quickAddApplication;
  String get quickSchedule;
  String get quickTemplate;
  String get quickExport;
  String get quickAddTooltip;
  String get upcomingReminders;
  String get noReminders;
  String get emptyRecentApps;
  String get emptyRecentAppsDesc;
  String get addFirstApp;
  String get applicationSummary;
  String get statsButton;
  String get appliedLabel;
  String get nextSchedule;
  String get openMeetingLink;
  String get viewDetails;
  String get followUpNeeded;
  String get sendFollowUpEmail;
  String get appliedCompanies;
  String get noAppliedCompanies;
  String get salaryUndisclosed;
  String get perMonth;
  String positionsCount(int count);
  String applicationsCount(int count);
  String staleAppSingle(String company);
  String staleAppMulti(int count, String company);

  // Applications List Screen
  String get applicationsTitle;
  String get allStatusTab;
  String get searchApplicationPlaceholder;
  String get filterStatus;
  String get filterPortal;
  String get filterWorkSystem;
  String get filterEmploymentType;
  String get sortNewest;
  String get sortOldest;
  String get sortCompanyAZ;
  String get sortSalaryHighest;
  String get sortStarredFirst;
  String get noApplicationsFound;
  String get clearFilters;
  String get deleteApplicationConfirmTitle;
  String get deleteApplicationConfirmMessage;
  String get listView;
  String get kanbanBoard;
  String get starred;
  String get emptyKanban;
  String get noApplicationsYet;
  String get noApplicationsYetMsg;
  String get newApplicationBtn;

  // Application Detail Screen
  String get applicationDetailTitle;
  String get overviewTab;
  String get timelineTab;
  String get companyInfo;
  String get salaryDetails;
  String get salaryExpectation;
  String get salaryOffered;
  String get appliedOn;
  String get notesTitle;
  String get noNotes;
  String get jobUrlLabel;
  String get openJobUrl;
  String get updateStatus;
  String get selectNewStatus;
  String get addTimelineStage;
  String get editTimelineStage;
  String get deleteTimelineStage;
  String get stageNameLabel;
  String get stageDateLabel;
  String get stageNotesLabel;
  String get cvAttachmentTitle;
  String get savedInDrive;
  String get uploadCvToDrive;
  String get manageAttachment;
  String get deleteFromDrive;
  String get detachOnly;
  String get updateStageStatusTitle;
  String get stageOptionPassed;
  String get stageOptionNext;
  String get stageOptionOffering;
  String get stageOptionWaiting;
  String get stageOptionFailed;
  String get deleteStageConfirmTitle;
  String get deleteStageConfirmMessage;
  String get noStagesRecorded;
  String get addStagePrompt;
  String get interviewerLabel;
  String get interviewerHint;
  String get meetingLinkLabel;
  String get meetingLinkHint;
  String get openMeetingButton;
  String get quickStagesTitle;
  String get stageStatusResult;
  String get stageNotesPlaceholder;
  String get editApplicationTooltip;
  String get deleteTooltip;
  String get jobSourceLabel;
  String get openUrl;
  String get attachedDriveFiles;
  String get noCvAttached;
  String get recruitmentStages;
  String get addStageBtn;
  String get noStagesMsg;
  String get editStage;
  String get deleteStage;
  String get deleteStageConfirm;
  String deleteStageMsg(String stageName);
  String get stageDeletedSuccess;
  String get stageResultUpdated;

  // Application Form Screen
  String get createApplicationTitle;
  String get editApplicationTitle;
  String get vacancyInfoSection;
  String get companyNameLabel;
  String get companyNameHint;
  String get companyNameRequired;
  String get positionTitleLabel;
  String get positionTitleHint;
  String get positionTitleRequired;
  String get locationLabel;
  String get locationHint;
  String get workTypeAndSystemSection;
  String get employmentTypeLabel;
  String get workSystemLabel;
  String get jobPortalSection;
  String get otherPortalHint;
  String get jobUrlSection;
  String get jobUrlHint;
  String get currentStatusSection;
  String get appliedDateLabel;
  String get salarySection;
  String get salaryExpectationHint;
  String get salaryOfferedHint;
  String get notesSection;
  String get notesHint;
  String get saveApplicationButton;
  String get updateApplicationButton;

  // Dashboard / Analytics Screen
  String get analyticsTitle;
  String get pipelineFunnel;
  String get systemsAndPortals;
  String get successRateTitle;
  String get interviewCallsRate;
  String get hiredRate;
  String get topPortals;
  String get monthlyApplications;
  String get responseRate;
  String get offerRate;
  String get totalApplicationsMetric;
  String get interviewStageMetric;
  String get offeringMetric;
  String get hiredMetric;
  String get statusDistribution;
  String get workSystemDistribution;
  String get noWorkSystemData;
  String get portalSources;
  String get noPortalData;
  String get noAnalyticsDataTitle;
  String get noAnalyticsDataMessage;

  // Schedule Screen
  String get scheduleTitle;
  String get searchScheduleHint;
  String get upcomingTab;
  String get allAgendaTab;
  String get noScheduleTitle;
  String get noScheduleMessage;
  String get refreshSchedule;
  String get noScheduleFoundTitle;
  String noScheduleFoundMessage(String query);
  String get resetSearch;
  String get noUpcomingScheduleTitle;
  String get noUpcomingScheduleMessage;
  String get noPastScheduleMessage;
  String get sectionOverdue;
  String get sectionOverdueSubtitle;
  String get sectionToday;
  String get sectionTodaySubtitle;
  String get sectionThisWeek;
  String get sectionThisWeekSubtitle;
  String get sectionUpcoming;
  String get sectionUpcomingSubtitle;
  String get sectionHistory;
  String get sectionHistorySubtitle;
  String get interviewerPrefix;
  String get openMeetingRoom;
  String get syncToCalendar;
  String get calendarSyncSuccess;
  String statusUpdatedTo(String status);
  String get dragToMove;

  // Profile & Settings Screen
  String get profileTitle;
  String get accountSection;
  String get preferencesSection;
  String get dataSection;
  String get aboutSection;
  String get themeSetting;
  String get accentSetting;
  String get languageSetting;
  String get notificationsSetting;
  String get exportDataSetting;
  String get googleDriveSetting;
  String get connected;
  String get disconnected;
  String get disconnectDriveConfirm;
  String get disconnectDriveMessage;
  String get logoutButton;
  String get logoutConfirmTitle;
  String get logoutConfirmMessage;
  String get appVersion;

  // Edit Profile Screen
  String get editProfileTitle;
  String get googleEmailLabel;
  String get googleEmailDesc;
  String get fullNameLabel;
  String get fullNameHint;
  String get fullNameEmptyError;
  String get usernameLabel;
  String get phoneLabel;
  String get targetRoleLabel;
  String get targetRoleHint;
  String get saveChangesButton;
  String get deleteAccountButton;
  String get deleteAccountConfirmTitle;
  String get deleteAccountConfirmMessage;
  String get profileUpdatedSuccess;
  String get accountDeletedSuccess;

  // Notification Sheet
  String get notificationCenterTitle;
  String get noUrgentReminders;
  String activeRemindersCount(int count);
  String get pushNotificationTestTitle;
  String get pushNotificationTestDesc;
  String get testNotificationButton;
  String get testNotificationSentToast;
  String get interviewAgendaSection;
  String get followUpNeededSection;
  String appliedDaysAgo(int days);
  String get emailHrButton;
  String get allSchedulesSafeTitle;
  String get allSchedulesSafeDesc;

  // HR Templates Sheet
  String get hrTemplatesSheetTitle;
  String get hrTemplatesSheetSubtitle;
  String get categoryAll;
  String get categoryFollowUp;
  String get categoryInterview;
  String get categoryOffering;
  String get copySubjectButton;
  String get copyBodyButton;
  String copiedToast(String label);

  // Language Modal
  String get languageModalTitle;
  String get languageModalSubtitle;
  String get languageIdName;
  String get languageIdSubtitle;
  String get languageEnName;
  String get languageEnSubtitle;
  String get languageJaName;
  String get languageJaSubtitle;
  String get languageKoName;
  String get languageKoSubtitle;
  String get languageComingSoonToast;

  // Export Sheet
  String get exportSheetTitle;
  String get exportSheetSubtitle;
  String get exportFormat;
  String get exportDateRange;
  String get exportAllTime;
  String get exportThisMonth;
  String get exportLast3Months;
  String get exportThisYear;
  String get exportButton;
  String get exportSuccess;
  String get exportEmpty;

  // Toasts & Snackbars
  String get errorOccurred;
  String get successSaved;
  String get successUpdated;
  String get successDeleted;
  String get fileUploadedDrive;
  String get fileDeletedDrive;
  String get attachmentDetached;
  String get fillRequiredFields;

  // Login Screen
  String get loginTagline;
  String get signInWithGoogle;
  String get termsPrefix;
  String get termsOfService;
  String get andConjunction;
  String get privacyPolicy;
  String get termsContent;
  String get privacyContent;
  String welcomeUser(String name);

  // Status Feedback Text
  String get feedbackSubmittedToday;
  String feedbackSubmittedDaysAgo(int days);
  String get feedbackNoResponse30Days;
  String get feedbackStayMotivated;
  String feedbackCurrentStage(String stageName);

  // Legal (Terms of Service & Privacy Policy Modals)
  String get termsModalTitle;
  String get termsModalSubtitle;
  List<Map<String, String>> get termsCards;
  String get privacyModalTitle;
  String get privacyModalSubtitle;
  List<Map<String, String>> get privacyCards;
  List<Map<String, String>> get faqList;

  // Settings & Bottom Sheets
  String get generalSettingsTitle;
  String get generalSettingsSubtitle;
  String get appearanceSection;
  String get darkModeTitle;
  String get darkModeDesc;
  String get monochromeTitle;
  String get monochromeDesc;
  String get preferencesFormatSection;
  String get appLanguageTitle;
  String get appLanguageDesc;
  String get defaultCurrencyTitle;
  String get defaultCurrencyDesc;
  String get dateFormatTitle;
  String get dateFormatDesc;
  String get feedbackHapticSection;
  String get hapticTitle;
  String get hapticDesc;
  String get defaultSortTitle;
  String get defaultSortDesc;
  String get sortPickerTitle;
  String get sortPickerSubtitle;
  String get sortOptionNewest;
  String get sortOptionNewestDesc;
  String get sortOptionClosest;
  String get sortOptionClosestDesc;
  String get sortOptionCompanyAZ;
  String get sortOptionCompanyAZDesc;
  String get sortOptionSalary;
  String get sortOptionSalaryDesc;
  String get securitySettingsTitle;
  String get securitySettingsSubtitle;
  String get cloudSyncTitle;
  String get cloudSyncSubtitle;

  String get quickResume;

  // Experience, CV & Cover Letter
  String get menuExperienceTitle;
  String get menuExperienceSubtitle;
  String get resumeBuilderTitle;
  String get previewCvAts;
  String get coverLetterTitle;
  String get documentPreviewTitle;
  String get customizeCoverLetter;
  String get digitalSignature;
  String get uploadSignature;
  String get changeSignature;
  String get signatureActive;
  String get applyChanges;
  String get saveResume;

  // Resume Builder Sections
  String get rbSectionContactTitle;
  String get rbSectionContactSubtitle;
  String get rbSectionSummaryTitle;
  String get rbSectionSummarySubtitle;
  String get rbSectionEducationTitle;
  String rbSectionEducationSubtitle(int count);
  String get rbSectionExperienceTitle;
  String rbSectionExperienceSubtitle(int count);
  String get rbSectionCertificationTitle;
  String rbSectionCertificationSubtitle(int count);
  String get rbSectionTechSkillsTitle;
  String rbSectionTechSkillsSubtitle(int count);
  String get rbSectionSoftSkillsTitle;
  String rbSectionSoftSkillsSubtitle(int count);
  String get rbSectionCoverLetterTitle;
  String get rbSectionCoverLetterSubtitle;

  // Resume Builder Form Labels & Hints
  String get cityCountryLabel;
  String get cityCountryHint;
  String get phoneNumberLabel;
  String get phoneNumberHint;
  String get emailLabel;
  String get emailHint;
  String get linkedinLabel;
  String get linkedinHint;
  String get portfolioLabel;
  String get portfolioHint;

  String get summaryLabel;
  String get summaryHint;

  String get addEducationButton;
  String get addExperienceButton;
  String get addCertificationButton;

  String get addTechSkillLabel;
  String get addTechSkillHint;
  String get addSoftSkillLabel;
  String get addSoftSkillHint;

  String get birthPlaceDateLabel;
  String get birthPlaceDateHint;
  String get fullAddressLabel;
  String get fullAddressHint;
  String get lastEducationLabel;
  String get lastEducationHint;
  String get targetJobPositionLabel;
  String get targetJobPositionHint;
  String get maritalStatusLabel;
  String get citizenshipLabel;
  String get attachmentListLabel;

  // Resume Builder Dialogs
  String get addEducation;
  String get editEducation;
  String get institutionName;
  String get institutionHint;
  String get degreeAndMajor;
  String get degreeHint;
  String get educationPeriod;
  String get educationPeriodHint;
  String get gpaLabel;
  String get gpaHint;
  String get institutionLocation;
  String get institutionLocationHint;
  String get educationActivities;
  String get educationActivitiesHint;
  String get resumeSavedSuccess;

  String get addExperience;
  String get editExperience;
  String get positionLabel;
  String get positionHint;
  String get workPeriod;
  String get workPeriodHint;
  String get responsibilitiesLabel;
  String get responsibilitiesHint;

  String get addCertification;
  String get editCertification;
  String get certificateName;
  String get certificateHint;
  String get issuerOrg;
  String get issuerHint;
  String get obtainedYear;
  String get yearHint;

  // Smart Job Parser
  String get smartParserTitle;
  String get smartParserSubtitle;
  String get smartParserPasteHint;
  String get smartParserButton;
  String get smartParserPasteClipboard;
  String get smartParserClear;
  String get smartParserSuccess;
  String get smartParserNoText;
  String get smartParserDetectedBadge;
  String get smartParserApplyToForm;
  String get smartParserAutoFillBanner;

  // Enums & Dynamic Values
  String localizedEmploymentType(EmploymentType type);
  String localizedWorkSystem(WorkSystem system);
  String localizedJobPortal(JobPortal portal);
  String localizedStatus(ApplicationStatus status);
  String localizedResult(String result);
}
