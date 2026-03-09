import 'package:indian_business_utils/indian_business_utils.dart';

void main() {
  final gst = GstCalculator.splitGST(
    amount: 1000,
    rate: 18,
    type: GstType.intraState,
  );

  print("CGST: ${gst.cgst}");
  print("SGST: ${gst.sgst}");

  final invoice = InvoiceCalculator.calculate(
    subtotal: 5000,
    discount: 200,
    gstRate: 18,
  );

  print("Total: ${invoice.total}");

  final invoiceNo = InvoiceNumberGenerator.generate(sequence: 1);

  print(invoiceNo);

  print(IndianCurrencyFormatter.format(1234567));
}
