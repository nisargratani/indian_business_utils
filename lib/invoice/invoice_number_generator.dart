import '../financial_year/financial_year_helper.dart';

/// Generates invoice numbers using financial year.
class InvoiceNumberGenerator {
  static String generate({
    required int sequence,
    String prefix = "INV",
    int padding = 4,
  }) {
    final fy = FinancialYearHelper.currentFY();

    return "$prefix/$fy/${sequence.toString().padLeft(padding, '0')}";
  }
}
