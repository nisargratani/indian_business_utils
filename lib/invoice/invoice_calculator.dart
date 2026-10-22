import '../gst/gst_calculator.dart';
import '../gst/gst_type.dart';
import '../models/invoice_result.dart';
import '../src/numeric.dart';

/// Calculates invoice totals including GST.
class InvoiceCalculator {
  /// Calculates the tax and total for an invoice.
  ///
  /// The taxable amount is `subtotal - discount`. Tax is charged at
  /// [gstRate] percent on it. The taxable amount, tax and total are each
  /// rounded half-up to [precision] decimal places (default 2, i.e. paise).
  ///
  /// Pass the transaction [type] (see `GstTypeDetector`) so that the tax
  /// matches the CGST/SGST or IGST printed on the invoice:
  ///
  /// * [GstType.intraState]: the tax is CGST + SGST, each calculated at half
  ///   of [gstRate] and rounded on its own, exactly as
  ///   `GstCalculator.splitGST` does. It can differ by one paisa from the
  ///   tax rounded at the full rate.
  /// * [GstType.interState]: the tax is IGST at the full [gstRate].
  /// * `null` (the default): the tax is rounded as IGST (full rate). For an
  ///   intra-state supply this can differ by one paisa from CGST + SGST, so
  ///   pass [type] when you print the split.
  ///
  /// When [type] is given, [InvoiceResult.gst] holds the split.
  ///
  /// ```dart
  /// final invoice = InvoiceCalculator.calculate(
  ///   subtotal: 5000,
  ///   discount: 200,
  ///   gstRate: 18,
  ///   type: GstType.intraState,
  /// );
  /// print(invoice.taxableAmount); // 4800.0
  /// print(invoice.tax);           // 864.0
  /// print(invoice.total);         // 5664.0
  /// print(invoice.gst!.cgst);     // 432.0
  /// ```
  ///
  /// Throws an [ArgumentError] if any value is not finite, [subtotal],
  /// [gstRate] or [discount] is negative, or [discount] exceeds [subtotal].
  /// Throws a [RangeError] if [precision] is outside `0..10`.
  static InvoiceResult calculate({
    required num subtotal,
    num discount = 0,
    num gstRate = 18,
    int precision = 2,
    GstType? type,
  }) {
    checkFinite(subtotal, 'subtotal');
    checkFinite(discount, 'discount');
    checkFinite(gstRate, 'gstRate');
    checkPrecision(precision);
    if (gstRate < 0) {
      throw ArgumentError.value(gstRate, 'gstRate', 'Must not be negative');
    }
    if (subtotal < 0) {
      throw ArgumentError.value(subtotal, 'subtotal', 'Must not be negative');
    }
    if (discount < 0) {
      throw ArgumentError.value(discount, 'discount', 'Must not be negative');
    }
    if (discount > subtotal) {
      throw ArgumentError.value(
        discount,
        'discount',
        'Must not exceed subtotal ($subtotal)',
      );
    }

    final taxable = roundHalfUp(subtotal - discount, precision);
    // Use splitGST itself, so the invoice tax and the printed split can
    // never drift apart.
    final gst = type == null
        ? null
        : GstCalculator.splitGST(
            amount: taxable,
            rate: gstRate,
            type: type,
            precision: precision,
          );
    final tax = gst?.total ?? roundHalfUp(taxable * gstRate / 100, precision);
    final total = roundHalfUp(taxable + tax, precision);

    return InvoiceResult(
      subtotal: subtotal.toDouble(),
      discount: discount.toDouble(),
      taxableAmount: taxable,
      tax: tax,
      total: total,
      gst: gst,
    );
  }
}
