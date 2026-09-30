import 'package:test/test.dart';
import 'package:indian_business_utils/indian_business_utils.dart';

void main() {
  group('GstCalculator.splitGST', () {
    test('GST split intra state', () {
      final result = GstCalculator.splitGST(
        amount: 1000,
        rate: 18,
        type: GstType.intraState,
      );

      expect(result.cgst, 90);
      expect(result.sgst, 90);
      expect(result.igst, 0);
      expect(result.total, 180);
    });

    test('GST split inter state', () {
      final result = GstCalculator.splitGST(
        amount: 1000,
        rate: 18,
        type: GstType.interState,
      );

      expect(result, const GstSplitResult(igst: 180));
      expect(result.total, 180);
    });

    // Regression: toStringAsFixed rounded binary values like 0.04499… down.
    test('rounds half-up on decimal values', () {
      double igst(num amount, num rate) => GstCalculator.splitGST(
            amount: amount,
            rate: rate,
            type: GstType.interState,
          ).igst;

      expect(igst(0.25, 18), 0.05);
      expect(igst(55.25, 18), 9.95);
      expect(igst(1000.55, 18), 180.10);
      expect(igst(100.5, 5), 5.03);
    });

    test('CGST and SGST are computed at half rate each', () {
      // 9% of 1000.55 = 90.0495 -> 90.05 each.
      final result = GstCalculator.splitGST(
        amount: 1000.55,
        rate: 18,
        type: GstType.intraState,
      );
      expect(result.cgst, 90.05);
      expect(result.sgst, 90.05);
      expect(result.total, 180.10);
    });

    test('supports special and fractional rates', () {
      final gold = GstCalculator.splitGST(
        amount: 100000,
        rate: 3,
        type: GstType.intraState,
      );
      expect(gold.cgst, 1500);

      final diamonds = GstCalculator.splitGST(
        amount: 1000,
        rate: 0.25,
        type: GstType.interState,
      );
      expect(diamonds.igst, 2.5);
    });

    test('custom precision', () {
      final result = GstCalculator.splitGST(
        amount: 1000.55,
        rate: 18,
        type: GstType.interState,
        precision: 0,
      );
      expect(result.igst, 180);
    });

    test('zero amount and zero rate', () {
      expect(
        GstCalculator.splitGST(amount: 0, rate: 18, type: GstType.intraState),
        const GstSplitResult(),
      );
      expect(
        GstCalculator.splitGST(amount: 500, rate: 0, type: GstType.interState)
            .total,
        0,
      );
    });

    test('negative amounts give negative tax', () {
      final result = GstCalculator.splitGST(
        amount: -1000,
        rate: 18,
        type: GstType.intraState,
      );
      expect(result.cgst, -90);
      expect(result.total, -180);
    });

    test('rejects invalid input', () {
      expect(
        () => GstCalculator.splitGST(
            amount: double.nan, rate: 18, type: GstType.interState),
        throwsArgumentError,
      );
      expect(
        () => GstCalculator.splitGST(
            amount: 100, rate: -5, type: GstType.interState),
        throwsArgumentError,
      );
      expect(
        () => GstCalculator.splitGST(
            amount: 100, rate: 18, type: GstType.interState, precision: -1),
        throwsRangeError,
      );
    });
  });

  group('GstSplitResult', () {
    test('value equality and toString', () {
      expect(
        const GstSplitResult(cgst: 1, sgst: 1),
        GstSplitResult(cgst: 1.0, sgst: 0.5 + 0.5),
      );
      expect(
        const GstSplitResult(cgst: 1, sgst: 1).hashCode,
        GstSplitResult(cgst: 1.0, sgst: 0.5 + 0.5).hashCode,
      );
      expect(
          const GstSplitResult(igst: 1), isNot(const GstSplitResult(cgst: 1)));
      expect(
        const GstSplitResult(igst: 18).toString(),
        'GstSplitResult(cgst: ${0.0}, sgst: ${0.0}, igst: ${18.0})',
      );
    });

    test('total has no floating point noise', () {
      expect(const GstSplitResult(cgst: 0.1, sgst: 0.2).total, 0.3);
    });
  });

  group('GstTypeDetector', () {
    test('same state is intra-state', () {
      expect(
        GstTypeDetector.detect(
          sellerGSTIN: '27AAPFU0939F1ZV',
          buyerGSTIN: '27AAACR5055K1Z7',
        ),
        GstType.intraState,
      );
    });

    test('different states are inter-state', () {
      expect(
        GstTypeDetector.detect(
          sellerGSTIN: '27AAPFU0939F1ZV',
          buyerGSTIN: '24AAACC1206D1ZM',
        ),
        GstType.interState,
      );
    });

    test('ignores surrounding whitespace', () {
      expect(
        GstTypeDetector.detect(
          sellerGSTIN: ' 27AAPFU0939F1ZV',
          buyerGSTIN: '27aaacr5055k1z7 ',
        ),
        GstType.intraState,
      );
    });

    // Regression: short input threw an unhelpful RangeError.
    test('rejects values without a state code', () {
      for (final bad in ['', '2', 'AB12345']) {
        expect(
          () => GstTypeDetector.detect(
              sellerGSTIN: bad, buyerGSTIN: '27AAPFU0939F1ZV'),
          throwsA(isA<ArgumentError>()
              .having((e) => e.name, 'name', 'sellerGSTIN')),
        );
      }
    });

    test('fromStateCodes', () {
      expect(
        GstTypeDetector.fromStateCodes(
            supplierStateCode: '27', placeOfSupplyStateCode: '27'),
        GstType.intraState,
      );
      expect(
        GstTypeDetector.fromStateCodes(
            supplierStateCode: '07', placeOfSupplyStateCode: '7'),
        GstType.intraState,
      );
      expect(
        GstTypeDetector.fromStateCodes(
            supplierStateCode: '27', placeOfSupplyStateCode: '24'),
        GstType.interState,
      );
      expect(
        () => GstTypeDetector.fromStateCodes(
            supplierStateCode: 'MH', placeOfSupplyStateCode: '27'),
        throwsArgumentError,
      );
    });
  });

  group('GstSlabHelper', () {
    test('isValidSlab without a date accepts every slab ever in force', () {
      for (final rate in [0, 5, 12, 18, 28, 40]) {
        expect(GstSlabHelper.isValidSlab(rate), isTrue, reason: '$rate');
      }
      for (final rate in [1, 3, 10, 15, 50, -5]) {
        expect(GstSlabHelper.isValidSlab(rate), isFalse, reason: '$rate');
      }
      expect(GstSlabHelper.isValidSlab(18.0), isTrue);
    });

    test('slabsOn follows the rate changes', () {
      expect(GstSlabHelper.slabsOn(DateTime(2024, 1, 1)), [0, 5, 12, 18, 28]);
      expect(
        GstSlabHelper.slabsOn(DateTime(2025, 9, 21, 23, 59)),
        [0, 5, 12, 18, 28],
      );
      expect(GstSlabHelper.slabsOn(DateTime(2025, 9, 22)), [0, 5, 18, 28, 40]);
      expect(GstSlabHelper.slabsOn(DateTime(2026, 1, 31)), [0, 5, 18, 28, 40]);
      expect(GstSlabHelper.slabsOn(DateTime(2026, 2, 1)), [0, 5, 18, 40]);
    });

    test('isValidSlab with a date', () {
      final today = DateTime(2026, 9, 30);
      expect(GstSlabHelper.isValidSlab(12, on: today), isFalse);
      expect(GstSlabHelper.isValidSlab(28, on: today), isFalse);
      expect(GstSlabHelper.isValidSlab(40, on: today), isTrue);
      expect(GstSlabHelper.isValidSlab(12, on: DateTime(2024, 5, 1)), isTrue);
      expect(GstSlabHelper.isValidSlab(40, on: DateTime(2024, 5, 1)), isFalse);
    });

    test('isValidRate includes special rates', () {
      expect(GstSlabHelper.isValidRate(3), isTrue);
      expect(GstSlabHelper.isValidRate(0.25), isTrue);
      expect(GstSlabHelper.isValidRate(1.5), isTrue);
      expect(GstSlabHelper.isValidRate(18), isTrue);
      expect(GstSlabHelper.isValidRate(2), isFalse);
      expect(GstSlabHelper.isValidSlab(3), isFalse);
    });

    test('deprecated slabs keeps its original value', () {
      // ignore: deprecated_member_use_from_same_package
      expect(GstSlabHelper.slabs, [0, 5, 12, 18, 28]);
    });
  });
}
