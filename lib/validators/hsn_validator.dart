/// Validates HSN code format.
class HsnValidator {
  static final _regex = RegExp(r'^\d{4,8}$');

  /// Returns true if HSN code is valid.
  static bool isValid(String hsn) {
    return _regex.hasMatch(hsn);
  }
}
