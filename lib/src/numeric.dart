import 'dart:math' as math;

/// Largest number of decimal places accepted by the rounding helpers.
///
/// Beyond this, a `double` no longer has enough significant digits for
/// decimal rounding to be meaningful for money values.
const int maxPrecision = 10;

/// Rounds [value] to [precision] decimal places using commercial
/// (half away from zero) rounding.
///
/// Binary floating point cannot represent most decimal fractions exactly, so
/// `9.945` is stored as `9.94499999…` and a naive `toStringAsFixed(2)` rounds
/// it *down*. The scaled value is first normalised to 15 significant digits
/// (the precision a `double` reliably holds), which removes that
/// representation error before rounding.
double roundHalfUp(num value, int precision) {
  checkPrecision(precision);
  final factor = math.pow(10, precision).toDouble();
  final scaled = normalize((value * factor).toDouble());
  final result = scaled.roundToDouble() / factor;
  // Avoid returning -0.0, which prints as "-0.0".
  return result == 0 ? 0.0 : result;
}

/// Removes binary representation noise such as `0.30000000000000004`.
double normalize(double value) {
  if (!value.isFinite) return value;
  final result = double.parse(value.toStringAsPrecision(15));
  return result == 0 ? 0.0 : result;
}

/// Throws an [ArgumentError] if [value] is NaN or infinite.
void checkFinite(num value, String name) {
  if (!value.isFinite) {
    throw ArgumentError.value(value, name, 'Must be a finite number');
  }
}

/// Throws a [RangeError] if [precision] is outside `0..maxPrecision`.
void checkPrecision(int precision) {
  RangeError.checkValueInInterval(precision, 0, maxPrecision, 'precision');
}
