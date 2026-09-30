import 'package:test/test.dart';
import 'package:indian_business_utils/indian_business_utils.dart';

void main() {
  group('PAN Validator', () {
    test('Valid PAN uppercase', () {
      expect(PanValidator.isValid('ABCPE1234F'), true);
    });

    test('Valid PAN lowercase (normalization)', () {
      expect(PanValidator.isValid('abcpe1234f'), true);
      expect(PanValidator.isValid('  ABCPE1234F '), true);
    });

    test('Invalid PAN status code', () {
      expect(PanValidator.isValid('ABCDE1234Z'), false); // D is not a status
    });

    test('every holder-type code is accepted', () {
      for (final status in 'CPHFATBLJG'.split('')) {
        expect(PanValidator.isValid('ABC${status}E1234F'), true,
            reason: status);
      }
    });

    test('Invalid PAN format', () {
      for (final pan in ['', 'ABCPE1234', 'ABCPE12345', 'ABCP11234F', '१२३']) {
        expect(PanValidator.isValid(pan), false, reason: pan);
      }
    });
  });

  group('GSTIN Validator', () {
    test('Valid GSTIN', () {
      expect(GstinValidator.isValid('27AAPFU0939F1ZV'), true);
      expect(GstinValidator.isValid('27AAACR5055K1Z7'), true);
      expect(GstinValidator.isValid('24AAACC1206D1ZM'), true);
    });

    test('Invalid GSTIN checksum', () {
      expect(GstinValidator.isValid('27AAPFU0939F1ZW'), false);
    });

    test('Invalid State Code', () {
      expect(GstinValidator.isValid('99AAPFU0939F1ZV'), false);
      expect(GstinValidator.isValid('00AAPFU0939F1ZV'), false);
    });

    test('accepts lowercase and surrounding whitespace', () {
      expect(GstinValidator.isValid('27aapfu0939f1zv'), true);
      expect(GstinValidator.isValid(' 27AAPFU0939F1ZV\n'), true);
    });

    test('accepts the Other Territory state code (97)', () {
      // Exactly one check character makes the GSTIN valid; 99 is rejected
      // whatever the check character is.
      const chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
      int validCount(String base) => chars
          .split('')
          .where((c) => GstinValidator.isValid('$base$c'))
          .length;
      expect(validCount('97AAPFU0939F1Z'), 1);
      expect(validCount('99AAPFU0939F1Z'), 0);
    });

    test('Invalid GSTIN format', () {
      for (final gstin in [
        '',
        '27AAPFU0939F1Z',
        '27AAPFU0939F1ZVX',
        '27 AAPFU0939F1Z',
        'AAAPFU0939F1ZVV',
      ]) {
        expect(GstinValidator.isValid(gstin), false, reason: gstin);
      }
    });
  });

  group('HSN/SAC Validator', () {
    test('Valid HSN', () {
      expect(HsnValidator.isValidHSN('8517'), true);
      expect(HsnValidator.isValidHSN('851712'), true);
      expect(HsnValidator.isValidHSN('85171200'), true);
      expect(HsnValidator.isValidHSN(' 8517 '), true);
    });

    // Regression: 5 and 7 digit codes were accepted.
    test('Invalid HSN', () {
      for (final hsn in [
        '',
        '85',
        '851',
        '85171',
        '8517120',
        '851712000',
        '85A7'
      ]) {
        expect(HsnValidator.isValidHSN(hsn), false, reason: hsn);
      }
    });

    test('Valid SAC', () {
      expect(HsnValidator.isValidSAC('9983'), false); // Too short
      expect(HsnValidator.isValidSAC('998311'), true);
      expect(HsnValidator.isValidSAC('998311 '), true);
      expect(HsnValidator.isValidSAC('888311'), false);
      expect(HsnValidator.isValidSAC('9983111'), false);
    });

    test('isValid accepts either', () {
      expect(HsnValidator.isValid('8517'), true);
      expect(HsnValidator.isValid('998311'), true);
      expect(HsnValidator.isValid('12345'), false);
    });
  });
}
