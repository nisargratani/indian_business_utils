/// Validates Indian GSTIN numbers.
class GstinValidator {
  static final _regex = RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][A-Z0-9]{3}$');

  /// Returns true if GSTIN is valid.
  static bool isValid(String gstin) {
    return _regex.hasMatch(gstin);
  }
}
