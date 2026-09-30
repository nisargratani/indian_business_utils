import 'gst_type.dart';

/// Detects the GST transaction type from GST state codes.
class GstTypeDetector {
  static final _stateCodePrefix = RegExp(r'^\d{2}');
  static final _stateCode = RegExp(r'^\d{1,2}$');

  /// Detects the transaction type from the seller's and buyer's GSTINs by
  /// comparing their state codes (the first two digits).
  ///
  /// Only the state code prefix is inspected. Use `GstinValidator.isValid` to
  /// validate the full GSTIN.
  ///
  /// For B2C sales, or when the place of supply differs from the buyer's
  /// registered state, use [fromStateCodes].
  ///
  /// Throws an [ArgumentError] if either value does not start with a
  /// two-digit state code.
  static GstType detect({
    required String sellerGSTIN,
    required String buyerGSTIN,
  }) {
    final sellerState = _stateCodeOf(sellerGSTIN, 'sellerGSTIN');
    final buyerState = _stateCodeOf(buyerGSTIN, 'buyerGSTIN');

    return sellerState == buyerState ? GstType.intraState : GstType.interState;
  }

  /// Detects the transaction type from the supplier's state code and the
  /// place-of-supply state code, for example `'27'` (Maharashtra) and `'24'`
  /// (Gujarat).
  ///
  /// Single-digit codes such as `'7'` are treated as `'07'`.
  ///
  /// Throws an [ArgumentError] if either code is not one or two digits.
  static GstType fromStateCodes({
    required String supplierStateCode,
    required String placeOfSupplyStateCode,
  }) {
    final supplier =
        _normalizeStateCode(supplierStateCode, 'supplierStateCode');
    final placeOfSupply =
        _normalizeStateCode(placeOfSupplyStateCode, 'placeOfSupplyStateCode');

    return supplier == placeOfSupply ? GstType.intraState : GstType.interState;
  }

  static String _stateCodeOf(String gstin, String name) {
    final value = gstin.trim();
    if (!_stateCodePrefix.hasMatch(value)) {
      throw ArgumentError.value(
        gstin,
        name,
        'Must start with a two-digit GST state code',
      );
    }
    return value.substring(0, 2);
  }

  static String _normalizeStateCode(String code, String name) {
    final value = code.trim();
    if (!_stateCode.hasMatch(value)) {
      throw ArgumentError.value(code, name, 'Must be a 1-2 digit state code');
    }
    return value.padLeft(2, '0');
  }
}
