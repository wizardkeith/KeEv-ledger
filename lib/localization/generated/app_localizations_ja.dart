// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'KeEv 家計簿';

  @override
  String get home => 'ホーム';

  @override
  String get history => '履歴';

  @override
  String get add => '追加';

  @override
  String get budget => '予算';

  @override
  String get more => 'その他';

  @override
  String get accounts => 'お金の口座';

  @override
  String get projects => 'プロジェクト／タグ';

  @override
  String get reports => 'レポート';

  @override
  String get settings => '設定';

  @override
  String get language => '言語';

  @override
  String get appearance => '外観';

  @override
  String get backup => 'バックアップ／復元';

  @override
  String get authentication => 'KeEv アカウント';

  @override
  String get premium => 'Premium';

  @override
  String get welcome => '毎日の収支を、わかりやすく';

  @override
  String get intro => '自分のペースで、かんたん家計管理。';

  @override
  String get preview => '一部の機能は開発中です。';

  @override
  String get emptyTitle => 'あなたのスペースができました';

  @override
  String get emptyBody => 'この機能は準備中です。架空の財務データは表示していません。';

  @override
  String get addUnavailable => 'かんたん入力はフェーズ 2 で追加予定です。このプレビューでは取引を保存できません。';

  @override
  String get languageIntro => '言語を選んでください。後から設定で変更できます。';

  @override
  String get continueLabel => '続ける';

  @override
  String get privacyIntro =>
      'アカウントを作らず、この端末で開始できます。このプレビューには KeEv のクラウド、広告、分析サービスはありません。';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get terms => '利用規約';

  @override
  String get developmentLegal =>
      '開発用の内容 — 正式なプライバシーポリシーや利用規約ではありません。公開前に、実装されたサービスに合わせて文面を確認します。';

  @override
  String get acceptPreview => '開発プレビューであることを理解しました。';

  @override
  String get startLocal => 'ローカルのみで開始';

  @override
  String get back => '戻る';

  @override
  String get close => '閉じる';

  @override
  String get systemTheme => 'システム';

  @override
  String get lightTheme => 'ライト';

  @override
  String get darkTheme => 'ダーク';

  @override
  String get followSystem => '端末の言語に合わせる';

  @override
  String get localMode => 'この端末のみ';

  @override
  String get sessionNotice => '言語、外観、初回案内の選択は今回の利用中のみ保持されます。';

  @override
  String get errorTitle => '問題が発生しました';

  @override
  String get preferencesError => '設定を更新できませんでした。もう一度お試しください。';

  @override
  String get loading => '読み込み中';

  @override
  String phaseLabel(int phase) {
    return 'フェーズ $phase プレビュー';
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
  String get quickAdd => 'クイック入力';

  @override
  String get expense => '支出';

  @override
  String get income => '収入';

  @override
  String get transfer => '振替';

  @override
  String get amount => '金額';

  @override
  String get sentAmount => '送金額';

  @override
  String get receivedAmount => '受取額';

  @override
  String get account => '口座';

  @override
  String get sourceAccount => '振替元の口座';

  @override
  String get destinationAccount => '振替先の口座';

  @override
  String get category => 'カテゴリ';

  @override
  String get businessDate => '日付';

  @override
  String get noteOptional => 'メモ（任意）';

  @override
  String get save => '保存';

  @override
  String get savedLocally => 'この端末に保存しました';

  @override
  String get saveFailed => '保存できませんでした。もう一度お試しください。';

  @override
  String get invalidMoney => '正しい小数桁数で、0より大きい金額を入力してください。';

  @override
  String get chooseAccount => '口座を選択';

  @override
  String get chooseCategory => 'カテゴリを選択';

  @override
  String get chooseOtherAccount => '別の振替先口座を選択';

  @override
  String get addAccount => '口座を追加';

  @override
  String get addCategory => 'カテゴリを追加';

  @override
  String get name => '名前';

  @override
  String get accountType => '口座の種類';

  @override
  String get currency => '通貨';

  @override
  String get create => '作成';

  @override
  String get firstAccount => '最初に口座を追加してください。';

  @override
  String get secondAccount => '振替には別の口座も必要です。';

  @override
  String get categoryNeeded => 'この種類のカテゴリを追加してください。';

  @override
  String get noHistory => '取引履歴はまだありません。';

  @override
  String get cash => '現金';

  @override
  String get bank => '銀行';

  @override
  String get creditCard => 'クレジットカード';

  @override
  String get eWallet => '電子ウォレット';

  @override
  String get other => 'その他';

  @override
  String get receivedRequired => '異なる通貨への振替には受取額が必要です。';

  @override
  String get differentAccounts => '振替元と振替先は別の口座を選んでください。';

  @override
  String get archivedEntity => '口座またはカテゴリはアーカイブされています。';

  @override
  String get mismatchEntity => '通貨またはカテゴリの種類が一致しません。';

  @override
  String get beforeOpening => '日付は両方の口座の開設日以降にしてください。';

  @override
  String get addBudget => '予算を追加';

  @override
  String get budgetName => '予算名';

  @override
  String get budgetAmount => '予算額';

  @override
  String get budgetMonth => '月（YYYY-MM）';

  @override
  String get budgetCategory => '支出カテゴリ（任意）';

  @override
  String get allExpenses => 'すべての支出';

  @override
  String warningAt(int percent) {
    return '$percent% で通知';
  }

  @override
  String get spent => '使用済み';

  @override
  String get remaining => '残額';

  @override
  String get overBudget => '予算超過';

  @override
  String missingFx(String currencies) {
    return '未完了 · 次の通貨の為替情報がありません：$currencies';
  }

  @override
  String get noBudgets => '今月の予算はまだありません。';

  @override
  String get archive => 'アーカイブ';

  @override
  String get edit => '編集';

  @override
  String get project => 'プロジェクト';

  @override
  String get noProject => 'プロジェクトなし';

  @override
  String get addProject => 'プロジェクトを追加';

  @override
  String get projectName => 'プロジェクト名';

  @override
  String get projectDescription => '説明（任意）';

  @override
  String get noProjects => '進行中のプロジェクトはありません。';

  @override
  String get incomeTotal => '収入';

  @override
  String get expenseTotal => '支出';

  @override
  String get netTotal => '純額';

  @override
  String get projectArchived => 'このプロジェクトはアーカイブされています。';

  @override
  String get invalidMonth => 'YYYY-MM 形式で有効な月を入力してください。';

  @override
  String get incomeExpenseReport => '収入・支出レポート';

  @override
  String get assetsLiabilitiesOverview => '資産・負債の概要';

  @override
  String get reportPeriod => 'レポート期間';

  @override
  String get previousPeriod => '前期間';

  @override
  String get reportComplete => '計算完了';

  @override
  String get reportIncomplete => '計算未完了';

  @override
  String get categoryBreakdown => 'カテゴリ別内訳';

  @override
  String get accountBreakdown => '口座別内訳';

  @override
  String get dailyTrend => '日別推移';

  @override
  String asOf(String date) {
    return '$date 現在';
  }

  @override
  String get assetsLabel => '資産';

  @override
  String get liabilitiesLabel => '負債';

  @override
  String get reportingCurrency => 'レポート通貨';

  @override
  String get prepareCsv => 'CSV を準備';

  @override
  String get csvReady => 'CSV を端末内で準備しました';

  @override
  String get comparisonUnavailable => '有効な前期間比率はありません';

  @override
  String changeFromPrevious(String percent) {
    return '前期間比 $percent%';
  }

  @override
  String get reportDisclaimer => '個人向け家計簿の概要であり、専門的な財務諸表ではありません。';

  @override
  String get allTransactions => 'すべて';

  @override
  String get searchNotes => 'メモを検索';

  @override
  String get applyFilter => '適用';

  @override
  String get noReportData => 'この期間の記録はありません。';

  @override
  String get receiptsOptional => 'レシート写真（任意）';

  @override
  String get receiptPrivacyNote => 'この端末にのみ保存します。最大5枚。';

  @override
  String get takePhoto => '写真を撮る';

  @override
  String get choosePhoto => '写真ライブラリから選ぶ';

  @override
  String get receiptPhoto => 'レシート写真';

  @override
  String get removeReceipt => 'レシートを削除';

  @override
  String get viewReceipt => 'レシートを表示';

  @override
  String get receiptLimitReached => '1件の取引に添付できるレシート写真は5枚までです。';

  @override
  String get receiptInvalid => '対応していない画像です。';

  @override
  String get receiptTooLarge => '画像が大きすぎて安全に処理できません。';

  @override
  String get receiptPermissionDenied => 'カメラまたは写真へのアクセスが許可されていません。設定で有効にできます。';

  @override
  String get voiceEntry => '音声入力';

  @override
  String get listening => '聞き取り中…';

  @override
  String get stopListening => '停止';

  @override
  String get cancelVoice => 'キャンセル';

  @override
  String get processingSpeech => '音声を処理中…';

  @override
  String get reviewVoiceDraft => '音声は下書き項目を提案するだけです。保存前に確認してください。';

  @override
  String get voicePermissionDenied =>
      'マイクまたは音声認識の権限がありません。手動入力を続けるか、設定で有効にしてください。';

  @override
  String get voiceLocaleUnavailable => 'この端末では適切な日本語音声認識を利用できません。手動で入力してください。';

  @override
  String get voiceUnavailable => '音声認識を利用できません。手動で入力してください。';

  @override
  String get voiceRecognitionFailed => '音声認識に失敗しました。既存の下書きは保持されています。';

  @override
  String get voicePrivacyDisclosure =>
      '端末の音声サービスがオンラインで音声を処理する場合があります。KeEv は音声を保存せず、AI や分析サービスにも送信しません。';

  @override
  String get appLock => 'アプリロック';

  @override
  String get appLocked => 'KeEv Ledger はロックされています';

  @override
  String get appLockDescription => 'PIN と任意のシステム生体認証で、この端末の家計簿データを保護します。';

  @override
  String get appLockEnabled => 'アプリロックは有効です';

  @override
  String get setPin => 'PIN を設定';

  @override
  String get confirmPin => 'PIN を確認';

  @override
  String get currentPin => '現在の PIN';

  @override
  String get newPin => '新しい PIN';

  @override
  String get enterPin => 'PIN を入力';

  @override
  String get pinRequirements => '4～6桁の数字の PIN を入力してください。';

  @override
  String get pinMismatch => 'PIN が一致しません。';

  @override
  String get incorrectPin => 'PIN が正しくありません。';

  @override
  String get tryAgainLater => '試行回数が多すぎます。しばらくしてから再試行してください。';

  @override
  String get useBiometrics => '生体認証を使用';

  @override
  String get biometricUnavailable => 'システム生体認証を利用できないか、登録されていません。';

  @override
  String get biometricCancelled => '生体認証をキャンセルしました。';

  @override
  String get biometricLocked => 'システム生体認証はロックされています。KeEv PIN を使用してください。';

  @override
  String get biometricFailed => '生体認証に失敗しました。PIN を使用してください。';

  @override
  String get biometricPromptReason => '端末内の KeEv Ledger をロック解除';

  @override
  String get biometricSystemDescription => 'この端末に設定された生体認証方式を使用します。';

  @override
  String get unlock => 'ロック解除';

  @override
  String get lockNow => '今すぐロック';

  @override
  String get changePin => 'PIN を変更';

  @override
  String get disableAppLock => 'アプリロックを無効化';

  @override
  String get authenticationRequired => '続行するには現在の PIN を入力してください。';

  @override
  String get authenticationCancelled => '認証がキャンセルされました。再試行してください。';

  @override
  String get lockConfigurationError => 'アプリロック設定を安全に読み取れないため、アクセスは許可されませんでした。';

  @override
  String get forgotPinGuidance =>
      'ローカル専用モードにはオンライン PIN 復旧がありません。KeEv は PIN を迂回せず、家計簿データを自動削除しません。';

  @override
  String get relockPolicy => 'アプリがバックグラウンドに移るとロックします。';

  @override
  String get privacyCover => 'KeEv Ledger が非アクティブな間は財務情報を隠します。';

  @override
  String get cloudAccount => 'クラウドアカウント';

  @override
  String get localOnlyModeTitle => 'ローカルのみ';

  @override
  String get localOnlyDataNotice => '記帳データは現在この端末だけに保存されます。アカウントやネット接続は不要です。';

  @override
  String get cloudAccountConnected => 'この端末には認証済みの KeEv クラウドセッションがあります。';

  @override
  String get cloudOptionalDescription =>
      '今後のクラウドバックアップでは KeEv アカウントを任意で利用できます。アカウントがなくてもローカル記帳を続けられます。';

  @override
  String get cloudAccountOptions => '任意のクラウドアカウントを確認';

  @override
  String get signInWithApple => 'Apple でサインイン';

  @override
  String get signInWithGoogle => 'Google でサインイン';

  @override
  String get signInWithEmail => 'メールで続ける';

  @override
  String get signOut => 'サインアウト';

  @override
  String get cloudUnavailableDevelopment =>
      'このビルドではクラウドサインインとバックアップは有効ではありません。データはアップロードされません。';

  @override
  String get continueLocalOnly => 'ローカルのみで続ける';

  @override
  String get cloudAccountError => 'クラウドアカウントサービスがリクエストを完了できませんでした。';

  @override
  String get cloudSignedOut => 'サインアウト済み';

  @override
  String get cloudAuthenticating => 'サインイン中…';

  @override
  String get cloudReauthenticationRequired =>
      'クラウドアカウント機能を続けるには、もう一度サインインしてください。';

  @override
  String get cloudTemporarilyUnavailable =>
      'クラウドサービスは一時的に利用できません。安全なセッションは保持されています。';

  @override
  String get cloudConfigurationUnavailable =>
      'このビルドにはクラウドサインインが設定されていません。ローカルのみで引き続き利用できます。';

  @override
  String get cloudBackupNotActive =>
      'クラウドバックアップはまだ有効ではありません。サインインしても家計簿データはアップロードされません。';

  @override
  String get emailAddress => 'メールアドレス';

  @override
  String get sendOtp => 'コードを送信';

  @override
  String get otpCode => '6桁のコード';

  @override
  String get verifyOtp => 'コードを確認';

  @override
  String get resendOtp => 'コードを再送';

  @override
  String get otpSent => 'サインインコードを送信しました。メールを確認してください。';

  @override
  String get invalidOtp => 'コードが正しくありません。';

  @override
  String get expiredOtp => 'コードの有効期限が切れました。新しいコードを取得してください。';

  @override
  String get authRateLimited => 'リクエストが多すぎます。しばらくしてから再試行してください。';

  @override
  String get cloudNetworkUnavailable =>
      'ネットワーク接続がありません。保存済みのクラウドセッションは保持されています。';

  @override
  String get appLockCloudSeparation =>
      'アプリロックはこの端末だけを保護します。PIN と生体認証は KeEv クラウドのサインイン情報ではありません。';

  @override
  String get backupStatus => 'バックアップ状態';

  @override
  String get localBackup => 'ローカルバックアップ';

  @override
  String get cloudBackup => 'クラウドバックアップ';

  @override
  String get createEncryptedBackup => '暗号化バックアップを作成';

  @override
  String get restoreFromBackupFile => 'バックアップファイルから復元';

  @override
  String get backupPassphrase => 'バックアップパスフレーズ';

  @override
  String get confirmBackupPassphrase => 'パスフレーズを確認';

  @override
  String get backupPassphraseHelp =>
      '10文字以上を使用してください。忘れたパスフレーズを KeEv が復元することはできません。';

  @override
  String get backupSecurityInfo => 'バックアップは書き出しまたはアップロード前に、この端末で暗号化されます。';

  @override
  String get backupCreated => '暗号化バックアップを作成しました。';

  @override
  String get backupFailed => 'バックアップを作成できませんでした。';

  @override
  String get restorePreview => '復元プレビュー';

  @override
  String get restoreReplaceWarning => '現在のローカル記帳データをすべて置き換えます。データは結合されません。';

  @override
  String get restoreConfirm => '置き換えて復元';

  @override
  String get restoreCompleted => 'バックアップを復元しました。';

  @override
  String get restoreFailedMessage => 'バックアップを復元できませんでした。';

  @override
  String get wrongBackupPassphrase => 'パスフレーズが違うか、バックアップが変更されています。';

  @override
  String get corruptedBackup => 'バックアップが無効、破損、または未対応です。';

  @override
  String get cloudSignInRequired =>
      '任意のクラウドバックアップにはサインインが必要です。ローカルバックアップは引き続き使用できます。';

  @override
  String get noCloudBackups => 'クラウドバックアップはありません。';

  @override
  String get deleteBackup => 'バックアップを削除';

  @override
  String get backupCreatedAt => '作成日時';

  @override
  String get backupFormatVersion => 'バックアップ形式';

  @override
  String get backupSourceApp => '作成元アプリ';

  @override
  String get backupBaseCurrency => '基準通貨';

  @override
  String get encryptedBackupSize => '暗号化サイズ';

  @override
  String get deleteCloudBackupConfirmation =>
      'このクラウドバックアップを完全に削除しますか？ローカルの記帳データは削除されません。';

  @override
  String get syncTitle => 'ライブ同期';

  @override
  String get syncEnable => '同期を有効化';

  @override
  String get syncDescription =>
      '複数端末の台帳を揃えます。ライブ同期では読み取り可能な台帳データを KeEv クラウドアカウントに保存し、暗号化バックアップとは別に扱います。';

  @override
  String get syncNow => '今すぐ同期';

  @override
  String get syncPause => '同期を一時停止';

  @override
  String get syncResume => '同期を再開';

  @override
  String get syncDisable => 'この端末のリンクを解除';

  @override
  String get syncLocalData => 'ローカルデータ';

  @override
  String get syncCloudData => 'クラウドデータ';

  @override
  String get syncKeepLocal => 'ローカルを使用';

  @override
  String get syncKeepCloud => 'クラウドを使用';

  @override
  String get syncCancel => 'キャンセル';

  @override
  String get syncNeedsReconciliation => '確認が必要';

  @override
  String get syncConflicts => '競合への対応が必要';

  @override
  String get syncActive => '同期は有効です';

  @override
  String get syncPaused => '同期は一時停止中';

  @override
  String get syncUpToDate => '最新です';

  @override
  String get syncOffline => '一時的に利用できません';

  @override
  String get syncAuthRequired => '認証が必要です';

  @override
  String get syncPendingChanges => '保留中の変更';

  @override
  String get syncLastSynced => '最終同期';

  @override
  String get syncChecking => 'ローカルとクラウドのデータを確認中…';

  @override
  String get syncInitializing => '台帳を準備中…';

  @override
  String get syncUploading => 'ローカルデータをアップロードして検証中…';

  @override
  String get syncDownloading => 'クラウドデータをダウンロード中…';

  @override
  String get syncVerifying => '台帳全体を検証中…';

  @override
  String get syncFinalizing => '同期を完了中…';

  @override
  String get syncDestructiveWarning =>
      'この選択では一方の台帳が置き換わります。復旧が必要になる可能性がある場合は先に暗号化バックアップを作成してください。';

  @override
  String get syncUnlinkWarning =>
      'ローカルとクラウドの台帳は残ります。以後この端末での変更はローカルのみとなり、保留中の変更も送信されません。';

  @override
  String get syncConflictsTitle => '競合を解決';

  @override
  String get syncLocalDelete => 'この端末で削除済み';

  @override
  String get syncCloudDelete => 'クラウドで削除済み';

  @override
  String get syncNoAutomaticMerge =>
      'ローカルとクラウドの両方にデータがあります。開始元を選択してください。KeEv は自動結合しません。';

  @override
  String get privacyAdvertising => 'プライバシーと広告';

  @override
  String get privacyAdvertisingSummary => '広告のプライバシー設定を管理';

  @override
  String get advertisingPreferences => '広告設定';

  @override
  String get advertisingPrivacyExplanation =>
      '広告は台帳とは分離されています。KeEv は残高、取引、メモ、レシートなどの金融情報を広告サービスに送信しません。';

  @override
  String get managePrivacyChoices => 'プライバシー設定を管理';

  @override
  String get advertisement => '広告';
}
