/// Utilities for the Indian financial year, which runs from 1 April to
/// 31 March.
///
/// Methods that take a [DateTime] use its calendar fields (`year`, `month`)
/// as-is, so pass a date that is already in Indian time.
class FinancialYearHelper {
  static const Duration _istOffset = Duration(hours: 5, minutes: 30);

  /// Returns the financial year containing [date], in `YYYY-YY` form.
  ///
  /// ```dart
  /// FinancialYearHelper.getFY(DateTime(2025, 3, 31)); // 2024-25
  /// FinancialYearHelper.getFY(DateTime(2025, 4, 1));  // 2025-26
  /// ```
  static String getFY(DateTime date) {
    final startYear = _startYear(date);
    final endYear = ((startYear + 1) % 100).toString().padLeft(2, '0');

    return '$startYear-$endYear';
  }

  /// Returns the current financial year, in `YYYY-YY` form.
  ///
  /// The current date is taken in Indian Standard Time (UTC+05:30) regardless
  /// of the device or server time zone, so a server running in UTC switches
  /// to the new financial year at midnight IST on 1 April.
  static String currentFY() => getFY(_nowInIst());

  /// Returns 1 April of the financial year containing [date].
  ///
  /// ```dart
  /// FinancialYearHelper.getFYStartDate(DateTime(2026, 1, 15)); // 2025-04-01
  /// ```
  static DateTime getFYStartDate(DateTime date) =>
      DateTime(_startYear(date), 4, 1);

  /// Returns 31 March (at midnight) that ends the financial year containing
  /// [date].
  ///
  /// This is a calendar date. To test whether a timestamp falls inside the
  /// financial year, compare against the *next* year's start instead:
  /// `ts.isBefore(DateTime(getFYStartDate(date).year + 1, 4, 1))`.
  static DateTime getFYEndDate(DateTime date) =>
      DateTime(_startYear(date) + 1, 3, 31);

  static int _startYear(DateTime date) =>
      date.month >= 4 ? date.year : date.year - 1;

  // A UTC DateTime whose calendar fields hold the current IST wall-clock time.
  static DateTime _nowInIst() => DateTime.now().toUtc().add(_istOffset);
}
