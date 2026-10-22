/// Validates Indian PAN (Permanent Account Number) values.
class PanValidator {
  // Both cases are listed explicitly: toUpperCase() maps some non-ASCII
  // letters, such as 'ı' and 'ſ', to ASCII, so the input is checked first.
  static final _regex = RegExp(r'^[A-Za-z]{5}[0-9]{4}[A-Za-z]$');

  /// Valid holder-type codes for the 4th character: Company, Person, HUF,
  /// Firm, AOP, Trust, BOI, Local authority, Artificial juridical person,
  /// Government.
  static const _validStatus = 'CPHFATBLJG';

  /// Returns true if [pan] has a valid PAN format and holder-type code.
  ///
  /// Surrounding whitespace and lowercase letters are accepted. Only the
  /// ASCII letters `A`–`Z` and digits `0`–`9` are allowed.
  static bool isValid(String pan) {
    final value = pan.trim();
    if (!_regex.hasMatch(value)) return false;

    return _validStatus.contains(value[3].toUpperCase());
  }
}
