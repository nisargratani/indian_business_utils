import 'package:test/test.dart';
import 'package:indian_business_utils/indian_business_utils.dart';

void main() {
  group('InvoiceCalculator Tests', () {
    test('calculate with default GST (18%)', () {
      final result = InvoiceCalculator.calculate(subtotal: 1000);
      expect(result.subtotal, 1000);
      expect(result.tax, 180);
      expect(result.total, 1180);
    });

    test('calculate with custom GST (5%)', () {
      final result = InvoiceCalculator.calculate(subtotal: 1000, gstRate: 5);
      expect(result.tax, 50);
      expect(result.total, 1050);
    });

    test('calculate with discount', () {
      final result = InvoiceCalculator.calculate(
        subtotal: 1100,
        discount: 100,
        gstRate: 18,
      );
      expect(result.tax, 180); // (1100 - 100) * 18%
      expect(result.total, 1180);
    });

    test('calculate with rounding', () {
      // 1000.55 * 18% = 180.099 -> 180.10
      final result = GstCalculator.splitGST(
        amount: 1000.55,
        rate: 18,
        type: GstType.interState,
        precision: 2,
      );
      expect(result.igst, 180.10);
    });
  });

  group('InvoiceNumberGenerator Tests', () {
    test('generate standard invoice number', () {
      final invoiceNum = InvoiceNumberGenerator.generate(sequence: 1);
      expect(invoiceNum, matches(RegExp(r'^INV/20[0-9]{2}-[0-9]{2}/0001$')));
    });

    test('generate with custom padding', () {
      final invoiceNum = InvoiceNumberGenerator.generate(
        sequence: 1,
        padding: 6,
      );
      expect(invoiceNum, matches(RegExp(r'^INV/20[0-9]{2}-[0-9]{2}/000001$')));
    });

    test('generate with custom prefix', () {
      final invoiceNum = InvoiceNumberGenerator.generate(
        sequence: 45,
        prefix: 'BILL',
      );
      expect(invoiceNum.startsWith('BILL/'), isTrue);
    });
  });
}
