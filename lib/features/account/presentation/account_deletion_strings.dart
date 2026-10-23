import 'package:flutter/widgets.dart';

/// KeEv-authored account-deletion copy. Store cancellation is separate.
final class AccountDeletionStrings {
  const AccountDeletionStrings(this.title, this.warning, this.confirm,
      this.cancel, this.failed, this.reauthenticate, this.appleReauthenticate, this.done);
  final String title, warning, confirm, cancel, failed, reauthenticate, appleReauthenticate, done;

  static AccountDeletionStrings of(BuildContext context) => switch (
      Localizations.localeOf(context).languageCode) {
    'zh' => const AccountDeletionStrings(
      '刪除 KeEv 帳戶',
      '這會刪除您的 KeEv 雲端帳戶、同步資料、雲端收據及加密雲端備份。目前裝置上的帳簿將保留並轉為「僅限本機」。如已連結 Apple，您需要再次驗證 Apple 帳戶。刪除帳戶不會取消 App Store 或 Google Play 訂閱；請在商店管理訂閱。此操作無法復原。',
      '確認刪除雲端帳戶', '取消', '未能完成刪除；請稍後重試。',
      '請重新登入 KeEv 帳戶，然後重試刪除。', '請重新驗證 Apple 帳戶，然後重試刪除。', '雲端帳戶已刪除；本機帳簿仍保留。'),
    'ja' => const AccountDeletionStrings(
      'KeEv アカウントを削除',
      'KeEv のクラウドアカウント、同期データ、クラウドの領収書と暗号化バックアップを削除します。この端末の帳簿は残り、ローカル専用になります。Apple を連携している場合は再認証が必要です。アカウントを削除しても App Store または Google Play の定期購入は解約されません。ストアで管理してください。この操作は元に戻せません。',
      'クラウドアカウントを削除', 'キャンセル', '削除を完了できませんでした。後で再試行してください。',
      'KeEv アカウントに再ログインしてから再試行してください。', 'Apple アカウントを再認証してから再試行してください。', 'クラウドアカウントを削除しました。端末の帳簿は残っています。'),
    'th' => const AccountDeletionStrings(
      'ลบบัญชี KeEv',
      'ระบบจะลบบัญชีคลาวด์ ข้อมูลซิงก์ ใบเสร็จบนคลาวด์ และข้อมูลสำรองที่เข้ารหัส สมุดบัญชีบนอุปกรณ์นี้ยังคงอยู่และจะใช้เฉพาะในเครื่อง หากเชื่อมบัญชี Apple คุณต้องยืนยันตัวตนอีกครั้ง การลบบัญชีไม่ยกเลิกการสมัครสมาชิกผ่าน App Store หรือ Google Play โปรดจัดการในร้านค้า การดำเนินการนี้ย้อนกลับไม่ได้',
      'ยืนยันลบบัญชีคลาวด์', 'ยกเลิก', 'ลบบัญชีไม่สำเร็จ โปรดลองอีกครั้ง',
      'โปรดลงชื่อเข้าใช้บัญชี KeEv อีกครั้งแล้วลองลบ', 'โปรดยืนยันตัวตนด้วย Apple อีกครั้งแล้วลองลบ', 'ลบบัญชีคลาวด์แล้ว สมุดบัญชีในเครื่องยังคงอยู่'),
    _ => const AccountDeletionStrings(
      'Delete KeEv account',
      'This deletes your KeEv cloud account, synced ledger, cloud receipts, and encrypted cloud backups. The ledger on this device stays and becomes Local Only. If Apple is linked, you will be asked to authenticate with Apple again. Deleting this account does not cancel an App Store or Google Play subscription; manage that in the store. This cannot be undone.',
      'Delete cloud account', 'Cancel', 'Deletion could not be completed. Please retry.',
      'Sign in to KeEv again, then retry deletion.', 'Authenticate with Apple again, then retry deletion.', 'Cloud account deleted. Your local ledger remains.'),
  };
}
