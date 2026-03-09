import 'package:test/test.dart';
import 'package:indian_business_utils/indian_business_utils.dart';

void main() {
  test('Valid PAN', () {
    expect(PanValidator.isValid("ABCDE1234F"), true);
  });

  test('Invalid PAN', () {
    expect(PanValidator.isValid("ABCDE123"), false);
  });

  test('Valid GSTIN', () {
    expect(GstinValidator.isValid("27AAPFU0939F1ZV"), true);
  });
}
