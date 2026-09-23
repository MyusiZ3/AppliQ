import '../../constants/app_enums.dart';
import 'base_language.dart';

/// Complete Japanese (日本語) localization for AppliQ.
class JaLanguage implements BaseLanguage {
  // Navigation
  @override
  String get navHome => 'ホーム';
  @override
  String get navApplications => '応募一覧';
  @override
  String get navAnalytics => '分析';
  @override
  String get navProfile => 'プロフィール';

  // Common Actions & Labels
  @override
  String get cancel => 'キャンセル';
  @override
  String get save => '保存';
  @override
  String get delete => '削除';
  @override
  String get edit => '編集';
  @override
  String get close => '閉じる';
  @override
  String get search => '検索...';
  @override
  String get filter => '絞り込み';
  @override
  String get sort => '並び替え';
  @override
  String get reset => 'リセット';
  @override
  String get apply => '適用';
  @override
  String get confirm => '確認';
  @override
  String get done => '完了';
  @override
  String get back => '戻る';
  @override
  String get retry => '再試行';
  @override
  String get loading => '読み込み中...';
  @override
  String get empty => 'データがありません';
  @override
  String get comingSoon => '近日公開';
  @override
  String get viewAll => 'すべて見る';
  @override
  String get openInDrive => 'Google ドライブで開く';
  @override
  String get scheduleDateLabel => '日程';

  // Home Screen
  @override
  String get greetingMorning => 'おはようございます';
  @override
  String get greetingAfternoon => 'こんにちは';
  @override
  String get greetingEvening => 'こんばんは';
  @override
  String get greetingNight => 'おやすみなさい';
  @override
  String get homeSubtitle => '就職活動の進捗をスムーズに管理';
  @override
  String get homeSearchHint => '企業名または職種を検索...';
  @override
  String get statTotal => '総応募数';
  @override
  String get statActive => '選考中';
  @override
  String get statInterview => '面接中';
  @override
  String get statOffering => '内定・オファー';
  @override
  String get recentApplications => '最近の応募';
  @override
  String get quickAddApplication => '応募追加';
  @override
  String get quickSchedule => '日程';
  @override
  String get quickTemplate => 'テンプレート';
  @override
  String get quickExport => 'エクスポート';
  @override
  String get quickAddTooltip => '新しい応募を記録';
  @override
  String get upcomingReminders => '今後の予定・リマインダー';
  @override
  String get noReminders => '直近の面接や予定はありません';
  @override
  String get emptyRecentApps => '保存された応募はありません';
  @override
  String get emptyRecentAppsDesc => '応募している求人を追加して管理を始めましょう。';
  @override
  String get addFirstApp => '最初の応募を記録する';
  @override
  String get applicationSummary => '応募サマリー';
  @override
  String get statsButton => '統計';
  @override
  String get appliedLabel => '応募済み';
  @override
  String get nextSchedule => '次の予定';
  @override
  String get openMeetingLink => 'ミーティングに参加';
  @override
  String get viewDetails => '詳細を見る';
  @override
  String get followUpNeeded => 'フォローアップ推奨';
  @override
  String get sendFollowUpEmail => 'フォローアップメールを送る';
  @override
  String get appliedCompanies => '応募先企業';
  @override
  String get noAppliedCompanies => '応募先企業がまだ登録されていません。';
  @override
  String get salaryUndisclosed => '給与非公開';
  @override
  String get perMonth => ' / 月';
  @override
  String positionsCount(int count) => '$count 件の職種';
  @override
  String applicationsCount(int count) => '$count 件の応募';
  @override
  String staleAppSingle(String company) => '$company の応募は7日以上ステータスの更新がありません。';
  @override
  String staleAppMulti(int count, String company) => '$company を含む $count 件の応募が7日以上未更新です。';

  // Applications List Screen
  @override
  String get applicationsTitle => '応募一覧';
  @override
  String get allStatusTab => 'すべて';
  @override
  String get searchApplicationPlaceholder => '職種、企業名、勤務地を検索...';
  @override
  String get filterStatus => 'ステータスで絞り込み';
  @override
  String get filterPortal => '求人媒体';
  @override
  String get filterWorkSystem => '勤務形態';
  @override
  String get filterEmploymentType => '雇用形態';
  @override
  String get sortNewest => '応募日が新しい順';
  @override
  String get sortOldest => '応募日が古い順';
  @override
  String get sortCompanyAZ => '企業名 (昇順)';
  @override
  String get sortSalaryHighest => '給与が高い順';
  @override
  String get sortStarredFirst => 'お気に入りを優先';
  @override
  String get noApplicationsFound => '条件に一致する応募が見つかりません';
  @override
  String get clearFilters => 'フィルターを解除';
  @override
  String get deleteApplicationConfirmTitle => '応募を削除しますか？';
  @override
  String get deleteApplicationConfirmMessage => 'この応募および関連するすべての面接記録が完全に削除されます。';
  @override
  String get listView => 'リスト表示';
  @override
  String get kanbanBoard => 'カンバン表示';
  @override
  String get starred => 'お気に入り';
  @override
  String get emptyKanban => '該当なし';
  @override
  String get noApplicationsYet => '応募履歴がありません';
  @override
  String get noApplicationsYetMsg => '求人応募や面接ステップをスマートに記録しましょう。';
  @override
  String get newApplicationBtn => '新規応募を記録';

  // Application Detail Screen
  @override
  String get applicationDetailTitle => '応募詳細';
  @override
  String get overviewTab => '概要';
  @override
  String get timelineTab => '選考ステップ・記録';
  @override
  String get companyInfo => '企業情報';
  @override
  String get salaryDetails => '希望・提示給与';
  @override
  String get salaryExpectation => '希望給与';
  @override
  String get salaryOffered => '提示給与';
  @override
  String get appliedOn => '応募日';
  @override
  String get notesTitle => 'メモ・補足事項';
  @override
  String get noNotes => 'この応募に関するメモはありません。';
  @override
  String get jobUrlLabel => '求人ページURL';
  @override
  String get openJobUrl => 'リンクを開く';
  @override
  String get updateStatus => 'ステータスを変更';
  @override
  String get selectNewStatus => '応募ステータスを選択';
  @override
  String get addTimelineStage => 'ステップを追加';
  @override
  String get editTimelineStage => 'ステップを編集';
  @override
  String get deleteTimelineStage => 'ステップを削除';
  @override
  String get stageNameLabel => 'ステップ名 (例: 一次面接, 適性検査)';
  @override
  String get stageDateLabel => '日時・日程';
  @override
  String get stageNotesLabel => '面接内容・質問・フィードバック';
  @override
  String get cvAttachmentTitle => '添付書類 (履歴書・職務経歴書)';
  @override
  String get savedInDrive => 'Google ドライブに保存済み';
  @override
  String get uploadCvToDrive => '履歴書・書類をGoogle ドライブにアップロード';
  @override
  String get manageAttachment => '添付書類を管理';
  @override
  String get deleteFromDrive => 'Google ドライブから完全に削除';
  @override
  String get detachOnly => '添付連携のみ解除';
  @override
  String get updateStageStatusTitle => '選考状況の更新';
  @override
  String get stageOptionPassed => '合格 / 通過';
  @override
  String get stageOptionNext => '次回選考へ進む';
  @override
  String get stageOptionOffering => '内定 / オファー';
  @override
  String get stageOptionWaiting => '結果待ち';
  @override
  String get stageOptionFailed => '不通過 (お見送り)';
  @override
  String get deleteStageConfirmTitle => 'ステップを削除しますか？';
  @override
  String get deleteStageConfirmMessage => 'この選考ステップの記録を削除します。';
  @override
  String get noStagesRecorded => '登録された選考ステップはありません。';
  @override
  String get addStagePrompt => '面接、テスト、書類選考のステップを追加しましょう。';
  @override
  String get interviewerLabel => '面接官・採用担当';
  @override
  String get interviewerHint => '例: 山田太郎 (エンジニアリングマネージャー)';
  @override
  String get meetingLinkLabel => 'ミーティング / ビデオ通話URL';
  @override
  String get meetingLinkHint => 'https://meet.google.com/...';
  @override
  String get openMeetingButton => 'ミーティングを開く';
  @override
  String get quickStagesTitle => 'クイック候補';
  @override
  String get stageStatusResult => '選考結果・ステータス';
  @override
  String get stageNotesPlaceholder => '質問内容、手応え、フィードバックなど...';
  @override
  String get editApplicationTooltip => '応募を編集';
  @override
  String get deleteTooltip => '削除';
  @override
  String get jobSourceLabel => '求人媒体';
  @override
  String get openUrl => 'URLを開く';
  @override
  String get attachedDriveFiles => '添付ファイル (Google ドライブ)';
  @override
  String get noCvAttached => '履歴書は添付されていません。「編集」からアップロードできます。';
  @override
  String get recruitmentStages => '選考プロセス';
  @override
  String get addStageBtn => 'ステップ追加';
  @override
  String get noStagesMsg => 'まだ面接や選考の予定は記録されていません。';
  @override
  String get editStage => 'ステップを編集';
  @override
  String get deleteStage => 'ステップを削除';
  @override
  String get deleteStageConfirm => 'ステップを削除しますか？';
  @override
  String deleteStageMsg(String stageName) => '選考ステップ「$stageName」を削除しますか？';
  @override
  String get stageDeletedSuccess => 'ステップを削除しました';
  @override
  String get stageResultUpdated => '選考ステータスを更新しました';

  // Application Form Screen
  @override
  String get createApplicationTitle => '新規応募の登録';
  @override
  String get editApplicationTitle => '応募情報の編集';
  @override
  String get vacancyInfoSection => '求人情報';
  @override
  String get companyNameLabel => '企業名 *';
  @override
  String get companyNameHint => '例: Google, Sony, トヨタ';
  @override
  String get companyNameRequired => '企業名を入力してください';
  @override
  String get positionTitleLabel => '職種・ポジション *';
  @override
  String get positionTitleHint => '例: シニア Flutter エンジニア';
  @override
  String get positionTitleRequired => '職種・ポジションを入力してください';
  @override
  String get locationLabel => '勤務地 / 本社所在地';
  @override
  String get locationHint => '例: 東京都港区, フルリモート';
  @override
  String get workTypeAndSystemSection => '雇用形態 & 勤務スタイル';
  @override
  String get employmentTypeLabel => '雇用形態';
  @override
  String get workSystemLabel => '勤務スタイル';
  @override
  String get jobPortalSection => '求人媒体 / 応募経路';
  @override
  String get otherPortalHint => '媒体名や紹介経路を入力';
  @override
  String get jobUrlSection => '求人URLリンク';
  @override
  String get jobUrlHint => 'https://linkedin.com/jobs/...';
  @override
  String get currentStatusSection => '現在のステータス';
  @override
  String get appliedDateLabel => '応募日';
  @override
  String get salarySection => '給与条件・オファー';
  @override
  String get salaryExpectationHint => '例: 6,000,000 (希望額)';
  @override
  String get salaryOfferedHint => '例: 6,500,000 (提示額)';
  @override
  String get notesSection => 'メモ・特記事項';
  @override
  String get notesHint => '応募条件、紹介者の連絡先、アピールポイントなど...';
  @override
  String get saveApplicationButton => '応募を保存';
  @override
  String get updateApplicationButton => '変更を保存';

  // Dashboard / Analytics Screen
  @override
  String get analyticsTitle => 'キャリア分析';
  @override
  String get pipelineFunnel => '選考ファネル';
  @override
  String get systemsAndPortals => '勤務形態 & 応募媒体';
  @override
  String get successRateTitle => '応募通過率・内定率';
  @override
  String get interviewCallsRate => '面接通過率';
  @override
  String get hiredRate => '内定獲得率';
  @override
  String get topPortals => '効果的な求人媒体';
  @override
  String get monthlyApplications => '月別応募推移';
  @override
  String get responseRate => '面接転換率';
  @override
  String get offerRate => 'オファー獲得率';
  @override
  String get totalApplicationsMetric => '総応募件数';
  @override
  String get interviewStageMetric => '面接ステップ';
  @override
  String get offeringMetric => '内定オファー';
  @override
  String get hiredMetric => '承諾・就職';
  @override
  String get statusDistribution => '選考状況の内訳';
  @override
  String get workSystemDistribution => '勤務形態の内訳';
  @override
  String get noWorkSystemData => '勤務形態データがありません';
  @override
  String get portalSources => '求人媒体の内訳';
  @override
  String get noPortalData => '求人媒体データがありません';
  @override
  String get noAnalyticsDataTitle => '分析データがありません';
  @override
  String get noAnalyticsDataMessage => '応募を記録すると、通過率や媒体別の効果分析が自動でグラフ化されます。';

  // Schedule Screen
  @override
  String get scheduleTitle => '日程 & スケジュール';
  @override
  String get searchScheduleHint => '企業、職種、面接段階を検索...';
  @override
  String get upcomingTab => '今後の予定';
  @override
  String get allAgendaTab => '全スケジュール';
  @override
  String get noScheduleTitle => '予定がありません';
  @override
  String get noScheduleMessage => '選考ステップや期限が設定されていません。ステップを追加すると自動で反映されます。';
  @override
  String get refreshSchedule => '更新';
  @override
  String get noScheduleFoundTitle => '予定が見つかりません';
  @override
  String noScheduleFoundMessage(String query) => '「$query」に該当するスケジュールはありません。';
  @override
  String get resetSearch => '検索リセット';
  @override
  String get noUpcomingScheduleTitle => '直近の予定はありません';
  @override
  String get noUpcomingScheduleMessage => 'すべての予定が完了しているか、新しい予定が未設定です。';
  @override
  String get noPastScheduleMessage => '過去の面接履歴はありません。';
  @override
  String get sectionOverdue => '期限超過・要確認';
  @override
  String get sectionOverdueSubtitle => '更新・対応が必要な項目';
  @override
  String get sectionToday => '本日';
  @override
  String get sectionTodaySubtitle => '本日予定されているスケジュール';
  @override
  String get sectionThisWeek => '今週';
  @override
  String get sectionThisWeekSubtitle => '今後7日以内のスケジュール';
  @override
  String get sectionUpcoming => '来週以降';
  @override
  String get sectionUpcomingSubtitle => '8日以降のスケジュール';
  @override
  String get sectionHistory => '完了履歴';
  @override
  String get sectionHistorySubtitle => '過去の選考記録';
  @override
  String get interviewerPrefix => '面接官: ';
  @override
  String get openMeetingRoom => 'ミーティングに参加';

  // Profile & Settings Screen
  @override
  String get profileTitle => 'プロフィール & 設定';
  @override
  String get accountSection => 'アカウント';
  @override
  String get preferencesSection => 'アプリ設定';
  @override
  String get dataSection => 'データ & バックアップ';
  @override
  String get aboutSection => 'AppliQ について';
  @override
  String get themeSetting => 'テーマ設定';
  @override
  String get accentSetting => 'アクセントカラー';
  @override
  String get languageSetting => '言語設定 (Language)';
  @override
  String get notificationsSetting => '通知 & リマインダー';
  @override
  String get exportDataSetting => 'データ出力 (Excel / CSV / PDF)';
  @override
  String get googleDriveSetting => 'Google ドライブ連携';
  @override
  String get connected => '連携済み';
  @override
  String get disconnected => '未連携';
  @override
  String get disconnectDriveConfirm => 'Google ドライブ連携を解除しますか？';
  @override
  String get disconnectDriveMessage => 'いつでも再連携して書類を管理できます。';
  @override
  String get logoutButton => 'ログアウト';
  @override
  String get logoutConfirmTitle => 'AppliQ からサインアウトしますか？';
  @override
  String get logoutConfirmMessage => 'データはクラウドに安全に保存されており、次回ログイン時に復元されます。';
  @override
  String get appVersion => 'アプリバージョン';

  // Edit Profile Screen
  @override
  String get editProfileTitle => 'プロフィール編集';
  @override
  String get googleEmailLabel => 'Googleアカウントのメール';
  @override
  String get googleEmailDesc => 'メールアドレスはGoogle認証から自動連携されています。';
  @override
  String get fullNameLabel => '氏名';
  @override
  String get fullNameHint => '氏名を入力';
  @override
  String get fullNameEmptyError => '氏名を入力してください';
  @override
  String get usernameLabel => 'ユーザー名';
  @override
  String get phoneLabel => '電話番号 / WhatsApp';
  @override
  String get targetRoleLabel => '志望職種・目標ポジション';
  @override
  String get targetRoleHint => '例: シニア Flutter エンジニア / UIデザイナー';
  @override
  String get saveChangesButton => '変更を保存';
  @override
  String get deleteAccountButton => 'アカウント削除';
  @override
  String get deleteAccountConfirmTitle => 'アカウントを完全に削除しますか？';
  @override
  String get deleteAccountConfirmMessage => '応募履歴、面接ログ、メモなどすべてのデータが完全に削除されます。この操作は取り消せません。';
  @override
  String get profileUpdatedSuccess => 'プロフィールを更新しました！';
  @override
  String get accountDeletedSuccess => 'アカウントを削除しました';

  // Notification Sheet
  @override
  String get notificationCenterTitle => '通知センター';
  @override
  String get noUrgentReminders => '緊急のリマインダーはありません';
  @override
  String activeRemindersCount(int count) => '$count 件のアクティブなリマインダー';
  @override
  String get pushNotificationTestTitle => 'プッシュ通知テスト';
  @override
  String get pushNotificationTestDesc => '端末のステータスバー通知をテストします。';
  @override
  String get testNotificationButton => 'テスト送信';
  @override
  String get testNotificationSentToast => 'テスト通知を端末に送信しました！';
  @override
  String get interviewAgendaSection => '面接 & 選考日程';
  @override
  String get followUpNeededSection => 'フォローアップ推奨 (7日以上経過)';
  @override
  String appliedDaysAgo(int days) => '$days 日前に応募';
  @override
  String get emailHrButton => '担当者に連絡';
  @override
  String get allSchedulesSafeTitle => 'すべての予定は順調です';
  @override
  String get allSchedulesSafeDesc => '緊急の面接や未対応のフォローアップはありません。';

  // HR Templates Sheet
  @override
  String get hrTemplatesSheetTitle => '採用担当向けメールテンプレート';
  @override
  String get hrTemplatesSheetSubtitle => 'コピーしてすぐ使えるビジネス定型文';
  @override
  String get categoryAll => 'すべて';
  @override
  String get categoryFollowUp => '状況確認';
  @override
  String get categoryInterview => '面接調整';
  @override
  String get categoryOffering => '内定・条件面談';
  @override
  String get copySubjectButton => '件名をコピー';
  @override
  String get copyBodyButton => '本文をコピー';
  @override
  String copiedToast(String label) => '$label をクリップボードにコピーしました！';

  // Language Modal
  @override
  String get languageModalTitle => '言語を選択 (Language)';
  @override
  String get languageModalSubtitle => 'アプリの表示言語を選択してください';
  @override
  String get languageIdName => 'Bahasa Indonesia';
  @override
  String get languageIdSubtitle => 'インドネシア語 (Bahasa Indonesia)';
  @override
  String get languageEnName => 'English';
  @override
  String get languageEnSubtitle => '英語 (English)';
  @override
  String get languageJaName => '日本語';
  @override
  String get languageJaSubtitle => '日本語 (Japanese)';
  @override
  String get languageKoName => '한국어';
  @override
  String get languageKoSubtitle => '韓国語 (Korean)';
  @override
  String get languageComingSoonToast => 'この言語は次回のアップデートで利用可能になります！';

  // Export Sheet
  @override
  String get exportSheetTitle => '応募データのエクスポート';
  @override
  String get exportSheetSubtitle => '希望の形式で就職活動レポートをダウンロード';
  @override
  String get exportFormat => 'ファイル形式';
  @override
  String get exportDateRange => '対象期間';
  @override
  String get exportAllTime => '全期間';
  @override
  String get exportThisMonth => '今月';
  @override
  String get exportLast3Months => '直近3ヶ月';
  @override
  String get exportThisYear => '今年';
  @override
  String get exportButton => 'エクスポートして共有';
  @override
  String get exportSuccess => 'データをエクスポートしました！';
  @override
  String get exportEmpty => '出力対象のデータがありません。';

  // Toasts & Snackbars
  @override
  String get errorOccurred => 'エラーが発生しました。もう一度お試しください。';
  @override
  String get successSaved => '応募を保存しました。';
  @override
  String get successUpdated => '応募情報を更新しました。';
  @override
  String get successDeleted => '応募を削除しました。';
  @override
  String get fileUploadedDrive => 'Google ドライブにアップロードしました。';
  @override
  String get fileDeletedDrive => 'Google ドライブからファイルを削除しました。';
  @override
  String get attachmentDetached => 'ファイルの添付を解除しました。';
  @override
  String get fillRequiredFields => '企業名と職種を入力してください。';

  // Login Screen
  @override
  String get loginTagline => '就職活動のあらゆるステップを\nリアルタイムでスマートに追跡・管理。';
  @override
  String get signInWithGoogle => 'Google でログイン';
  @override
  String get termsPrefix => 'ログインすることで、AppliQ の ';
  @override
  String get termsOfService => '利用規約';
  @override
  String get andConjunction => ' および ';
  @override
  String get privacyPolicy => 'プライバシーポリシー';
  @override
  String get termsContent => 'AppliQ をご利用いただくにあたり、就職活動の適切な管理目的で利用することに同意するものとします。お客様のデータは業界標準の暗号化プロトコルにより安全に保管されます。';
  @override
  String get privacyContent => 'AppliQ はお客様のプライバシーを最優先に保護します。応募履歴や個人情報はアカウント保持者のみが閲覧可能であり、事前の同意なく第三者に提供されることはありません。';
  @override
  String welcomeUser(String name) => 'ようこそ、$name さん！';

  // Enums & Dynamic Values
  @override
  String localizedEmploymentType(EmploymentType type) {
    switch (type) {
      case EmploymentType.fullTime:
        return '正社員';
      case EmploymentType.internship:
        return 'インターン';
      case EmploymentType.contract:
        return '契約社員';
      case EmploymentType.partTime:
        return 'パート・アルバイト';
      case EmploymentType.freelance:
        return '業務委託・フリーランス';
    }
  }

  @override
  String localizedWorkSystem(WorkSystem system) {
    switch (system) {
      case WorkSystem.onSite:
        return '出社 (オンサイト)';
      case WorkSystem.hybrid:
        return 'ハイブリッド';
      case WorkSystem.wfh:
        return 'フルリモート (在宅勤務)';
      case WorkSystem.remoteOverseas:
        return '海外リモート';
      case WorkSystem.flexible:
        return 'フレックス';
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
        return 'リファラル・知人紹介';
      case JobPortal.directEmail:
        return '企業直接連絡・スカウト';
      case JobPortal.kitaLulus:
        return 'KitaLulus';
      case JobPortal.jobFair:
        return '就職フェア・学内説明会';
      case JobPortal.website:
        return '企業採用サイト';
      case JobPortal.instagram:
        return 'SNS・ソーシャルメディア';
      case JobPortal.komunitas:
        return 'コミュニティ・勉強会';
      case JobPortal.freelance:
        return 'クラウドソーシング';
      case JobPortal.lainnya:
        return 'その他';
    }
  }

  @override
  String localizedStatus(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.applied:
        return '応募済み';
      case ApplicationStatus.interview:
        return '面接中';
      case ApplicationStatus.offering:
        return '内定・オファー';
      case ApplicationStatus.accepted:
        return '内定承諾';
      case ApplicationStatus.rejected:
        return '不通過';
      case ApplicationStatus.noResponse:
        return '未返信';
    }
  }

  @override
  String localizedResult(String result) {
    switch (result.trim().toLowerCase()) {
      case 'lolos':
      case 'selesai':
      case 'passed':
      case 'done':
      case '合格':
      case '通過':
        return '合格';
      case 'diterima':
      case 'offering':
      case 'accepted':
      case '内定':
        return '内定';
      case 'gagal':
      case 'ditolak':
      case 'failed':
      case 'rejected':
      case 'tidak lolos':
      case '不合格':
      case 'お見送り':
        return '不通過';
      case 'waiting':
      case 'menunggu':
      case '選考中':
      case '結果待ち':
      default:
        return '結果待ち';
    }
  }
}
