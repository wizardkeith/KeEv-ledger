import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_th.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('th'),
    Locale('zh'),
    Locale('zh', 'CN'),
    Locale('zh', 'HK'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'KeEv Ledger'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @budget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @accounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accounts;

  /// No description provided for @projects.
  ///
  /// In en, this message translates to:
  /// **'Projects / Tags'**
  String get projects;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @backup.
  ///
  /// In en, this message translates to:
  /// **'Backup / Restore'**
  String get backup;

  /// No description provided for @authentication.
  ///
  /// In en, this message translates to:
  /// **'KeEv Account'**
  String get authentication;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'A clearer view of your day'**
  String get welcome;

  /// No description provided for @intro.
  ///
  /// In en, this message translates to:
  /// **'Simple bookkeeping, at your own pace.'**
  String get intro;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Some features are still in development.'**
  String get preview;

  /// No description provided for @emptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your space is ready'**
  String get emptyTitle;

  /// No description provided for @emptyBody.
  ///
  /// In en, this message translates to:
  /// **'This feature is being prepared. No sample financial data is shown.'**
  String get emptyBody;

  /// No description provided for @addUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Quick Add arrives in Phase 2. You cannot save a transaction in this preview.'**
  String get addUnavailable;

  /// No description provided for @languageIntro.
  ///
  /// In en, this message translates to:
  /// **'Choose a language. You can change it later in Settings.'**
  String get languageIntro;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @privacyIntro.
  ///
  /// In en, this message translates to:
  /// **'Start on your device without creating an account. This preview has no KeEv cloud, advertising or analytics services.'**
  String get privacyIntro;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get terms;

  /// No description provided for @developmentLegal.
  ///
  /// In en, this message translates to:
  /// **'DEVELOPMENT CONTENT — These are placeholders, not the final Privacy Policy or Terms. Final wording will be reviewed against the implemented services before release.'**
  String get developmentLegal;

  /// No description provided for @acceptPreview.
  ///
  /// In en, this message translates to:
  /// **'I understand this is a development preview.'**
  String get acceptPreview;

  /// No description provided for @startLocal.
  ///
  /// In en, this message translates to:
  /// **'Start Local Only'**
  String get startLocal;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @followSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow device language'**
  String get followSystem;

  /// No description provided for @localMode.
  ///
  /// In en, this message translates to:
  /// **'Local Only'**
  String get localMode;

  /// No description provided for @sessionNotice.
  ///
  /// In en, this message translates to:
  /// **'Language, appearance and onboarding choices last for this session only.'**
  String get sessionNotice;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorTitle;

  /// No description provided for @preferencesError.
  ///
  /// In en, this message translates to:
  /// **'Your preference could not be updated. Please try again.'**
  String get preferencesError;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @phaseLabel.
  ///
  /// In en, this message translates to:
  /// **'Phase {phase} preview'**
  String phaseLabel(int phase);

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageHongKong.
  ///
  /// In en, this message translates to:
  /// **'繁體中文（香港）'**
  String get languageHongKong;

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'简体中文'**
  String get languageChinese;

  /// No description provided for @languageJapanese.
  ///
  /// In en, this message translates to:
  /// **'日本語'**
  String get languageJapanese;

  /// No description provided for @languageThai.
  ///
  /// In en, this message translates to:
  /// **'ไทย'**
  String get languageThai;

  /// No description provided for @quickAdd.
  ///
  /// In en, this message translates to:
  /// **'Quick Add'**
  String get quickAdd;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @transfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transfer;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @sentAmount.
  ///
  /// In en, this message translates to:
  /// **'Sent amount'**
  String get sentAmount;

  /// No description provided for @receivedAmount.
  ///
  /// In en, this message translates to:
  /// **'Received amount'**
  String get receivedAmount;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @sourceAccount.
  ///
  /// In en, this message translates to:
  /// **'From account'**
  String get sourceAccount;

  /// No description provided for @destinationAccount.
  ///
  /// In en, this message translates to:
  /// **'To account'**
  String get destinationAccount;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @businessDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get businessDate;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptional;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @savedLocally.
  ///
  /// In en, this message translates to:
  /// **'Saved on this device'**
  String get savedLocally;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Try again.'**
  String get saveFailed;

  /// No description provided for @invalidMoney.
  ///
  /// In en, this message translates to:
  /// **'Enter a positive amount with the correct decimal places.'**
  String get invalidMoney;

  /// No description provided for @chooseAccount.
  ///
  /// In en, this message translates to:
  /// **'Choose an account'**
  String get chooseAccount;

  /// No description provided for @chooseCategory.
  ///
  /// In en, this message translates to:
  /// **'Choose a category'**
  String get chooseCategory;

  /// No description provided for @chooseOtherAccount.
  ///
  /// In en, this message translates to:
  /// **'Choose a different destination account'**
  String get chooseOtherAccount;

  /// No description provided for @addAccount.
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get addAccount;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get addCategory;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @accountType.
  ///
  /// In en, this message translates to:
  /// **'Account type'**
  String get accountType;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @firstAccount.
  ///
  /// In en, this message translates to:
  /// **'Add an account to get started.'**
  String get firstAccount;

  /// No description provided for @secondAccount.
  ///
  /// In en, this message translates to:
  /// **'Create another account for transfers.'**
  String get secondAccount;

  /// No description provided for @categoryNeeded.
  ///
  /// In en, this message translates to:
  /// **'Add a category for this type.'**
  String get categoryNeeded;

  /// No description provided for @noHistory.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet.'**
  String get noHistory;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @bank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get bank;

  /// No description provided for @creditCard.
  ///
  /// In en, this message translates to:
  /// **'Credit card'**
  String get creditCard;

  /// No description provided for @eWallet.
  ///
  /// In en, this message translates to:
  /// **'E-wallet'**
  String get eWallet;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @receivedRequired.
  ///
  /// In en, this message translates to:
  /// **'A received amount is required for different currencies.'**
  String get receivedRequired;

  /// No description provided for @differentAccounts.
  ///
  /// In en, this message translates to:
  /// **'Both accounts must be different.'**
  String get differentAccounts;

  /// No description provided for @archivedEntity.
  ///
  /// In en, this message translates to:
  /// **'Account or category is archived.'**
  String get archivedEntity;

  /// No description provided for @mismatchEntity.
  ///
  /// In en, this message translates to:
  /// **'Currency or category does not match.'**
  String get mismatchEntity;

  /// No description provided for @beforeOpening.
  ///
  /// In en, this message translates to:
  /// **'The date must be on or after both accounts opened.'**
  String get beforeOpening;

  /// No description provided for @addBudget.
  ///
  /// In en, this message translates to:
  /// **'Add budget'**
  String get addBudget;

  /// No description provided for @budgetName.
  ///
  /// In en, this message translates to:
  /// **'Budget name'**
  String get budgetName;

  /// No description provided for @budgetAmount.
  ///
  /// In en, this message translates to:
  /// **'Budget amount'**
  String get budgetAmount;

  /// No description provided for @budgetMonth.
  ///
  /// In en, this message translates to:
  /// **'Month (YYYY-MM)'**
  String get budgetMonth;

  /// No description provided for @budgetCategory.
  ///
  /// In en, this message translates to:
  /// **'Expense category (optional)'**
  String get budgetCategory;

  /// No description provided for @allExpenses.
  ///
  /// In en, this message translates to:
  /// **'All expenses'**
  String get allExpenses;

  /// No description provided for @warningAt.
  ///
  /// In en, this message translates to:
  /// **'Warning at {percent}%'**
  String warningAt(int percent);

  /// No description provided for @spent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spent;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @overBudget.
  ///
  /// In en, this message translates to:
  /// **'Over budget'**
  String get overBudget;

  /// No description provided for @missingFx.
  ///
  /// In en, this message translates to:
  /// **'Incomplete · missing FX for: {currencies}'**
  String missingFx(String currencies);

  /// No description provided for @noBudgets.
  ///
  /// In en, this message translates to:
  /// **'No budgets for this month yet.'**
  String get noBudgets;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @project.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get project;

  /// No description provided for @noProject.
  ///
  /// In en, this message translates to:
  /// **'No project'**
  String get noProject;

  /// No description provided for @addProject.
  ///
  /// In en, this message translates to:
  /// **'Add project'**
  String get addProject;

  /// No description provided for @projectName.
  ///
  /// In en, this message translates to:
  /// **'Project name'**
  String get projectName;

  /// No description provided for @projectDescription.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get projectDescription;

  /// No description provided for @noProjects.
  ///
  /// In en, this message translates to:
  /// **'No active projects yet.'**
  String get noProjects;

  /// No description provided for @incomeTotal.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get incomeTotal;

  /// No description provided for @expenseTotal.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expenseTotal;

  /// No description provided for @netTotal.
  ///
  /// In en, this message translates to:
  /// **'Net'**
  String get netTotal;

  /// No description provided for @projectArchived.
  ///
  /// In en, this message translates to:
  /// **'This project is archived.'**
  String get projectArchived;

  /// No description provided for @invalidMonth.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid month as YYYY-MM.'**
  String get invalidMonth;

  /// No description provided for @incomeExpenseReport.
  ///
  /// In en, this message translates to:
  /// **'Income & Expense Report'**
  String get incomeExpenseReport;

  /// No description provided for @assetsLiabilitiesOverview.
  ///
  /// In en, this message translates to:
  /// **'Assets & Liabilities Overview'**
  String get assetsLiabilitiesOverview;

  /// No description provided for @reportPeriod.
  ///
  /// In en, this message translates to:
  /// **'Report period'**
  String get reportPeriod;

  /// No description provided for @previousPeriod.
  ///
  /// In en, this message translates to:
  /// **'Previous period'**
  String get previousPeriod;

  /// No description provided for @reportComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete calculation'**
  String get reportComplete;

  /// No description provided for @reportIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Incomplete calculation'**
  String get reportIncomplete;

  /// No description provided for @categoryBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Category breakdown'**
  String get categoryBreakdown;

  /// No description provided for @accountBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Account breakdown'**
  String get accountBreakdown;

  /// No description provided for @dailyTrend.
  ///
  /// In en, this message translates to:
  /// **'Daily trend'**
  String get dailyTrend;

  /// No description provided for @asOf.
  ///
  /// In en, this message translates to:
  /// **'As of {date}'**
  String asOf(String date);

  /// No description provided for @assetsLabel.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get assetsLabel;

  /// No description provided for @liabilitiesLabel.
  ///
  /// In en, this message translates to:
  /// **'Liabilities'**
  String get liabilitiesLabel;

  /// No description provided for @reportingCurrency.
  ///
  /// In en, this message translates to:
  /// **'Reporting currency'**
  String get reportingCurrency;

  /// No description provided for @prepareCsv.
  ///
  /// In en, this message translates to:
  /// **'Prepare CSV'**
  String get prepareCsv;

  /// No description provided for @csvReady.
  ///
  /// In en, this message translates to:
  /// **'CSV prepared locally'**
  String get csvReady;

  /// No description provided for @comparisonUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No meaningful previous-period percentage'**
  String get comparisonUnavailable;

  /// No description provided for @changeFromPrevious.
  ///
  /// In en, this message translates to:
  /// **'{percent}% vs previous period'**
  String changeFromPrevious(String percent);

  /// No description provided for @reportDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Personal bookkeeping overview — not a professional financial statement.'**
  String get reportDisclaimer;

  /// No description provided for @allTransactions.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allTransactions;

  /// No description provided for @searchNotes.
  ///
  /// In en, this message translates to:
  /// **'Search notes'**
  String get searchNotes;

  /// No description provided for @applyFilter.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyFilter;

  /// No description provided for @noReportData.
  ///
  /// In en, this message translates to:
  /// **'No activity in this period.'**
  String get noReportData;

  /// No description provided for @receiptsOptional.
  ///
  /// In en, this message translates to:
  /// **'Receipt photos (optional)'**
  String get receiptsOptional;

  /// No description provided for @receiptPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Stored only on this device. Up to 5 photos.'**
  String get receiptPrivacyNote;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @choosePhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose photo'**
  String get choosePhoto;

  /// No description provided for @receiptPhoto.
  ///
  /// In en, this message translates to:
  /// **'Receipt photo'**
  String get receiptPhoto;

  /// No description provided for @removeReceipt.
  ///
  /// In en, this message translates to:
  /// **'Remove receipt'**
  String get removeReceipt;

  /// No description provided for @viewReceipt.
  ///
  /// In en, this message translates to:
  /// **'View receipt'**
  String get viewReceipt;

  /// No description provided for @receiptLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You can attach up to 5 receipt photos.'**
  String get receiptLimitReached;

  /// No description provided for @receiptInvalid.
  ///
  /// In en, this message translates to:
  /// **'This is not a supported receipt image.'**
  String get receiptInvalid;

  /// No description provided for @receiptTooLarge.
  ///
  /// In en, this message translates to:
  /// **'This image is too large to process safely.'**
  String get receiptTooLarge;

  /// No description provided for @receiptPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera or photo access was not granted. You can enable it in Settings.'**
  String get receiptPermissionDenied;

  /// No description provided for @voiceEntry.
  ///
  /// In en, this message translates to:
  /// **'Voice Entry'**
  String get voiceEntry;

  /// No description provided for @listening.
  ///
  /// In en, this message translates to:
  /// **'Listening…'**
  String get listening;

  /// No description provided for @stopListening.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopListening;

  /// No description provided for @cancelVoice.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelVoice;

  /// No description provided for @processingSpeech.
  ///
  /// In en, this message translates to:
  /// **'Processing speech…'**
  String get processingSpeech;

  /// No description provided for @reviewVoiceDraft.
  ///
  /// In en, this message translates to:
  /// **'Voice only suggests draft fields. Review them before saving.'**
  String get reviewVoiceDraft;

  /// No description provided for @voicePermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone or speech permission was denied. You can continue manually or enable it in Settings.'**
  String get voicePermissionDenied;

  /// No description provided for @voiceLocaleUnavailable.
  ///
  /// In en, this message translates to:
  /// **'A suitable speech language is not available on this device. Continue with manual entry.'**
  String get voiceLocaleUnavailable;

  /// No description provided for @voiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition is unavailable. Continue with manual entry.'**
  String get voiceUnavailable;

  /// No description provided for @voiceRecognitionFailed.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition failed. Your existing draft was kept.'**
  String get voiceRecognitionFailed;

  /// No description provided for @voicePrivacyDisclosure.
  ///
  /// In en, this message translates to:
  /// **'Your device speech service may process audio online. KeEv does not store audio or send it to AI or analytics.'**
  String get voicePrivacyDisclosure;

  /// No description provided for @appLock.
  ///
  /// In en, this message translates to:
  /// **'App Lock'**
  String get appLock;

  /// No description provided for @appLocked.
  ///
  /// In en, this message translates to:
  /// **'KeEv Ledger is locked'**
  String get appLocked;

  /// No description provided for @appLockDescription.
  ///
  /// In en, this message translates to:
  /// **'Protect local bookkeeping on this device with a PIN and optional system biometrics.'**
  String get appLockDescription;

  /// No description provided for @appLockEnabled.
  ///
  /// In en, this message translates to:
  /// **'App Lock is enabled'**
  String get appLockEnabled;

  /// No description provided for @setPin.
  ///
  /// In en, this message translates to:
  /// **'Set PIN'**
  String get setPin;

  /// No description provided for @confirmPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get confirmPin;

  /// No description provided for @currentPin.
  ///
  /// In en, this message translates to:
  /// **'Current PIN'**
  String get currentPin;

  /// No description provided for @newPin.
  ///
  /// In en, this message translates to:
  /// **'New PIN'**
  String get newPin;

  /// No description provided for @enterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get enterPin;

  /// No description provided for @pinRequirements.
  ///
  /// In en, this message translates to:
  /// **'Enter a 4–6 digit PIN.'**
  String get pinRequirements;

  /// No description provided for @pinMismatch.
  ///
  /// In en, this message translates to:
  /// **'The PINs do not match.'**
  String get pinMismatch;

  /// No description provided for @incorrectPin.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN.'**
  String get incorrectPin;

  /// No description provided for @tryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again later.'**
  String get tryAgainLater;

  /// No description provided for @useBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Use biometrics'**
  String get useBiometrics;

  /// No description provided for @biometricUnavailable.
  ///
  /// In en, this message translates to:
  /// **'System biometrics are unavailable or not enrolled.'**
  String get biometricUnavailable;

  /// No description provided for @biometricCancelled.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication was cancelled.'**
  String get biometricCancelled;

  /// No description provided for @biometricLocked.
  ///
  /// In en, this message translates to:
  /// **'System biometrics are locked. Use your KeEv PIN.'**
  String get biometricLocked;

  /// No description provided for @biometricFailed.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication failed. Use your PIN.'**
  String get biometricFailed;

  /// No description provided for @biometricPromptReason.
  ///
  /// In en, this message translates to:
  /// **'Unlock your local KeEv Ledger'**
  String get biometricPromptReason;

  /// No description provided for @biometricSystemDescription.
  ///
  /// In en, this message translates to:
  /// **'Uses the biometric method configured on this device.'**
  String get biometricSystemDescription;

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @lockNow.
  ///
  /// In en, this message translates to:
  /// **'Lock Now'**
  String get lockNow;

  /// No description provided for @changePin.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get changePin;

  /// No description provided for @disableAppLock.
  ///
  /// In en, this message translates to:
  /// **'Disable App Lock'**
  String get disableAppLock;

  /// No description provided for @authenticationRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your current PIN to continue.'**
  String get authenticationRequired;

  /// No description provided for @authenticationCancelled.
  ///
  /// In en, this message translates to:
  /// **'Authentication was cancelled. Try again.'**
  String get authenticationCancelled;

  /// No description provided for @lockConfigurationError.
  ///
  /// In en, this message translates to:
  /// **'App Lock configuration could not be read safely. Access was not granted.'**
  String get lockConfigurationError;

  /// No description provided for @forgotPinGuidance.
  ///
  /// In en, this message translates to:
  /// **'There is no online PIN recovery in Local Only mode. KeEv cannot bypass the PIN or automatically delete your bookkeeping data.'**
  String get forgotPinGuidance;

  /// No description provided for @relockPolicy.
  ///
  /// In en, this message translates to:
  /// **'Locks when the app moves to the background.'**
  String get relockPolicy;

  /// No description provided for @privacyCover.
  ///
  /// In en, this message translates to:
  /// **'Financial details are hidden while KeEv Ledger is inactive.'**
  String get privacyCover;

  /// No description provided for @cloudAccount.
  ///
  /// In en, this message translates to:
  /// **'Cloud Account'**
  String get cloudAccount;

  /// No description provided for @localOnlyModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Local Only'**
  String get localOnlyModeTitle;

  /// No description provided for @localOnlyDataNotice.
  ///
  /// In en, this message translates to:
  /// **'Your bookkeeping data remains on this device. No account or network connection is required.'**
  String get localOnlyDataNotice;

  /// No description provided for @cloudAccountConnected.
  ///
  /// In en, this message translates to:
  /// **'This device has an authenticated KeEv cloud session.'**
  String get cloudAccountConnected;

  /// No description provided for @cloudOptionalDescription.
  ///
  /// In en, this message translates to:
  /// **'A KeEv cloud account will be optional for future backup features. Local bookkeeping continues without one.'**
  String get cloudOptionalDescription;

  /// No description provided for @cloudAccountOptions.
  ///
  /// In en, this message translates to:
  /// **'View optional cloud account'**
  String get cloudAccountOptions;

  /// No description provided for @signInWithApple.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get signInWithApple;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @signInWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Continue with email'**
  String get signInWithEmail;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @cloudUnavailableDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Cloud sign-in and backup are not active in this build. No data is uploaded.'**
  String get cloudUnavailableDevelopment;

  /// No description provided for @continueLocalOnly.
  ///
  /// In en, this message translates to:
  /// **'Continue Local Only'**
  String get continueLocalOnly;

  /// No description provided for @cloudAccountError.
  ///
  /// In en, this message translates to:
  /// **'The cloud account service could not complete that request.'**
  String get cloudAccountError;

  /// No description provided for @cloudSignedOut.
  ///
  /// In en, this message translates to:
  /// **'Signed out'**
  String get cloudSignedOut;

  /// No description provided for @cloudAuthenticating.
  ///
  /// In en, this message translates to:
  /// **'Signing in…'**
  String get cloudAuthenticating;

  /// No description provided for @cloudReauthenticationRequired.
  ///
  /// In en, this message translates to:
  /// **'Sign in again to continue using cloud account features.'**
  String get cloudReauthenticationRequired;

  /// No description provided for @cloudTemporarilyUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Cloud service is temporarily unavailable. Your secure session has been kept.'**
  String get cloudTemporarilyUnavailable;

  /// No description provided for @cloudConfigurationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Cloud sign-in is not configured in this build. Local Only remains available.'**
  String get cloudConfigurationUnavailable;

  /// No description provided for @cloudBackupNotActive.
  ///
  /// In en, this message translates to:
  /// **'Cloud backup is not active yet. Signing in does not upload your bookkeeping data.'**
  String get cloudBackupNotActive;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendOtp;

  /// No description provided for @otpCode.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get otpCode;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify code'**
  String get verifyOtp;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendOtp;

  /// No description provided for @otpSent.
  ///
  /// In en, this message translates to:
  /// **'A sign-in code was sent. Check your email.'**
  String get otpSent;

  /// No description provided for @invalidOtp.
  ///
  /// In en, this message translates to:
  /// **'The code is invalid.'**
  String get invalidOtp;

  /// No description provided for @expiredOtp.
  ///
  /// In en, this message translates to:
  /// **'The code has expired. Request a new one.'**
  String get expiredOtp;

  /// No description provided for @authRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please wait and try again.'**
  String get authRateLimited;

  /// No description provided for @cloudNetworkUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No network connection. Your saved cloud session was kept.'**
  String get cloudNetworkUnavailable;

  /// No description provided for @appLockCloudSeparation.
  ///
  /// In en, this message translates to:
  /// **'App Lock protects this device only. Its PIN and biometrics are not KeEv cloud sign-in credentials.'**
  String get appLockCloudSeparation;

  /// No description provided for @backupStatus.
  ///
  /// In en, this message translates to:
  /// **'Backup status'**
  String get backupStatus;

  /// No description provided for @localBackup.
  ///
  /// In en, this message translates to:
  /// **'Local backup'**
  String get localBackup;

  /// No description provided for @cloudBackup.
  ///
  /// In en, this message translates to:
  /// **'Cloud backup'**
  String get cloudBackup;

  /// No description provided for @createEncryptedBackup.
  ///
  /// In en, this message translates to:
  /// **'Create encrypted backup'**
  String get createEncryptedBackup;

  /// No description provided for @restoreFromBackupFile.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup file'**
  String get restoreFromBackupFile;

  /// No description provided for @backupPassphrase.
  ///
  /// In en, this message translates to:
  /// **'Backup passphrase'**
  String get backupPassphrase;

  /// No description provided for @confirmBackupPassphrase.
  ///
  /// In en, this message translates to:
  /// **'Confirm backup passphrase'**
  String get confirmBackupPassphrase;

  /// No description provided for @backupPassphraseHelp.
  ///
  /// In en, this message translates to:
  /// **'Use at least 10 characters. KeEv cannot recover a forgotten backup passphrase.'**
  String get backupPassphraseHelp;

  /// No description provided for @backupSecurityInfo.
  ///
  /// In en, this message translates to:
  /// **'Backups are encrypted on this device before export or upload.'**
  String get backupSecurityInfo;

  /// No description provided for @backupCreated.
  ///
  /// In en, this message translates to:
  /// **'Encrypted backup created.'**
  String get backupCreated;

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'The backup could not be created.'**
  String get backupFailed;

  /// No description provided for @restorePreview.
  ///
  /// In en, this message translates to:
  /// **'Restore preview'**
  String get restorePreview;

  /// No description provided for @restoreReplaceWarning.
  ///
  /// In en, this message translates to:
  /// **'This will replace all current local bookkeeping data. It will not merge records.'**
  String get restoreReplaceWarning;

  /// No description provided for @restoreConfirm.
  ///
  /// In en, this message translates to:
  /// **'Replace and restore'**
  String get restoreConfirm;

  /// No description provided for @restoreCompleted.
  ///
  /// In en, this message translates to:
  /// **'Backup restored.'**
  String get restoreCompleted;

  /// No description provided for @restoreFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'The backup could not be restored.'**
  String get restoreFailedMessage;

  /// No description provided for @wrongBackupPassphrase.
  ///
  /// In en, this message translates to:
  /// **'The passphrase is incorrect or the backup was changed.'**
  String get wrongBackupPassphrase;

  /// No description provided for @corruptedBackup.
  ///
  /// In en, this message translates to:
  /// **'This backup is invalid, corrupted, or unsupported.'**
  String get corruptedBackup;

  /// No description provided for @cloudSignInRequired.
  ///
  /// In en, this message translates to:
  /// **'Sign in to use optional cloud backup. Local backup remains available.'**
  String get cloudSignInRequired;

  /// No description provided for @noCloudBackups.
  ///
  /// In en, this message translates to:
  /// **'No cloud backups yet.'**
  String get noCloudBackups;

  /// No description provided for @deleteBackup.
  ///
  /// In en, this message translates to:
  /// **'Delete backup'**
  String get deleteBackup;

  /// No description provided for @backupCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get backupCreatedAt;

  /// No description provided for @backupFormatVersion.
  ///
  /// In en, this message translates to:
  /// **'Backup format'**
  String get backupFormatVersion;

  /// No description provided for @backupSourceApp.
  ///
  /// In en, this message translates to:
  /// **'Source app'**
  String get backupSourceApp;

  /// No description provided for @backupBaseCurrency.
  ///
  /// In en, this message translates to:
  /// **'Base currency'**
  String get backupBaseCurrency;

  /// No description provided for @encryptedBackupSize.
  ///
  /// In en, this message translates to:
  /// **'Encrypted size'**
  String get encryptedBackupSize;

  /// No description provided for @deleteCloudBackupConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete this cloud backup? Your local bookkeeping data will not be deleted.'**
  String get deleteCloudBackupConfirmation;

  /// No description provided for @syncTitle.
  ///
  /// In en, this message translates to:
  /// **'Live Sync'**
  String get syncTitle;

  /// No description provided for @syncEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable Sync'**
  String get syncEnable;

  /// No description provided for @syncDescription.
  ///
  /// In en, this message translates to:
  /// **'Keep this ledger aligned across your devices. Live sync stores readable ledger records in your KeEv cloud account and is separate from encrypted backup.'**
  String get syncDescription;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get syncNow;

  /// No description provided for @syncPause.
  ///
  /// In en, this message translates to:
  /// **'Pause Sync'**
  String get syncPause;

  /// No description provided for @syncResume.
  ///
  /// In en, this message translates to:
  /// **'Resume Sync'**
  String get syncResume;

  /// No description provided for @syncDisable.
  ///
  /// In en, this message translates to:
  /// **'Unlink This Device'**
  String get syncDisable;

  /// No description provided for @syncLocalData.
  ///
  /// In en, this message translates to:
  /// **'Local data'**
  String get syncLocalData;

  /// No description provided for @syncCloudData.
  ///
  /// In en, this message translates to:
  /// **'Cloud data'**
  String get syncCloudData;

  /// No description provided for @syncKeepLocal.
  ///
  /// In en, this message translates to:
  /// **'Keep Local'**
  String get syncKeepLocal;

  /// No description provided for @syncKeepCloud.
  ///
  /// In en, this message translates to:
  /// **'Keep Cloud'**
  String get syncKeepCloud;

  /// No description provided for @syncCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get syncCancel;

  /// No description provided for @syncNeedsReconciliation.
  ///
  /// In en, this message translates to:
  /// **'Needs reconciliation'**
  String get syncNeedsReconciliation;

  /// No description provided for @syncConflicts.
  ///
  /// In en, this message translates to:
  /// **'Conflicts need attention'**
  String get syncConflicts;

  /// No description provided for @syncActive.
  ///
  /// In en, this message translates to:
  /// **'Sync active'**
  String get syncActive;

  /// No description provided for @syncPaused.
  ///
  /// In en, this message translates to:
  /// **'Sync paused'**
  String get syncPaused;

  /// No description provided for @syncUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Up to date'**
  String get syncUpToDate;

  /// No description provided for @syncOffline.
  ///
  /// In en, this message translates to:
  /// **'Temporarily unavailable'**
  String get syncOffline;

  /// No description provided for @syncAuthRequired.
  ///
  /// In en, this message translates to:
  /// **'Authentication required'**
  String get syncAuthRequired;

  /// No description provided for @syncPendingChanges.
  ///
  /// In en, this message translates to:
  /// **'Pending changes'**
  String get syncPendingChanges;

  /// No description provided for @syncLastSynced.
  ///
  /// In en, this message translates to:
  /// **'Last synced'**
  String get syncLastSynced;

  /// No description provided for @syncChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking local and cloud data…'**
  String get syncChecking;

  /// No description provided for @syncInitializing.
  ///
  /// In en, this message translates to:
  /// **'Preparing your ledger…'**
  String get syncInitializing;

  /// No description provided for @syncUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading and verifying local data…'**
  String get syncUploading;

  /// No description provided for @syncDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading cloud data…'**
  String get syncDownloading;

  /// No description provided for @syncVerifying.
  ///
  /// In en, this message translates to:
  /// **'Verifying the complete ledger…'**
  String get syncVerifying;

  /// No description provided for @syncFinalizing.
  ///
  /// In en, this message translates to:
  /// **'Finalizing sync…'**
  String get syncFinalizing;

  /// No description provided for @syncDestructiveWarning.
  ///
  /// In en, this message translates to:
  /// **'This choice replaces one ledger. Create an encrypted backup first if you may need to recover it.'**
  String get syncDestructiveWarning;

  /// No description provided for @syncUnlinkWarning.
  ///
  /// In en, this message translates to:
  /// **'Local and cloud ledgers remain. Future edits on this device will stay local and pending changes will not be sent.'**
  String get syncUnlinkWarning;

  /// No description provided for @syncConflictsTitle.
  ///
  /// In en, this message translates to:
  /// **'Resolve Conflicts'**
  String get syncConflictsTitle;

  /// No description provided for @syncLocalDelete.
  ///
  /// In en, this message translates to:
  /// **'Deleted on this device'**
  String get syncLocalDelete;

  /// No description provided for @syncCloudDelete.
  ///
  /// In en, this message translates to:
  /// **'Deleted in cloud'**
  String get syncCloudDelete;

  /// No description provided for @syncNoAutomaticMerge.
  ///
  /// In en, this message translates to:
  /// **'Both ledgers contain data. Choose which ledger becomes the starting point; KeEv will not merge them automatically.'**
  String get syncNoAutomaticMerge;

  /// No description provided for @privacyAdvertising.
  ///
  /// In en, this message translates to:
  /// **'Privacy & advertising'**
  String get privacyAdvertising;

  /// No description provided for @privacyAdvertisingSummary.
  ///
  /// In en, this message translates to:
  /// **'Manage advertising privacy choices'**
  String get privacyAdvertisingSummary;

  /// No description provided for @advertisingPreferences.
  ///
  /// In en, this message translates to:
  /// **'Advertising preferences'**
  String get advertisingPreferences;

  /// No description provided for @advertisingPrivacyExplanation.
  ///
  /// In en, this message translates to:
  /// **'Advertising is separate from your ledger. KeEv does not send balances, transactions, notes, receipts, or other financial content to advertising services.'**
  String get advertisingPrivacyExplanation;

  /// No description provided for @managePrivacyChoices.
  ///
  /// In en, this message translates to:
  /// **'Manage privacy choices'**
  String get managePrivacyChoices;

  /// No description provided for @advertisement.
  ///
  /// In en, this message translates to:
  /// **'Advertisement'**
  String get advertisement;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'th', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'CN':
            return AppLocalizationsZhCn();
          case 'HK':
            return AppLocalizationsZhHk();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'th':
      return AppLocalizationsTh();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
