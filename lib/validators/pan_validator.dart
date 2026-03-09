/// Validates Indian PAN numbers.
class PanValidator {
  static final _regex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');

  /// Returns true if PAN is valid.
  static bool isValid(String pan) {
    return _regex.hasMatch(pan);
  }
}
