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
  });

  group('InvoiceNumberGenerator Tests', () {
    test('generate standard invoice number', () {
      final invoiceNum = InvoiceNumberGenerator.generate(sequence: 1);
      // Based on current date 2026-03-09, FY should be 2025-26
      expect(invoiceNum, matches(RegExp(r'^INV/20[0-9]{2}-[0-9]{2}/0001$')));
      expect(invoiceNum.contains('2025-26'), isTrue);
    });

    test('generate with custom prefix', () {
      final invoiceNum = InvoiceNumberGenerator.generate(
        sequence: 45,
        prefix: 'BILL',
      );
      expect(invoiceNum.startsWith('BILL/'), isTrue);
      expect(invoiceNum.endsWith('/0045'), isTrue);
    });
  });
}
