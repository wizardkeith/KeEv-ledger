// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get appTitle => 'KeEv บันทึกรายรับรายจ่าย';

  @override
  String get home => 'หน้าหลัก';

  @override
  String get history => 'ประวัติ';

  @override
  String get add => 'เพิ่ม';

  @override
  String get budget => 'งบประมาณ';

  @override
  String get more => 'เพิ่มเติม';

  @override
  String get accounts => 'บัญชีเงิน';

  @override
  String get projects => 'โครงการ / แท็ก';

  @override
  String get reports => 'รายงาน';

  @override
  String get settings => 'การตั้งค่า';

  @override
  String get language => 'ภาษา';

  @override
  String get appearance => 'รูปแบบ';

  @override
  String get backup => 'สำรอง / กู้คืน';

  @override
  String get authentication => 'บัญชี KeEv';

  @override
  String get premium => 'Premium';

  @override
  String get welcome => 'เห็นรายรับรายจ่ายแต่ละวันชัดเจน';

  @override
  String get intro => 'บันทึกง่าย ๆ ตามจังหวะของคุณ';

  @override
  String get preview => 'บางฟีเจอร์ยังอยู่ระหว่างพัฒนา';

  @override
  String get emptyTitle => 'พื้นที่ของคุณพร้อมแล้ว';

  @override
  String get emptyBody =>
      'ฟีเจอร์นี้อยู่ระหว่างเตรียมการ ไม่มีข้อมูลการเงินสมมติ';

  @override
  String get addUnavailable =>
      'การเพิ่มรายการอย่างรวดเร็วจะมาในระยะที่ 2 รุ่นตัวอย่างนี้ยังบันทึกรายการไม่ได้';

  @override
  String get languageIntro => 'เลือกภาษา คุณเปลี่ยนได้ภายหลังในการตั้งค่า';

  @override
  String get continueLabel => 'ดำเนินการต่อ';

  @override
  String get privacyIntro =>
      'เริ่มใช้งานบนอุปกรณ์นี้ได้โดยไม่ต้องสร้างบัญชี รุ่นตัวอย่างนี้ไม่มีบริการคลาวด์ของ KeEv โฆษณา หรือการวิเคราะห์';

  @override
  String get privacyPolicy => 'นโยบายความเป็นส่วนตัว';

  @override
  String get terms => 'ข้อกำหนดการใช้งาน';

  @override
  String get developmentLegal =>
      'เนื้อหาระหว่างพัฒนา — ข้อความนี้ไม่ใช่นโยบายความเป็นส่วนตัวหรือข้อกำหนดฉบับสมบูรณ์ จะตรวจทานตามบริการจริงก่อนเผยแพร่';

  @override
  String get acceptPreview => 'ฉันเข้าใจว่านี่เป็นรุ่นตัวอย่างระหว่างพัฒนา';

  @override
  String get startLocal => 'เริ่มใช้เฉพาะบนอุปกรณ์';

  @override
  String get back => 'ย้อนกลับ';

  @override
  String get close => 'ปิด';

  @override
  String get systemTheme => 'ตามระบบ';

  @override
  String get lightTheme => 'สว่าง';

  @override
  String get darkTheme => 'มืด';

  @override
  String get followSystem => 'ตามภาษาของอุปกรณ์';

  @override
  String get localMode => 'เฉพาะบนอุปกรณ์นี้';

  @override
  String get sessionNotice =>
      'ภาษา รูปแบบ และตัวเลือกเริ่มต้นจะคงอยู่เฉพาะการใช้งานครั้งนี้';

  @override
  String get errorTitle => 'เกิดปัญหา';

  @override
  String get preferencesError => 'อัปเดตการตั้งค่าไม่ได้ โปรดลองอีกครั้ง';

  @override
  String get loading => 'กำลังโหลด';

  @override
  String phaseLabel(int phase) {
    return 'ตัวอย่างระยะที่ $phase';
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
  String get quickAdd => 'เพิ่มรายการด่วน';

  @override
  String get expense => 'รายจ่าย';

  @override
  String get income => 'รายรับ';

  @override
  String get transfer => 'โอนเงิน';

  @override
  String get amount => 'จำนวนเงิน';

  @override
  String get sentAmount => 'จำนวนที่ส่ง';

  @override
  String get receivedAmount => 'จำนวนที่รับ';

  @override
  String get account => 'บัญชี';

  @override
  String get sourceAccount => 'บัญชีต้นทาง';

  @override
  String get destinationAccount => 'บัญชีปลายทาง';

  @override
  String get category => 'หมวดหมู่';

  @override
  String get businessDate => 'วันที่';

  @override
  String get noteOptional => 'บันทึก (ไม่บังคับ)';

  @override
  String get save => 'บันทึก';

  @override
  String get savedLocally => 'บันทึกลงในอุปกรณ์แล้ว';

  @override
  String get saveFailed => 'บันทึกไม่สำเร็จ โปรดลองอีกครั้ง';

  @override
  String get invalidMoney => 'กรอกจำนวนเงินมากกว่าศูนย์และใช้ทศนิยมให้ถูกต้อง';

  @override
  String get chooseAccount => 'เลือกบัญชี';

  @override
  String get chooseCategory => 'เลือกหมวดหมู่';

  @override
  String get chooseOtherAccount => 'เลือกบัญชีปลายทางอื่น';

  @override
  String get addAccount => 'เพิ่มบัญชี';

  @override
  String get addCategory => 'เพิ่มหมวดหมู่';

  @override
  String get name => 'ชื่อ';

  @override
  String get accountType => 'ประเภทบัญชี';

  @override
  String get currency => 'สกุลเงิน';

  @override
  String get create => 'สร้าง';

  @override
  String get firstAccount => 'เพิ่มบัญชีก่อนเริ่มใช้งาน';

  @override
  String get secondAccount => 'การโอนต้องมีอีกหนึ่งบัญชี';

  @override
  String get categoryNeeded => 'เพิ่มหมวดหมู่สำหรับรายการประเภทนี้';

  @override
  String get noHistory => 'ยังไม่มีรายการ';

  @override
  String get cash => 'เงินสด';

  @override
  String get bank => 'ธนาคาร';

  @override
  String get creditCard => 'บัตรเครดิต';

  @override
  String get eWallet => 'กระเป๋าเงินอิเล็กทรอนิกส์';

  @override
  String get other => 'อื่นๆ';

  @override
  String get receivedRequired => 'การโอนต่างสกุลเงินต้องระบุจำนวนที่ได้รับ';

  @override
  String get differentAccounts => 'บัญชีต้นทางและปลายทางต้องต่างกัน';

  @override
  String get archivedEntity => 'บัญชีหรือหมวดหมู่ถูกเก็บถาวรแล้ว';

  @override
  String get mismatchEntity => 'สกุลเงินหรือประเภทหมวดหมู่ไม่ตรงกัน';

  @override
  String get beforeOpening => 'วันที่ต้องไม่ก่อนวันเปิดของทั้งสองบัญชี';

  @override
  String get addBudget => 'เพิ่มงบประมาณ';

  @override
  String get budgetName => 'ชื่องบประมาณ';

  @override
  String get budgetAmount => 'จำนวนงบประมาณ';

  @override
  String get budgetMonth => 'เดือน (YYYY-MM)';

  @override
  String get budgetCategory => 'หมวดรายจ่าย (ไม่บังคับ)';

  @override
  String get allExpenses => 'รายจ่ายทั้งหมด';

  @override
  String warningAt(int percent) {
    return 'แจ้งเตือนเมื่อถึง $percent%';
  }

  @override
  String get spent => 'ใช้แล้ว';

  @override
  String get remaining => 'คงเหลือ';

  @override
  String get overBudget => 'เกินงบประมาณ';

  @override
  String missingFx(String currencies) {
    return 'คำนวณไม่ครบ · ไม่มีอัตราแลกเปลี่ยนสำหรับ: $currencies';
  }

  @override
  String get noBudgets => 'ยังไม่มีงบประมาณสำหรับเดือนนี้';

  @override
  String get archive => 'เก็บถาวร';

  @override
  String get edit => 'แก้ไข';

  @override
  String get project => 'โปรเจกต์';

  @override
  String get noProject => 'ไม่มีโปรเจกต์';

  @override
  String get addProject => 'เพิ่มโปรเจกต์';

  @override
  String get projectName => 'ชื่อโปรเจกต์';

  @override
  String get projectDescription => 'คำอธิบาย (ไม่บังคับ)';

  @override
  String get noProjects => 'ยังไม่มีโปรเจกต์ที่ใช้งานอยู่';

  @override
  String get incomeTotal => 'รายรับ';

  @override
  String get expenseTotal => 'รายจ่าย';

  @override
  String get netTotal => 'สุทธิ';

  @override
  String get projectArchived => 'โปรเจกต์นี้ถูกเก็บถาวรแล้ว';

  @override
  String get invalidMonth => 'กรอกเดือนที่ถูกต้องในรูปแบบ YYYY-MM';

  @override
  String get incomeExpenseReport => 'รายงานรายรับและรายจ่าย';

  @override
  String get assetsLiabilitiesOverview => 'ภาพรวมสินทรัพย์และหนี้สิน';

  @override
  String get reportPeriod => 'ช่วงเวลารายงาน';

  @override
  String get previousPeriod => 'ช่วงเวลาก่อนหน้า';

  @override
  String get reportComplete => 'คำนวณครบถ้วน';

  @override
  String get reportIncomplete => 'คำนวณไม่ครบถ้วน';

  @override
  String get categoryBreakdown => 'แยกตามหมวดหมู่';

  @override
  String get accountBreakdown => 'แยกตามบัญชี';

  @override
  String get dailyTrend => 'แนวโน้มรายวัน';

  @override
  String asOf(String date) {
    return 'ณ วันที่ $date';
  }

  @override
  String get assetsLabel => 'สินทรัพย์';

  @override
  String get liabilitiesLabel => 'หนี้สิน';

  @override
  String get reportingCurrency => 'สกุลเงินรายงาน';

  @override
  String get prepareCsv => 'เตรียม CSV';

  @override
  String get csvReady => 'เตรียม CSV ไว้ในเครื่องแล้ว';

  @override
  String get comparisonUnavailable =>
      'ไม่มีเปอร์เซ็นต์เปรียบเทียบช่วงก่อนหน้าที่มีความหมาย';

  @override
  String changeFromPrevious(String percent) {
    return 'เทียบช่วงก่อนหน้า $percent%';
  }

  @override
  String get reportDisclaimer =>
      'ภาพรวมบัญชีส่วนบุคคล ไม่ใช่งบการเงินระดับมืออาชีพ';

  @override
  String get allTransactions => 'ทั้งหมด';

  @override
  String get searchNotes => 'ค้นหาบันทึก';

  @override
  String get applyFilter => 'ใช้ตัวกรอง';

  @override
  String get noReportData => 'ไม่มีกิจกรรมในช่วงเวลานี้';

  @override
  String get receiptsOptional => 'รูปใบเสร็จ (ไม่บังคับ)';

  @override
  String get receiptPrivacyNote => 'เก็บไว้ในอุปกรณ์นี้เท่านั้น สูงสุด 5 รูป';

  @override
  String get takePhoto => 'ถ่ายรูป';

  @override
  String get choosePhoto => 'เลือกจากคลังรูปภาพ';

  @override
  String get receiptPhoto => 'รูปใบเสร็จ';

  @override
  String get removeReceipt => 'นำใบเสร็จออก';

  @override
  String get viewReceipt => 'ดูใบเสร็จ';

  @override
  String get receiptLimitReached => 'แนบรูปใบเสร็จได้สูงสุด 5 รูปต่อรายการ';

  @override
  String get receiptInvalid => 'ไม่รองรับไฟล์รูปนี้';

  @override
  String get receiptTooLarge => 'รูปมีขนาดใหญ่เกินกว่าจะประมวลผลอย่างปลอดภัย';

  @override
  String get receiptPermissionDenied =>
      'ไม่ได้รับสิทธิ์ใช้กล้องหรือรูปภาพ คุณเปิดสิทธิ์ได้ในการตั้งค่า';

  @override
  String get voiceEntry => 'ป้อนด้วยเสียง';

  @override
  String get listening => 'กำลังฟัง…';

  @override
  String get stopListening => 'หยุด';

  @override
  String get cancelVoice => 'ยกเลิก';

  @override
  String get processingSpeech => 'กำลังประมวลผลเสียง…';

  @override
  String get reviewVoiceDraft =>
      'เสียงใช้เพื่อแนะนำข้อมูลร่างเท่านั้น โปรดตรวจสอบก่อนบันทึก';

  @override
  String get voicePermissionDenied =>
      'ไม่ได้รับสิทธิ์ใช้ไมโครโฟนหรือการรู้จำเสียง คุณยังป้อนเองได้ หรือเปิดสิทธิ์ในการตั้งค่า';

  @override
  String get voiceLocaleUnavailable =>
      'อุปกรณ์นี้ไม่มีบริการรู้จำเสียงภาษาไทยที่เหมาะสม โปรดป้อนข้อมูลด้วยตนเอง';

  @override
  String get voiceUnavailable =>
      'ไม่สามารถใช้การรู้จำเสียงได้ โปรดป้อนข้อมูลด้วยตนเอง';

  @override
  String get voiceRecognitionFailed =>
      'การรู้จำเสียงล้มเหลว ข้อมูลร่างเดิมยังคงอยู่';

  @override
  String get voicePrivacyDisclosure =>
      'บริการเสียงของอุปกรณ์อาจประมวลผลเสียงทางออนไลน์ KeEv ไม่เก็บเสียงและไม่ส่งให้ AI หรือบริการวิเคราะห์';

  @override
  String get appLock => 'ล็อกแอป';

  @override
  String get appLocked => 'KeEv Ledger ถูกล็อก';

  @override
  String get appLockDescription =>
      'ปกป้องข้อมูลบัญชีในเครื่องนี้ด้วย PIN และไบโอเมตริกของระบบหากต้องการ';

  @override
  String get appLockEnabled => 'เปิดใช้ล็อกแอปแล้ว';

  @override
  String get setPin => 'ตั้ง PIN';

  @override
  String get confirmPin => 'ยืนยัน PIN';

  @override
  String get currentPin => 'PIN ปัจจุบัน';

  @override
  String get newPin => 'PIN ใหม่';

  @override
  String get enterPin => 'ป้อน PIN';

  @override
  String get pinRequirements => 'ป้อน PIN ตัวเลข 4–6 หลัก';

  @override
  String get pinMismatch => 'PIN ทั้งสองไม่ตรงกัน';

  @override
  String get incorrectPin => 'PIN ไม่ถูกต้อง';

  @override
  String get tryAgainLater => 'ลองหลายครั้งเกินไป โปรดลองใหม่ภายหลัง';

  @override
  String get useBiometrics => 'ใช้ไบโอเมตริก';

  @override
  String get biometricUnavailable =>
      'ไบโอเมตริกของระบบใช้ไม่ได้หรือยังไม่ได้ลงทะเบียน';

  @override
  String get biometricCancelled => 'ยกเลิกการยืนยันด้วยไบโอเมตริกแล้ว';

  @override
  String get biometricLocked => 'ไบโอเมตริกของระบบถูกล็อก โปรดใช้ KeEv PIN';

  @override
  String get biometricFailed => 'การยืนยันด้วยไบโอเมตริกล้มเหลว โปรดใช้ PIN';

  @override
  String get biometricPromptReason => 'ปลดล็อก KeEv Ledger ในเครื่อง';

  @override
  String get biometricSystemDescription =>
      'ใช้วิธีไบโอเมตริกที่ตั้งค่าไว้ในอุปกรณ์นี้';

  @override
  String get unlock => 'ปลดล็อก';

  @override
  String get lockNow => 'ล็อกตอนนี้';

  @override
  String get changePin => 'เปลี่ยน PIN';

  @override
  String get disableAppLock => 'ปิดล็อกแอป';

  @override
  String get authenticationRequired => 'ป้อน PIN ปัจจุบันเพื่อดำเนินการต่อ';

  @override
  String get authenticationCancelled => 'ยกเลิกการยืนยันแล้ว โปรดลองใหม่';

  @override
  String get lockConfigurationError =>
      'ไม่สามารถอ่านการตั้งค่าล็อกแอปได้อย่างปลอดภัย จึงไม่อนุญาตให้เข้าถึง';

  @override
  String get forgotPinGuidance =>
      'โหมดเฉพาะในเครื่องไม่มีการกู้ PIN ออนไลน์ KeEv ไม่สามารถข้าม PIN และจะไม่ลบข้อมูลบัญชีของคุณโดยอัตโนมัติ';

  @override
  String get relockPolicy => 'ล็อกเมื่อแอปย้ายไปทำงานเบื้องหลัง';

  @override
  String get privacyCover => 'ซ่อนข้อมูลการเงินเมื่อ KeEv Ledger ไม่ได้ใช้งาน';

  @override
  String get cloudAccount => 'บัญชีคลาวด์';

  @override
  String get localOnlyModeTitle => 'เฉพาะในเครื่อง';

  @override
  String get localOnlyDataNotice =>
      'ขณะนี้ข้อมูลบัญชีของคุณเก็บอยู่ในอุปกรณ์นี้ ไม่ต้องมีบัญชีหรือการเชื่อมต่ออินเทอร์เน็ต';

  @override
  String get cloudAccountConnected =>
      'อุปกรณ์นี้มีเซสชันคลาวด์ KeEv ที่ยืนยันตัวตนแล้ว';

  @override
  String get cloudOptionalDescription =>
      'บัญชี KeEv จะเป็นตัวเลือกสำหรับการสำรองข้อมูลบนคลาวด์ในอนาคต คุณยังใช้บัญชีในเครื่องต่อได้โดยไม่มีบัญชีคลาวด์';

  @override
  String get cloudAccountOptions => 'ดูตัวเลือกบัญชีคลาวด์';

  @override
  String get signInWithApple => 'ลงชื่อเข้าใช้ด้วย Apple';

  @override
  String get signInWithGoogle => 'ลงชื่อเข้าใช้ด้วย Google';

  @override
  String get signInWithEmail => 'ดำเนินการต่อด้วยอีเมล';

  @override
  String get signOut => 'ออกจากระบบ';

  @override
  String get cloudUnavailableDevelopment =>
      'รุ่นนี้ยังไม่เปิดใช้การลงชื่อเข้าใช้และสำรองข้อมูลบนคลาวด์ จึงไม่มีการอัปโหลดข้อมูล';

  @override
  String get continueLocalOnly => 'ใช้เฉพาะในเครื่องต่อ';

  @override
  String get cloudAccountError =>
      'บริการบัญชีคลาวด์ไม่สามารถดำเนินการตามคำขอนี้ได้';

  @override
  String get cloudSignedOut => 'ออกจากระบบแล้ว';

  @override
  String get cloudAuthenticating => 'กำลังลงชื่อเข้าใช้…';

  @override
  String get cloudReauthenticationRequired =>
      'ลงชื่อเข้าใช้อีกครั้งเพื่อใช้คุณสมบัติบัญชีคลาวด์ต่อ';

  @override
  String get cloudTemporarilyUnavailable =>
      'บริการคลาวด์ไม่พร้อมใช้งานชั่วคราว เซสชันที่ปลอดภัยของคุณยังคงถูกเก็บไว้';

  @override
  String get cloudConfigurationUnavailable =>
      'รุ่นนี้ยังไม่ได้ตั้งค่าการลงชื่อเข้าใช้คลาวด์ คุณยังใช้เฉพาะในเครื่องได้';

  @override
  String get cloudBackupNotActive =>
      'ยังไม่เปิดใช้การสำรองข้อมูลบนคลาวด์ การลงชื่อเข้าใช้จะไม่อัปโหลดข้อมูลบัญชีของคุณ';

  @override
  String get emailAddress => 'ที่อยู่อีเมล';

  @override
  String get sendOtp => 'ส่งรหัส';

  @override
  String get otpCode => 'รหัส 6 หลัก';

  @override
  String get verifyOtp => 'ยืนยันรหัส';

  @override
  String get resendOtp => 'ส่งรหัสอีกครั้ง';

  @override
  String get otpSent => 'ส่งรหัสลงชื่อเข้าใช้แล้ว โปรดตรวจสอบอีเมล';

  @override
  String get invalidOtp => 'รหัสไม่ถูกต้อง';

  @override
  String get expiredOtp => 'รหัสหมดอายุแล้ว โปรดขอรหัสใหม่';

  @override
  String get authRateLimited => 'มีคำขอมากเกินไป โปรดรอแล้วลองใหม่';

  @override
  String get cloudNetworkUnavailable =>
      'ไม่มีการเชื่อมต่อเครือข่าย เซสชันคลาวด์ที่บันทึกไว้ยังคงอยู่';

  @override
  String get appLockCloudSeparation =>
      'ล็อกแอปปกป้องเฉพาะอุปกรณ์นี้ PIN และข้อมูลชีวมิติไม่ใช่ข้อมูลลงชื่อเข้าใช้คลาวด์ KeEv';

  @override
  String get backupStatus => 'สถานะการสำรองข้อมูล';

  @override
  String get localBackup => 'สำรองข้อมูลในเครื่อง';

  @override
  String get cloudBackup => 'สำรองข้อมูลบนคลาวด์';

  @override
  String get createEncryptedBackup => 'สร้างข้อมูลสำรองที่เข้ารหัส';

  @override
  String get restoreFromBackupFile => 'คืนค่าจากไฟล์สำรอง';

  @override
  String get backupPassphrase => 'รหัสผ่านข้อมูลสำรอง';

  @override
  String get confirmBackupPassphrase => 'ยืนยันรหัสผ่านข้อมูลสำรอง';

  @override
  String get backupPassphraseHelp =>
      'ใช้อย่างน้อย 10 อักขระ KeEv ไม่สามารถกู้คืนรหัสผ่านข้อมูลสำรองที่ลืมได้';

  @override
  String get backupSecurityInfo =>
      'ข้อมูลสำรองจะถูกเข้ารหัสบนอุปกรณ์นี้ก่อนส่งออกหรืออัปโหลด';

  @override
  String get backupCreated => 'สร้างข้อมูลสำรองที่เข้ารหัสแล้ว';

  @override
  String get backupFailed => 'ไม่สามารถสร้างข้อมูลสำรองได้';

  @override
  String get restorePreview => 'ตัวอย่างก่อนคืนค่า';

  @override
  String get restoreReplaceWarning =>
      'การดำเนินการนี้จะแทนที่ข้อมูลบัญชีในเครื่องทั้งหมด และจะไม่รวมระเบียน';

  @override
  String get restoreConfirm => 'แทนที่และคืนค่า';

  @override
  String get restoreCompleted => 'คืนค่าข้อมูลสำรองแล้ว';

  @override
  String get restoreFailedMessage => 'ไม่สามารถคืนค่าข้อมูลสำรองได้';

  @override
  String get wrongBackupPassphrase =>
      'รหัสผ่านไม่ถูกต้องหรือข้อมูลสำรองถูกเปลี่ยนแปลง';

  @override
  String get corruptedBackup => 'ข้อมูลสำรองไม่ถูกต้อง เสียหาย หรือไม่รองรับ';

  @override
  String get cloudSignInRequired =>
      'ลงชื่อเข้าใช้เพื่อใช้การสำรองข้อมูลบนคลาวด์แบบเลือกได้ การสำรองในเครื่องยังใช้ได้';

  @override
  String get noCloudBackups => 'ยังไม่มีข้อมูลสำรองบนคลาวด์';

  @override
  String get deleteBackup => 'ลบข้อมูลสำรอง';

  @override
  String get backupCreatedAt => 'สร้างเมื่อ';

  @override
  String get backupFormatVersion => 'รูปแบบข้อมูลสำรอง';

  @override
  String get backupSourceApp => 'แอปต้นทาง';

  @override
  String get backupBaseCurrency => 'สกุลเงินหลัก';

  @override
  String get encryptedBackupSize => 'ขนาดที่เข้ารหัส';

  @override
  String get deleteCloudBackupConfirmation =>
      'ลบข้อมูลสำรองบนคลาวด์นี้อย่างถาวรหรือไม่ ข้อมูลบัญชีในเครื่องจะไม่ถูกลบ';

  @override
  String get syncTitle => 'ซิงค์แบบสด';

  @override
  String get syncEnable => 'เปิดใช้การซิงค์';

  @override
  String get syncDescription =>
      'ทำให้บัญชีตรงกันในอุปกรณ์หลายเครื่อง การซิงค์แบบสดเก็บระเบียนบัญชีที่อ่านได้ในบัญชีคลาวด์ KeEv และแยกจากข้อมูลสำรองที่เข้ารหัส';

  @override
  String get syncNow => 'ซิงค์ตอนนี้';

  @override
  String get syncPause => 'หยุดซิงค์ชั่วคราว';

  @override
  String get syncResume => 'ซิงค์ต่อ';

  @override
  String get syncDisable => 'ยกเลิกการเชื่อมโยงอุปกรณ์นี้';

  @override
  String get syncLocalData => 'ข้อมูลในเครื่อง';

  @override
  String get syncCloudData => 'ข้อมูลบนคลาวด์';

  @override
  String get syncKeepLocal => 'ใช้ข้อมูลในเครื่อง';

  @override
  String get syncKeepCloud => 'ใช้ข้อมูลบนคลาวด์';

  @override
  String get syncCancel => 'ยกเลิก';

  @override
  String get syncNeedsReconciliation => 'ต้องตรวจสอบข้อมูล';

  @override
  String get syncConflicts => 'มีข้อขัดแย้งที่ต้องจัดการ';

  @override
  String get syncActive => 'เปิดใช้การซิงค์แล้ว';

  @override
  String get syncPaused => 'หยุดซิงค์ชั่วคราว';

  @override
  String get syncUpToDate => 'เป็นข้อมูลล่าสุด';

  @override
  String get syncOffline => 'ไม่พร้อมใช้งานชั่วคราว';

  @override
  String get syncAuthRequired => 'ต้องยืนยันตัวตน';

  @override
  String get syncPendingChanges => 'การเปลี่ยนแปลงที่รอส่ง';

  @override
  String get syncLastSynced => 'ซิงค์ล่าสุด';

  @override
  String get syncChecking => 'กำลังตรวจสอบข้อมูลในเครื่องและคลาวด์…';

  @override
  String get syncInitializing => 'กำลังเตรียมบัญชี…';

  @override
  String get syncUploading => 'กำลังอัปโหลดและตรวจสอบข้อมูลในเครื่อง…';

  @override
  String get syncDownloading => 'กำลังดาวน์โหลดข้อมูลคลาวด์…';

  @override
  String get syncVerifying => 'กำลังตรวจสอบบัญชีทั้งหมด…';

  @override
  String get syncFinalizing => 'กำลังดำเนินการซิงค์ให้เสร็จ…';

  @override
  String get syncDestructiveWarning =>
      'ตัวเลือกนี้จะแทนที่บัญชีฝั่งหนึ่ง โปรดสร้างข้อมูลสำรองที่เข้ารหัสก่อนหากอาจต้องกู้คืน';

  @override
  String get syncUnlinkWarning =>
      'บัญชีในเครื่องและคลาวด์จะยังอยู่ การแก้ไขต่อไปบนอุปกรณ์นี้จะอยู่ในเครื่องและการเปลี่ยนแปลงที่รอจะไม่ถูกส่ง';

  @override
  String get syncConflictsTitle => 'แก้ไขข้อขัดแย้ง';

  @override
  String get syncLocalDelete => 'ลบแล้วบนอุปกรณ์นี้';

  @override
  String get syncCloudDelete => 'ลบแล้วบนคลาวด์';

  @override
  String get syncNoAutomaticMerge =>
      'ทั้งในเครื่องและคลาวด์มีข้อมูล เลือกบัญชีเริ่มต้น โดย KeEv จะไม่รวมข้อมูลอัตโนมัติ';

  @override
  String get privacyAdvertising => 'ความเป็นส่วนตัวและโฆษณา';

  @override
  String get privacyAdvertisingSummary =>
      'จัดการตัวเลือกความเป็นส่วนตัวของโฆษณา';

  @override
  String get advertisingPreferences => 'การตั้งค่าโฆษณา';

  @override
  String get advertisingPrivacyExplanation =>
      'โฆษณาแยกจากบัญชีแยกประเภท KeEv ไม่ส่งยอดคงเหลือ ธุรกรรม บันทึก ใบเสร็จ หรือข้อมูลทางการเงินอื่นให้บริการโฆษณา';

  @override
  String get managePrivacyChoices => 'จัดการตัวเลือกความเป็นส่วนตัว';

  @override
  String get advertisement => 'โฆษณา';
}
