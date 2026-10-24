import 'package:flutter/widgets.dart';

import '../domain/purchase.dart';

/// KeEv-authored strings only. Store titles and prices remain store-localized.
final class PremiumStrings {
  const PremiumStrings(
    this.title,
    this.description,
    this.signIn,
    this.unavailable,
    this.verification,
    this.active,
    this.pending,
    this.restore,
    this.manage,
    this.subscribe,
    this.recurring,
    this.cancelled,
    this.error,
    this.terms,
    this.privacy,
  );
  final String title,
      description,
      signIn,
      unavailable,
      verification,
      active,
      pending,
      restore,
      manage,
      subscribe,
      recurring,
      cancelled,
      error,
      terms,
      privacy;

  String billingPeriod(SubscriptionPeriod period, String language) {
    final number = period.value;
    final unit = switch (language) {
      'zh' => switch (period.unit) {
        SubscriptionPeriodUnit.day => '日',
        SubscriptionPeriodUnit.week => '週',
        SubscriptionPeriodUnit.month => '個月',
        SubscriptionPeriodUnit.year => '年',
      },
      'ja' => switch (period.unit) {
        SubscriptionPeriodUnit.day => '日',
        SubscriptionPeriodUnit.week => '週',
        SubscriptionPeriodUnit.month => 'か月',
        SubscriptionPeriodUnit.year => '年',
      },
      'th' => switch (period.unit) {
        SubscriptionPeriodUnit.day => 'วัน',
        SubscriptionPeriodUnit.week => 'สัปดาห์',
        SubscriptionPeriodUnit.month => 'เดือน',
        SubscriptionPeriodUnit.year => 'ปี',
      },
      _ => switch (period.unit) {
        SubscriptionPeriodUnit.day => number == 1 ? 'day' : 'days',
        SubscriptionPeriodUnit.week => number == 1 ? 'week' : 'weeks',
        SubscriptionPeriodUnit.month => number == 1 ? 'month' : 'months',
        SubscriptionPeriodUnit.year => number == 1 ? 'year' : 'years',
      },
    };
    return language == 'en'
        ? 'Every $number $unit'
        : language == 'zh'
        ? '每 $number $unit'
        : language == 'ja'
        ? '$number$unitごと'
        : 'ทุก $number $unit';
  }

  static PremiumStrings of(BuildContext context) =>
      switch (Localizations.localeOf(context).languageCode) {
        'zh' => const PremiumStrings(
          'KeEv 尊享版',
          '免費記帳功能可繼續使用。尊享版日後可移除廣告。',
          '購買或還原前，請先登入 KeEv 雲端帳戶。',
          '目前無法購買；商店或驗證服務尚未準備就緒。',
          '正在等候安全驗證；尚未開通尊享版。',
          '尊享版已驗證',
          '購買待處理',
          '還原購買項目',
          '管理訂閱',
          '訂閱',
          '訂閱會自動續期；可於商店取消。',
          '已取消購買',
          '商店暫時無法完成操作。',
          '條款',
          '私隱政策',
        ),
        'ja' => const PremiumStrings(
          'KeEv プレミアム',
          '無料の家計簿機能は引き続き利用できます。プレミアムでは広告を非表示にできます。',
          '購入や復元には KeEv クラウドアカウントへのログインが必要です。',
          'ストアまたは検証サービスの準備ができていません。',
          '安全な確認を待っています。プレミアムはまだ有効ではありません。',
          'プレミアム確認済み',
          '購入手続き中',
          '購入を復元',
          'サブスクリプションを管理',
          '登録する',
          'サブスクリプションは自動更新され、ストアで解約できます。',
          '購入をキャンセルしました',
          'ストア処理を完了できませんでした。',
          '利用規約',
          'プライバシー',
        ),
        'th' => const PremiumStrings(
          'KeEv Premium',
          'คุณยังใช้บัญชีรายรับรายจ่ายพื้นฐานได้ฟรี Premium สามารถซ่อนโฆษณาได้ในอนาคต',
          'โปรดลงชื่อเข้าใช้บัญชี KeEv Cloud ก่อนซื้อหรือกู้คืน',
          'ร้านค้าหรือระบบยืนยันยังไม่พร้อมให้ซื้อ',
          'กำลังรอการยืนยันอย่างปลอดภัย ยังไม่เปิดใช้ Premium',
          'ยืนยัน Premium แล้ว',
          'การซื้อรอดำเนินการ',
          'กู้คืนการซื้อ',
          'จัดการการสมัครสมาชิก',
          'สมัครสมาชิก',
          'ต่ออายุอัตโนมัติ ยกเลิกได้ในร้านค้า',
          'ยกเลิกการซื้อแล้ว',
          'ร้านค้าไม่สามารถดำเนินการได้ชั่วคราว',
          'ข้อกำหนด',
          'ความเป็นส่วนตัว',
        ),
        _ => const PremiumStrings(
          'KeEv Premium',
          'Free bookkeeping remains available. Premium can remove ads once verified.',
          'Sign in to a KeEv cloud account before buying or restoring.',
          'Purchases are unavailable until the store and trusted verification are configured.',
          'Waiting for trusted verification. Premium is not active yet.',
          'Premium verified',
          'Purchase pending',
          'Restore purchases',
          'Manage subscription',
          'Subscribe',
          'Subscriptions renew automatically; cancel in the store.',
          'Purchase cancelled',
          'The store could not complete this request.',
          'Terms',
          'Privacy',
        ),
      };
}
