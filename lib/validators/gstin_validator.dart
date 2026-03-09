/// Validates Indian GSTIN numbers.
class GstinValidator {
  static final _regex = RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][A-Z0-9]{3}$');

  /// Returns true if GSTIN is valid.
  static bool isValid(String gstin) {
    if (!_regex.hasMatch(gstin)) return false;

    // Validate State Code (01-38)
    final stateCode = int.parse(gstin.substring(0, 2));
    if (stateCode < 1 || stateCode > 38) return false;

    // Checksum validation
    return _checkChecksum(gstin);
  }

  /// ISO 7064 Mod 36, 37 checksum validation for GSTIN.
  static bool _checkChecksum(String gstin) {
    const chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    int factor = 1;
    int sum = 0;
    int checkCode = 0;

    for (int i = 0; i < 14; i++) {
      int code = chars.indexOf(gstin[i]);
      int digit = code * factor;
      digit = (digit ~/ 36) + (digit % 36);
      sum += digit;
      factor = (factor == 1) ? 2 : 1;
    }

    checkCode = (36 - (sum % 36)) % 36;
    return gstin[14] == chars[checkCode];
  }
}
