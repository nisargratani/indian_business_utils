import '../models/invoice_result.dart';

/// Calculates invoice totals including GST.
class InvoiceCalculator {
  static InvoiceResult calculate({
    required double subtotal,
    double discount = 0,
    int gstRate = 18,
  }) {
    final taxable = subtotal - discount;
    final tax = taxable * gstRate / 100;
    final total = taxable + tax;

    return InvoiceResult(
      subtotal: subtotal,
      discount: discount,
      tax: tax,
      total: total,
    );
  }
}
