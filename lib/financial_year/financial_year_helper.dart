/// Utility class for Indian financial year operations.
class FinancialYearHelper {
  /// Returns the current financial year.
  ///
  /// Example:
  /// 2025-26
  static String currentFY() {
    final now = DateTime.now();

    int startYear = now.month >= 4 ? now.year : now.year - 1;
    final endYear = (startYear + 1).toString().substring(2);

    return "$startYear-$endYear";
  }
}
