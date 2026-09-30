import 'package:intl/intl.dart';

import '../src/numeric.dart';

/// Formats amounts using the Indian numbering system (lakhs and crores).
class IndianCurrencyFormatter {
  /// Amounts in words must be strictly below this absolute value
  /// (10,00,000 crore).
  ///
  /// Larger values cannot be represented to the paisa by a `double`.
  static const double maxAmountInWords = 1e13;

  // Creating a NumberFormat parses its pattern, so build it once and reuse it.
  // The locale is explicit, so the result never depends on Intl.defaultLocale.
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
  );

  /// Formats [amount] as Indian rupees with two decimal places.
  ///
  /// ```dart
  /// IndianCurrencyFormatter.format(1234567.891); // ₹12,34,567.89
  /// IndianCurrencyFormatter.format(-1234.5);     // -₹1,234.50
  /// ```
  static String format(num amount) => _currencyFormat.format(amount);

  /// Converts [amount] to words in the Indian numbering system, as printed on
  /// invoices and cheques.
  ///
  /// The amount is rounded to the nearest paisa first.
  ///
  /// ```dart
  /// IndianCurrencyFormatter.formatToWords(1234.56);
  /// // One Thousand Two Hundred Thirty Four and Fifty Six Paise Only
  /// IndianCurrencyFormatter.formatToWords(0.5);  // Fifty Paise Only
  /// IndianCurrencyFormatter.formatToWords(-25);  // Minus Twenty Five Only
  /// IndianCurrencyFormatter.formatToWords(0);    // Zero Rupees Only
  /// ```
  ///
  /// Throws an [ArgumentError] if [amount] is NaN, infinite, or its absolute
  /// value is not below [maxAmountInWords].
  static String formatToWords(num amount) {
    checkFinite(amount, 'amount');
    if (amount.abs() >= maxAmountInWords) {
      throw ArgumentError.value(
        amount,
        'amount',
        'Absolute value must be less than $maxAmountInWords',
      );
    }

    // Round once, in paise, so that e.g. 1.999 becomes 2 rupees rather than
    // "1 rupee and 100 paise".
    final totalPaise = (roundHalfUp(amount.abs(), 2) * 100).round();
    if (totalPaise == 0) return 'Zero Rupees Only';

    final rupees = totalPaise ~/ 100;
    final paise = totalPaise % 100;

    final parts = <String>[
      if (rupees > 0) _convertToWords(rupees),
      if (paise > 0) '${_convertToWords(paise)} Paise',
    ];
    final sign = amount < 0 ? 'Minus ' : '';

    return '$sign${parts.join(' and ')} Only';
  }

  static const List<String> _units = [
    '',
    'One',
    'Two',
    'Three',
    'Four',
    'Five',
    'Six',
    'Seven',
    'Eight',
    'Nine',
    'Ten',
    'Eleven',
    'Twelve',
    'Thirteen',
    'Fourteen',
    'Fifteen',
    'Sixteen',
    'Seventeen',
    'Eighteen',
    'Nineteen',
  ];

  static const List<String> _tens = [
    '',
    '',
    'Twenty',
    'Thirty',
    'Forty',
    'Fifty',
    'Sixty',
    'Seventy',
    'Eighty',
    'Ninety',
  ];

  /// Converts a positive integer to words. Returns an empty string for 0.
  static String _convertToWords(int n) {
    if (n < 20) return _units[n];
    if (n < 100) return _join(_tens[n ~/ 10], n % 10);
    if (n < 1000) return _join('${_units[n ~/ 100]} Hundred', n % 100);
    if (n < 100000) {
      return _join('${_convertToWords(n ~/ 1000)} Thousand', n % 1000);
    }
    if (n < 10000000) {
      return _join('${_convertToWords(n ~/ 100000)} Lakh', n % 100000);
    }
    return _join('${_convertToWords(n ~/ 10000000)} Crore', n % 10000000);
  }

  static String _join(String head, int remainder) =>
      remainder == 0 ? head : '$head ${_convertToWords(remainder)}';
}
