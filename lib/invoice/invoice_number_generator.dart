import '../financial_year/financial_year_helper.dart';

/// Generates invoice numbers using financial year.
class InvoiceNumberGenerator {
  static String generate({
    required int sequence,
    String prefix = "INV",
  }) {
    final fy = FinancialYearHelper.currentFY();

    return "$prefix/$fy/${sequence.toString().padLeft(4, '0')}";
  }
}
