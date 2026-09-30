import '../financial_year/financial_year_helper.dart';

/// Generates financial-year based invoice numbers such as `INV/2025-26/0001`.
class InvoiceNumberGenerator {
  /// Maximum invoice number length allowed by GST (Rule 46(b), CGST Rules).
  static const int maxGstLength = 16;

  static final _gstAllowedChars = RegExp(r'^[A-Za-z0-9/-]+$');

  /// Returns `<prefix>/<financial year>/<sequence>`, with [sequence]
  /// left-padded with zeros to [padding] digits.
  ///
  /// The financial year is taken from [date], or from the current date in
  /// IST when [date] is omitted (see `FinancialYearHelper.currentFY`). Pass
  /// [date] to number back-dated invoices or to get deterministic output.
  ///
  /// ```dart
  /// InvoiceNumberGenerator.generate(
  ///   sequence: 42,
  ///   date: DateTime(2025, 6, 1),
  /// ); // INV/2025-26/0042
  /// ```
  ///
  /// This does not track sequences. Persist the last issued sequence per
  /// financial year yourself, and check the result with [isGstCompliant] if
  /// you use a longer prefix or padding.
  ///
  /// Throws an [ArgumentError] if [sequence] is negative.
  static String generate({
    required int sequence,
    String prefix = 'INV',
    int padding = 4,
    DateTime? date,
  }) {
    if (sequence < 0) {
      throw ArgumentError.value(sequence, 'sequence', 'Must not be negative');
    }
    final fy = date == null
        ? FinancialYearHelper.currentFY()
        : FinancialYearHelper.getFY(date);

    return '$prefix/$fy/${sequence.toString().padLeft(padding, '0')}';
  }

  /// Returns true if [invoiceNumber] satisfies the GST invoice number rules:
  /// at most [maxGstLength] characters, using only letters, digits, `-`
  /// and `/`.
  ///
  /// ```dart
  /// InvoiceNumberGenerator.isGstCompliant('INV/2025-26/0001');   // true
  /// InvoiceNumberGenerator.isGstCompliant('INV/2025-26/000001'); // false (18 chars)
  /// ```
  static bool isGstCompliant(String invoiceNumber) =>
      invoiceNumber.length <= maxGstLength &&
      _gstAllowedChars.hasMatch(invoiceNumber);
}
