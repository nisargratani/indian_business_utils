/// Validates HSN/SAC code format.
class HsnValidator {
  static final _hsnRegex = RegExp(r'^\d{4,8}$');
  static final _sacRegex = RegExp(r'^99\d{4}$');

  /// Returns true if HSN code (Goods) is valid.
  static bool isValidHSN(String hsn) => _hsnRegex.hasMatch(hsn);

  /// Returns true if SAC code (Services) is valid.
  static bool isValidSAC(String sac) => _sacRegex.hasMatch(sac);

  /// Generic validation for either HSN or SAC.
  static bool isValid(String code) => isValidHSN(code) || isValidSAC(code);
}
