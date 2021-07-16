import 'package:big_decimal/src/big_decimal.dart';
import 'package:test/test.dart';

import 'helpers/coerce.dart';
import 'helpers/matchers.dart';
import 'helpers/tabular.dart';

void main() {
  group(
    'parse',
    tabular((String s, int intVal, int scale, int precision) {
      final decimal = s.dec;
      expect(decimal.intVal, BigInt.from(intVal), reason: 'intVal');
      expect(decimal.scale, scale, reason: 'scale');
      expect(decimal.precision, precision, reason: 'precision');
    }, [
      tabCase(['2', 2, 0, 1], 'positive integer with no decimal places'),
      tabCase(['-2', -2, 0, 1], 'negative integer with no decimal places'),
      tabCase(['2.000', 2000, 3, 4], 'positive integer with decimal places'),
      tabCase(['-2.000', -2000, 3, 4], 'negative integer with decimal places'),
      tabCase(['2.01', 201, 2, 3], 'positive number with decimal places'),
      tabCase(['-2.01', -201, 2, 3], 'negative number with decimal places'),
    ]),
  );

  group(
    '+ operator',
    tabular((Object a, Object b, Object result) {
      expect(
        a.dec + b.dec,
        exactly(result.dec),
      );
    }, [
      tabCase([10, 10, 20]),
      tabCase([12, 23, 35]),
      tabCase(['2.01', '3', '5.01']),
      tabCase(['2.01', '3.01287', '5.02287']),
      tabCase(['2.01', '-1.01', '1.00']),
    ]),
  );

  group(
    '* operator',
    tabular((Object a, Object b, Object result) {
      expect(
        a.dec * b.dec,
        exactly(result.dec),
      );
    }, [
      tabCase([10, 10, 100]),
      tabCase([12, 23, 276]),
      tabCase(['10.0', '10.0', '100.00']),
      tabCase(['2.01', '3', '6.03']),
      tabCase(['2.01', '3.01287', '6.0558687']),
      tabCase(['2.01', '-1.01', '-2.0301']),
    ]),
  );

  group(
    '- operator',
    tabular((Object a, Object b, Object result) {
      expect(
        a.dec - b.dec,
        exactly(result.dec),
      );
    }, [
      tabCase(['3.128', '1.82', '1.308']),
    ]),
  );

  group('< operator', () {
    test('works', () {
      expect('38.2873'.dec < '98129'.dec, true);
      expect('32487239'.dec < '98129'.dec, false);
      expect('-12.1287'.dec < '10.7861'.dec, true);
      expect('-100.1287'.dec < '-1.2872'.dec, true);
      expect('10.01'.dec < '10.01'.dec, false);
    });
  });

  group('<= operator', () {
    test('works', () {
      expect('38.2873'.dec <= '98129'.dec, true);
      expect('32487239'.dec <= '98129'.dec, false);
      expect('-12.1287'.dec <= '10.7861'.dec, true);
      expect('-100.1287'.dec <= '-1.2872'.dec, true);
      expect('10.01'.dec <= '10.01'.dec, true);
    });
  });

  group('> operator', () {
    test('works', () {
      expect('38.2873'.dec > '98129'.dec, false);
      expect('32487239'.dec > '98129'.dec, true);
      expect('-12.1287'.dec > '10.7861'.dec, false);
      expect('-100.1287'.dec > '-1.2872'.dec, false);
      expect('10.01'.dec > '10.01'.dec, false);
    });
  });

  group('>= operator', () {
    test('works', () {
      expect('38.2873'.dec >= '98129'.dec, false);
      expect('32487239'.dec >= '98129'.dec, true);
      expect('-12.1287'.dec >= '10.7861'.dec, false);
      expect('-100.1287'.dec >= '-1.2872'.dec, false);
      expect('10.01'.dec >= '10.01'.dec, true);
    });
  });

  group('== operator', () {
    test('works', () {
      expect('10.0198'.dec == '10.0198'.dec, true);
      expect('10.0198'.dec == '10.0199'.dec, false);
      expect('10.0198'.dec == '10.01980000'.dec, true);
      expect('10.0198'.dec == '0000010.0198'.dec, true);
      expect('-10.0198'.dec == '-10.0198'.dec, true);
      expect('0'.dec == '-0'.dec, true);
    });
  });

  group('abs()', () {
    test('works', () {
      expect('10.0198'.dec.abs(), '10.0198'.dec);
      expect('-10.0198'.dec.abs(), '10.0198'.dec);
      expect('0'.dec.abs(), '0'.dec);
      expect('-0'.dec.abs(), '0'.dec);
    });
  });

  group('divide', () {
    test('division works', () {
      expect('20'.dec.divide('2'.dec), '10'.dec);
      expect('20.0'.dec.divide('2.5'.dec), '8.0'.dec);
      expect('20'.dec.divide('-2'.dec), '-10'.dec);
      expect(() => '10'.dec.divide('3'.dec), throwsException);
      expect(
        '10'.dec.divide('3'.dec, roundingMode: RoundingMode.CEILING),
        '4'.dec,
      );
      expect(
        '10'.dec.divide('3'.dec, roundingMode: RoundingMode.UP),
        '4'.dec,
      );
      expect(
        '10'.dec.divide('3'.dec, roundingMode: RoundingMode.FLOOR),
        '3'.dec,
      );
      expect(
        '10'.dec.divide('3'.dec, roundingMode: RoundingMode.DOWN),
        '3'.dec,
      );
      expect(
        '10'.dec.divide('3'.dec, roundingMode: RoundingMode.HALF_DOWN),
        '3'.dec,
      );
      expect(
        '10'.dec.divide('3'.dec, roundingMode: RoundingMode.HALF_EVEN),
        '3'.dec,
      );
      expect(
        '10'.dec.divide('3'.dec, roundingMode: RoundingMode.HALF_UP),
        '3'.dec,
      );
      expect(
        '10'.dec.divide('3'.dec, roundingMode: RoundingMode.CEILING, scale: 2),
        '3.34'.dec,
      );
      expect(
        '10'
            .dec
            .divide('8'.dec, roundingMode: RoundingMode.HALF_EVEN, scale: 1),
        '1.2'.dec,
      );
      expect(
        '10'.dec.divide('8'.dec, roundingMode: RoundingMode.HALF_UP, scale: 1),
        '1.3'.dec,
      );
      expect(
        '10'
            .dec
            .divide('8'.dec, roundingMode: RoundingMode.HALF_DOWN, scale: 1),
        '1.2'.dec,
      );
    });
  });

  group('pow', () {
    test('works', () {
      expect('10.0'.dec.pow(2), '100.00'.dec);
      expect('-10.0'.dec.pow(2), '100.00'.dec);
      expect('-10.0'.dec.pow(3), '-1000.00'.dec);
      expect('0.5'.dec.pow(2), '0.25'.dec);
      expect('0.50'.dec.pow(2), '0.2500'.dec);
      expect('-0.5'.dec.pow(3), '-0.125'.dec);
    });
  });

  group('unary -', () {
    test('works', () {
      expect(-'10.0'.dec, '-10.0'.dec);
      expect(-'-10.0'.dec, '10.0'.dec);
    });
  });

  group('withScale', () {
    test('works', () {
      expect('100'.dec.withScale(2).toString(), '100.00');
      expect(() => '0.331276'.dec.withScale(2).toString(), throwsException);
      expect(
          '0.331276'
              .dec
              .withScale(2, roundingMode: RoundingMode.DOWN)
              .toString(),
          '.33');
      // TODO: Need to fix toString before testing this
      // expect('100'.d.withScale(-2).toString(), '1');
    });
  });
}
