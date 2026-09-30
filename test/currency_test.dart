import 'package:intl/intl.dart';
import 'package:test/test.dart';
import 'package:indian_business_utils/indian_business_utils.dart';

void main() {
  group('IndianCurrencyFormatter.format', () {
    test('formats with lakh/crore grouping', () {
      expect(IndianCurrencyFormatter.format(1234567.89), '₹12,34,567.89');
      expect(IndianCurrencyFormatter.format(123456789), '₹12,34,56,789.00');
    });

    test('formats small, zero and negative amounts', () {
      expect(IndianCurrencyFormatter.format(0), '₹0.00');
      expect(IndianCurrencyFormatter.format(999), '₹999.00');
      expect(IndianCurrencyFormatter.format(-1234.5), '-₹1,234.50');
    });

    test('is not affected by Intl.defaultLocale', () {
      final previous = Intl.defaultLocale;
      addTearDown(() => Intl.defaultLocale = previous);
      Intl.defaultLocale = 'en_US';
      expect(IndianCurrencyFormatter.format(1234567), '₹12,34,567.00');
    });
  });

  group('IndianCurrencyFormatter.formatToWords', () {
    test('formatToWords basic', () {
      expect(
        IndianCurrencyFormatter.formatToWords(1000),
        'One Thousand Only',
      );
    });

    test('formatToWords complex', () {
      expect(
        IndianCurrencyFormatter.formatToWords(1234.56),
        'One Thousand Two Hundred Thirty Four and Fifty Six Paise Only',
      );
    });

    test('formatToWords Lakhs', () {
      expect(
        IndianCurrencyFormatter.formatToWords(125000),
        'One Lakh Twenty Five Thousand Only',
      );
    });

    test('crores and beyond', () {
      expect(
        IndianCurrencyFormatter.formatToWords(1234567890.12),
        'One Hundred Twenty Three Crore Forty Five Lakh Sixty Seven Thousand '
        'Eight Hundred Ninety and Twelve Paise Only',
      );
      expect(
          IndianCurrencyFormatter.formatToWords(1e12), 'One Lakh Crore Only');
    });

    test('number boundaries', () {
      const cases = {
        1: 'One Only',
        19: 'Nineteen Only',
        20: 'Twenty Only',
        21: 'Twenty One Only',
        100: 'One Hundred Only',
        101: 'One Hundred One Only',
        99999: 'Ninety Nine Thousand Nine Hundred Ninety Nine Only',
        100000: 'One Lakh Only',
        10000000: 'One Crore Only',
      };
      cases.forEach((amount, words) {
        expect(IndianCurrencyFormatter.formatToWords(amount), words);
      });
    });

    test('accepts int values', () {
      const int amount = 42;
      expect(IndianCurrencyFormatter.formatToWords(amount), 'Forty Two Only');
    });

    test('zero', () {
      expect(IndianCurrencyFormatter.formatToWords(0), 'Zero Rupees Only');
      expect(IndianCurrencyFormatter.formatToWords(0.004), 'Zero Rupees Only');
    });

    // Regression: produced " and Fifty Paise Only" (leading space).
    test('amounts below one rupee', () {
      expect(IndianCurrencyFormatter.formatToWords(0.5), 'Fifty Paise Only');
      expect(IndianCurrencyFormatter.formatToWords(0.01), 'One Paise Only');
    });

    // Regression: 1.999 produced "One and One Hundred Paise Only".
    test('rounds to the nearest paisa before converting', () {
      expect(IndianCurrencyFormatter.formatToWords(1.999), 'Two Only');
      expect(IndianCurrencyFormatter.formatToWords(0.999), 'One Only');
      expect(
        IndianCurrencyFormatter.formatToWords(10.005),
        'Ten and One Paise Only',
      );
    });

    // Regression: negative amounts threw a RangeError.
    test('negative amounts', () {
      expect(
        IndianCurrencyFormatter.formatToWords(-25.5),
        'Minus Twenty Five and Fifty Paise Only',
      );
      expect(IndianCurrencyFormatter.formatToWords(-0.001), 'Zero Rupees Only');
    });

    test('rejects values that cannot be represented', () {
      for (final value in [double.nan, double.infinity, 1e13, -1e20]) {
        expect(
          () => IndianCurrencyFormatter.formatToWords(value),
          throwsArgumentError,
          reason: '$value',
        );
      }
      expect(
        IndianCurrencyFormatter.formatToWords(9999999999999.99),
        startsWith(
            'Nine Lakh Ninety Nine Thousand Nine Hundred Ninety Nine Crore'),
      );
    });

    // Regression: formatToWords set Intl.defaultLocale globally.
    test('does not modify Intl.defaultLocale', () {
      final previous = Intl.defaultLocale;
      addTearDown(() => Intl.defaultLocale = previous);
      Intl.defaultLocale = 'fr_FR';
      IndianCurrencyFormatter.formatToWords(1234.56);
      expect(Intl.defaultLocale, 'fr_FR');
    });
  });
}
