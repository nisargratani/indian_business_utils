import 'package:test/test.dart';
import 'package:indian_business_utils/indian_business_utils.dart';

void main() {
  group('FinancialYearHelper', () {
    test('getFY for specific date', () {
      expect(FinancialYearHelper.getFY(DateTime(2025, 3, 31)), '2024-25');
      expect(FinancialYearHelper.getFY(DateTime(2025, 4, 1)), '2025-26');
    });

    test('getFY at year and century boundaries', () {
      expect(FinancialYearHelper.getFY(DateTime(2026, 1, 1)), '2025-26');
      expect(FinancialYearHelper.getFY(DateTime(2025, 12, 31)), '2025-26');
      expect(FinancialYearHelper.getFY(DateTime(2099, 6, 1)), '2099-00');
      expect(FinancialYearHelper.getFY(DateTime(2000, 1, 1)), '1999-00');
    });

    // Regression: years below 1000 threw a RangeError.
    test('getFY with short years', () {
      expect(FinancialYearHelper.getFY(DateTime(5, 6, 1)), '5-06');
    });

    test('getFY ignores time of day', () {
      expect(
        FinancialYearHelper.getFY(DateTime(2025, 3, 31, 23, 59, 59)),
        '2024-25',
      );
    });

    test('currentFY format', () {
      final fy = FinancialYearHelper.currentFY();
      expect(fy, matches(RegExp(r'^20[0-9]{2}-[0-9]{2}$')));
    });

    test('currentFY uses Indian Standard Time', () {
      final ist =
          DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));
      expect(FinancialYearHelper.currentFY(), FinancialYearHelper.getFY(ist));
    });

    test('start and end dates', () {
      final date = DateTime(2026, 1, 15);
      expect(FinancialYearHelper.getFYStartDate(date), DateTime(2025, 4, 1));
      expect(FinancialYearHelper.getFYEndDate(date), DateTime(2026, 3, 31));
      expect(
        FinancialYearHelper.getFYStartDate(DateTime(2025, 4, 1)),
        DateTime(2025, 4, 1),
      );
      expect(
        FinancialYearHelper.getFYEndDate(DateTime(2025, 3, 31)),
        DateTime(2025, 3, 31),
      );
    });
  });
}
