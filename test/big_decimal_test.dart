import 'package:big_decimal/src/big_decimal.dart';
import 'package:test/test.dart';

void main() {
  group('parse', () {
    test('can parse a positive number', () {
      final decimal = dec('2.01');
      expect(decimal.intVal, BigInt.from(201));
      expect(decimal.scale, 2);
      expect(decimal.precision, 3);
    });
    test('can parse a negative number', () {
      final decimal = dec('-2.01');
      expect(decimal.intVal, BigInt.from(-201));
      expect(decimal.scale, 2);
      expect(decimal.precision, 3);
    });
  });
  group('+ operator', () {
    test('sum works', () {
      expect(
        BigDecimal.fromBigInt(BigInt.from(10)) +
            BigDecimal.fromBigInt(BigInt.from(10)),
        BigDecimal.fromBigInt(BigInt.from(20)),
      );
      expect(
        BigDecimal.fromBigInt(BigInt.from(12)) +
            BigDecimal.fromBigInt(BigInt.from(23)),
        BigDecimal.fromBigInt(BigInt.from(35)),
      );
      expect(
        dec('2.01') + dec('3'),
        dec('5.01'),
      );
      expect(
        dec('2.01') + dec('3.01287'),
        dec('5.02287'),
      );
      expect(
        dec('2.01') + dec('-1.01'),
        dec('1.00'),
      );
    });
  });

  group('* operator', () {
    test('can multiply numbers', () {
      expect(
        dec('3.01') * dec('2'),
        dec('6.02'),
      );
      expect(
        dec('3.01') * dec('2.5'),
        dec('7.525'),
      );
    });
  });

  group('- operator', () {
    test('can subtract numbers', () {
      expect(
        dec('3.128') - dec('1.82'),
        dec('1.308'),
      );
    });
  });

  group('< operator', () {
    test('works', () {
      expect(dec('38.2873') < dec('98129'), true);
      expect(dec('32487239') < dec('98129'), false);
      expect(dec('-12.1287') < dec('10.7861'), true);
      expect(dec('-100.1287') < dec('-1.2872'), true);
      expect(dec('10.01') < dec('10.01'), false);
    });
  });

  group('<= operator', () {
    test('works', () {
      expect(dec('38.2873') <= dec('98129'), true);
      expect(dec('32487239') <= dec('98129'), false);
      expect(dec('-12.1287') <= dec('10.7861'), true);
      expect(dec('-100.1287') <= dec('-1.2872'), true);
      expect(dec('10.01') <= dec('10.01'), true);
    });
  });

  group('> operator', () {
    test('works', () {
      expect(dec('38.2873') > dec('98129'), false);
      expect(dec('32487239') > dec('98129'), true);
      expect(dec('-12.1287') > dec('10.7861'), false);
      expect(dec('-100.1287') > dec('-1.2872'), false);
      expect(dec('10.01') > dec('10.01'), false);
    });
  });

  group('>= operator', () {
    test('works', () {
      expect(dec('38.2873') >= dec('98129'), false);
      expect(dec('32487239') >= dec('98129'), true);
      expect(dec('-12.1287') >= dec('10.7861'), false);
      expect(dec('-100.1287') >= dec('-1.2872'), false);
      expect(dec('10.01') >= dec('10.01'), true);
    });
  });

  group('== operator', () {
    test('works', () {
      expect(dec('10.0198') == dec('10.0198'), true);
      expect(dec('10.0198') == dec('10.0199'), false);
      expect(dec('10.0198') == dec('10.01980000'), true);
      expect(dec('10.0198') == dec('0000010.0198'), true);
      expect(dec('-10.0198') == dec('-10.0198'), true);
      expect(dec('0') == dec('-0'), true);
    });
  });

  group('abs()', () {
    test('works', () {
      expect(dec('10.0198').abs(), dec('10.0198'));
      expect(dec('-10.0198').abs(), dec('10.0198'));
      expect(dec('0').abs(), dec('0'));
      expect(dec('-0').abs(), dec('0'));
    });
  });

  group('divide', () {
    test('division works', () {
      expect(dec('20').divide(dec('2')), dec('10'));
      expect(dec('20.0').divide(dec('2.5')), dec('8.0'));
      expect(dec('20').divide(dec('-2')), dec('-10'));
      expect(() => dec('10').divide(dec('3')), throwsException);
      expect(
        dec('10').divide(dec('3'), roundingMode: RoundingMode.CEILING),
        dec('4'),
      );
      expect(
        dec('10').divide(dec('3'), roundingMode: RoundingMode.UP),
        dec('4'),
      );
      expect(
        dec('10').divide(dec('3'), roundingMode: RoundingMode.FLOOR),
        dec('3'),
      );
      expect(
        dec('10').divide(dec('3'), roundingMode: RoundingMode.DOWN),
        dec('3'),
      );
      expect(
        dec('10').divide(dec('3'), roundingMode: RoundingMode.HALF_DOWN),
        dec('3'),
      );
      expect(
        dec('10').divide(dec('3'), roundingMode: RoundingMode.HALF_EVEN),
        dec('3'),
      );
      expect(
        dec('10').divide(dec('3'), roundingMode: RoundingMode.HALF_UP),
        dec('3'),
      );
      expect(
        dec('10')
            .divide(dec('3'), roundingMode: RoundingMode.CEILING, scale: 2),
        dec('3.34'),
      );
      expect(
        dec('10')
            .divide(dec('8'), roundingMode: RoundingMode.HALF_EVEN, scale: 1),
        dec('1.2'),
      );
      expect(
        dec('10')
            .divide(dec('8'), roundingMode: RoundingMode.HALF_UP, scale: 1),
        dec('1.3'),
      );
      expect(
        dec('10')
            .divide(dec('8'), roundingMode: RoundingMode.HALF_DOWN, scale: 1),
        dec('1.2'),
      );
    });
  });

  group('pow', () {
    test('works', () {
      expect(dec('10.0').pow(2), dec('100.00'));
      expect(dec('-10.0').pow(2), dec('100.00'));
      expect(dec('-10.0').pow(3), dec('-1000.00'));
      expect(dec('0.5').pow(2), dec('0.25'));
      expect(dec('0.50').pow(2), dec('0.2500'));
      expect(dec('-0.5').pow(3), dec('-0.125'));
    });
  });

  group('unary -', () {
    test('works', () {
      expect(-dec('10.0'), dec('-10.0'));
      expect(-dec('-10.0'), dec('10.0'));
    });
  });

  group('withScale', () {
    test('works', () {
      expect(dec('100').withScale(2).toString(), '100.00');
      expect(() => dec('0.331276').withScale(2).toString(), throwsException);
      expect(
          dec('0.331276')
              .withScale(2, roundingMode: RoundingMode.DOWN)
              .toString(),
          '.33');
      // TODO: Need to fix toString before testing this
      // expect(dec('100').withScale(-2).toString(), '1');
    });
  });
}
