/// Utility class for Indian financial year operations.
class FinancialYearHelper {
  /// Returns the financial year for a given date.
  ///
  /// Example:
  /// 2025-26
  static String getFY(DateTime date) {
    int startYear = date.month >= 4 ? date.year : date.year - 1;
    final endYear = (startYear + 1).toString().substring(2);

    return "$startYear-$endYear";
  }

  /// Returns the current financial year.
  static String currentFY() => getFY(DateTime.now());
}
