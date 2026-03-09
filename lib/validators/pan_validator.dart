/// Validates Indian PAN numbers.
class PanValidator {
  static final _regex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');

  /// Returns true if PAN is valid.
  static bool isValid(String pan) {
    final normalizedPan = pan.toUpperCase().trim();
    if (!_regex.hasMatch(normalizedPan)) return false;

    // 4th character represents status of the holder
    const validStatus = 'CPHFATBLJG';
    if (!validStatus.contains(normalizedPan[3])) return false;

    return true;
  }
}
