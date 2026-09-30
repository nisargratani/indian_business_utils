/// Result of an invoice calculation.
class InvoiceResult {
  /// Invoice amount before discount and tax.
  final double subtotal;

  /// Discount deducted from [subtotal].
  final double discount;

  /// Amount GST is charged on: `subtotal - discount`.
  final double taxableAmount;

  /// GST charged on [taxableAmount].
  final double tax;

  /// Amount payable: `taxableAmount + tax`.
  final double total;

  /// Creates a result. If [taxableAmount] is omitted it is computed as
  /// `subtotal - discount`.
  const InvoiceResult({
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    double? taxableAmount,
  }) : taxableAmount = taxableAmount ?? subtotal - discount;

  @override
  bool operator ==(Object other) =>
      other is InvoiceResult &&
      other.subtotal == subtotal &&
      other.discount == discount &&
      other.taxableAmount == taxableAmount &&
      other.tax == tax &&
      other.total == total;

  @override
  int get hashCode =>
      Object.hash(subtotal, discount, taxableAmount, tax, total);

  @override
  String toString() => 'InvoiceResult(subtotal: $subtotal, '
      'discount: $discount, taxableAmount: $taxableAmount, '
      'tax: $tax, total: $total)';
}
