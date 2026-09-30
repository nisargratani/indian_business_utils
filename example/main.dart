// ignore_for_file: avoid_print

import 'package:indian_business_utils/indian_business_utils.dart';

void main() {
  const sellerGstin = '27AAPFU0939F1ZV'; // Maharashtra
  const buyerGstin = '24AAACC1206D1ZM'; // Gujarat

  // 1. Validate the parties.
  print('Seller GSTIN valid: ${GstinValidator.isValid(sellerGstin)}');
  print('Buyer GSTIN valid:  ${GstinValidator.isValid(buyerGstin)}');
  print('PAN valid:          ${PanValidator.isValid('ABCPE1234F')}');
  print('HSN 8517 valid:     ${HsnValidator.isValid('8517')}');

  // 2. Check the rate is a slab in force today.
  const rate = 18;
  print('18% is a current slab: '
      '${GstSlabHelper.isValidSlab(rate, on: DateTime.now())}');

  // 3. Calculate the invoice.
  final invoice = InvoiceCalculator.calculate(
    subtotal: 5000,
    discount: 200,
    gstRate: rate,
  );

  // 4. Split the tax by transaction type.
  final type = GstTypeDetector.detect(
    sellerGSTIN: sellerGstin,
    buyerGSTIN: buyerGstin,
  );
  final gst = GstCalculator.splitGST(
    amount: invoice.taxableAmount,
    rate: rate,
    type: type,
  );

  // 5. Print it.
  final invoiceNo = InvoiceNumberGenerator.generate(sequence: 1);
  print('');
  print('Invoice $invoiceNo (FY ${FinancialYearHelper.currentFY()})');
  print('Subtotal: ${IndianCurrencyFormatter.format(invoice.subtotal)}');
  print('Discount: ${IndianCurrencyFormatter.format(invoice.discount)}');
  print('Taxable:  ${IndianCurrencyFormatter.format(invoice.taxableAmount)}');
  if (type == GstType.intraState) {
    print('CGST:     ${IndianCurrencyFormatter.format(gst.cgst)}');
    print('SGST:     ${IndianCurrencyFormatter.format(gst.sgst)}');
  } else {
    print('IGST:     ${IndianCurrencyFormatter.format(gst.igst)}');
  }
  print('Total:    ${IndianCurrencyFormatter.format(invoice.total)}');
  print('In words: ${IndianCurrencyFormatter.formatToWords(invoice.total)}');

  // 6. Invalid input throws an ArgumentError with a useful message.
  try {
    InvoiceCalculator.calculate(subtotal: 100, discount: 150);
  } on ArgumentError catch (e) {
    print('');
    print('Rejected: ${e.message}');
  }
}
