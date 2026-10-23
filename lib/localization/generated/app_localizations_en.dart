// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'KeEv Ledger';

  @override
  String get home => 'Home';

  @override
  String get history => 'History';

  @override
  String get add => 'Add';

  @override
  String get budget => 'Budget';

  @override
  String get more => 'More';

  @override
  String get accounts => 'Accounts';

  @override
  String get projects => 'Projects / Tags';

  @override
  String get reports => 'Reports';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get appearance => 'Appearance';

  @override
  String get backup => 'Backup / Restore';

  @override
  String get authentication => 'KeEv Account';

  @override
  String get premium => 'Premium';

  @override
  String get welcome => 'A clearer view of your day';

  @override
  String get intro => 'Simple bookkeeping, at your own pace.';

  @override
  String get preview => 'Some features are still in development.';

  @override
  String get emptyTitle => 'Your space is ready';

  @override
  String get emptyBody =>
      'This feature is being prepared. No sample financial data is shown.';

  @override
  String get addUnavailable =>
      'Quick Add arrives in Phase 2. You cannot save a transaction in this preview.';

  @override
  String get languageIntro =>
      'Choose a language. You can change it later in Settings.';

  @override
  String get continueLabel => 'Continue';

  @override
  String get privacyIntro =>
      'Start on your device without creating an account. This preview has no KeEv cloud, advertising or analytics services.';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get terms => 'Terms of Use';

  @override
  String get developmentLegal =>
      'DEVELOPMENT CONTENT — These are placeholders, not the final Privacy Policy or Terms. Final wording will be reviewed against the implemented services before release.';

  @override
  String get acceptPreview => 'I understand this is a development preview.';

  @override
  String get startLocal => 'Start Local Only';

  @override
  String get back => 'Back';

  @override
  String get close => 'Close';

  @override
  String get systemTheme => 'System';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get followSystem => 'Follow device language';

  @override
  String get localMode => 'Local Only';

  @override
  String get sessionNotice =>
      'Language, appearance and onboarding choices last for this session only.';

  @override
  String get errorTitle => 'Something went wrong';

  @override
  String get preferencesError =>
      'Your preference could not be updated. Please try again.';

  @override
  String get loading => 'Loading';

  @override
  String phaseLabel(int phase) {
    return 'Phase $phase preview';
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
  String get quickAdd => 'Quick Add';

  @override
  String get expense => 'Expense';

  @override
  String get income => 'Income';

  @override
  String get transfer => 'Transfer';

  @override
  String get amount => 'Amount';

  @override
  String get sentAmount => 'Sent amount';

  @override
  String get receivedAmount => 'Received amount';

  @override
  String get account => 'Account';

  @override
  String get sourceAccount => 'From account';

  @override
  String get destinationAccount => 'To account';

  @override
  String get category => 'Category';

  @override
  String get businessDate => 'Date';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get save => 'Save';

  @override
  String get savedLocally => 'Saved on this device';

  @override
  String get saveFailed => 'Could not save. Try again.';

  @override
  String get invalidMoney =>
      'Enter a positive amount with the correct decimal places.';

  @override
  String get chooseAccount => 'Choose an account';

  @override
  String get chooseCategory => 'Choose a category';

  @override
  String get chooseOtherAccount => 'Choose a different destination account';

  @override
  String get addAccount => 'Add account';

  @override
  String get addCategory => 'Add category';

  @override
  String get name => 'Name';

  @override
  String get accountType => 'Account type';

  @override
  String get currency => 'Currency';

  @override
  String get create => 'Create';

  @override
  String get firstAccount => 'Add an account to get started.';

  @override
  String get secondAccount => 'Create another account for transfers.';

  @override
  String get categoryNeeded => 'Add a category for this type.';

  @override
  String get noHistory => 'No transactions yet.';

  @override
  String get cash => 'Cash';

  @override
  String get bank => 'Bank';

  @override
  String get creditCard => 'Credit card';

  @override
  String get eWallet => 'E-wallet';

  @override
  String get other => 'Other';

  @override
  String get receivedRequired =>
      'A received amount is required for different currencies.';

  @override
  String get differentAccounts => 'Both accounts must be different.';

  @override
  String get archivedEntity => 'Account or category is archived.';

  @override
  String get mismatchEntity => 'Currency or category does not match.';

  @override
  String get beforeOpening =>
      'The date must be on or after both accounts opened.';

  @override
  String get addBudget => 'Add budget';

  @override
  String get budgetName => 'Budget name';

  @override
  String get budgetAmount => 'Budget amount';

  @override
  String get budgetMonth => 'Month (YYYY-MM)';

  @override
  String get budgetCategory => 'Expense category (optional)';

  @override
  String get allExpenses => 'All expenses';

  @override
  String warningAt(int percent) {
    return 'Warning at $percent%';
  }

  @override
  String get spent => 'Spent';

  @override
  String get remaining => 'Remaining';

  @override
  String get overBudget => 'Over budget';

  @override
  String missingFx(String currencies) {
    return 'Incomplete · missing FX for: $currencies';
  }

  @override
  String get noBudgets => 'No budgets for this month yet.';

  @override
  String get archive => 'Archive';

  @override
  String get edit => 'Edit';

  @override
  String get project => 'Project';

  @override
  String get noProject => 'No project';

  @override
  String get addProject => 'Add project';

  @override
  String get projectName => 'Project name';

  @override
  String get projectDescription => 'Description (optional)';

  @override
  String get noProjects => 'No active projects yet.';

  @override
  String get incomeTotal => 'Income';

  @override
  String get expenseTotal => 'Expense';

  @override
  String get netTotal => 'Net';

  @override
  String get projectArchived => 'This project is archived.';

  @override
  String get invalidMonth => 'Enter a valid month as YYYY-MM.';

  @override
  String get incomeExpenseReport => 'Income & Expense Report';

  @override
  String get assetsLiabilitiesOverview => 'Assets & Liabilities Overview';

  @override
  String get reportPeriod => 'Report period';

  @override
  String get previousPeriod => 'Previous period';

  @override
  String get reportComplete => 'Complete calculation';

  @override
  String get reportIncomplete => 'Incomplete calculation';

  @override
  String get categoryBreakdown => 'Category breakdown';

  @override
  String get accountBreakdown => 'Account breakdown';

  @override
  String get dailyTrend => 'Daily trend';

  @override
  String asOf(String date) {
    return 'As of $date';
  }

  @override
  String get assetsLabel => 'Assets';

  @override
  String get liabilitiesLabel => 'Liabilities';

  @override
  String get reportingCurrency => 'Reporting currency';

  @override
  String get prepareCsv => 'Prepare CSV';

  @override
  String get csvReady => 'CSV prepared locally';

  @override
  String get comparisonUnavailable =>
      'No meaningful previous-period percentage';

  @override
  String changeFromPrevious(String percent) {
    return '$percent% vs previous period';
  }

  @override
  String get reportDisclaimer =>
      'Personal bookkeeping overview — not a professional financial statement.';

  @override
  String get allTransactions => 'All';

  @override
  String get searchNotes => 'Search notes';

  @override
  String get applyFilter => 'Apply';

  @override
  String get noReportData => 'No activity in this period.';

  @override
  String get receiptsOptional => 'Receipt photos (optional)';

  @override
  String get receiptPrivacyNote =>
      'Stored only on this device. Up to 5 photos.';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get choosePhoto => 'Choose photo';

  @override
  String get receiptPhoto => 'Receipt photo';

  @override
  String get removeReceipt => 'Remove receipt';

  @override
  String get viewReceipt => 'View receipt';

  @override
  String get receiptLimitReached => 'You can attach up to 5 receipt photos.';

  @override
  String get receiptInvalid => 'This is not a supported receipt image.';

  @override
  String get receiptTooLarge => 'This image is too large to process safely.';

  @override
  String get receiptPermissionDenied =>
      'Camera or photo access was not granted. You can enable it in Settings.';

  @override
  String get voiceEntry => 'Voice Entry';

  @override
  String get listening => 'Listening…';

  @override
  String get stopListening => 'Stop';

  @override
  String get cancelVoice => 'Cancel';

  @override
  String get processingSpeech => 'Processing speech…';

  @override
  String get reviewVoiceDraft =>
      'Voice only suggests draft fields. Review them before saving.';

  @override
  String get voicePermissionDenied =>
      'Microphone or speech permission was denied. You can continue manually or enable it in Settings.';

  @override
  String get voiceLocaleUnavailable =>
      'A suitable speech language is not available on this device. Continue with manual entry.';

  @override
  String get voiceUnavailable =>
      'Speech recognition is unavailable. Continue with manual entry.';

  @override
  String get voiceRecognitionFailed =>
      'Speech recognition failed. Your existing draft was kept.';

  @override
  String get voicePrivacyDisclosure =>
      'Your device speech service may process audio online. KeEv does not store audio or send it to AI or analytics.';

  @override
  String get appLock => 'App Lock';

  @override
  String get appLocked => 'KeEv Ledger is locked';

  @override
  String get appLockDescription =>
      'Protect local bookkeeping on this device with a PIN and optional system biometrics.';

  @override
  String get appLockEnabled => 'App Lock is enabled';

  @override
  String get setPin => 'Set PIN';

  @override
  String get confirmPin => 'Confirm PIN';

  @override
  String get currentPin => 'Current PIN';

  @override
  String get newPin => 'New PIN';

  @override
  String get enterPin => 'Enter PIN';

  @override
  String get pinRequirements => 'Enter a 4–6 digit PIN.';

  @override
  String get pinMismatch => 'The PINs do not match.';

  @override
  String get incorrectPin => 'Incorrect PIN.';

  @override
  String get tryAgainLater => 'Too many attempts. Try again later.';

  @override
  String get useBiometrics => 'Use biometrics';

  @override
  String get biometricUnavailable =>
      'System biometrics are unavailable or not enrolled.';

  @override
  String get biometricCancelled => 'Biometric authentication was cancelled.';

  @override
  String get biometricLocked =>
      'System biometrics are locked. Use your KeEv PIN.';

  @override
  String get biometricFailed =>
      'Biometric authentication failed. Use your PIN.';

  @override
  String get biometricPromptReason => 'Unlock your local KeEv Ledger';

  @override
  String get biometricSystemDescription =>
      'Uses the biometric method configured on this device.';

  @override
  String get unlock => 'Unlock';

  @override
  String get lockNow => 'Lock Now';

  @override
  String get changePin => 'Change PIN';

  @override
  String get disableAppLock => 'Disable App Lock';

  @override
  String get authenticationRequired => 'Enter your current PIN to continue.';

  @override
  String get authenticationCancelled =>
      'Authentication was cancelled. Try again.';

  @override
  String get lockConfigurationError =>
      'App Lock configuration could not be read safely. Access was not granted.';

  @override
  String get forgotPinGuidance =>
      'There is no online PIN recovery in Local Only mode. KeEv cannot bypass the PIN or automatically delete your bookkeeping data.';

  @override
  String get relockPolicy => 'Locks when the app moves to the background.';

  @override
  String get privacyCover =>
      'Financial details are hidden while KeEv Ledger is inactive.';

  @override
  String get cloudAccount => 'Cloud Account';

  @override
  String get localOnlyModeTitle => 'Local Only';

  @override
  String get localOnlyDataNotice =>
      'Your bookkeeping data remains on this device. No account or network connection is required.';

  @override
  String get cloudAccountConnected =>
      'This device has an authenticated KeEv cloud session.';

  @override
  String get cloudOptionalDescription =>
      'A KeEv cloud account will be optional for future backup features. Local bookkeeping continues without one.';

  @override
  String get cloudAccountOptions => 'View optional cloud account';

  @override
  String get signInWithApple => 'Sign in with Apple';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get signInWithEmail => 'Continue with email';

  @override
  String get signOut => 'Sign out';

  @override
  String get cloudUnavailableDevelopment =>
      'Cloud sign-in and backup are not active in this build. No data is uploaded.';

  @override
  String get continueLocalOnly => 'Continue Local Only';

  @override
  String get cloudAccountError =>
      'The cloud account service could not complete that request.';

  @override
  String get cloudSignedOut => 'Signed out';

  @override
  String get cloudAuthenticating => 'Signing in…';

  @override
  String get cloudReauthenticationRequired =>
      'Sign in again to continue using cloud account features.';

  @override
  String get cloudTemporarilyUnavailable =>
      'Cloud service is temporarily unavailable. Your secure session has been kept.';

  @override
  String get cloudConfigurationUnavailable =>
      'Cloud sign-in is not configured in this build. Local Only remains available.';

  @override
  String get cloudBackupNotActive =>
      'Cloud backup is not active yet. Signing in does not upload your bookkeeping data.';

  @override
  String get emailAddress => 'Email address';

  @override
  String get sendOtp => 'Send code';

  @override
  String get otpCode => '6-digit code';

  @override
  String get verifyOtp => 'Verify code';

  @override
  String get resendOtp => 'Resend code';

  @override
  String get otpSent => 'A sign-in code was sent. Check your email.';

  @override
  String get invalidOtp => 'The code is invalid.';

  @override
  String get expiredOtp => 'The code has expired. Request a new one.';

  @override
  String get authRateLimited => 'Too many requests. Please wait and try again.';

  @override
  String get cloudNetworkUnavailable =>
      'No network connection. Your saved cloud session was kept.';

  @override
  String get appLockCloudSeparation =>
      'App Lock protects this device only. Its PIN and biometrics are not KeEv cloud sign-in credentials.';

  @override
  String get backupStatus => 'Backup status';

  @override
  String get localBackup => 'Local backup';

  @override
  String get cloudBackup => 'Cloud backup';

  @override
  String get createEncryptedBackup => 'Create encrypted backup';

  @override
  String get restoreFromBackupFile => 'Restore from backup file';

  @override
  String get backupPassphrase => 'Backup passphrase';

  @override
  String get confirmBackupPassphrase => 'Confirm backup passphrase';

  @override
  String get backupPassphraseHelp =>
      'Use at least 10 characters. KeEv cannot recover a forgotten backup passphrase.';

  @override
  String get backupSecurityInfo =>
      'Backups are encrypted on this device before export or upload.';

  @override
  String get backupCreated => 'Encrypted backup created.';

  @override
  String get backupFailed => 'The backup could not be created.';

  @override
  String get restorePreview => 'Restore preview';

  @override
  String get restoreReplaceWarning =>
      'This will replace all current local bookkeeping data. It will not merge records.';

  @override
  String get restoreConfirm => 'Replace and restore';

  @override
  String get restoreCompleted => 'Backup restored.';

  @override
  String get restoreFailedMessage => 'The backup could not be restored.';

  @override
  String get wrongBackupPassphrase =>
      'The passphrase is incorrect or the backup was changed.';

  @override
  String get corruptedBackup =>
      'This backup is invalid, corrupted, or unsupported.';

  @override
  String get cloudSignInRequired =>
      'Sign in to use optional cloud backup. Local backup remains available.';

  @override
  String get noCloudBackups => 'No cloud backups yet.';

  @override
  String get deleteBackup => 'Delete backup';

  @override
  String get backupCreatedAt => 'Created';

  @override
  String get backupFormatVersion => 'Backup format';

  @override
  String get backupSourceApp => 'Source app';

  @override
  String get backupBaseCurrency => 'Base currency';

  @override
  String get encryptedBackupSize => 'Encrypted size';

  @override
  String get deleteCloudBackupConfirmation =>
      'Permanently delete this cloud backup? Your local bookkeeping data will not be deleted.';

  @override
  String get syncTitle => 'Live Sync';

  @override
  String get syncEnable => 'Enable Sync';

  @override
  String get syncDescription =>
      'Keep this ledger aligned across your devices. Live sync stores readable ledger records in your KeEv cloud account and is separate from encrypted backup.';

  @override
  String get syncNow => 'Sync Now';

  @override
  String get syncPause => 'Pause Sync';

  @override
  String get syncResume => 'Resume Sync';

  @override
  String get syncDisable => 'Unlink This Device';

  @override
  String get syncLocalData => 'Local data';

  @override
  String get syncCloudData => 'Cloud data';

  @override
  String get syncKeepLocal => 'Keep Local';

  @override
  String get syncKeepCloud => 'Keep Cloud';

  @override
  String get syncCancel => 'Cancel';

  @override
  String get syncNeedsReconciliation => 'Needs reconciliation';

  @override
  String get syncConflicts => 'Conflicts need attention';

  @override
  String get syncActive => 'Sync active';

  @override
  String get syncPaused => 'Sync paused';

  @override
  String get syncUpToDate => 'Up to date';

  @override
  String get syncOffline => 'Temporarily unavailable';

  @override
  String get syncAuthRequired => 'Authentication required';

  @override
  String get syncPendingChanges => 'Pending changes';

  @override
  String get syncLastSynced => 'Last synced';

  @override
  String get syncChecking => 'Checking local and cloud data…';

  @override
  String get syncInitializing => 'Preparing your ledger…';

  @override
  String get syncUploading => 'Uploading and verifying local data…';

  @override
  String get syncDownloading => 'Downloading cloud data…';

  @override
  String get syncVerifying => 'Verifying the complete ledger…';

  @override
  String get syncFinalizing => 'Finalizing sync…';

  @override
  String get syncDestructiveWarning =>
      'This choice replaces one ledger. Create an encrypted backup first if you may need to recover it.';

  @override
  String get syncUnlinkWarning =>
      'Local and cloud ledgers remain. Future edits on this device will stay local and pending changes will not be sent.';

  @override
  String get syncConflictsTitle => 'Resolve Conflicts';

  @override
  String get syncLocalDelete => 'Deleted on this device';

  @override
  String get syncCloudDelete => 'Deleted in cloud';

  @override
  String get syncNoAutomaticMerge =>
      'Both ledgers contain data. Choose which ledger becomes the starting point; KeEv will not merge them automatically.';

  @override
  String get privacyAdvertising => 'Privacy & advertising';

  @override
  String get privacyAdvertisingSummary => 'Manage advertising privacy choices';

  @override
  String get advertisingPreferences => 'Advertising preferences';

  @override
  String get advertisingPrivacyExplanation =>
      'Advertising is separate from your ledger. KeEv does not send balances, transactions, notes, receipts, or other financial content to advertising services.';

  @override
  String get managePrivacyChoices => 'Manage privacy choices';

  @override
  String get advertisement => 'Advertisement';
}
