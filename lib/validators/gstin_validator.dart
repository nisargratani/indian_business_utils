/// Validates Indian GSTIN (GST Identification Number) values.
class GstinValidator {
  static final _regex = RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][A-Z0-9]{3}$');

  /// "Other Territory" state code.
  static const int _otherTerritoryCode = 97;

  /// Returns true if [gstin] is a valid PAN-based GSTIN.
  ///
  /// Checks the 15-character format, the state code (01–38, or 97 for Other
  /// Territory) and the check digit. Surrounding whitespace and lowercase
  /// letters are accepted. Store the normalized value,
  /// `gstin.trim().toUpperCase()`.
  ///
  /// Registrations that are not PAN-based, such as TDS/TCS, UIN, NRTP and
  /// OIDAR numbers, are not supported and return false.
  static bool isValid(String gstin) {
    final value = gstin.trim().toUpperCase();
    if (!_regex.hasMatch(value)) return false;

    final stateCode = int.parse(value.substring(0, 2));
    final isKnownState =
        (stateCode >= 1 && stateCode <= 38) || stateCode == _otherTerritoryCode;
    if (!isKnownState) return false;

    return _checkChecksum(value);
  }

  /// ISO 7064 Mod 36, 37 checksum validation for GSTIN.
  static bool _checkChecksum(String gstin) {
    const chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    var factor = 1;
    var sum = 0;

    for (var i = 0; i < 14; i++) {
      final product = chars.indexOf(gstin[i]) * factor;
      sum += (product ~/ 36) + (product % 36);
      factor = (factor == 1) ? 2 : 1;
    }

    final checkCode = (36 - (sum % 36)) % 36;
    return gstin[14] == chars[checkCode];
  }
}
