import 'package:flutter_test/flutter_test.dart';
import 'package:iris_payment/src/afm_validator.dart';

void main() {
  group('AfmValidator', () {
    test('valid AFM passes checksum', () {
      // Known valid AFMs (checksum verified)
      expect(AfmValidator.isValid('090000045'), true);
      expect(AfmValidator.isValid('094019245'), true);
    });

    test('rejects non-9-digit strings', () {
      expect(AfmValidator.isValid('12345'), false);
      expect(AfmValidator.isValid('12345678901'), false);
      expect(AfmValidator.isValid('abcdefghi'), false);
      expect(AfmValidator.isValid(''), false);
    });

    test('rejects all zeros', () {
      expect(AfmValidator.isValid('000000000'), false);
    });

    test('rejects wrong checksum', () {
      // Change last digit of a valid AFM
      expect(AfmValidator.isValid('090000044'), false);
      expect(AfmValidator.isValid('090000046'), false);
    });

    test('strips whitespace and dashes', () {
      expect(AfmValidator.isValid('090 000 045'), true);
      expect(AfmValidator.isValid('090-000-045'), true);
      expect(AfmValidator.isValid(' 090000045 '), true);
    });

    test('validate returns detailed result', () {
      final valid = AfmValidator.validate('090000045');
      expect(valid.isValid, true);
      expect(valid.message, isNull);

      final invalid = AfmValidator.validate('123');
      expect(invalid.isValid, false);
      expect(invalid.message, contains('9 digits'));
    });

    test('format returns cleaned string for valid AFM', () {
      expect(AfmValidator.format('090-000-045'), '090000045');
      expect(AfmValidator.format('invalid'), isNull);
    });

    // Verify checksum algorithm: digit[8] = (sum % 11) % 10
    // where sum = digit[0]*256 + digit[1]*128 + ... + digit[7]*2
    test('checksum algorithm is correct', () {
      // For AFM "090000045":
      // 0*256 + 9*128 + 0*64 + 0*32 + 0*16 + 0*8 + 0*4 + 4*2 = 1152 + 8 = 1160
      // 1160 % 11 = 5, 5 % 10 = 5, matches the last digit
      expect(AfmValidator.isValid('090000045'), true);
    });

    test('formValidator returns null or the error message', () {
      expect(AfmValidator.formValidator('090000045'), isNull);
      expect(AfmValidator.formValidator('090 000 045'), isNull);
      expect(AfmValidator.formValidator(null), 'AFM is required');
      expect(AfmValidator.formValidator('  '), 'AFM is required');
      expect(AfmValidator.formValidator('123'), contains('9 digits'));
      expect(AfmValidator.formValidator('090000044'), 'Invalid AFM checksum');
    });
  });
}
