/// Validates Indian PAN (Permanent Account Number) values.
class PanValidator {
  static final _regex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');

  /// Valid holder-type codes for the 4th character: Company, Person, HUF,
  /// Firm, AOP, Trust, BOI, Local authority, Artificial juridical person,
  /// Government.
  static const _validStatus = 'CPHFATBLJG';

  /// Returns true if [pan] has a valid PAN format and holder-type code.
  ///
  /// Surrounding whitespace and lowercase letters are accepted.
  static bool isValid(String pan) {
    final normalizedPan = pan.toUpperCase().trim();
    if (!_regex.hasMatch(normalizedPan)) return false;

    return _validStatus.contains(normalizedPan[3]);
  }
}
