/// Result model for invoice calculation.
class InvoiceResult {
  final double subtotal;
  final double discount;
  final double tax;
  final double total;

  const InvoiceResult({
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
  });
}
