import 'package:test/test.dart';
import 'package:indian_business_utils/indian_business_utils.dart';

void main() {
  group('FinancialYearHelper Tests', () {
    test('getFY for specific date', () {
      expect(FinancialYearHelper.getFY(DateTime(2025, 3, 31)), '2024-25');
      expect(FinancialYearHelper.getFY(DateTime(2025, 4, 1)), '2025-26');
    });

    test('currentFY format', () {
      final fy = FinancialYearHelper.currentFY();
      expect(fy, matches(RegExp(r'^20[0-9]{2}-[0-9]{2}$')));
    });
  });
}
