import 'package:test/test.dart';
import 'package:indian_business_utils/indian_business_utils.dart';

void main() {
  group('PAN Validator', () {
    test('Valid PAN uppercase', () {
      expect(PanValidator.isValid("ABCPE1234F"), true);
    });

    test('Valid PAN lowercase (normalization)', () {
      expect(PanValidator.isValid("abcpe1234f"), true);
    });

    test('Invalid PAN status code', () {
      expect(PanValidator.isValid("ABCDE1234Z"), false); // Z is not a valid status
    });
  });

  group('GSTIN Validator', () {
    test('Valid GSTIN', () {
      expect(GstinValidator.isValid("27AAPFU0939F1ZV"), true);
    });

    test('Invalid GSTIN checksum', () {
      expect(GstinValidator.isValid("27AAPFU0939F1ZW"), false);
    });

    test('Invalid State Code', () {
      expect(GstinValidator.isValid("99AAPFU0939F1ZV"), false);
    });
  });

  group('HSN/SAC Validator', () {
    test('Valid HSN', () {
      expect(HsnValidator.isValidHSN("8517"), true);
      expect(HsnValidator.isValidHSN("85171200"), true);
    });

    test('Valid SAC', () {
      expect(HsnValidator.isValidSAC("9983"), false); // Too short
      expect(HsnValidator.isValidSAC("998311"), true);
    });
  });
}
