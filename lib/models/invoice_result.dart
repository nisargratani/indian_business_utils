import '../src/numeric.dart';
import 'gst_split_result.dart';

/// Result of an invoice calculation.
class InvoiceResult {
  /// Invoice amount before discount and tax.
  final double subtotal;

  /// Discount deducted from [subtotal].
  final double discount;

  /// Amount GST is charged on: `subtotal - discount`.
  ///
  /// When it is not passed to the constructor, it is computed without
  /// floating point noise: `subtotal: 0.3, discount: 0.1` gives `0.2`.
  double get taxableAmount => _taxableAmount ?? normalize(subtotal - discount);
  final double? _taxableAmount;

  /// GST charged on [taxableAmount].
  final double tax;

  /// Amount payable: `taxableAmount + tax`.
  final double total;

  /// The tax split into CGST/SGST or IGST, whose `total` equals [tax].
  ///
  /// Set when a GST type is passed to `InvoiceCalculator.calculate`, and
  /// null otherwise.
  final GstSplitResult? gst;

  /// Creates a result. If `taxableAmount` is omitted it is computed as
  /// `subtotal - discount`.
  const InvoiceResult({
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    double? taxableAmount,
    this.gst,
  }) : _taxableAmount = taxableAmount;

  @override
  bool operator ==(Object other) =>
      other is InvoiceResult &&
      other.subtotal == subtotal &&
      other.discount == discount &&
      other.taxableAmount == taxableAmount &&
      other.tax == tax &&
      other.total == total &&
      other.gst == gst;

  @override
  int get hashCode =>
      Object.hash(subtotal, discount, taxableAmount, tax, total, gst);

  @override
  String toString() => 'InvoiceResult(subtotal: $subtotal, '
      'discount: $discount, taxableAmount: $taxableAmount, '
      'tax: $tax, total: $total${gst == null ? '' : ', gst: $gst'})';
}
