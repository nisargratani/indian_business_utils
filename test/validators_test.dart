import 'dart:math';

import 'package:test/test.dart';
import 'package:indian_business_utils/indian_business_utils.dart';

const _gstinChars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';

/// Builds a GSTIN with a correct check character, using GSTN's published
/// mod-36 algorithm independently of the package code.
String buildGstin(String stateCode, String pan, {String entity = '1'}) {
  final base = '$stateCode$pan${entity}Z';
  var sum = 0;
  for (var i = 0; i < 14; i++) {
    final product = _gstinChars.indexOf(base[i]) * (i.isEven ? 1 : 2);
    sum += product ~/ 36 + product % 36;
  }
  return '$base${_gstinChars[(36 - sum % 36) % 36]}';
}

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

    // Regression: toUpperCase() maps 'ı' to 'I' and 'ſ' to 'S', so these
    // passed the ASCII-only check.
    test('rejects non-ASCII letters', () {
      expect(PanValidator.isValid('ıBCPE1234F'), false);
      expect(PanValidator.isValid('ABCPE1234ſ'), false);
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

    test('buildGstin matches known GSTINs', () {
      expect(buildGstin('27', 'AAPFU0939F'), '27AAPFU0939F1ZV');
      expect(buildGstin('24', 'AAACC1206D'), '24AAACC1206D1ZM');
    });

    // Regression: toUpperCase() maps 'ı' to 'I' and 'ſ' to 'S', so these
    // passed with a correct check character.
    test('rejects non-ASCII letters', () {
      final gstin = buildGstin('27', 'ISIPS1234K');
      expect(GstinValidator.isValid(gstin), true);
      expect(GstinValidator.isValid(gstin.replaceFirst('I', 'ı')), false);
      expect(GstinValidator.isValid(gstin.replaceFirst('S', 'ſ')), false);
    });

    // Regression: the embedded PAN was not checked, so holder type 'D'
    // was accepted.
    test('rejects GSTINs whose embedded PAN is invalid', () {
      expect(PanValidator.isValid('AAADU0939F'), false);
      expect(GstinValidator.isValid(buildGstin('27', 'AAADU0939F')), false);
    });

    test('accepts GSTINs for every PAN holder type', () {
      const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
      final random = Random(20261022);
      String pick(String from) => from[random.nextInt(from.length)];
      for (var i = 0; i < 1000; i++) {
        for (final status in 'CPHFATBLJG'.split('')) {
          final pan = '${pick(letters)}${pick(letters)}${pick(letters)}'
              '$status${pick(letters)}'
              '${random.nextInt(10000).toString().padLeft(4, '0')}'
              '${pick(letters)}';
          final gstin = buildGstin('27', pan);
          expect(PanValidator.isValid(pan), true, reason: pan);
          expect(GstinValidator.isValid(gstin), true, reason: gstin);
          expect(GstinValidator.isValid(gstin.toLowerCase()), true,
              reason: gstin);
        }
      }
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
