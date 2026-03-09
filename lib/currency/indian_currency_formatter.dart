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
}
