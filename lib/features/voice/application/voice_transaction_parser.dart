import '../../../core/currency.dart';
import '../../../core/money.dart';
import '../../../core/result.dart';
import '../../bookkeeping/application/money_input.dart';
import '../../bookkeeping/domain/bookkeeping.dart';

enum VoiceCategoryIntent { food, transport, shopping }

final class VoiceTransactionCandidate {
  const VoiceTransactionCandidate({this.amount, this.kind, this.category});

  final Money? amount;
  final EntryKind? kind;
  final VoiceCategoryIntent? category;
}

/// Intentionally small, deterministic parser. Unclear input remains unresolved.
final class VoiceTransactionParser {
  const VoiceTransactionParser();

  VoiceTransactionCandidate parse(
    String transcript, {
    required Currency contextCurrency,
  }) {
    final text = transcript.trim();
    if (text.isEmpty) return const VoiceTransactionCandidate();
    final lower = text.toLowerCase();
    final kind = _containsAny(lower, _incomeWords)
        ? EntryKind.income
        : _containsAny(lower, _expenseWords)
        ? EntryKind.expense
        : null;
    final category = _containsAny(lower, _foodWords)
        ? VoiceCategoryIntent.food
        : _containsAny(lower, _transportWords)
        ? VoiceCategoryIntent.transport
        : _containsAny(lower, _shoppingWords)
        ? VoiceCategoryIntent.shopping
        : null;
    return VoiceTransactionCandidate(
      amount: _amount(text, lower, contextCurrency),
      kind: kind,
      category: category,
    );
  }

  Money? _amount(String text, String lower, Currency contextCurrency) {
    final explicitJpy = RegExp(
      r'(?:\byen\b|jpy|円|日圓|日元)',
      caseSensitive: false,
    ).hasMatch(text);
    final currency = explicitJpy ? Currency.jpy : contextCurrency;
    final digits = RegExp(r'(?<!\d)(\d+(?:[.,]\d+)?)(?!\d)').firstMatch(text);
    if (digits != null) {
      final parsed = MoneyInput.parsePositive(
        digits.group(1)!.replaceAll(',', '.'),
        currency,
      );
      return parsed is Success<Money> ? parsed.value : null;
    }
    if (contextCurrency != Currency.hkd || !RegExp(r'[蚊元塊]').hasMatch(text)) {
      return null;
    }
    final chinese = RegExp(r'([零〇一二兩三四五六七八九十百千]+)\s*[蚊元塊]').firstMatch(text);
    if (chinese == null) return null;
    final units = _chineseInteger(chinese.group(1)!);
    if (units == null || units <= 0) return null;
    final parsed = MoneyInput.parsePositive('$units', Currency.hkd);
    return parsed is Success<Money> ? parsed.value : null;
  }

  int? _chineseInteger(String value) {
    const digits = {
      '零': 0,
      '〇': 0,
      '一': 1,
      '二': 2,
      '兩': 2,
      '三': 3,
      '四': 4,
      '五': 5,
      '六': 6,
      '七': 7,
      '八': 8,
      '九': 9,
    };
    var total = 0, section = 0, digit = 0;
    for (final rune in value.runes) {
      final char = String.fromCharCode(rune);
      final number = digits[char];
      if (number != null) {
        digit = number;
        continue;
      }
      final multiplier = switch (char) {
        '十' => 10,
        '百' => 100,
        '千' => 1000,
        _ => null,
      };
      if (multiplier == null) return null;
      section += (digit == 0 ? 1 : digit) * multiplier;
      digit = 0;
    }
    total += section + digit;
    return total <= 9999 ? total : null;
  }

  bool _containsAny(String text, List<String> words) =>
      words.any(text.contains);

  static const _expenseWords = [
    'lunch',
    'dinner',
    'taxi',
    'shopping',
    'paid',
    'spent',
    '午餐',
    '晚餐',
    '的士',
    '計程車',
    '出租车',
    '購物',
    '购物',
    '支付',
    'ランチ',
    '昼食',
    '夕食',
    'タクシー',
    '買い物',
    '支払',
    'อาหารกลางวัน',
    'อาหารเย็น',
    'แท็กซี่',
    'ซื้อ',
    'จ่าย',
  ];
  static const _incomeWords = [
    'salary',
    'received',
    'income',
    'wage',
    '工資',
    '工资',
    '薪金',
    '收入',
    '收到',
    '給料',
    '収入',
    '受け取',
    'เงินเดือน',
    'รายได้',
    'ได้รับ',
  ];
  static const _foodWords = [
    'lunch',
    'dinner',
    'food',
    'restaurant',
    '午餐',
    '晚餐',
    '早餐',
    '餐廳',
    '餐厅',
    '飲食',
    '饮食',
    'ランチ',
    '昼食',
    '夕食',
    '食事',
    'อาหารกลางวัน',
    'อาหารเย็น',
    'ร้านอาหาร',
    'อาหาร',
  ];
  static const _transportWords = [
    'taxi',
    'metro',
    'transport',
    '的士',
    '計程車',
    '出租车',
    '地鐵',
    '地铁',
    'タクシー',
    '地下鉄',
    '交通',
    'แท็กซี่',
    'รถไฟ',
    'เดินทาง',
  ];
  static const _shoppingWords = [
    'shopping',
    'shop',
    '購物',
    '购物',
    '買い物',
    'ซื้อของ',
  ];
}

bool categoryMatchesVoiceIntent(
  String categoryName,
  VoiceCategoryIntent intent,
) {
  final name = categoryName.trim().toLowerCase();
  final aliases = switch (intent) {
    VoiceCategoryIntent.food => const [
      'food',
      'dining',
      '餐飲',
      '餐饮',
      '飲食',
      '食事',
      'อาหาร',
    ],
    VoiceCategoryIntent.transport => const [
      'transport',
      'transportation',
      '交通',
      '交通費',
      'เดินทาง',
    ],
    VoiceCategoryIntent.shopping => const [
      'shopping',
      '購物',
      '购物',
      '買い物',
      'ซื้อของ',
    ],
  };
  return aliases.any((alias) => name == alias || name.contains(alias));
}
