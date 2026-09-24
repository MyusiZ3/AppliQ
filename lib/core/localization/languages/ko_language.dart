import '../../constants/app_enums.dart';
import 'base_language.dart';

/// Complete Korean (한국어) localization for AppliQ.
class KoLanguage implements BaseLanguage {
  // Navigation
  @override
  String get navHome => '홈';
  @override
  String get navApplications => '지원 내역';
  @override
  String get navSchedule => '일정';
  @override
  String get navStats => '통계';
  @override
  String get navAnalytics => '통계 분석';
  @override
  String get navProfile => '프로필';

  // Common Actions & Labels
  @override
  String get cancel => '취소';
  @override
  String get save => '저장';
  @override
  String get delete => '삭제';
  @override
  String get edit => '수정';
  @override
  String get close => '닫기';
  @override
  String get search => '검색...';
  @override
  String get filter => '필터';
  @override
  String get sort => '정렬';
  @override
  String get reset => '초기화';
  @override
  String get apply => '적용';
  @override
  String get confirm => '확인';
  @override
  String get done => '완료';
  @override
  String get back => '뒤로';
  @override
  String get retry => '다시 시도';
  @override
  String get loading => '불러오는 중...';
  @override
  String get empty => '데이터가 없습니다';
  @override
  String get comingSoon => '출시 예정';
  @override
  String get viewAll => '전체보기';
  @override
  String get openInDrive => 'Google 드라이브에서 열기';
  @override
  String get scheduleDateLabel => '일정';

  // Home Screen
  @override
  String get greetingMorning => '좋은 아침입니다';
  @override
  String get greetingAfternoon => '좋은 오후입니다';
  @override
  String get greetingEvening => '좋은 저녁입니다';
  @override
  String get greetingNight => '편안한 밤 되세요';
  @override
  String get homeSubtitle => '구직 활동의 모든 단계를 스마트하게 관리';
  @override
  String get homeSearchHint => '회사명 또는 포지션 검색...';
  @override
  String get statTotal => '총 지원';
  @override
  String get statActive => '진행 중';
  @override
  String get statInterview => '면접 진행';
  @override
  String get statOffering => '최종 합격 / 오퍼';
  @override
  String get recentApplications => '최근 지원 내역';
  @override
  String get quickAddApplication => '지원 추가';
  @override
  String get quickSchedule => '일정';
  @override
  String get quickTemplate => '템플릿';
  @override
  String get quickExport => '내보내기';
  @override
  String get quickAddTooltip => '새 지원 내역 등록';
  @override
  String get upcomingReminders => '다가오는 일정 및 알림';
  @override
  String get noReminders => '예정된 면접이나 일정이 없습니다';
  @override
  String get emptyRecentApps => '등록된 지원 내역이 없습니다';
  @override
  String get emptyRecentAppsDesc => '관심 있는 채용 공고를 등록하고 관리를 시작해보세요.';
  @override
  String get addFirstApp => '첫 지원 내역 등록하기';
  @override
  String get applicationSummary => '지원 요약';
  @override
  String get statsButton => '통계';
  @override
  String get appliedLabel => '지원 완료';
  @override
  String get nextSchedule => '다음 일정';
  @override
  String get openMeetingLink => '회의 링크 접속';
  @override
  String get viewDetails => '상세보기';
  @override
  String get followUpNeeded => '팔로업 권장';
  @override
  String get sendFollowUpEmail => '팔로업 이메일 작성';
  @override
  String get appliedCompanies => '지원한 기업';
  @override
  String get noAppliedCompanies => '아직 등록된 지원 기업이 없습니다.';
  @override
  String get salaryUndisclosed => '급여 비공개';
  @override
  String get perMonth => ' / 월';
  @override
  String positionsCount(int count) => '$count 개 포지션';
  @override
  String applicationsCount(int count) => '$count 건의 지원';
  @override
  String staleAppSingle(String company) => '$company 지원 건의 상태가 7일 이상 업데이트되지 않았습니다.';
  @override
  String staleAppMulti(int count, String company) => '$company 포함 $count 건의 지원이 7일 이상 응답 대기 중입니다.';

  // Applications List Screen
  @override
  String get applicationsTitle => '지원 내역';
  @override
  String get allStatusTab => '전체';
  @override
  String get searchApplicationPlaceholder => '직무, 회사명, 근무지 검색...';
  @override
  String get filterStatus => '상태 필터';
  @override
  String get filterPortal => '채용 플랫폼';
  @override
  String get filterWorkSystem => '근무 형태';
  @override
  String get filterEmploymentType => '고용 형태';
  @override
  String get sortNewest => '최신 지원순';
  @override
  String get sortOldest => '오래된 지원순';
  @override
  String get sortCompanyAZ => '회사명 (가나다순)';
  @override
  String get sortSalaryHighest => '희망 급여 높은순';
  @override
  String get sortStarredFirst => '즐겨찾기 우선';
  @override
  String get noApplicationsFound => '조건에 일치하는 지원 내역이 없습니다';
  @override
  String get clearFilters => '필터 초기화';
  @override
  String get deleteApplicationConfirmTitle => '지원 내역을 삭제하시겠습니까?';
  @override
  String get deleteApplicationConfirmMessage => '이 지원 내역과 모든 면접 기록이 영구적으로 삭제됩니다.';
  @override
  String get listView => '리스트 보기';
  @override
  String get kanbanBoard => '칸반 보드';
  @override
  String get starred => '즐겨찾기';
  @override
  String get emptyKanban => '내용 없음';
  @override
  String get noApplicationsYet => '지원 내역이 없습니다';
  @override
  String get noApplicationsYetMsg => '입사 지원 현황과 면접 일정을 체계적으로 정리해보세요.';
  @override
  String get newApplicationBtn => '새 지원 등록';

  // Application Detail Screen
  @override
  String get applicationDetailTitle => '지원 상세 정보';
  @override
  String get overviewTab => '개요';
  @override
  String get timelineTab => '전형 단계 & 기록';
  @override
  String get companyInfo => '기업 정보';
  @override
  String get salaryDetails => '희망 및 제시 급여';
  @override
  String get salaryExpectation => '희망 급여';
  @override
  String get salaryOffered => '제시 급여';
  @override
  String get appliedOn => '지원일';
  @override
  String get notesTitle => '메모 및 세부 정보';
  @override
  String get noNotes => '등록된 메모가 없습니다.';
  @override
  String get jobUrlLabel => '채용 공고 링크';
  @override
  String get openJobUrl => '공고 열기';
  @override
  String get updateStatus => '상태 변경';
  @override
  String get selectNewStatus => '지원 상태 선택';
  @override
  String get addTimelineStage => '전형 단계 추가';
  @override
  String get editTimelineStage => '전형 단계 수정';
  @override
  String get deleteTimelineStage => '단계 삭제';
  @override
  String get stageNameLabel => '전형 단계명 (예: 1차 면접, 코딩 테스트)';
  @override
  String get stageDateLabel => '일시 및 시간';
  @override
  String get stageNotesLabel => '면접 질문, 소감, 피드백';
  @override
  String get cvAttachmentTitle => '첨부 문서';
  @override
  String get savedInDrive => 'Google 드라이브에 저장됨';
  @override
  String get uploadCvToDrive => '문서 업로드';
  @override
  String get manageAttachment => '첨부 파일 관리';
  @override
  String get deleteFromDrive => 'Google 드라이브에서 영구 삭제';
  @override
  String get detachOnly => '첨부 연결만 해제';
  @override
  String get updateStageStatusTitle => '전형 결과 상태 업데이트';
  @override
  String get stageOptionPassed => '합격 / 통과';
  @override
  String get stageOptionNext => '다음 전형 진행';
  @override
  String get stageOptionOffering => '최종 합격 / 오퍼';
  @override
  String get stageOptionWaiting => '결과 대기 중';
  @override
  String get stageOptionFailed => '불합격';
  @override
  String get deleteStageConfirmTitle => '전형 단계를 삭제하시겠습니까?';
  @override
  String get deleteStageConfirmMessage => '해당 전형 단계 기록이 삭제됩니다.';
  @override
  String get noStagesRecorded => '등록된 전형 단계가 없습니다.';
  @override
  String get addStagePrompt => '면접, 과제 전형, 서류 심사 일정을 추가해보세요.';
  @override
  String get interviewerLabel => '면접관 / 채용 담당자';
  @override
  String get interviewerHint => '예: 김철수 (엔지니어링 리드)';
  @override
  String get meetingLinkLabel => '화상 회의 링크';
  @override
  String get meetingLinkHint => 'https://meet.google.com/...';
  @override
  String get openMeetingButton => '회의실 입장';
  @override
  String get quickStagesTitle => '추천 전형 목록';
  @override
  String get stageStatusResult => '전형 결과 / 상태';
  @override
  String get stageNotesPlaceholder => '질문 내용, 면접 분위기, 주요 피드백...';
  @override
  String get editApplicationTooltip => '지원 내역 수정';
  @override
  String get deleteTooltip => '삭제';
  @override
  String get jobSourceLabel => '지원 경로';
  @override
  String get openUrl => 'URL 열기';
  @override
  String get attachedDriveFiles => '첨부 서류 (Google 드라이브)';
  @override
  String get noCvAttached => '첨부된 이력서가 없습니다. [수정]에서 업로드할 수 있습니다.';
  @override
  String get recruitmentStages => '채용 전형 단계';
  @override
  String get addStageBtn => '단계 추가';
  @override
  String get noStagesMsg => '아직 기록된 면접 또는 전형 일정이 없습니다.';
  @override
  String get editStage => '단계 수정';
  @override
  String get deleteStage => '단계 삭제';
  @override
  String get deleteStageConfirm => '단계를 삭제하시겠습니까?';
  @override
  String deleteStageMsg(String stageName) => '전형 단계 "$stageName"을(를) 삭제하시겠습니까?';
  @override
  String get stageDeletedSuccess => '전형 단계가 삭제되었습니다';
  @override
  String get stageResultUpdated => '전형 상태가 업데이트되었습니다';

  // Application Form Screen
  @override
  String get createApplicationTitle => '새 지원 등록';
  @override
  String get editApplicationTitle => '지원 정보 수정';
  @override
  String get vacancyInfoSection => '공고 기본 정보';
  @override
  String get companyNameLabel => '회사명 *';
  @override
  String get companyNameHint => '예: 네이버, 카카오, 라인, 쿠팡';
  @override
  String get companyNameRequired => '회사명을 입력해주세요';
  @override
  String get positionTitleLabel => '직무 / 포지션 *';
  @override
  String get positionTitleHint => '예: 시니어 Flutter 개발자';
  @override
  String get positionTitleRequired => '직무 및 포지션을 입력해주세요';
  @override
  String get locationLabel => '근무지 / 본사 위치';
  @override
  String get locationHint => '예: 서울 강남구, 원격 근무';
  @override
  String get workTypeAndSystemSection => '고용 및 근무 형태';
  @override
  String get employmentTypeLabel => '고용 형태';
  @override
  String get workSystemLabel => '근무 형태';
  @override
  String get jobPortalSection => '채용 플랫폼 / 유입 경로';
  @override
  String get otherPortalHint => '플랫폼명 또는 추천 경로 입력';
  @override
  String get jobUrlSection => '채용 공고 URL';
  @override
  String get jobUrlHint => 'https://linkedin.com/jobs/...';
  @override
  String get currentStatusSection => '현재 진행 상태';
  @override
  String get appliedDateLabel => '지원 일자';
  @override
  String get salarySection => '희망 및 오퍼 급여';
  @override
  String get salaryExpectationHint => '예: 50,000,000 (희망 연봉)';
  @override
  String get salaryOfferedHint => '예: 55,000,000 (제시 연봉)';
  @override
  String get notesSection => '추가 메모';
  @override
  String get notesHint => '지원 요건, 추천인 연락처, 주요 어필 포인트...';
  @override
  String get saveApplicationButton => '지원 내역 저장';
  @override
  String get updateApplicationButton => '변경사항 저장';

  // Dashboard / Analytics Screen
  @override
  String get analyticsTitle => '커리어 분석';
  @override
  String get pipelineFunnel => '전형 퍼널 분석';
  @override
  String get systemsAndPortals => '근무 형태 및 지원 경로';
  @override
  String get successRateTitle => '지원 및 합격 전환율';
  @override
  String get interviewCallsRate => '서류 통과율';
  @override
  String get hiredRate => '최종 합격률';
  @override
  String get topPortals => '가장 효과적인 채용 플랫폼';
  @override
  String get monthlyApplications => '월별 지원 추이';
  @override
  String get responseRate => '면접 전환율';
  @override
  String get offerRate => '최종 오퍼율';
  @override
  String get totalApplicationsMetric => '총 지원 건수';
  @override
  String get interviewStageMetric => '면접 전형 단계';
  @override
  String get offeringMetric => '최종 오퍼';
  @override
  String get hiredMetric => '최종 입사';
  @override
  String get statusDistribution => '지원 상태별 분포';
  @override
  String get workSystemDistribution => '근무 형태 분포';
  @override
  String get noWorkSystemData => '근무 형태 데이터가 없습니다';
  @override
  String get portalSources => '지원 플랫폼 분포';
  @override
  String get noPortalData => '플랫폼 데이터가 없습니다';
  @override
  String get noAnalyticsDataTitle => '분석 데이터 없음';
  @override
  String get noAnalyticsDataMessage => '지원 내역을 등록하면 서류 통과율과 플랫폼별 효과가 자동 분석됩니다.';

  // Schedule Screen
  @override
  String get scheduleTitle => '일정 및 캘린더';
  @override
  String get searchScheduleHint => '회사, 직무, 면접 단계 검색...';
  @override
  String get upcomingTab => '예정된 일정';
  @override
  String get allAgendaTab => '전체 일정';
  @override
  String get noScheduleTitle => '등록된 일정이 없습니다';
  @override
  String get noScheduleMessage => '면접이나 과제 마감일이 없습니다. 전형 단계를 등록하면 자동으로 표시됩니다.';
  @override
  String get refreshSchedule => '새로고침';
  @override
  String get noScheduleFoundTitle => '일정을 찾을 수 없습니다';
  @override
  String noScheduleFoundMessage(String query) => '검색어 "$query"에 해당하는 일정이 없습니다.';
  @override
  String get resetSearch => '검색 초기화';
  @override
  String get noUpcomingScheduleTitle => '예정된 일정이 없습니다';
  @override
  String get noUpcomingScheduleMessage => '모든 일정이 완료되었거나 새로운 일정이 없습니다.';
  @override
  String get noPastScheduleMessage => '지난 면접 기록이 없습니다.';
  @override
  String get sectionOverdue => '기한 경과 / 확인 필요';
  @override
  String get sectionOverdueSubtitle => '업데이트가 필요한 전형';
  @override
  String get sectionToday => '오늘';
  @override
  String get sectionTodaySubtitle => '오늘 예정된 면접 및 일정';
  @override
  String get sectionThisWeek => '이번 주';
  @override
  String get sectionThisWeekSubtitle => '향후 7일 이내 일정';
  @override
  String get sectionUpcoming => '다음 주 이후';
  @override
  String get sectionUpcomingSubtitle => '8일 이후 예정된 일정';
  @override
  String get sectionHistory => '완료된 기록';
  @override
  String get sectionHistorySubtitle => '종료된 지난 일정';
  @override
  String get interviewerPrefix => '면접관: ';
  @override
  String get openMeetingRoom => '회의실 입장';
  @override
  String get syncToCalendar => '캘린더에 동기화';
  @override
  String get calendarSyncSuccess => 'Google 캘린더를 여는 중...';
  @override
  String statusUpdatedTo(String status) => '상태가 $status(으)로 변경되었습니다';
  @override
  String get dragToMove => '길게 눌러 드래그하여 상태 변경';

  // Profile & Settings Screen
  @override
  String get profileTitle => '프로필 및 설정';
  @override
  String get accountSection => '계정';
  @override
  String get preferencesSection => '앱 환경설정';
  @override
  String get dataSection => '데이터 및 백업';
  @override
  String get aboutSection => 'AppliQ 정보';
  @override
  String get themeSetting => '테마 설정';
  @override
  String get accentSetting => '강조 색상';
  @override
  String get languageSetting => '언어 설정 (Language)';
  @override
  String get notificationsSetting => '알림 및 리마인더';
  @override
  String get exportDataSetting => '데이터 내보내기 (Excel / CSV / PDF)';
  @override
  String get googleDriveSetting => 'Google 드라이브 연동';
  @override
  String get connected => '연동됨';
  @override
  String get disconnected => '연동 안 됨';
  @override
  String get disconnectDriveConfirm => 'Google 드라이브 연동을 해제하시겠습니까?';
  @override
  String get disconnectDriveMessage => '언제든지 다시 연동하여 서류를 관리할 수 있습니다.';
  @override
  String get logoutButton => '로그아웃';
  @override
  String get logoutConfirmTitle => 'AppliQ에서 로그아웃하시겠습니까?';
  @override
  String get logoutConfirmMessage => '데이터는 클라우드에 안전하게 보관되며 다음 로그인 시 복원됩니다.';
  @override
  String get appVersion => '앱 버전';

  // Edit Profile Screen
  @override
  String get editProfileTitle => '프로필 수정';
  @override
  String get googleEmailLabel => 'Google 계정 이메일';
  @override
  String get googleEmailDesc => 'Google에서 동기화됨';
  @override
  String get fullNameLabel => '이름';
  @override
  String get fullNameHint => '이름을 입력하세요';
  @override
  String get fullNameEmptyError => '이름을 입력해주세요';
  @override
  String get usernameLabel => '사용자명';
  @override
  String get phoneLabel => '연락처 / WhatsApp';
  @override
  String get targetRoleLabel => '목표 직무 / 희망 포지션';
  @override
  String get targetRoleHint => '예: 시니어 Flutter 개발자 / UI 디자이너';
  @override
  String get saveChangesButton => '변경사항 저장';
  @override
  String get deleteAccountButton => '계정 삭제';
  @override
  String get deleteAccountConfirmTitle => '계정을 영구 삭제하시겠습니까?';
  @override
  String get deleteAccountConfirmMessage => '모든 지원 내역, 면접 기록, 메모가 영구 삭제됩니다. 이 작업은 되돌릴 수 없습니다.';
  @override
  String get profileUpdatedSuccess => '프로필이 성공적으로 수정되었습니다!';
  @override
  String get accountDeletedSuccess => '계정이 삭제되었습니다';

  // Notification Sheet
  @override
  String get notificationCenterTitle => '알림 센터';
  @override
  String get noUrgentReminders => '긴급한 알림이 없습니다';
  @override
  String activeRemindersCount(int count) => '$count 개의 활성 알림';
  @override
  String get pushNotificationTestTitle => '푸시 알림 테스트';
  @override
  String get pushNotificationTestDesc => '기기 상태 표시줄 알림 팝업을 테스트합니다.';
  @override
  String get testNotificationButton => '테스트 발송';
  @override
  String get testNotificationSentToast => '테스트 알림이 기기로 발송되었습니다!';
  @override
  String get interviewAgendaSection => '면접 및 전형 일정';
  @override
  String get followUpNeededSection => '팔로업 권장 (7일 이상 경과)';
  @override
  String appliedDaysAgo(int days) => '$days 일 전 지원';
  @override
  String get emailHrButton => '인사팀 이메일';
  @override
  String get allSchedulesSafeTitle => '모든 일정이 안전하게 진행 중입니다';
  @override
  String get allSchedulesSafeDesc => '긴급한 면접이나 지연된 지원 건이 없습니다.';

  // HR Templates Sheet
  @override
  String get hrTemplatesSheetTitle => '채용 담당자 이메일 템플릿';
  @override
  String get hrTemplatesSheetSubtitle => '복사해서 바로 사용하는 전문 비즈니스 메일 양식';
  @override
  String get categoryAll => '전체';
  @override
  String get categoryFollowUp => '진행상황 문의';
  @override
  String get categoryInterview => '면접 일정';
  @override
  String get categoryOffering => '처우 및 오퍼';
  @override
  String get copySubjectButton => '제목 복사';
  @override
  String get copyBodyButton => '본문 복사';
  @override
  String copiedToast(String label) => '$label 이(가) 클립보드에 복사되었습니다!';

  // Language Modal
  @override
  String get languageModalTitle => '언어 선택 (Language)';
  @override
  String get languageModalSubtitle => '앱 인터페이스 언어를 선택하세요';
  @override
  String get languageIdName => 'Bahasa Indonesia';
  @override
  String get languageIdSubtitle => '인도네시아어 (Bahasa Indonesia)';
  @override
  String get languageEnName => 'English';
  @override
  String get languageEnSubtitle => '영어 (English)';
  @override
  String get languageJaName => '日本語';
  @override
  String get languageJaSubtitle => '일본어 (Japanese)';
  @override
  String get languageKoName => '한국어';
  @override
  String get languageKoSubtitle => '한국어 (Korean)';
  @override
  String get languageComingSoonToast => '이 언어는 다음 업데이트에서 제공될 예정입니다!';

  // Export Sheet
  @override
  String get exportSheetTitle => '지원 데이터 내보내기';
  @override
  String get exportSheetSubtitle => '원하는 형식으로 구직 활동 리포트 다운로드';
  @override
  String get exportFormat => '파일 형식';
  @override
  String get exportDateRange => '기간 선택';
  @override
  String get exportAllTime => '전체 기간';
  @override
  String get exportThisMonth => '이번 달';
  @override
  String get exportLast3Months => '최근 3개월';
  @override
  String get exportThisYear => '올해';
  @override
  String get exportButton => '내보내기 및 공유';
  @override
  String get exportSuccess => '데이터를 성공적으로 내보냈습니다!';
  @override
  String get exportEmpty => '내보낼 지원 데이터가 없습니다.';

  // Toasts & Snackbars
  @override
  String get errorOccurred => '오류가 발생했습니다. 다시 시도해주세요.';
  @override
  String get successSaved => '지원 내역이 저장되었습니다.';
  @override
  String get successUpdated => '지원 정보가 수정되었습니다.';
  @override
  String get successDeleted => '지원 내역이 삭제되었습니다.';
  @override
  String get fileUploadedDrive => 'Google 드라이브에 파일이 업로드되었습니다.';
  @override
  String get fileDeletedDrive => 'Google 드라이브에서 파일이 삭제되었습니다.';
  @override
  String get attachmentDetached => '파일 첨부가 해제되었습니다.';
  @override
  String get fillRequiredFields => '회사명과 직무를 입력해주세요.';

  // Login Screen
  @override
  String get loginTagline => '구직 활동의 모든 전형 과정을\n실시간으로 스마트하게 추적하고 관리하세요.';
  @override
  String get signInWithGoogle => 'Google 계정으로 로그인';
  @override
  String get termsPrefix => '로그인 시 AppliQ의 ';
  @override
  String get termsOfService => '이용약관';
  @override
  String get andConjunction => ' 및 ';
  @override
  String get privacyPolicy => '개인정보 처리방침';
  @override
  String get termsContent => 'AppliQ를 이용함으로써 책임감 있는 구직 활동 기록 관리에 동의하게 됩니다. 사용자 데이터는 업계 표준 암호화 프로토콜을 통해 안전하게 저장됩니다.';
  @override
  String get privacyContent => 'AppliQ는 귀하의 개인정보를 최우선으로 보호합니다. 모든 지원 기록 및 개인정보는 본인만 열람할 수 있으며, 명시적 동의 없이 제3자에게 제공되지 않습니다.';
  @override
  String welcomeUser(String name) => '환영합니다, $name님!';

  // Status Feedback Text
  @override
  String get feedbackSubmittedToday => '오늘 지원 완료';
  @override
  String feedbackSubmittedDaysAgo(int days) => '$days 일 전 지원 완료';
  @override
  String get feedbackNoResponse30Days => '30일 이상 미응답';
  @override
  String get feedbackStayMotivated => '힘내세요! 더 좋은 기회가 기다리고 있습니다';
  @override
  String feedbackCurrentStage(String stageName) => '현재 [$stageName] 전형 단계입니다';

  // Legal (Terms of Service & Privacy Policy Modals)
  @override
  String get termsModalTitle => '서비스 이용약관';
  @override
  String get termsModalSubtitle => 'AppliQ 공식 이용약관';
  @override
  List<Map<String, String>> get termsCards => [
    {
      'title': '1. 약관 동의 (Acceptance of Terms)',
      'content': 'AppliQ 플랫폼에 가입, 접속 또는 이용함으로써 귀하는 본 서비스 이용약관에 구속되는 데 동의합니다. 본 약관의 조항에 동의하지 않는 경우 서비스 이용을 중단해주시기 바랍니다.',
    },
    {
      'title': '2. 사용자 계정 및 보안 책임',
      'content': '귀하는 Google 계정 인증 정보의 기밀성을 유지할 전적인 책임이 있습니다. 귀하의 계정 하에서 발생하는 모든 활동은 본인의 책임이며, AppliQ는 계정 관리 소홀로 인한 손실에 대해 책임을 지지 않습니다.',
    },
    {
      'title': '3. 지원 내역 관리 및 트래커 서비스',
      'content': 'AppliQ는 입사 지원 내역 기록(Job Tracker), 면접 일정 관리, 전형 합격률 통계 계산 및 커리어 관리 기능을 제공합니다. 본 서비스는 취업 활동의 생산성을 지원하기 위해 "있는 그대로(as is)" 제공됩니다.',
    },
    {
      'title': '4. 지적재산권 및 저작권',
      'content': 'UI/UX 디자인, 일러스트, 3D 마스코트, AppliQ 로고, 시스템 아키텍처 및 소스 코드는 Muhamad Sidik / Arch Studio (@Imyusi_)의 독점적 지적 재산입니다. 사전 서면 허가 없이 본 애플리케이션을 복제, 재배포, 리버스 엔지니어링 또는 권리를 주장하는 것은 엄격히 금지됩니다.',
    },
    {
      'title': '5. 책임의 한계 및 보증의 부인',
      'content': 'AppliQ는 특정 기업의 채용 또는 합격 결과를 보장하지 않습니다. 서버 안정성과 데이터 동기화를 위해 최선을 다하나, 제3자 네트워크 장애로 인한 손실에 대해서는 책임을 지지 않습니다.',
    },
    {
      'title': '6. 이용약관의 변경',
      'content': '당사는 관련 법령 준수 또는 신규 기능 추가에 따라 본 이용약관을 수시로 개정할 수 있습니다. 변경 사항은 본 페이지에 시행일자와 함께 공지됩니다.',
    },
  ];

  @override
  String get privacyModalTitle => '개인정보 처리방침';
  @override
  String get privacyModalSubtitle => '암호화된 개인정보 보호';
  @override
  List<Map<String, String>> get privacyCards => [
    {
      'title': '1. 수집하는 개인정보 항목',
      'content': 'AppliQ 이용 시 다음과 같은 정보를 수집합니다: Google 프로필 정보 (이름, 이메일 주소, 프로필 사진 URL), 입사 지원 데이터 (회사명, 직무, 진행 상태, 급여 정보, 면접 메모) 및 앱 환경설정.',
    },
    {
      'title': '2. 개인정보의 이용 목적',
      'content': '수집된 정보는 입사 지원 관리 기능 제공 (Supabase 클라우드 데이터베이스 동기화, 면접 알림 전송, 개인 커리어 분석 통계 생성, UI 최적화) 목적으로만 활용됩니다.',
    },
    {
      'title': '3. 암호화 및 데이터베이스 보안',
      'content': '모든 데이터 전송은 TLS/HTTPS 암호화로 보호되며, Supabase의 행 수준 보안 (Row-Level Security, RLS)을 통해 안전하게 저장됩니다. 인증된 본인 계정만 데이터에 접근하고 수정할 수 있습니다.',
    },
    {
      'title': '4. 제3자 데이터 판매 금지',
      'content': 'AppliQ는 귀하의 지원 내역 및 개인정보를 광고주나 제3자에게 판매, 대여 또는 공유하지 않습니다.',
    },
    {
      'title': '5. 계정 영구 삭제 및 데이터 통제권',
      'content': '귀하는 언제든지 프로필 정보를 수정하거나, 지원 내역을 내보내거나, [프로필 수정] 내 "계정 삭제"를 통해 모든 데이터를 영구적으로 삭제할 권리가 있습니다.',
    },
  ];

  @override
  List<Map<String, String>> get faqList => [
    {
      'q': 'AppliQ는 어떤 앱인가요?',
      'a': 'AppliQ는 입사 지원 내역을 체계적으로 기록하고, 면접 일정을 관리하며, 서류 통과율과 전환율을 실시간으로 분석해주는 스마트 구직 관리 플랫폼입니다.',
    },
    {
      'q': '면접 일정 알림은 어떻게 설정하나요?',
      'a': '지원 상세 화면에서 전형 단계를 추가하거나 수정할 때 날짜와 시간을 입력하세요. 설정 화면에서 "알림 및 리마인더"가 켜져 있는지 확인해주시기 바랍니다.',
    },
    {
      'q': '희망 연봉과 지원 기록의 보안은 안전한가요?',
      'a': '매우 안전합니다. AppliQ는 Supabase의 행 수준 보안(RLS)과 TLS 암호화를 적용하여 본인 외에는 누구도 지원 기록과 급여 정보를 열람할 수 없습니다.',
    },
    {
      'q': '지원 내역 검색과 필터링은 어떻게 하나요?',
      'a': '[지원] 또는 [일정] 탭 상단 검색창에서 회사명이나 직무를 검색할 수 있으며, 상태 필터(지원 완료, 면접 진행, 최종 합격, 불합격)를 통해 빠르게 분류할 수 있습니다.',
    },
    {
      'q': '지원 기록 데이터를 외부로 내보낼 수 있나요?',
      'a': '네. [데이터 내보내기] 기능을 통해 PDF 리포트 또는 CSV 스프레드시트 형태로 언제든지 다운로드할 수 있습니다.',
    },
  ];

  // Settings & Bottom Sheets
  @override
  String get generalSettingsTitle => '일반 설정';
  @override
  String get generalSettingsSubtitle => '화면 테마 및 앱 환경설정 맞춤 변경';
  @override
  String get appearanceSection => '화면 테마';
  @override
  String get darkModeTitle => '다크 모드';
  @override
  String get darkModeDesc => '다크 테마와 라이트 테마 전환';
  @override
  String get monochromeTitle => '모노크롬 모드';
  @override
  String get monochromeDesc => '미니멀한 흑백 톤 디자인 적용';
  @override
  String get preferencesFormatSection => '환경설정 & 형식';
  @override
  String get appLanguageTitle => '앱 표시 언어 (Language)';
  @override
  String get appLanguageDesc => '인터페이스 언어 선택';
  @override
  String get defaultCurrencyTitle => '기본 통화';
  @override
  String get defaultCurrencyDesc => '급여 표시 통화 단위 포맷';
  @override
  String get dateFormatTitle => '날짜 표시 형식';
  @override
  String get dateFormatDesc => '앱 전반의 날짜 표기 형식';
  @override
  String get feedbackHapticSection => '인터랙션 & 정렬';
  @override
  String get hapticTitle => '햅틱 진동 피드백';
  @override
  String get hapticDesc => '버튼 탭 시 가벼운 진동 반응';
  @override
  String get defaultSortTitle => '기본 정렬 방식';
  @override
  String get defaultSortDesc => '지원 목록의 자동 정렬 기준';
  @override
  String get sortPickerTitle => '지원 목록 정렬 선택';
  @override
  String get sortPickerSubtitle => '지원 내역 자동 정렬 기준 설정';
  @override
  String get sortOptionNewest => '최신 지원순';
  @override
  String get sortOptionNewestDesc => '가장 최근에 등록한 지원서를 상단에 표시';
  @override
  String get sortOptionClosest => '마감 / 일정 임박순';
  @override
  String get sortOptionClosestDesc => '가까운 일정이 있는 지원 내역을 우선 표시';
  @override
  String get sortOptionCompanyAZ => '회사명 (가나다 / A-Z)';
  @override
  String get sortOptionCompanyAZDesc => '회사명 알파벳 및 가나다순 정렬';
  @override
  String get sortOptionSalary => '희망 급여 높은순';
  @override
  String get sortOptionSalaryDesc => '제시 또는 희망 급여가 높은 순서대로 표시';
  @override
  String get securitySettingsTitle => '보안 및 계정 인증';
  @override
  String get securitySettingsSubtitle => 'Google 계정 및 클라우드 데이터베이스 보호';
  @override
  String get cloudSyncTitle => 'Google 드라이브 클라우드 동기화';
  @override
  String get cloudSyncSubtitle => '이력서, 포트폴리오 첨부 파일 클라우드 보관';

  @override
  String get quickResume => '이력서';

  @override
  String get menuExperienceTitle => '경력 및 이력';
  @override
  String get menuExperienceSubtitle => 'ATS 이력서 및 자기소개서';
  @override
  String get resumeBuilderTitle => '경력 및 이력서 관리';
  @override
  String get previewCvAts => 'ATS 이력서 미리보기';
  @override
  String get coverLetterTitle => '자기소개서';
  @override
  String get documentPreviewTitle => '문서 미리보기';
  @override
  String get customizeCoverLetter => '자기소개서 설정';
  @override
  String get digitalSignature => '디지털 서명';
  @override
  String get uploadSignature => '서명 업로드';
  @override
  String get changeSignature => '서명 변경';
  @override
  String get signatureActive => '서명 활성화됨';
  @override
  String get applyChanges => '변경사항 적용';
  @override
  String get saveResume => '데이터 저장';

  // Resume Builder Sections
  @override
  String get rbSectionContactTitle => '기본 정보 및 연락처';
  @override
  String get rbSectionContactSubtitle => '이름, 연락처, SNS 및 프로필 링크';
  @override
  String get rbSectionSummaryTitle => '자기소개 및 요약';
  @override
  String get rbSectionSummarySubtitle => '경력 개요 및 핵심 역량 요약';
  @override
  String get rbSectionEducationTitle => '학력 사항';
  @override
  String rbSectionEducationSubtitle(int count) => '$count 건의 학력';
  @override
  String get rbSectionExperienceTitle => '경력 및 프로젝트';
  @override
  String rbSectionExperienceSubtitle(int count) => '$count 건의 경력';
  @override
  String get rbSectionCertificationTitle => '자격증 및 수료';
  @override
  String rbSectionCertificationSubtitle(int count) => '$count 건의 자격증';
  @override
  String get rbSectionTechSkillsTitle => '기술 스택 (Hard Skills)';
  @override
  String rbSectionTechSkillsSubtitle(int count) => '$count 건의 기술';
  @override
  String get rbSectionSoftSkillsTitle => '소프트 스킬 / 개인 역량';
  @override
  String rbSectionSoftSkillsSubtitle(int count) => '$count 건의 역량 (3열 배치)';
  @override
  String get rbSectionCoverLetterTitle => '자기소개서 세부정보';
  @override
  String get rbSectionCoverLetterSubtitle => '생년월일, 주소, 첨부 서류 체크리스트';

  // Resume Builder Form Labels & Hints
  @override
  String get cityCountryLabel => '거주지・국가 (City, Country)';
  @override
  String get cityCountryHint => '예: 서울특별시, 대한민국';
  @override
  String get phoneNumberLabel => '연락처 / WhatsApp';
  @override
  String get phoneNumberHint => '010-1234-5678';
  @override
  String get emailLabel => '이메일 주소';
  @override
  String get emailHint => 'hong@email.com';
  @override
  String get linkedinLabel => 'LinkedIn URL (선택)';
  @override
  String get linkedinHint => 'linkedin.com/in/hong';
  @override
  String get portfolioLabel => '포트폴리오 / GitHub (선택)';
  @override
  String get portfolioHint => 'github.com/hong';

  @override
  String get summaryLabel => '자기소개 및 요약 (Summary)';
  @override
  String get summaryHint => '자신의 경력 개요, 핵심 역량 및 주요 성과를 간략히 요약해 주세요...';

  @override
  String get addEducationButton => '+ 학력 추가';
  @override
  String get addExperienceButton => '+ 경력 추가';
  @override
  String get addCertificationButton => '+ 자격증 추가';

  @override
  String get addTechSkillLabel => '기술 스택 추가';
  @override
  String get addTechSkillHint => '예: Flutter, Python, SQL...';
  @override
  String get addSoftSkillLabel => '소프트 스킬 추가';
  @override
  String get addSoftSkillHint => '예: 문제 해결력, 팀워크...';

  @override
  String get birthPlaceDateLabel => '생년월일・출생지';
  @override
  String get birthPlaceDateHint => '예: 서울특별시, 2000년 1월 12일';
  @override
  String get fullAddressLabel => '상세 주소 (주민등록/실거주지)';
  @override
  String get fullAddressHint => '예: 서울특별시 강남구 테헤란로 123';
  @override
  String get lastEducationLabel => '최종 학력 (전공 및 학교)';
  @override
  String get lastEducationHint => '예: 서울대학교 컴퓨터공학부 학사';
  @override
  String get targetJobPositionLabel => '희망 직무 / 포지션';
  @override
  String get targetJobPositionHint => '예: 모바일 개발자 / 소프트웨어 엔지니어';
  @override
  String get maritalStatusLabel => '결혼 여부';
  @override
  String get citizenshipLabel => '국적';
  @override
  String get attachmentListLabel => '첨부 서류 목록:';

  // Resume Builder Dialogs
  @override
  String get addEducation => '학력 사항 추가';
  @override
  String get editEducation => '학력 사항 수정';
  @override
  String get institutionName => '학교 / 교육기관명';
  @override
  String get institutionHint => '예: 서울대학교';
  @override
  String get degreeAndMajor => '학위 및 전공';
  @override
  String get degreeHint => '예: 컴퓨터공학 학사';
  @override
  String get educationPeriod => '재학 기간';
  @override
  String get educationPeriodHint => '예: 2020년 3월 - 2024년 2월';
  @override
  String get gpaLabel => '학점 / 성적 (선택)';
  @override
  String get gpaHint => '예: 3.85 / 4.50';
  @override
  String get institutionLocation => '학교 소재지';
  @override
  String get institutionLocationHint => '예: 서울특별시 관악구';
  @override
  String get educationActivities => '주요 활동 및 성과 (줄당 1개)';
  @override
  String get educationActivitiesHint => '예: UI/UX 공모전 대상 수상\n학생회장 활동';
  @override
  String get resumeSavedSuccess => '이력서 및 프로필이 클라우드에 저장되었습니다!';

  @override
  String get addExperience => '경력 / 프로젝트 추가';
  @override
  String get editExperience => '경력 / 프로젝트 수정';
  @override
  String get positionLabel => '직책 / 역할';
  @override
  String get positionHint => '예: 모바일 앱 개발자';
  @override
  String get workPeriod => '근무 기간';
  @override
  String get workPeriodHint => '예: 2023년 3월 - 현재';
  @override
  String get responsibilitiesLabel => '주요 업무 및 성과 (줄당 1개)';
  @override
  String get responsibilitiesHint => '예: Flutter 기반 핵심 서비스 5개 개발\n사용자 유지율 20% 향상';

  @override
  String get addCertification => '자격증 및 수료 추가';
  @override
  String get editCertification => '자격증 및 수료 수정';
  @override
  String get certificateName => '자격증 / 수료증 명칭';
  @override
  String get certificateHint => '예: 정보처리기사 / Google Cloud Associate';
  @override
  String get issuerOrg => '발급 기관';
  @override
  String get issuerHint => '예: 한국산업인력공단 / Google / AWS';
  @override
  String get obtainedYear => '취득 연월';
  @override
  String get yearHint => '예: 2024년';

  // Smart Job Parser
  @override
  String get smartParserTitle => '스마트 파서';
  @override
  String get smartParserSubtitle => '채용공고 텍스트를 붙여넣어 자동 입력';
  @override
  String get smartParserPasteHint => '채용공고 텍스트를 여기에 붙여넣기...';
  @override
  String get smartParserButton => '자동 추출';
  @override
  String get smartParserPasteClipboard => '클립보드 붙여넣기';
  @override
  String get smartParserClear => '지우기';
  @override
  String get smartParserSuccess => '채용공고 정보가 추출되었습니다!';
  @override
  String get smartParserNoText => '채용공고 텍스트가 비어있습니다.';
  @override
  String get smartParserDetectedBadge => '감지된 항목';
  @override
  String get smartParserApplyToForm => '양식에 적용';
  @override
  String get smartParserAutoFillBanner => '채용공고 자동 입력';

  // Career & Currently Working Hub
  @override
  String get menuCareerTitle => '경력 및 경험';
  @override
  String get menuCareerSubtitle => '현재 직무, 경력 및 ATS 이력서';
  @override
  String get careerScreenTitle => '커리어 여정';
  @override
  String get currentlyWorkingHeader => '현재 직무';
  @override
  String get currentlyWorkingSubtitle => '현재 활동 중인 직무 및 직장';
  @override
  String get noCurrentlyWorking => '현재 설정된 직무가 없습니다';
  @override
  String get noCurrentlyWorkingDesc => '현재 직무를 추가하거나 합격한 지원서를 연결하세요.';
  @override
  String get setCurrentlyWorkingBtn => '현재 직무 설정';
  @override
  String get workHistoryHeader => '경력 사항';
  @override
  String get workHistorySubtitle => '이전 직무 및 커리어 이력';
  @override
  String get noWorkHistory => '이전 경력 사항이 없습니다';
  @override
  String get noWorkHistoryDesc => '이전 경력을 기록하여 ATS 이력서를 완성하세요.';
  @override
  String get addExperienceBtn => '경력 추가';
  @override
  String get isCurrentlyWorkingCheckbox => '현재 이 직무에서 근무 중';
  @override
  String get startDateLabel => '시작일';
  @override
  String get endDateLabel => '종료일';
  @override
  String get presentLabel => '현재';
  @override
  String get endJobConfirmTitle => '이 직무를 종료하시겠습니까?';
  @override
  String get endJobConfirmMessage => '종료일을 설정하여 이전 경력으로 이동합니다.';
  @override
  String get deleteExperienceConfirmTitle => '경력을 삭제하시겠습니까?';
  @override
  String get deleteExperienceConfirmMessage => '이 경력 정보는 완전히 삭제됩니다.';
  @override
  String get acceptedPromptTitle => '입사를 축하합니다!';
  @override
  String get acceptedPromptMessage => '이 지원서를 현재 근무 중(Currently Working) 직무로 등록할까요?';
  @override
  String get acceptedPromptConfirm => '현재 직무로 등록';
  @override
  String get acceptedPromptLater => '나중에';
  @override
  String get activeRoleBadge => '재직 중';
  @override
  String get careerMonthlySalary => '월급';
  @override
  String get careerAtsCardTitle => 'ATS 이력서 및 경력기술서 생성';
  @override
  String get careerAtsCardDesc => '등록된 경력 데이터로 ATS 친화적 PDF 이력서를 생성합니다.';

  // Enums & Dynamic Values
  @override
  String localizedEmploymentType(EmploymentType type) {
    switch (type) {
      case EmploymentType.fullTime:
        return '정규직';
      case EmploymentType.internship:
        return '인턴';
      case EmploymentType.contract:
        return '계약직';
      case EmploymentType.partTime:
        return '파트타임 / 알바';
      case EmploymentType.freelance:
        return '프리랜서 / 외주';
    }
  }

  @override
  String localizedWorkSystem(WorkSystem system) {
    switch (system) {
      case WorkSystem.onSite:
        return '사무실 출근 (온사이트)';
      case WorkSystem.hybrid:
        return '하이브리드 (혼합)';
      case WorkSystem.wfh:
        return '풀 원격 (재택근무)';
      case WorkSystem.remoteOverseas:
        return '해외 원격';
      case WorkSystem.flexible:
        return '유연 근무';
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
        return '사내 추천 / 지인';
      case JobPortal.directEmail:
        return '기업 직접 지원 / 헤드헌터';
      case JobPortal.kitaLulus:
        return 'KitaLulus';
      case JobPortal.jobFair:
        return '채용 박람회 / 캠퍼스';
      case JobPortal.website:
        return '기업 채용 홈페이지';
      case JobPortal.instagram:
        return 'SNS / 소셜미디어';
      case JobPortal.komunitas:
        return '커뮤니티 / 오픈채팅';
      case JobPortal.freelance:
        return '프리랜서 플랫폼';
      case JobPortal.lainnya:
        return '기타';
    }
  }

  @override
  String localizedStatus(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.applied:
        return '지원 완료';
      case ApplicationStatus.interview:
        return '면접 진행';
      case ApplicationStatus.offering:
        return '최종 합격 / 오퍼';
      case ApplicationStatus.accepted:
        return '입사 확정';
      case ApplicationStatus.rejected:
        return '불합격';
      case ApplicationStatus.noResponse:
        return '응답 없음';
    }
  }

  @override
  String localizedResult(String result) {
    switch (result.trim().toLowerCase()) {
      case 'lolos':
      case 'selesai':
      case 'passed':
      case 'done':
      case '합격':
      case '통과':
        return '합격';
      case 'diterima':
      case 'offering':
      case 'accepted':
      case '오퍼':
        return '합격';
      case 'gagal':
      case 'ditolak':
      case 'failed':
      case 'rejected':
      case 'tidak lolos':
      case '불합격':
        return '불합격';
      case 'waiting':
      case 'menunggu':
      case '대기':
      case '결과 대기':
      default:
        return '결과 대기';
    }
  }
}
