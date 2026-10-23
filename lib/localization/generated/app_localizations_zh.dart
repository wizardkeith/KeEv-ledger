// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'KeEv 記帳';

  @override
  String get home => '首頁';

  @override
  String get history => '紀錄';

  @override
  String get add => '新增';

  @override
  String get budget => '預算';

  @override
  String get more => '更多';

  @override
  String get accounts => '戶口';

  @override
  String get projects => '項目／標籤';

  @override
  String get reports => '報告';

  @override
  String get settings => '設定';

  @override
  String get language => '語言';

  @override
  String get appearance => '外觀';

  @override
  String get backup => '備份／還原';

  @override
  String get authentication => 'KeEv 帳戶';

  @override
  String get premium => 'Premium';

  @override
  String get welcome => '每天收支，一目了然';

  @override
  String get intro => '輕鬆記帳，按自己的步伐開始。';

  @override
  String get preview => '部分功能仍在開發中。';

  @override
  String get emptyTitle => '你的空間已準備好';

  @override
  String get emptyBody => '此功能正在準備中，沒有顯示模擬財務資料。';

  @override
  String get addUnavailable => '快速新增功能將於第 2 階段加入。此預覽版未能儲存交易。';

  @override
  String get languageIntro => '選擇語言。稍後可在設定更改。';

  @override
  String get continueLabel => '繼續';

  @override
  String get privacyIntro => '毋須建立帳戶，即可在此裝置開始。此預覽版沒有 KeEv 雲端、廣告或分析服務。';

  @override
  String get privacyPolicy => '私隱政策';

  @override
  String get terms => '使用條款';

  @override
  String get developmentLegal =>
      '開發用內容 — 此處為佔位內容，並非最終私隱政策或使用條款。正式推出前，會按實際服務審閱最終文字。';

  @override
  String get acceptPreview => '我明白這是開發預覽版。';

  @override
  String get startLocal => '以本機模式開始';

  @override
  String get back => '返回';

  @override
  String get close => '關閉';

  @override
  String get systemTheme => '跟隨系統';

  @override
  String get lightTheme => '淺色';

  @override
  String get darkTheme => '深色';

  @override
  String get followSystem => '跟隨裝置語言';

  @override
  String get localMode => '只儲存在此裝置';

  @override
  String get sessionNotice => '語言、外觀及引導選項只會在本次使用期間保留。';

  @override
  String get errorTitle => '發生問題';

  @override
  String get preferencesError => '未能更新你的偏好設定，請再試一次。';

  @override
  String get loading => '載入中';

  @override
  String phaseLabel(int phase) {
    return '第 $phase 階段預覽';
  }

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHongKong => '繁體中文（香港）';

  @override
  String get languageChinese => '简体中文';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageThai => 'ไทย';

  @override
  String get quickAdd => '快速新增';

  @override
  String get expense => '支出';

  @override
  String get income => '收入';

  @override
  String get transfer => '轉帳';

  @override
  String get amount => '金額';

  @override
  String get sentAmount => '轉出金額';

  @override
  String get receivedAmount => '轉入金額';

  @override
  String get account => '戶口';

  @override
  String get sourceAccount => '轉出戶口';

  @override
  String get destinationAccount => '轉入戶口';

  @override
  String get category => '分類';

  @override
  String get businessDate => '日期';

  @override
  String get noteOptional => '備註（可選）';

  @override
  String get save => '儲存';

  @override
  String get savedLocally => '已儲存在此裝置';

  @override
  String get saveFailed => '未能儲存，請再試。';

  @override
  String get invalidMoney => '請輸入大於零的金額，並使用正確的小數位。';

  @override
  String get chooseAccount => '選擇戶口';

  @override
  String get chooseCategory => '選擇分類';

  @override
  String get chooseOtherAccount => '選擇另一個轉入戶口';

  @override
  String get addAccount => '新增戶口';

  @override
  String get addCategory => '新增分類';

  @override
  String get name => '名稱';

  @override
  String get accountType => '戶口類型';

  @override
  String get currency => '貨幣';

  @override
  String get create => '建立';

  @override
  String get firstAccount => '先新增一個戶口。';

  @override
  String get secondAccount => '轉帳需要多一個戶口。';

  @override
  String get categoryNeeded => '請新增此類型的分類。';

  @override
  String get noHistory => '暫無交易紀錄。';

  @override
  String get cash => '現金';

  @override
  String get bank => '銀行';

  @override
  String get creditCard => '信用卡';

  @override
  String get eWallet => '電子錢包';

  @override
  String get other => '其他';

  @override
  String get receivedRequired => '不同貨幣的轉帳必須填寫轉入金額。';

  @override
  String get differentAccounts => '轉出及轉入戶口不可相同。';

  @override
  String get archivedEntity => '戶口或分類已封存。';

  @override
  String get mismatchEntity => '貨幣或分類類型不相符。';

  @override
  String get beforeOpening => '日期不可早於兩個戶口的開戶日期。';

  @override
  String get addBudget => '新增預算';

  @override
  String get budgetName => '預算名稱';

  @override
  String get budgetAmount => '預算金額';

  @override
  String get budgetMonth => '月份（YYYY-MM）';

  @override
  String get budgetCategory => '支出分類（可選）';

  @override
  String get allExpenses => '所有支出';

  @override
  String warningAt(int percent) {
    return '達 $percent% 時提醒';
  }

  @override
  String get spent => '已使用';

  @override
  String get remaining => '尚餘';

  @override
  String get overBudget => '超出預算';

  @override
  String missingFx(String currencies) {
    return '計算未完整 · 欠缺以下貨幣匯率：$currencies';
  }

  @override
  String get noBudgets => '本月尚未有預算。';

  @override
  String get archive => '封存';

  @override
  String get edit => '編輯';

  @override
  String get project => '項目';

  @override
  String get noProject => '不屬於項目';

  @override
  String get addProject => '新增項目';

  @override
  String get projectName => '項目名稱';

  @override
  String get projectDescription => '描述（可選）';

  @override
  String get noProjects => '尚未有進行中的項目。';

  @override
  String get incomeTotal => '收入';

  @override
  String get expenseTotal => '支出';

  @override
  String get netTotal => '淨額';

  @override
  String get projectArchived => '此項目已封存。';

  @override
  String get invalidMonth => '請以 YYYY-MM 輸入有效月份。';

  @override
  String get incomeExpenseReport => '收入與支出報告';

  @override
  String get assetsLiabilitiesOverview => '資產與負債概覽';

  @override
  String get reportPeriod => '報告期間';

  @override
  String get previousPeriod => '上一期間';

  @override
  String get reportComplete => '計算完整';

  @override
  String get reportIncomplete => '計算未完整';

  @override
  String get categoryBreakdown => '類別明細';

  @override
  String get accountBreakdown => '帳戶明細';

  @override
  String get dailyTrend => '每日趨勢';

  @override
  String asOf(String date) {
    return '截至 $date';
  }

  @override
  String get assetsLabel => '資產';

  @override
  String get liabilitiesLabel => '負債';

  @override
  String get reportingCurrency => '報告貨幣';

  @override
  String get prepareCsv => '準備 CSV';

  @override
  String get csvReady => 'CSV 已在本機準備';

  @override
  String get comparisonUnavailable => '沒有具意義的上一期間百分比';

  @override
  String changeFromPrevious(String percent) {
    return '較上一期間 $percent%';
  }

  @override
  String get reportDisclaimer => '個人記帳概覽，並非專業財務報表。';

  @override
  String get allTransactions => '全部';

  @override
  String get searchNotes => '搜尋備註';

  @override
  String get applyFilter => '套用';

  @override
  String get noReportData => '此期間沒有活動。';

  @override
  String get receiptsOptional => '收據相片（選填）';

  @override
  String get receiptPrivacyNote => '只儲存於此裝置，最多 5 張相片。';

  @override
  String get takePhoto => '拍攝相片';

  @override
  String get choosePhoto => '從相片圖庫選擇';

  @override
  String get receiptPhoto => '收據相片';

  @override
  String get removeReceipt => '移除收據';

  @override
  String get viewReceipt => '查看收據';

  @override
  String get receiptLimitReached => '每項交易最多可附加 5 張收據相片。';

  @override
  String get receiptInvalid => '這不是支援的收據圖片。';

  @override
  String get receiptTooLarge => '圖片太大，無法安全處理。';

  @override
  String get receiptPermissionDenied => '未獲相機或相片存取權限；你可前往「設定」啟用。';

  @override
  String get voiceEntry => '語音輸入';

  @override
  String get listening => '正在聆聽…';

  @override
  String get stopListening => '停止';

  @override
  String get cancelVoice => '取消';

  @override
  String get processingSpeech => '正在處理語音…';

  @override
  String get reviewVoiceDraft => '語音只會建議草稿欄位，儲存前請先核對。';

  @override
  String get voicePermissionDenied => '未獲咪高峰或語音辨識權限。你可繼續手動輸入，或前往「設定」啟用。';

  @override
  String get voiceLocaleUnavailable => '此裝置沒有合適的香港粵語辨識服務，請手動輸入。';

  @override
  String get voiceUnavailable => '語音辨識目前無法使用，請手動輸入。';

  @override
  String get voiceRecognitionFailed => '語音辨識失敗；現有草稿已保留。';

  @override
  String get voicePrivacyDisclosure =>
      '裝置的語音服務可能會在網上處理音訊。KeEv 不會儲存音訊，亦不會傳送至 AI 或分析服務。';

  @override
  String get appLock => '應用程式鎖';

  @override
  String get appLocked => 'KeEv Ledger 已鎖定';

  @override
  String get appLockDescription => '以 PIN 及選用的系統生物辨識保護此裝置上的本機記帳資料。';

  @override
  String get appLockEnabled => '應用程式鎖已啟用';

  @override
  String get setPin => '設定 PIN';

  @override
  String get confirmPin => '確認 PIN';

  @override
  String get currentPin => '目前 PIN';

  @override
  String get newPin => '新 PIN';

  @override
  String get enterPin => '輸入 PIN';

  @override
  String get pinRequirements => '請輸入 4 至 6 位數字 PIN。';

  @override
  String get pinMismatch => '兩次輸入的 PIN 不一致。';

  @override
  String get incorrectPin => 'PIN 不正確。';

  @override
  String get tryAgainLater => '嘗試次數過多，請稍後再試。';

  @override
  String get useBiometrics => '使用生物辨識';

  @override
  String get biometricUnavailable => '系統生物辨識無法使用或尚未設定。';

  @override
  String get biometricCancelled => '已取消生物辨識。';

  @override
  String get biometricLocked => '系統生物辨識已鎖定，請使用 KeEv PIN。';

  @override
  String get biometricFailed => '生物辨識失敗，請使用 PIN。';

  @override
  String get biometricPromptReason => '解鎖本機 KeEv Ledger';

  @override
  String get biometricSystemDescription => '使用此裝置已設定的生物辨識方式。';

  @override
  String get unlock => '解鎖';

  @override
  String get lockNow => '立即鎖定';

  @override
  String get changePin => '更改 PIN';

  @override
  String get disableAppLock => '停用應用程式鎖';

  @override
  String get authenticationRequired => '請輸入目前 PIN 以繼續。';

  @override
  String get authenticationCancelled => '認證已取消，請再試。';

  @override
  String get lockConfigurationError => '無法安全讀取應用程式鎖設定，因此未有開放存取。';

  @override
  String get forgotPinGuidance =>
      '本機模式不設網上 PIN 復原。KeEv 無法繞過 PIN，亦不會自動刪除你的記帳資料。';

  @override
  String get relockPolicy => '應用程式進入背景時會鎖定。';

  @override
  String get privacyCover => 'KeEv Ledger 非使用中時會隱藏財務資料。';

  @override
  String get cloudAccount => '雲端帳戶';

  @override
  String get localOnlyModeTitle => '只儲存於本機';

  @override
  String get localOnlyDataNotice => '你的記帳資料目前只保留在此裝置，毋須帳戶或網絡連線。';

  @override
  String get cloudAccountConnected => '此裝置已有已認證的 KeEv 雲端工作階段。';

  @override
  String get cloudOptionalDescription => '日後的雲端備份可選擇使用 KeEv 帳戶；沒有帳戶亦可繼續在本機記帳。';

  @override
  String get cloudAccountOptions => '查看可選雲端帳戶';

  @override
  String get signInWithApple => '使用 Apple 登入';

  @override
  String get signInWithGoogle => '使用 Google 登入';

  @override
  String get signInWithEmail => '使用電郵繼續';

  @override
  String get signOut => '登出';

  @override
  String get cloudUnavailableDevelopment => '此版本尚未啟用雲端登入及備份，不會上載任何資料。';

  @override
  String get continueLocalOnly => '繼續只使用本機';

  @override
  String get cloudAccountError => '雲端帳戶服務未能完成此要求。';

  @override
  String get cloudSignedOut => '已登出';

  @override
  String get cloudAuthenticating => '正在登入…';

  @override
  String get cloudReauthenticationRequired => '請重新登入以繼續使用雲端帳戶功能。';

  @override
  String get cloudTemporarilyUnavailable => '雲端服務暫時無法使用；安全工作階段已保留。';

  @override
  String get cloudConfigurationUnavailable => '此版本未設定雲端登入；你仍可只使用本機。';

  @override
  String get cloudBackupNotActive => '雲端備份尚未啟用。登入不會上載你的記帳資料。';

  @override
  String get emailAddress => '電郵地址';

  @override
  String get sendOtp => '傳送驗證碼';

  @override
  String get otpCode => '6 位數驗證碼';

  @override
  String get verifyOtp => '驗證';

  @override
  String get resendOtp => '重新傳送';

  @override
  String get otpSent => '登入驗證碼已傳送，請查看電郵。';

  @override
  String get invalidOtp => '驗證碼不正確。';

  @override
  String get expiredOtp => '驗證碼已過期，請索取新的驗證碼。';

  @override
  String get authRateLimited => '要求次數過多，請稍後再試。';

  @override
  String get cloudNetworkUnavailable => '沒有網絡連線；已儲存的雲端工作階段已保留。';

  @override
  String get appLockCloudSeparation => '應用程式鎖只保護此裝置；其 PIN 及生物認證並非 KeEv 雲端登入憑證。';

  @override
  String get backupStatus => '備份狀態';

  @override
  String get localBackup => '本機備份';

  @override
  String get cloudBackup => '雲端備份';

  @override
  String get createEncryptedBackup => '建立加密備份';

  @override
  String get restoreFromBackupFile => '從備份檔案還原';

  @override
  String get backupPassphrase => '備份密碼';

  @override
  String get confirmBackupPassphrase => '確認備份密碼';

  @override
  String get backupPassphraseHelp => '請使用最少 10 個字元。KeEv 無法復原遺失的備份密碼。';

  @override
  String get backupSecurityInfo => '備份會先在此裝置加密，才匯出或上載。';

  @override
  String get backupCreated => '已建立加密備份。';

  @override
  String get backupFailed => '未能建立備份。';

  @override
  String get restorePreview => '還原預覽';

  @override
  String get restoreReplaceWarning => '此操作會取代現有全部本機記帳資料，不會合併紀錄。';

  @override
  String get restoreConfirm => '取代並還原';

  @override
  String get restoreCompleted => '備份已還原。';

  @override
  String get restoreFailedMessage => '未能還原備份。';

  @override
  String get wrongBackupPassphrase => '密碼不正確，或備份已被更改。';

  @override
  String get corruptedBackup => '此備份無效、已損壞或版本不受支援。';

  @override
  String get cloudSignInRequired => '登入後可使用自選雲端備份；本機備份仍然可用。';

  @override
  String get noCloudBackups => '尚無雲端備份。';

  @override
  String get deleteBackup => '刪除備份';

  @override
  String get backupCreatedAt => '建立時間';

  @override
  String get backupFormatVersion => '備份格式';

  @override
  String get backupSourceApp => '來源應用程式';

  @override
  String get backupBaseCurrency => '基準貨幣';

  @override
  String get encryptedBackupSize => '加密檔案大小';

  @override
  String get deleteCloudBackupConfirmation => '永久刪除此雲端備份？你的本機記帳資料不會被刪除。';

  @override
  String get syncTitle => '即時同步';

  @override
  String get syncEnable => '啟用同步';

  @override
  String get syncDescription =>
      '讓多部裝置的帳簿保持一致。即時同步會把可讀取的帳簿紀錄儲存在你的 KeEv 雲端帳戶，與加密備份分開。';

  @override
  String get syncNow => '立即同步';

  @override
  String get syncPause => '暫停同步';

  @override
  String get syncResume => '繼續同步';

  @override
  String get syncDisable => '取消連結此裝置';

  @override
  String get syncLocalData => '本機資料';

  @override
  String get syncCloudData => '雲端資料';

  @override
  String get syncKeepLocal => '保留本機';

  @override
  String get syncKeepCloud => '保留雲端';

  @override
  String get syncCancel => '取消';

  @override
  String get syncNeedsReconciliation => '需要核對';

  @override
  String get syncConflicts => '有衝突需要處理';

  @override
  String get syncActive => '同步已啟用';

  @override
  String get syncPaused => '同步已暫停';

  @override
  String get syncUpToDate => '已是最新';

  @override
  String get syncOffline => '暫時無法使用';

  @override
  String get syncAuthRequired => '需要登入驗證';

  @override
  String get syncPendingChanges => '待同步變更';

  @override
  String get syncLastSynced => '上次同步';

  @override
  String get syncChecking => '正在檢查本機及雲端資料…';

  @override
  String get syncInitializing => '正在準備帳簿…';

  @override
  String get syncUploading => '正在上載及驗證本機資料…';

  @override
  String get syncDownloading => '正在下載雲端資料…';

  @override
  String get syncVerifying => '正在驗證完整帳簿…';

  @override
  String get syncFinalizing => '正在完成同步…';

  @override
  String get syncDestructiveWarning => '此選擇會取代其中一份帳簿。如日後可能需要復原，請先建立加密備份。';

  @override
  String get syncUnlinkWarning => '本機及雲端帳簿會保留。此裝置之後的變更只會留在本機，待同步變更亦不會傳送。';

  @override
  String get syncConflictsTitle => '處理衝突';

  @override
  String get syncLocalDelete => '已在此裝置刪除';

  @override
  String get syncCloudDelete => '已在雲端刪除';

  @override
  String get syncNoAutomaticMerge => '本機及雲端都有資料。請選擇作為起點的帳簿；KeEv 不會自動合併。';

  @override
  String get privacyAdvertising => '隐私与广告';

  @override
  String get privacyAdvertisingSummary => '管理广告隐私选择';

  @override
  String get advertisingPreferences => '广告偏好';

  @override
  String get advertisingPrivacyExplanation =>
      '广告与账本相互独立。KeEv 不会向广告服务发送余额、交易、备注、收据或其他财务内容。';

  @override
  String get managePrivacyChoices => '管理隐私选择';

  @override
  String get advertisement => '广告';
}

/// The translations for Chinese, as used in China (`zh_CN`).
class AppLocalizationsZhCn extends AppLocalizationsZh {
  AppLocalizationsZhCn() : super('zh_CN');

  @override
  String get appTitle => 'KeEv 记账';

  @override
  String get home => '首页';

  @override
  String get history => '记录';

  @override
  String get add => '新增';

  @override
  String get budget => '预算';

  @override
  String get more => '更多';

  @override
  String get accounts => '资金账户';

  @override
  String get projects => '项目／标签';

  @override
  String get reports => '报告';

  @override
  String get settings => '设置';

  @override
  String get language => '语言';

  @override
  String get appearance => '外观';

  @override
  String get backup => '备份／恢复';

  @override
  String get authentication => 'KeEv 账号';

  @override
  String get premium => 'Premium';

  @override
  String get welcome => '每天收支，一目了然';

  @override
  String get intro => '轻松记账，按自己的节奏开始。';

  @override
  String get preview => '部分功能仍在开发中。';

  @override
  String get emptyTitle => '你的空间已准备好';

  @override
  String get emptyBody => '此功能正在准备中，没有显示模拟财务数据。';

  @override
  String get addUnavailable => '快速新增功能将在第 2 阶段加入。此预览版无法保存交易。';

  @override
  String get languageIntro => '选择语言。稍后可在设置中更改。';

  @override
  String get continueLabel => '继续';

  @override
  String get privacyIntro => '无需创建账号，即可在此设备开始。此预览版没有 KeEv 云端、广告或分析服务。';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get terms => '使用条款';

  @override
  String get developmentLegal =>
      '开发内容 — 此处为占位内容，并非最终隐私政策或使用条款。正式发布前，将根据实际服务审核最终文字。';

  @override
  String get acceptPreview => '我了解这是开发预览版。';

  @override
  String get startLocal => '以本地模式开始';

  @override
  String get back => '返回';

  @override
  String get close => '关闭';

  @override
  String get systemTheme => '跟随系统';

  @override
  String get lightTheme => '浅色';

  @override
  String get darkTheme => '深色';

  @override
  String get followSystem => '跟随设备语言';

  @override
  String get localMode => '仅保存在此设备';

  @override
  String get sessionNotice => '语言、外观及引导选项仅在本次使用期间保留。';

  @override
  String get errorTitle => '出现问题';

  @override
  String get preferencesError => '无法更新你的偏好设置，请重试。';

  @override
  String get loading => '加载中';

  @override
  String phaseLabel(int phase) {
    return '第 $phase 阶段预览';
  }

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHongKong => '繁體中文（香港）';

  @override
  String get languageChinese => '简体中文';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageThai => 'ไทย';

  @override
  String get quickAdd => '快速添加';

  @override
  String get expense => '支出';

  @override
  String get income => '收入';

  @override
  String get transfer => '转账';

  @override
  String get amount => '金额';

  @override
  String get sentAmount => '转出金额';

  @override
  String get receivedAmount => '转入金额';

  @override
  String get account => '账户';

  @override
  String get sourceAccount => '转出账户';

  @override
  String get destinationAccount => '转入账户';

  @override
  String get category => '分类';

  @override
  String get businessDate => '日期';

  @override
  String get noteOptional => '备注（可选）';

  @override
  String get save => '保存';

  @override
  String get savedLocally => '已保存到此设备';

  @override
  String get saveFailed => '保存失败，请重试。';

  @override
  String get invalidMoney => '请输入大于零的金额，并使用正确的小数位。';

  @override
  String get chooseAccount => '选择账户';

  @override
  String get chooseCategory => '选择分类';

  @override
  String get chooseOtherAccount => '选择另一个转入账户';

  @override
  String get addAccount => '添加账户';

  @override
  String get addCategory => '添加分类';

  @override
  String get name => '名称';

  @override
  String get accountType => '账户类型';

  @override
  String get currency => '货币';

  @override
  String get create => '创建';

  @override
  String get firstAccount => '请先添加账户。';

  @override
  String get secondAccount => '转账需要另一个账户。';

  @override
  String get categoryNeeded => '请添加此类型的分类。';

  @override
  String get noHistory => '暂无交易记录。';

  @override
  String get cash => '现金';

  @override
  String get bank => '银行';

  @override
  String get creditCard => '信用卡';

  @override
  String get eWallet => '电子钱包';

  @override
  String get other => '其他';

  @override
  String get receivedRequired => '跨币种转账必须填写转入金额。';

  @override
  String get differentAccounts => '转出与转入账户不能相同。';

  @override
  String get archivedEntity => '账户或分类已归档。';

  @override
  String get mismatchEntity => '货币或分类类型不匹配。';

  @override
  String get beforeOpening => '日期不能早于两个账户的开户日期。';

  @override
  String get addBudget => '添加预算';

  @override
  String get budgetName => '预算名称';

  @override
  String get budgetAmount => '预算金额';

  @override
  String get budgetMonth => '月份（YYYY-MM）';

  @override
  String get budgetCategory => '支出分类（可选）';

  @override
  String get allExpenses => '所有支出';

  @override
  String warningAt(int percent) {
    return '达到 $percent% 时提醒';
  }

  @override
  String get spent => '已使用';

  @override
  String get remaining => '剩余';

  @override
  String get overBudget => '超出预算';

  @override
  String missingFx(String currencies) {
    return '计算不完整 · 缺少以下货币汇率：$currencies';
  }

  @override
  String get noBudgets => '本月还没有预算。';

  @override
  String get archive => '归档';

  @override
  String get edit => '编辑';

  @override
  String get project => '项目';

  @override
  String get noProject => '无项目';

  @override
  String get addProject => '添加项目';

  @override
  String get projectName => '项目名称';

  @override
  String get projectDescription => '说明（可选）';

  @override
  String get noProjects => '还没有进行中的项目。';

  @override
  String get incomeTotal => '收入';

  @override
  String get expenseTotal => '支出';

  @override
  String get netTotal => '净额';

  @override
  String get projectArchived => '该项目已归档。';

  @override
  String get invalidMonth => '请按 YYYY-MM 输入有效月份。';

  @override
  String get incomeExpenseReport => '收入与支出报告';

  @override
  String get assetsLiabilitiesOverview => '资产与负债概览';

  @override
  String get reportPeriod => '报告期间';

  @override
  String get previousPeriod => '上一期间';

  @override
  String get reportComplete => '计算完整';

  @override
  String get reportIncomplete => '计算不完整';

  @override
  String get categoryBreakdown => '类别明细';

  @override
  String get accountBreakdown => '账户明细';

  @override
  String get dailyTrend => '每日趋势';

  @override
  String asOf(String date) {
    return '截至 $date';
  }

  @override
  String get assetsLabel => '资产';

  @override
  String get liabilitiesLabel => '负债';

  @override
  String get reportingCurrency => '报告货币';

  @override
  String get prepareCsv => '准备 CSV';

  @override
  String get csvReady => 'CSV 已在本地准备';

  @override
  String get comparisonUnavailable => '没有有意义的上一期间百分比';

  @override
  String changeFromPrevious(String percent) {
    return '较上一期间 $percent%';
  }

  @override
  String get reportDisclaimer => '个人记账概览，并非专业财务报表。';

  @override
  String get allTransactions => '全部';

  @override
  String get searchNotes => '搜索备注';

  @override
  String get applyFilter => '应用';

  @override
  String get noReportData => '此期间没有活动。';

  @override
  String get receiptsOptional => '收据照片（选填）';

  @override
  String get receiptPrivacyNote => '仅存储在此设备上，最多 5 张照片。';

  @override
  String get takePhoto => '拍摄照片';

  @override
  String get choosePhoto => '从照片图库选择';

  @override
  String get receiptPhoto => '收据照片';

  @override
  String get removeReceipt => '移除收据';

  @override
  String get viewReceipt => '查看收据';

  @override
  String get receiptLimitReached => '每笔交易最多可附加 5 张收据照片。';

  @override
  String get receiptInvalid => '这不是受支持的收据图片。';

  @override
  String get receiptTooLarge => '图片太大，无法安全处理。';

  @override
  String get receiptPermissionDenied => '未授予相机或照片访问权限；可在“设置”中启用。';

  @override
  String get voiceEntry => '语音输入';

  @override
  String get listening => '正在聆听…';

  @override
  String get stopListening => '停止';

  @override
  String get cancelVoice => '取消';

  @override
  String get processingSpeech => '正在处理语音…';

  @override
  String get reviewVoiceDraft => '语音只会建议草稿字段，保存前请先核对。';

  @override
  String get voicePermissionDenied => '未授予麦克风或语音识别权限。您可继续手动输入，或在“设置”中启用。';

  @override
  String get voiceLocaleUnavailable => '此设备没有合适的简体中文语音识别服务，请手动输入。';

  @override
  String get voiceUnavailable => '语音识别目前不可用，请手动输入。';

  @override
  String get voiceRecognitionFailed => '语音识别失败；现有草稿已保留。';

  @override
  String get voicePrivacyDisclosure =>
      '设备的语音服务可能会在线处理音频。KeEv 不会存储音频，也不会将其发送至 AI 或分析服务。';

  @override
  String get appLock => '应用锁';

  @override
  String get appLocked => 'KeEv Ledger 已锁定';

  @override
  String get appLockDescription => '使用 PIN 和可选的系统生物识别保护此设备上的本地记账数据。';

  @override
  String get appLockEnabled => '应用锁已启用';

  @override
  String get setPin => '设置 PIN';

  @override
  String get confirmPin => '确认 PIN';

  @override
  String get currentPin => '当前 PIN';

  @override
  String get newPin => '新 PIN';

  @override
  String get enterPin => '输入 PIN';

  @override
  String get pinRequirements => '请输入 4 至 6 位数字 PIN。';

  @override
  String get pinMismatch => '两次输入的 PIN 不一致。';

  @override
  String get incorrectPin => 'PIN 不正确。';

  @override
  String get tryAgainLater => '尝试次数过多，请稍后再试。';

  @override
  String get useBiometrics => '使用生物识别';

  @override
  String get biometricUnavailable => '系统生物识别不可用或尚未录入。';

  @override
  String get biometricCancelled => '已取消生物识别。';

  @override
  String get biometricLocked => '系统生物识别已锁定，请使用 KeEv PIN。';

  @override
  String get biometricFailed => '生物识别失败，请使用 PIN。';

  @override
  String get biometricPromptReason => '解锁本地 KeEv Ledger';

  @override
  String get biometricSystemDescription => '使用此设备上已设置的生物识别方式。';

  @override
  String get unlock => '解锁';

  @override
  String get lockNow => '立即锁定';

  @override
  String get changePin => '更改 PIN';

  @override
  String get disableAppLock => '停用应用锁';

  @override
  String get authenticationRequired => '请输入当前 PIN 以继续。';

  @override
  String get authenticationCancelled => '认证已取消，请重试。';

  @override
  String get lockConfigurationError => '无法安全读取应用锁配置，因此未授予访问权限。';

  @override
  String get forgotPinGuidance =>
      '本地模式没有在线 PIN 恢复。KeEv 无法绕过 PIN，也不会自动删除您的记账数据。';

  @override
  String get relockPolicy => '应用进入后台时会锁定。';

  @override
  String get privacyCover => 'KeEv Ledger 非活动时会隐藏财务信息。';

  @override
  String get cloudAccount => '云端账号';

  @override
  String get localOnlyModeTitle => '仅存储在本机';

  @override
  String get localOnlyDataNotice => '您的记账数据目前仅保留在此设备，无需账号或网络连接。';

  @override
  String get cloudAccountConnected => '此设备已有经过认证的 KeEv 云端会话。';

  @override
  String get cloudOptionalDescription => '未来的云端备份可选择使用 KeEv 账号；没有账号也可继续在本机记账。';

  @override
  String get cloudAccountOptions => '查看可选云端账号';

  @override
  String get signInWithApple => '使用 Apple 登录';

  @override
  String get signInWithGoogle => '使用 Google 登录';

  @override
  String get signInWithEmail => '使用电子邮件继续';

  @override
  String get signOut => '退出登录';

  @override
  String get cloudUnavailableDevelopment => '此版本尚未启用云端登录和备份，不会上传任何数据。';

  @override
  String get continueLocalOnly => '继续仅使用本机';

  @override
  String get cloudAccountError => '云端账号服务无法完成此请求。';

  @override
  String get cloudSignedOut => '已退出登录';

  @override
  String get cloudAuthenticating => '正在登录…';

  @override
  String get cloudReauthenticationRequired => '请重新登录以继续使用云端账号功能。';

  @override
  String get cloudTemporarilyUnavailable => '云端服务暂时不可用；安全会话已保留。';

  @override
  String get cloudConfigurationUnavailable => '此版本未配置云端登录；您仍可仅使用本机。';

  @override
  String get cloudBackupNotActive => '云端备份尚未启用。登录不会上传您的记账数据。';

  @override
  String get emailAddress => '电子邮件地址';

  @override
  String get sendOtp => '发送验证码';

  @override
  String get otpCode => '6 位验证码';

  @override
  String get verifyOtp => '验证';

  @override
  String get resendOtp => '重新发送';

  @override
  String get otpSent => '登录验证码已发送，请查看电子邮件。';

  @override
  String get invalidOtp => '验证码无效。';

  @override
  String get expiredOtp => '验证码已过期，请获取新验证码。';

  @override
  String get authRateLimited => '请求过多，请稍后重试。';

  @override
  String get cloudNetworkUnavailable => '没有网络连接；已保存的云端会话已保留。';

  @override
  String get appLockCloudSeparation => '应用锁仅保护此设备；其 PIN 和生物认证并非 KeEv 云端登录凭证。';

  @override
  String get backupStatus => '备份状态';

  @override
  String get localBackup => '本机备份';

  @override
  String get cloudBackup => '云端备份';

  @override
  String get createEncryptedBackup => '创建加密备份';

  @override
  String get restoreFromBackupFile => '从备份文件还原';

  @override
  String get backupPassphrase => '备份密码';

  @override
  String get confirmBackupPassphrase => '确认备份密码';

  @override
  String get backupPassphraseHelp => '请使用至少 10 个字符。KeEv 无法恢复遗失的备份密码。';

  @override
  String get backupSecurityInfo => '备份会先在此设备加密，再导出或上传。';

  @override
  String get backupCreated => '已创建加密备份。';

  @override
  String get backupFailed => '无法创建备份。';

  @override
  String get restorePreview => '还原预览';

  @override
  String get restoreReplaceWarning => '此操作会替换现有全部本机记账数据，不会合并记录。';

  @override
  String get restoreConfirm => '替换并还原';

  @override
  String get restoreCompleted => '备份已还原。';

  @override
  String get restoreFailedMessage => '无法还原备份。';

  @override
  String get wrongBackupPassphrase => '密码不正确，或备份已被更改。';

  @override
  String get corruptedBackup => '此备份无效、已损坏或版本不受支持。';

  @override
  String get cloudSignInRequired => '登录后可使用可选云端备份；本机备份仍然可用。';

  @override
  String get noCloudBackups => '尚无云端备份。';

  @override
  String get deleteBackup => '删除备份';

  @override
  String get backupCreatedAt => '创建时间';

  @override
  String get backupFormatVersion => '备份格式';

  @override
  String get backupSourceApp => '来源应用';

  @override
  String get backupBaseCurrency => '基础货币';

  @override
  String get encryptedBackupSize => '加密文件大小';

  @override
  String get deleteCloudBackupConfirmation => '永久删除此云端备份？您的本机记账数据不会被删除。';

  @override
  String get syncTitle => '实时同步';

  @override
  String get syncEnable => '启用同步';

  @override
  String get syncDescription =>
      '让多台设备的账簿保持一致。实时同步会将可读取的账簿记录存储在您的 KeEv 云端账户中，与加密备份分开。';

  @override
  String get syncNow => '立即同步';

  @override
  String get syncPause => '暂停同步';

  @override
  String get syncResume => '继续同步';

  @override
  String get syncDisable => '取消关联此设备';

  @override
  String get syncLocalData => '本机数据';

  @override
  String get syncCloudData => '云端数据';

  @override
  String get syncKeepLocal => '保留本机';

  @override
  String get syncKeepCloud => '保留云端';

  @override
  String get syncCancel => '取消';

  @override
  String get syncNeedsReconciliation => '需要核对';

  @override
  String get syncConflicts => '有冲突需要处理';

  @override
  String get syncActive => '同步已启用';

  @override
  String get syncPaused => '同步已暂停';

  @override
  String get syncUpToDate => '已是最新';

  @override
  String get syncOffline => '暂时不可用';

  @override
  String get syncAuthRequired => '需要登录验证';

  @override
  String get syncPendingChanges => '待同步更改';

  @override
  String get syncLastSynced => '上次同步';

  @override
  String get syncChecking => '正在检查本机和云端数据…';

  @override
  String get syncInitializing => '正在准备账簿…';

  @override
  String get syncUploading => '正在上传并验证本机数据…';

  @override
  String get syncDownloading => '正在下载云端数据…';

  @override
  String get syncVerifying => '正在验证完整账簿…';

  @override
  String get syncFinalizing => '正在完成同步…';

  @override
  String get syncDestructiveWarning => '此选择会替换其中一份账簿。如日后可能需要恢复，请先创建加密备份。';

  @override
  String get syncUnlinkWarning => '本机和云端账簿都会保留。此设备之后的更改仅保留在本机，待同步更改也不会发送。';

  @override
  String get syncConflictsTitle => '处理冲突';

  @override
  String get syncLocalDelete => '已在此设备删除';

  @override
  String get syncCloudDelete => '已在云端删除';

  @override
  String get syncNoAutomaticMerge => '本机和云端都有数据。请选择作为起点的账簿；KeEv 不会自动合并。';

  @override
  String get privacyAdvertising => '隐私与广告';

  @override
  String get privacyAdvertisingSummary => '管理广告隐私选择';

  @override
  String get advertisingPreferences => '广告偏好';

  @override
  String get advertisingPrivacyExplanation =>
      '广告与账本相互独立。KeEv 不会向广告服务发送余额、交易、备注、收据或其他财务内容。';

  @override
  String get managePrivacyChoices => '管理隐私选择';

  @override
  String get advertisement => '广告';
}

/// The translations for Chinese, as used in Hong Kong (`zh_HK`).
class AppLocalizationsZhHk extends AppLocalizationsZh {
  AppLocalizationsZhHk() : super('zh_HK');

  @override
  String get appTitle => 'KeEv 記帳';

  @override
  String get home => '首頁';

  @override
  String get history => '紀錄';

  @override
  String get add => '新增';

  @override
  String get budget => '預算';

  @override
  String get more => '更多';

  @override
  String get accounts => '戶口';

  @override
  String get projects => '項目／標籤';

  @override
  String get reports => '報告';

  @override
  String get settings => '設定';

  @override
  String get language => '語言';

  @override
  String get appearance => '外觀';

  @override
  String get backup => '備份／還原';

  @override
  String get authentication => 'KeEv 帳戶';

  @override
  String get premium => 'Premium';

  @override
  String get welcome => '每天收支，一目了然';

  @override
  String get intro => '輕鬆記帳，按自己的步伐開始。';

  @override
  String get preview => '部分功能仍在開發中。';

  @override
  String get emptyTitle => '你的空間已準備好';

  @override
  String get emptyBody => '此功能正在準備中，沒有顯示模擬財務資料。';

  @override
  String get addUnavailable => '快速新增功能將於第 2 階段加入。此預覽版未能儲存交易。';

  @override
  String get languageIntro => '選擇語言。稍後可在設定更改。';

  @override
  String get continueLabel => '繼續';

  @override
  String get privacyIntro => '毋須建立帳戶，即可在此裝置開始。此預覽版沒有 KeEv 雲端、廣告或分析服務。';

  @override
  String get privacyPolicy => '私隱政策';

  @override
  String get terms => '使用條款';

  @override
  String get developmentLegal =>
      '開發用內容 — 此處為佔位內容，並非最終私隱政策或使用條款。正式推出前，會按實際服務審閱最終文字。';

  @override
  String get acceptPreview => '我明白這是開發預覽版。';

  @override
  String get startLocal => '以本機模式開始';

  @override
  String get back => '返回';

  @override
  String get close => '關閉';

  @override
  String get systemTheme => '跟隨系統';

  @override
  String get lightTheme => '淺色';

  @override
  String get darkTheme => '深色';

  @override
  String get followSystem => '跟隨裝置語言';

  @override
  String get localMode => '只儲存在此裝置';

  @override
  String get sessionNotice => '語言、外觀及引導選項只會在本次使用期間保留。';

  @override
  String get errorTitle => '發生問題';

  @override
  String get preferencesError => '未能更新你的偏好設定，請再試一次。';

  @override
  String get loading => '載入中';

  @override
  String phaseLabel(int phase) {
    return '第 $phase 階段預覽';
  }

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHongKong => '繁體中文（香港）';

  @override
  String get languageChinese => '简体中文';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageThai => 'ไทย';

  @override
  String get quickAdd => '快速新增';

  @override
  String get expense => '支出';

  @override
  String get income => '收入';

  @override
  String get transfer => '轉帳';

  @override
  String get amount => '金額';

  @override
  String get sentAmount => '轉出金額';

  @override
  String get receivedAmount => '轉入金額';

  @override
  String get account => '戶口';

  @override
  String get sourceAccount => '轉出戶口';

  @override
  String get destinationAccount => '轉入戶口';

  @override
  String get category => '分類';

  @override
  String get businessDate => '日期';

  @override
  String get noteOptional => '備註（可選）';

  @override
  String get save => '儲存';

  @override
  String get savedLocally => '已儲存在此裝置';

  @override
  String get saveFailed => '未能儲存，請再試。';

  @override
  String get invalidMoney => '請輸入大於零的金額，並使用正確的小數位。';

  @override
  String get chooseAccount => '選擇戶口';

  @override
  String get chooseCategory => '選擇分類';

  @override
  String get chooseOtherAccount => '選擇另一個轉入戶口';

  @override
  String get addAccount => '新增戶口';

  @override
  String get addCategory => '新增分類';

  @override
  String get name => '名稱';

  @override
  String get accountType => '戶口類型';

  @override
  String get currency => '貨幣';

  @override
  String get create => '建立';

  @override
  String get firstAccount => '先新增一個戶口。';

  @override
  String get secondAccount => '轉帳需要多一個戶口。';

  @override
  String get categoryNeeded => '請新增此類型的分類。';

  @override
  String get noHistory => '暫無交易紀錄。';

  @override
  String get cash => '現金';

  @override
  String get bank => '銀行';

  @override
  String get creditCard => '信用卡';

  @override
  String get eWallet => '電子錢包';

  @override
  String get other => '其他';

  @override
  String get receivedRequired => '不同貨幣的轉帳必須填寫轉入金額。';

  @override
  String get differentAccounts => '轉出及轉入戶口不可相同。';

  @override
  String get archivedEntity => '戶口或分類已封存。';

  @override
  String get mismatchEntity => '貨幣或分類類型不相符。';

  @override
  String get beforeOpening => '日期不可早於兩個戶口的開戶日期。';

  @override
  String get addBudget => '新增預算';

  @override
  String get budgetName => '預算名稱';

  @override
  String get budgetAmount => '預算金額';

  @override
  String get budgetMonth => '月份（YYYY-MM）';

  @override
  String get budgetCategory => '支出分類（可選）';

  @override
  String get allExpenses => '所有支出';

  @override
  String warningAt(int percent) {
    return '達 $percent% 時提醒';
  }

  @override
  String get spent => '已使用';

  @override
  String get remaining => '尚餘';

  @override
  String get overBudget => '超出預算';

  @override
  String missingFx(String currencies) {
    return '計算未完整 · 欠缺以下貨幣匯率：$currencies';
  }

  @override
  String get noBudgets => '本月尚未有預算。';

  @override
  String get archive => '封存';

  @override
  String get edit => '編輯';

  @override
  String get project => '項目';

  @override
  String get noProject => '不屬於項目';

  @override
  String get addProject => '新增項目';

  @override
  String get projectName => '項目名稱';

  @override
  String get projectDescription => '描述（可選）';

  @override
  String get noProjects => '尚未有進行中的項目。';

  @override
  String get incomeTotal => '收入';

  @override
  String get expenseTotal => '支出';

  @override
  String get netTotal => '淨額';

  @override
  String get projectArchived => '此項目已封存。';

  @override
  String get invalidMonth => '請以 YYYY-MM 輸入有效月份。';

  @override
  String get incomeExpenseReport => '收入與支出報告';

  @override
  String get assetsLiabilitiesOverview => '資產與負債概覽';

  @override
  String get reportPeriod => '報告期間';

  @override
  String get previousPeriod => '上一期間';

  @override
  String get reportComplete => '計算完整';

  @override
  String get reportIncomplete => '計算未完整';

  @override
  String get categoryBreakdown => '類別明細';

  @override
  String get accountBreakdown => '帳戶明細';

  @override
  String get dailyTrend => '每日趨勢';

  @override
  String asOf(String date) {
    return '截至 $date';
  }

  @override
  String get assetsLabel => '資產';

  @override
  String get liabilitiesLabel => '負債';

  @override
  String get reportingCurrency => '報告貨幣';

  @override
  String get prepareCsv => '準備 CSV';

  @override
  String get csvReady => 'CSV 已在本機準備';

  @override
  String get comparisonUnavailable => '沒有具意義的上一期間百分比';

  @override
  String changeFromPrevious(String percent) {
    return '較上一期間 $percent%';
  }

  @override
  String get reportDisclaimer => '個人記帳概覽，並非專業財務報表。';

  @override
  String get allTransactions => '全部';

  @override
  String get searchNotes => '搜尋備註';

  @override
  String get applyFilter => '套用';

  @override
  String get noReportData => '此期間沒有活動。';

  @override
  String get receiptsOptional => '收據相片（選填）';

  @override
  String get receiptPrivacyNote => '只儲存於此裝置，最多 5 張相片。';

  @override
  String get takePhoto => '拍攝相片';

  @override
  String get choosePhoto => '從相片圖庫選擇';

  @override
  String get receiptPhoto => '收據相片';

  @override
  String get removeReceipt => '移除收據';

  @override
  String get viewReceipt => '查看收據';

  @override
  String get receiptLimitReached => '每項交易最多可附加 5 張收據相片。';

  @override
  String get receiptInvalid => '這不是支援的收據圖片。';

  @override
  String get receiptTooLarge => '圖片太大，無法安全處理。';

  @override
  String get receiptPermissionDenied => '未獲相機或相片存取權限；你可前往「設定」啟用。';

  @override
  String get voiceEntry => '語音輸入';

  @override
  String get listening => '正在聆聽…';

  @override
  String get stopListening => '停止';

  @override
  String get cancelVoice => '取消';

  @override
  String get processingSpeech => '正在處理語音…';

  @override
  String get reviewVoiceDraft => '語音只會建議草稿欄位，儲存前請先核對。';

  @override
  String get voicePermissionDenied => '未獲咪高峰或語音辨識權限。你可繼續手動輸入，或前往「設定」啟用。';

  @override
  String get voiceLocaleUnavailable => '此裝置沒有合適的香港粵語辨識服務，請手動輸入。';

  @override
  String get voiceUnavailable => '語音辨識目前無法使用，請手動輸入。';

  @override
  String get voiceRecognitionFailed => '語音辨識失敗；現有草稿已保留。';

  @override
  String get voicePrivacyDisclosure =>
      '裝置的語音服務可能會在網上處理音訊。KeEv 不會儲存音訊，亦不會傳送至 AI 或分析服務。';

  @override
  String get appLock => '應用程式鎖';

  @override
  String get appLocked => 'KeEv Ledger 已鎖定';

  @override
  String get appLockDescription => '以 PIN 及選用的系統生物辨識保護此裝置上的本機記帳資料。';

  @override
  String get appLockEnabled => '應用程式鎖已啟用';

  @override
  String get setPin => '設定 PIN';

  @override
  String get confirmPin => '確認 PIN';

  @override
  String get currentPin => '目前 PIN';

  @override
  String get newPin => '新 PIN';

  @override
  String get enterPin => '輸入 PIN';

  @override
  String get pinRequirements => '請輸入 4 至 6 位數字 PIN。';

  @override
  String get pinMismatch => '兩次輸入的 PIN 不一致。';

  @override
  String get incorrectPin => 'PIN 不正確。';

  @override
  String get tryAgainLater => '嘗試次數過多，請稍後再試。';

  @override
  String get useBiometrics => '使用生物辨識';

  @override
  String get biometricUnavailable => '系統生物辨識無法使用或尚未設定。';

  @override
  String get biometricCancelled => '已取消生物辨識。';

  @override
  String get biometricLocked => '系統生物辨識已鎖定，請使用 KeEv PIN。';

  @override
  String get biometricFailed => '生物辨識失敗，請使用 PIN。';

  @override
  String get biometricPromptReason => '解鎖本機 KeEv Ledger';

  @override
  String get biometricSystemDescription => '使用此裝置已設定的生物辨識方式。';

  @override
  String get unlock => '解鎖';

  @override
  String get lockNow => '立即鎖定';

  @override
  String get changePin => '更改 PIN';

  @override
  String get disableAppLock => '停用應用程式鎖';

  @override
  String get authenticationRequired => '請輸入目前 PIN 以繼續。';

  @override
  String get authenticationCancelled => '認證已取消，請再試。';

  @override
  String get lockConfigurationError => '無法安全讀取應用程式鎖設定，因此未有開放存取。';

  @override
  String get forgotPinGuidance =>
      '本機模式不設網上 PIN 復原。KeEv 無法繞過 PIN，亦不會自動刪除你的記帳資料。';

  @override
  String get relockPolicy => '應用程式進入背景時會鎖定。';

  @override
  String get privacyCover => 'KeEv Ledger 非使用中時會隱藏財務資料。';

  @override
  String get cloudAccount => '雲端帳戶';

  @override
  String get localOnlyModeTitle => '只儲存於本機';

  @override
  String get localOnlyDataNotice => '你的記帳資料目前只保留在此裝置，毋須帳戶或網絡連線。';

  @override
  String get cloudAccountConnected => '此裝置已有已認證的 KeEv 雲端工作階段。';

  @override
  String get cloudOptionalDescription => '日後的雲端備份可選擇使用 KeEv 帳戶；沒有帳戶亦可繼續在本機記帳。';

  @override
  String get cloudAccountOptions => '查看可選雲端帳戶';

  @override
  String get signInWithApple => '使用 Apple 登入';

  @override
  String get signInWithGoogle => '使用 Google 登入';

  @override
  String get signInWithEmail => '使用電郵繼續';

  @override
  String get signOut => '登出';

  @override
  String get cloudUnavailableDevelopment => '此版本尚未啟用雲端登入及備份，不會上載任何資料。';

  @override
  String get continueLocalOnly => '繼續只使用本機';

  @override
  String get cloudAccountError => '雲端帳戶服務未能完成此要求。';

  @override
  String get cloudSignedOut => '已登出';

  @override
  String get cloudAuthenticating => '正在登入…';

  @override
  String get cloudReauthenticationRequired => '請重新登入以繼續使用雲端帳戶功能。';

  @override
  String get cloudTemporarilyUnavailable => '雲端服務暫時無法使用；安全工作階段已保留。';

  @override
  String get cloudConfigurationUnavailable => '此版本未設定雲端登入；你仍可只使用本機。';

  @override
  String get cloudBackupNotActive => '雲端備份尚未啟用。登入不會上載你的記帳資料。';

  @override
  String get emailAddress => '電郵地址';

  @override
  String get sendOtp => '傳送驗證碼';

  @override
  String get otpCode => '6 位數驗證碼';

  @override
  String get verifyOtp => '驗證';

  @override
  String get resendOtp => '重新傳送';

  @override
  String get otpSent => '登入驗證碼已傳送，請查看電郵。';

  @override
  String get invalidOtp => '驗證碼不正確。';

  @override
  String get expiredOtp => '驗證碼已過期，請索取新的驗證碼。';

  @override
  String get authRateLimited => '要求次數過多，請稍後再試。';

  @override
  String get cloudNetworkUnavailable => '沒有網絡連線；已儲存的雲端工作階段已保留。';

  @override
  String get appLockCloudSeparation => '應用程式鎖只保護此裝置；其 PIN 及生物認證並非 KeEv 雲端登入憑證。';

  @override
  String get backupStatus => '備份狀態';

  @override
  String get localBackup => '本機備份';

  @override
  String get cloudBackup => '雲端備份';

  @override
  String get createEncryptedBackup => '建立加密備份';

  @override
  String get restoreFromBackupFile => '從備份檔案還原';

  @override
  String get backupPassphrase => '備份密碼';

  @override
  String get confirmBackupPassphrase => '確認備份密碼';

  @override
  String get backupPassphraseHelp => '請使用最少 10 個字元。KeEv 無法復原遺失的備份密碼。';

  @override
  String get backupSecurityInfo => '備份會先在此裝置加密，才匯出或上載。';

  @override
  String get backupCreated => '已建立加密備份。';

  @override
  String get backupFailed => '未能建立備份。';

  @override
  String get restorePreview => '還原預覽';

  @override
  String get restoreReplaceWarning => '此操作會取代現有全部本機記帳資料，不會合併紀錄。';

  @override
  String get restoreConfirm => '取代並還原';

  @override
  String get restoreCompleted => '備份已還原。';

  @override
  String get restoreFailedMessage => '未能還原備份。';

  @override
  String get wrongBackupPassphrase => '密碼不正確，或備份已被更改。';

  @override
  String get corruptedBackup => '此備份無效、已損壞或版本不受支援。';

  @override
  String get cloudSignInRequired => '登入後可使用自選雲端備份；本機備份仍然可用。';

  @override
  String get noCloudBackups => '尚無雲端備份。';

  @override
  String get deleteBackup => '刪除備份';

  @override
  String get backupCreatedAt => '建立時間';

  @override
  String get backupFormatVersion => '備份格式';

  @override
  String get backupSourceApp => '來源應用程式';

  @override
  String get backupBaseCurrency => '基準貨幣';

  @override
  String get encryptedBackupSize => '加密檔案大小';

  @override
  String get deleteCloudBackupConfirmation => '永久刪除此雲端備份？你的本機記帳資料不會被刪除。';

  @override
  String get syncTitle => '即時同步';

  @override
  String get syncEnable => '啟用同步';

  @override
  String get syncDescription =>
      '讓多部裝置的帳簿保持一致。即時同步會把可讀取的帳簿紀錄儲存在你的 KeEv 雲端帳戶，與加密備份分開。';

  @override
  String get syncNow => '立即同步';

  @override
  String get syncPause => '暫停同步';

  @override
  String get syncResume => '繼續同步';

  @override
  String get syncDisable => '取消連結此裝置';

  @override
  String get syncLocalData => '本機資料';

  @override
  String get syncCloudData => '雲端資料';

  @override
  String get syncKeepLocal => '保留本機';

  @override
  String get syncKeepCloud => '保留雲端';

  @override
  String get syncCancel => '取消';

  @override
  String get syncNeedsReconciliation => '需要核對';

  @override
  String get syncConflicts => '有衝突需要處理';

  @override
  String get syncActive => '同步已啟用';

  @override
  String get syncPaused => '同步已暫停';

  @override
  String get syncUpToDate => '已是最新';

  @override
  String get syncOffline => '暫時無法使用';

  @override
  String get syncAuthRequired => '需要登入驗證';

  @override
  String get syncPendingChanges => '待同步變更';

  @override
  String get syncLastSynced => '上次同步';

  @override
  String get syncChecking => '正在檢查本機及雲端資料…';

  @override
  String get syncInitializing => '正在準備帳簿…';

  @override
  String get syncUploading => '正在上載及驗證本機資料…';

  @override
  String get syncDownloading => '正在下載雲端資料…';

  @override
  String get syncVerifying => '正在驗證完整帳簿…';

  @override
  String get syncFinalizing => '正在完成同步…';

  @override
  String get syncDestructiveWarning => '此選擇會取代其中一份帳簿。如日後可能需要復原，請先建立加密備份。';

  @override
  String get syncUnlinkWarning => '本機及雲端帳簿會保留。此裝置之後的變更只會留在本機，待同步變更亦不會傳送。';

  @override
  String get syncConflictsTitle => '處理衝突';

  @override
  String get syncLocalDelete => '已在此裝置刪除';

  @override
  String get syncCloudDelete => '已在雲端刪除';

  @override
  String get syncNoAutomaticMerge => '本機及雲端都有資料。請選擇作為起點的帳簿；KeEv 不會自動合併。';

  @override
  String get privacyAdvertising => '私隱與廣告';

  @override
  String get privacyAdvertisingSummary => '管理廣告私隱選擇';

  @override
  String get advertisingPreferences => '廣告偏好';

  @override
  String get advertisingPrivacyExplanation =>
      '廣告與你的帳簿分開。KeEv 不會向廣告服務傳送結餘、交易、備註、收據或其他財務內容。';

  @override
  String get managePrivacyChoices => '管理私隱選擇';

  @override
  String get advertisement => '廣告';
}
