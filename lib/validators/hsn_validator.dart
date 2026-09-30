/// Validates HSN (goods) and SAC (services) code formats.
///
/// Only the format is checked, not whether the code exists in the official
/// HSN/SAC schedule. Surrounding whitespace is ignored.
class HsnValidator {
  static final _hsnRegex = RegExp(r'^(\d{4}|\d{6}|\d{8})$');
  static final _sacRegex = RegExp(r'^99\d{4}$');

  /// Returns true if [hsn] is a 4, 6 or 8 digit HSN code.
  ///
  /// HSN codes have an even number of digits (heading, sub-heading, tariff
  /// item), so 5 and 7 digit values are rejected.
  static bool isValidHSN(String hsn) => _hsnRegex.hasMatch(hsn.trim());

  /// Returns true if [sac] is a 6 digit SAC code starting with `99`.
  static bool isValidSAC(String sac) => _sacRegex.hasMatch(sac.trim());

  /// Returns true if [code] is a valid HSN or SAC code.
  static bool isValid(String code) => isValidHSN(code) || isValidSAC(code);
}
