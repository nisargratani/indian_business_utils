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
  /// ```dart
  /// final invoice = InvoiceCalculator.calculate(
  ///   subtotal: 5000,
  ///   discount: 200,
  ///   gstRate: 18,
  /// );
  /// print(invoice.taxableAmount); // 4800.0
  /// print(invoice.tax);           // 864.0
  /// print(invoice.total);         // 5664.0
  /// ```
  ///
  /// To split the tax into CGST/SGST or IGST, pass
  /// [InvoiceResult.taxableAmount] to `GstCalculator.splitGST`.
  ///
  /// Throws an [ArgumentError] if any value is not finite, [gstRate] or
  /// [discount] is negative, or [discount] exceeds [subtotal]. Throws a
  /// [RangeError] if [precision] is outside `0..10`.
  static InvoiceResult calculate({
    required num subtotal,
    num discount = 0,
    num gstRate = 18,
    int precision = 2,
  }) {
    checkFinite(subtotal, 'subtotal');
    checkFinite(discount, 'discount');
    checkFinite(gstRate, 'gstRate');
    checkPrecision(precision);
    if (gstRate < 0) {
      throw ArgumentError.value(gstRate, 'gstRate', 'Must not be negative');
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
    final tax = roundHalfUp(taxable * gstRate / 100, precision);
    final total = roundHalfUp(taxable + tax, precision);

    return InvoiceResult(
      subtotal: subtotal.toDouble(),
      discount: discount.toDouble(),
      taxableAmount: taxable,
      tax: tax,
      total: total,
    );
  }
}
