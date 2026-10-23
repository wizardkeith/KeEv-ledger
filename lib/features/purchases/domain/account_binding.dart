/// Store evidence takes precedence over local hints. A disagreement is
/// reported even when the store value matches the signed-in account.
final class PurchaseAccountBinding {
  const PurchaseAccountBinding({
    required this.accountId,
    required this.conflict,
  });

  final String? accountId;
  final bool conflict;

  static PurchaseAccountBinding resolve({
    String? store,
    String? journal,
    String? initiated,
    String? restore,
  }) {
    final values = [store, journal, initiated, restore]
        .where((value) => value != null && value.isNotEmpty)
        .cast<String>()
        .toList();
    return PurchaseAccountBinding(
      accountId: values.isEmpty ? null : values.first,
      conflict:
          values.isNotEmpty && values.any((value) => value != values.first),
    );
  }
}
