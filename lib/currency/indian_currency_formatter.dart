import 'package:intl/intl.dart';

/// Formats numbers into Indian currency format.
class IndianCurrencyFormatter {
  static String format(num amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
    );

    return formatter.format(amount);
  }

  /// Converts an amount to words in Indian Numbering System.
  ///
  /// Example:
  /// 1234.56 -> "One Thousand Two Hundred Thirty Four and Fifty Six Paise Only"
  static String formatToWords(double amount) {
    if (amount == 0) return "Zero Rupees Only";

    Intl.defaultLocale = 'en_IN';
    final wholeNumber = amount.truncate();
    final fraction = ((amount - wholeNumber) * 100).round();

    String result = _convertToWords(wholeNumber);

    if (fraction > 0) {
      result += " and ${_convertToWords(fraction)} Paise";
    }

    return "$result Only";
  }

  static String _convertToWords(int n) {
    if (n == 0) return "";

    final units = [
      "",
      "One",
      "Two",
      "Three",
      "Four",
      "Five",
      "Six",
      "Seven",
      "Eight",
      "Nine",
      "Ten",
      "Eleven",
      "Twelve",
      "Thirteen",
      "Fourteen",
      "Fifteen",
      "Sixteen",
      "Seventeen",
      "Eighteen",
      "Nineteen"
    ];

    final tens = [
      "",
      "",
      "Twenty",
      "Thirty",
      "Forty",
      "Fifty",
      "Sixty",
      "Seventy",
      "Eighty",
      "Ninety"
    ];

    if (n < 20) return units[n];
    if (n < 100) {
      return "${tens[n ~/ 10]}${n % 10 != 0 ? " ${_convertToWords(n % 10)}" : ""}";
    }
    if (n < 1000) {
      return "${units[n ~/ 100]} Hundred${n % 100 != 0 ? " ${_convertToWords(n % 100)}" : ""}";
    }
    if (n < 100000) {
      return "${_convertToWords(n ~/ 1000)} Thousand${n % 1000 != 0 ? " ${_convertToWords(n % 1000)}" : ""}";
    }
    if (n < 10000000) {
      return "${_convertToWords(n ~/ 100000)} Lakh${n % 100000 != 0 ? " ${_convertToWords(n % 100000)}" : ""}";
    }
    return "${_convertToWords(n ~/ 10000000)} Crore${n % 10000000 != 0 ? " ${_convertToWords(n % 10000000)}" : ""}";
  }
}
