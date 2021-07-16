import 'package:big_decimal/src/big_decimal.dart';
import 'package:test/test.dart';

import 'helpers/coerce.dart';
import 'helpers/matchers.dart';
import 'helpers/tabular.dart';

void main() {
  group('parse', () {
    test('can parse a positive number', () {
      final decimal = '2.01'.d;
      expect(decimal.intVal, BigInt.from(201));
      expect(decimal.scale, 2);
      expect(decimal.precision, 3);
    });
    test('can parse a negative number', () {
      final decimal = '-2.01'.d;
      expect(decimal.intVal, BigInt.from(-201));
      expect(decimal.scale, 2);
      expect(decimal.precision, 3);
    });
  });
  tabular(
    '+ operator',
    (Object a, Object b, Object result) => expect(
      a.d + b.d,
      exactly(result.d),
    ),
    [
      tabCase([10, 10, 20]),
      tabCase([12, 23, 35]),
      tabCase(['2.01', '3', '5.01']),
      tabCase(['2.01', '3.01287', '5.02287']),
      tabCase(['2.01', '-1.01', '1.00']),
    ],
  );

  group('* operator', () {
    test('can multiply numbers', () {
      expect(
        '3.01'.d * '2'.d,
        '6.02'.d,
      );
      expect(
        '3.01'.d * '2.5'.d,
        '7.525'.d,
      );
    });
  });

  group('- operator', () {
    test('can subtract numbers', () {
      expect(
        '3.128'.d - '1.82'.d,
        '1.308'.d,
      );
    });
  });

  group('< operator', () {
    test('works', () {
      expect('38.2873'.d < '98129'.d, true);
      expect('32487239'.d < '98129'.d, false);
      expect('-12.1287'.d < '10.7861'.d, true);
      expect('-100.1287'.d < '-1.2872'.d, true);
      expect('10.01'.d < '10.01'.d, false);
    });
  });

  group('<= operator', () {
    test('works', () {
      expect('38.2873'.d <= '98129'.d, true);
      expect('32487239'.d <= '98129'.d, false);
      expect('-12.1287'.d <= '10.7861'.d, true);
      expect('-100.1287'.d <= '-1.2872'.d, true);
      expect('10.01'.d <= '10.01'.d, true);
    });
  });

  group('> operator', () {
    test('works', () {
      expect('38.2873'.d > '98129'.d, false);
      expect('32487239'.d > '98129'.d, true);
      expect('-12.1287'.d > '10.7861'.d, false);
      expect('-100.1287'.d > '-1.2872'.d, false);
      expect('10.01'.d > '10.01'.d, false);
    });
  });

  group('>= operator', () {
    test('works', () {
      expect('38.2873'.d >= '98129'.d, false);
      expect('32487239'.d >= '98129'.d, true);
      expect('-12.1287'.d >= '10.7861'.d, false);
      expect('-100.1287'.d >= '-1.2872'.d, false);
      expect('10.01'.d >= '10.01'.d, true);
    });
  });

  group('== operator', () {
    test('works', () {
      expect('10.0198'.d == '10.0198'.d, true);
      expect('10.0198'.d == '10.0199'.d, false);
      expect('10.0198'.d == '10.01980000'.d, true);
      expect('10.0198'.d == '0000010.0198'.d, true);
      expect('-10.0198'.d == '-10.0198'.d, true);
      expect('0'.d == '-0'.d, true);
    });
  });

  group('abs()', () {
    test('works', () {
      expect('10.0198'.d.abs(), '10.0198'.d);
      expect('-10.0198'.d.abs(), '10.0198'.d);
      expect('0'.d.abs(), '0'.d);
      expect('-0'.d.abs(), '0'.d);
    });
  });

  group('divide', () {
    test('division works', () {
      expect('20'.d.divide('2'.d), '10'.d);
      expect('20.0'.d.divide('2.5'.d), '8.0'.d);
      expect('20'.d.divide('-2'.d), '-10'.d);
      expect(() => '10'.d.divide('3'.d), throwsException);
      expect(
        '10'.d.divide('3'.d, roundingMode: RoundingMode.CEILING),
        '4'.d,
      );
      expect(
        '10'.d.divide('3'.d, roundingMode: RoundingMode.UP),
        '4'.d,
      );
      expect(
        '10'.d.divide('3'.d, roundingMode: RoundingMode.FLOOR),
        '3'.d,
      );
      expect(
        '10'.d.divide('3'.d, roundingMode: RoundingMode.DOWN),
        '3'.d,
      );
      expect(
        '10'.d.divide('3'.d, roundingMode: RoundingMode.HALF_DOWN),
        '3'.d,
      );
      expect(
        '10'.d.divide('3'.d, roundingMode: RoundingMode.HALF_EVEN),
        '3'.d,
      );
      expect(
        '10'.d.divide('3'.d, roundingMode: RoundingMode.HALF_UP),
        '3'.d,
      );
      expect(
        '10'.d.divide('3'.d, roundingMode: RoundingMode.CEILING, scale: 2),
        '3.34'.d,
      );
      expect(
        '10'.d.divide('8'.d, roundingMode: RoundingMode.HALF_EVEN, scale: 1),
        '1.2'.d,
      );
      expect(
        '10'.d.divide('8'.d, roundingMode: RoundingMode.HALF_UP, scale: 1),
        '1.3'.d,
      );
      expect(
        '10'.d.divide('8'.d, roundingMode: RoundingMode.HALF_DOWN, scale: 1),
        '1.2'.d,
      );
    });
  });

  group('pow', () {
    test('works', () {
      expect('10.0'.d.pow(2), '100.00'.d);
      expect('-10.0'.d.pow(2), '100.00'.d);
      expect('-10.0'.d.pow(3), '-1000.00'.d);
      expect('0.5'.d.pow(2), '0.25'.d);
      expect('0.50'.d.pow(2), '0.2500'.d);
      expect('-0.5'.d.pow(3), '-0.125'.d);
    });
  });

  group('unary -', () {
    test('works', () {
      expect(-'10.0'.d, '-10.0'.d);
      expect(-'-10.0'.d, '10.0'.d);
    });
  });

  group('withScale', () {
    test('works', () {
      expect('100'.d.withScale(2).toString(), '100.00');
      expect(() => '0.331276'.d.withScale(2).toString(), throwsException);
      expect(
          '0.331276'.d.withScale(2, roundingMode: RoundingMode.DOWN).toString(),
          '.33');
      // TODO: Need to fix toString before testing this
      // expect('100'.d.withScale(-2).toString(), '1');
    });
  });
}
