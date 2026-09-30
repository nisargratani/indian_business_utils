import '../models/gst_split_result.dart';
import '../src/numeric.dart';
import 'gst_type.dart';

/// Utility class for calculating GST values.
class GstCalculator {
  /// Calculates GST on the taxable [amount] at [rate] percent and splits it
  /// by transaction [type].
  ///
  /// * [GstType.intraState]: CGST and SGST, each at half of [rate].
  /// * [GstType.interState]: IGST at the full [rate].
  ///
  /// Each tax component is computed separately and rounded half-up to
  /// [precision] decimal places (default 2, i.e. paise). CGST and SGST are
  /// separate levies, so each is rounded on its own. Their sum can therefore
  /// differ from IGST on the same amount by one unit in the last place.
  ///
  /// ```dart
  /// final gst = GstCalculator.splitGST(
  ///   amount: 1000,
  ///   rate: 18,
  ///   type: GstType.intraState,
  /// );
  /// print(gst.cgst); // 90.0
  /// print(gst.sgst); // 90.0
  /// ```
  ///
  /// A negative [amount] (for example a credit-note adjustment) gives
  /// negative tax values.
  ///
  /// Throws an [ArgumentError] if [amount] or [rate] is not finite or [rate]
  /// is negative. Throws a [RangeError] if [precision] is outside `0..10`.
  static GstSplitResult splitGST({
    required num amount,
    required num rate,
    required GstType type,
    int precision = 2,
  }) {
    checkFinite(amount, 'amount');
    checkFinite(rate, 'rate');
    if (rate < 0) {
      throw ArgumentError.value(rate, 'rate', 'Must not be negative');
    }
    checkPrecision(precision);

    switch (type) {
      case GstType.intraState:
        final half = roundHalfUp(amount * rate / 200, precision);
        return GstSplitResult(cgst: half, sgst: half);
      case GstType.interState:
        return GstSplitResult(
            igst: roundHalfUp(amount * rate / 100, precision));
    }
  }
}
