import 'package:flutter_test/flutter_test.dart';
import 'package:iris_payment/src/iris_data.dart';

void main() {
  group('IrisData', () {
    group('fromAfm (static QR)', () {
      test('creates IRISTIN string from valid AFM', () {
        final data = IrisData.fromAfm('090000045');
        expect(data.qrString, 'IRISTIN090000045');
        expect(data.type, IrisQrType.tin);
        expect(data.afm, '090000045');
      });

      test('strips whitespace and dashes', () {
        final data = IrisData.fromAfm('090-000-045');
        expect(data.qrString, 'IRISTIN090000045');
      });

      test('throws on invalid AFM', () {
        expect(() => IrisData.fromAfm('123'), throwsArgumentError);
        expect(() => IrisData.fromAfm('000000000'), throwsArgumentError);
      });
    });

    group('tryFromAfm', () {
      test('returns IrisData for valid AFM', () {
        final data = IrisData.tryFromAfm('090000045');
        expect(data, isNotNull);
        expect(data!.qrString, 'IRISTIN090000045');
      });

      test('returns null for invalid AFM', () {
        expect(IrisData.tryFromAfm('123'), isNull);
        expect(IrisData.tryFromAfm('000000000'), isNull);
      });
    });

    group('fromTransactionId (dynamic QR)', () {
      test('creates IRISCOM string from UUID', () {
        final data = IrisData.fromTransactionId(
            '52bb5e73-2ebd-4299-9ccf-e9714b9873fc');
        expect(data.qrString,
            'IRISCOM52bb5e73-2ebd-4299-9ccf-e9714b9873fc');
        expect(data.type, IrisQrType.com);
        expect(data.transactionId,
            '52bb5e73-2ebd-4299-9ccf-e9714b9873fc');
      });

      test('throws on empty transaction ID', () {
        expect(() => IrisData.fromTransactionId(''), throwsArgumentError);
        expect(() => IrisData.fromTransactionId('   '), throwsArgumentError);
      });
    });

    group('parse', () {
      test('parses IRISTIN format', () {
        final data = IrisData.parse('IRISTIN090000045');
        expect(data, isNotNull);
        expect(data!.type, IrisQrType.tin);
        expect(data.afm, '090000045');
      });

      test('parses IRISCOM format', () {
        final data =
            IrisData.parse('IRISCOM52bb5e73-2ebd-4299-9ccf-e9714b9873fc');
        expect(data, isNotNull);
        expect(data!.type, IrisQrType.com);
        expect(data.transactionId,
            '52bb5e73-2ebd-4299-9ccf-e9714b9873fc');
      });

      test('returns null for invalid strings', () {
        expect(IrisData.parse('HELLO'), isNull);
        expect(IrisData.parse('IRISTIN000000000'), isNull); // invalid AFM
        expect(IrisData.parse('IRISCOM'), isNull); // empty ID
        expect(IrisData.parse(''), isNull);
      });
    });

    group('equality', () {
      test('equal for same AFM', () {
        final a = IrisData.fromAfm('090000045');
        final b = IrisData.fromAfm('090000045');
        expect(a, equals(b));
        expect(a.hashCode, b.hashCode);
      });

      test('not equal for different AFM', () {
        final a = IrisData.fromAfm('090000045');
        final b = IrisData.fromAfm('094019245');
        expect(a, isNot(equals(b)));
      });
    });

    test('toString returns qrString', () {
      final data = IrisData.fromAfm('090000045');
      expect(data.toString(), 'IRISTIN090000045');
    });
  });
}
