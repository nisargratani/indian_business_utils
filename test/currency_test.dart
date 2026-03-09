import 'package:test/test.dart';
import 'package:indian_business_utils/indian_business_utils.dart';

void main() {
  group('IndianCurrencyFormatter Tests', () {
    test('format currency', () {
      expect(IndianCurrencyFormatter.format(1234567.89), '₹12,34,567.89');
    });

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
  });
}
