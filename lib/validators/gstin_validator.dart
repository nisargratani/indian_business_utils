import 'pan_validator.dart';

/// Validates Indian GSTIN (GST Identification Number) values.
class GstinValidator {
  // Both cases are listed explicitly: toUpperCase() maps some non-ASCII
  // letters, such as 'ı' and 'ſ', to ASCII, so the input is checked first.
  static final _regex =
      RegExp(r'^[0-9]{2}[A-Za-z]{5}[0-9]{4}[A-Za-z][A-Za-z0-9]{3}$');

  /// "Other Territory" state code.
  static const int _otherTerritoryCode = 97;

  /// Returns true if [gstin] is a valid PAN-based GSTIN.
  ///
  /// Checks the 15-character format, the state code (01–38, or 97 for Other
  /// Territory), the embedded PAN (characters 3–12, checked with
  /// [PanValidator.isValid]) and the check digit. Surrounding whitespace and
  /// lowercase letters are accepted; only the ASCII letters `A`–`Z` and
  /// digits `0`–`9` are allowed. Store the normalized value,
  /// `gstin.trim().toUpperCase()`.
  ///
  /// Registrations that are not PAN-based, such as TDS/TCS, UIN, NRTP and
  /// OIDAR numbers, are not supported and return false.
  static bool isValid(String gstin) {
    final trimmed = gstin.trim();
    if (!_regex.hasMatch(trimmed)) return false;
    final value = trimmed.toUpperCase();

    final stateCode = int.parse(value.substring(0, 2));
    final isKnownState =
        (stateCode >= 1 && stateCode <= 38) || stateCode == _otherTerritoryCode;
    if (!isKnownState) return false;

    if (!PanValidator.isValid(value.substring(2, 12))) return false;

    return _checkChecksum(value);
  }

  /// Checks the 15th character with the Luhn mod-36 algorithm published by
  /// GSTN. (This is not ISO 7064 MOD 37,36, which is a different scheme.)
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
