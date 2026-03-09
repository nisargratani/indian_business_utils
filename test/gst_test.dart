import 'package:test/test.dart';
import 'package:indian_business_utils/indian_business_utils.dart';

void main() {
  test('GST split intra state', () {
    final result = GstCalculator.splitGST(
      amount: 1000,
      rate: 18,
      type: GstType.intraState,
    );

    expect(result.cgst, 90);
    expect(result.sgst, 90);
  });
}
