import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/core/currency.dart';
import 'package:ledger/features/bookkeeping/domain/bookkeeping.dart';
import 'package:ledger/features/voice/application/voice_recognition.dart';
import 'package:ledger/features/voice/application/voice_transaction_parser.dart';
import 'package:ledger/features/voice/infrastructure/speech_to_text_recognizer.dart';

void main() {
  const parser = VoiceTransactionParser();

  group('deterministic voice parsing', () {
    test('parses digits, decimal money and zero-decimal JPY exactly', () {
      expect(
        parser
            .parse('lunch 85.50', contextCurrency: Currency.hkd)
            .amount!
            .minorUnits,
        8550,
      );
      final yen = parser.parse('taxi 100 yen', contextCurrency: Currency.hkd);
      expect(yen.amount!.currency, Currency.jpy);
      expect(yen.amount!.minorUnits, 100);
      expect(
        parser.parse('100.5 yen', contextCurrency: Currency.hkd).amount,
        isNull,
      );
    });

    test('parses bounded Cantonese amounts in HKD context', () {
      expect(
        parser
            .parse('今日午餐八十五蚊', contextCurrency: Currency.hkd)
            .amount!
            .minorUnits,
        8500,
      );
      expect(
        parser.parse('一百二十蚊', contextCurrency: Currency.hkd).amount!.minorUnits,
        12000,
      );
      expect(
        parser.parse('二百五十蚊', contextCurrency: Currency.hkd).amount!.minorUnits,
        25000,
      );
      expect(
        parser.parse('八十五蚊', contextCurrency: Currency.usd).amount,
        isNull,
      );
    });

    test('suggests only clear type and category intents', () {
      final lunch = parser.parse('今日午餐八十五蚊', contextCurrency: Currency.hkd);
      expect(lunch.kind, EntryKind.expense);
      expect(lunch.category, VoiceCategoryIntent.food);
      expect(
        parser.parse('salary 5000', contextCurrency: Currency.hkd).kind,
        EntryKind.income,
      );
      final ambiguous = parser.parse(
        'meeting tomorrow',
        contextCurrency: Currency.hkd,
      );
      expect(ambiguous.amount, isNull);
      expect(ambiguous.kind, isNull);
      expect(ambiguous.category, isNull);
    });
  });

  test('draft ownership rejects user-overwrite and stale sessions', () {
    final ownership = VoiceDraftOwnership();
    final first = ownership.beginSession();
    expect(ownership.mayApply(first, VoiceDraftField.amount), isTrue);
    ownership.markUserEdited(VoiceDraftField.amount);
    expect(ownership.mayApply(first, VoiceDraftField.amount), isFalse);
    final second = ownership.beginSession();
    expect(ownership.mayApply(first, VoiceDraftField.category), isFalse);
    expect(ownership.mayApply(second, VoiceDraftField.category), isTrue);
    ownership.cancelSession();
    expect(ownership.mayApply(second, VoiceDraftField.category), isFalse);
  });

  test(
    'speech locale mapping never crosses HK Cantonese to TW or Mandarin',
    () {
      expect(SpeechLocaleResolver.resolve('zh-HK', ['zh_TW', 'zh_CN']), isNull);
      expect(
        SpeechLocaleResolver.resolve('zh-HK', ['zh_TW', 'yue-HK', 'zh_CN']),
        'yue-HK',
      );
      expect(
        SpeechLocaleResolver.resolve('zh-CN', ['zh_HK', 'zh_CN']),
        'zh_CN',
      );
      expect(SpeechLocaleResolver.resolve('ja', ['ja_JP']), 'ja_JP');
      expect(SpeechLocaleResolver.resolve('th', ['th_TH']), 'th_TH');
      expect(SpeechLocaleResolver.resolve('en', ['en_GB']), 'en_GB');
    },
  );
}
