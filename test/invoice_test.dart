import 'dart:math';

import 'package:test/test.dart';
import 'package:indian_business_utils/indian_business_utils.dart';

void main() {
  group('InvoiceCalculator Tests', () {
    test('calculate with default GST (18%)', () {
      final result = InvoiceCalculator.calculate(subtotal: 1000);
      expect(result.subtotal, 1000);
      expect(result.discount, 0);
      expect(result.taxableAmount, 1000);
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
      expect(result.taxableAmount, 1000);
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

    // Regression: tax and total were returned unrounded (180.099, 1180.649).
    test('rounds taxable amount, tax and total to paise', () {
      final result = InvoiceCalculator.calculate(subtotal: 1000.55);
      expect(result.tax, 180.10);
      expect(result.total, 1180.65);

      final noisy = InvoiceCalculator.calculate(subtotal: 0.3, discount: 0.1);
      expect(noisy.taxableAmount, 0.2);
      expect(noisy.tax, 0.04);
      expect(noisy.total, 0.24);
    });

    test('custom precision and fractional rate', () {
      final result = InvoiceCalculator.calculate(
        subtotal: 1234.5,
        gstRate: 3,
        precision: 0,
      );
      expect(result.taxableAmount, 1235);
      expect(result.tax, 37);
      expect(result.total, 1272);
    });

    test('full discount and zero values', () {
      final result = InvoiceCalculator.calculate(subtotal: 500, discount: 500);
      expect(result.taxableAmount, 0);
      expect(result.total, 0);
      expect(InvoiceCalculator.calculate(subtotal: 0).total, 0);
    });

    test('works with GstCalculator for CGST/SGST split', () {
      final invoice =
          InvoiceCalculator.calculate(subtotal: 5000, discount: 200);
      final split = GstCalculator.splitGST(
        amount: invoice.taxableAmount,
        rate: 18,
        type: GstType.intraState,
      );
      expect(split.cgst, 432);
      expect(split.total, invoice.tax);
    });

    // Regression: the invoice tax was rounded at the full rate, so it could
    // differ by a paisa from CGST + SGST, each rounded at half the rate.
    test('intra-state tax equals CGST + SGST', () {
      final small = InvoiceCalculator.calculate(
        subtotal: 0.25,
        gstRate: 18,
        type: GstType.intraState,
      );
      expect(small.tax, 0.04);
      expect(small.total, 0.29);
      expect(small.gst, const GstSplitResult(cgst: 0.02, sgst: 0.02));

      final odd = InvoiceCalculator.calculate(
        subtotal: 100.05,
        type: GstType.intraState,
      );
      expect(odd.tax, 18);
      expect(odd.total, 118.05);
      expect(odd.gst, const GstSplitResult(cgst: 9, sgst: 9));
    });

    test('intra-state tax matches splitGST for random subtotals', () {
      int paise(double amount) => (amount * 100).round();
      final random = Random(20261022);
      for (var i = 0; i < 10000; i++) {
        final subtotal = random.nextInt(100000000) / 100;
        final invoice = InvoiceCalculator.calculate(
          subtotal: subtotal,
          type: GstType.intraState,
        );
        final gst = GstCalculator.splitGST(
          amount: invoice.taxableAmount,
          rate: 18,
          type: GstType.intraState,
        );
        expect(invoice.gst, gst, reason: '$subtotal');
        expect(invoice.tax, gst.total, reason: '$subtotal');
        expect(
          paise(invoice.total),
          paise(invoice.taxableAmount) + paise(gst.cgst) + paise(gst.sgst),
          reason: '$subtotal',
        );
      }
    });

    test('inter-state and default tax are rounded at the full rate', () {
      final inter = InvoiceCalculator.calculate(
        subtotal: 100.05,
        type: GstType.interState,
      );
      expect(inter.tax, 18.01);
      expect(inter.total, 118.06);
      expect(inter.gst, const GstSplitResult(igst: 18.01));

      final untyped = InvoiceCalculator.calculate(subtotal: 100.05);
      expect(untyped.tax, 18.01);
      expect(untyped.total, 118.06);
      expect(untyped.gst, isNull);
    });

    // Regression: a negative subtotal was reported as a bad discount.
    test('negative subtotal is not reported as a discount error', () {
      try {
        InvoiceCalculator.calculate(subtotal: -100);
      } on ArgumentError catch (e) {
        expect(e.name, 'subtotal');
      }
    });

    // Regression: invalid input silently produced negative totals.
    test('rejects invalid input', () {
      expect(
        () => InvoiceCalculator.calculate(subtotal: 100, discount: 200),
        throwsArgumentError,
      );
      expect(
        () => InvoiceCalculator.calculate(subtotal: 100, discount: -1),
        throwsArgumentError,
      );
      expect(
        () => InvoiceCalculator.calculate(subtotal: 100, gstRate: -18),
        throwsArgumentError,
      );
      expect(
        () => InvoiceCalculator.calculate(subtotal: -100),
        throwsArgumentError,
      );
      expect(
        () => InvoiceCalculator.calculate(subtotal: double.infinity),
        throwsArgumentError,
      );
      expect(
        () => InvoiceCalculator.calculate(subtotal: 100, precision: 11),
        throwsRangeError,
      );
    });
  });

  group('InvoiceResult', () {
    test('taxableAmount defaults to subtotal - discount', () {
      const result = InvoiceResult(
        subtotal: 1000,
        discount: 100,
        tax: 162,
        total: 1062,
      );
      expect(result.taxableAmount, 900);
    });

    test('value equality and toString', () {
      expect(
        InvoiceCalculator.calculate(subtotal: 1000),
        const InvoiceResult(subtotal: 1000, discount: 0, tax: 180, total: 1180),
      );
      expect(
        InvoiceCalculator.calculate(subtotal: 1000).hashCode,
        const InvoiceResult(subtotal: 1000, discount: 0, tax: 180, total: 1180)
            .hashCode,
      );
      expect(
        InvoiceCalculator.calculate(subtotal: 1000).toString(),
        // Interpolated so the expectation matches double.toString on both
        // native (1000.0) and JavaScript (1000) platforms.
        'InvoiceResult(subtotal: ${1000.0}, discount: ${0.0}, '
        'taxableAmount: ${1000.0}, tax: ${180.0}, total: ${1180.0})',
      );
    });

    test('equality, hashCode and toString include the GST split', () {
      final intra = InvoiceCalculator.calculate(
        subtotal: 1000,
        type: GstType.intraState,
      );
      final inter = InvoiceCalculator.calculate(
        subtotal: 1000,
        type: GstType.interState,
      );
      expect(
        intra,
        const InvoiceResult(
          subtotal: 1000,
          discount: 0,
          tax: 180,
          total: 1180,
          gst: GstSplitResult(cgst: 90, sgst: 90),
        ),
      );
      expect(intra, isNot(inter));
      expect(intra, isNot(InvoiceCalculator.calculate(subtotal: 1000)));
      expect(
        intra.hashCode,
        InvoiceCalculator.calculate(subtotal: 1000, type: GstType.intraState)
            .hashCode,
      );
      expect(
        inter.toString(),
        'InvoiceResult(subtotal: ${1000.0}, discount: ${0.0}, '
        'taxableAmount: ${1000.0}, tax: ${180.0}, total: ${1180.0}, '
        'gst: GstSplitResult(cgst: ${0.0}, sgst: ${0.0}, igst: ${180.0}))',
      );
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

    test('uses the current IST financial year by default', () {
      expect(
        InvoiceNumberGenerator.generate(sequence: 7),
        'INV/${FinancialYearHelper.currentFY()}/0007',
      );
    });

    test('generate for a specific date', () {
      expect(
        InvoiceNumberGenerator.generate(
            sequence: 42, date: DateTime(2025, 6, 1)),
        'INV/2025-26/0042',
      );
      expect(
        InvoiceNumberGenerator.generate(
            sequence: 1, date: DateTime(2026, 3, 31)),
        'INV/2025-26/0001',
      );
      expect(
        InvoiceNumberGenerator.generate(
            sequence: 1, date: DateTime(2026, 4, 1)),
        'INV/2026-27/0001',
      );
    });

    test('sequence longer than padding is not truncated', () {
      expect(
        InvoiceNumberGenerator.generate(
            sequence: 123456, date: DateTime(2025, 6, 1)),
        'INV/2025-26/123456',
      );
    });

    // Regression: negative sequences produced "INV/2026-27/00-3".
    test('rejects negative sequence', () {
      expect(
        () => InvoiceNumberGenerator.generate(sequence: -3),
        throwsArgumentError,
      );
    });

    test('isGstCompliant', () {
      expect(InvoiceNumberGenerator.isGstCompliant('INV/2025-26/0001'), isTrue);
      expect(InvoiceNumberGenerator.isGstCompliant('A1'), isTrue);
      expect(
        InvoiceNumberGenerator.isGstCompliant('INV/2025-26/000001'),
        isFalse,
      );
      expect(InvoiceNumberGenerator.isGstCompliant('INV 2025'), isFalse);
      expect(InvoiceNumberGenerator.isGstCompliant('INV#1'), isFalse);
      expect(InvoiceNumberGenerator.isGstCompliant(''), isFalse);
    });
  });
}
