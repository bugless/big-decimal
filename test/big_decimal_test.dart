import 'package:big_decimal/src/big_decimal.dart';
import 'package:test/test.dart';

import 'helpers/coerce.dart';
import 'helpers/matchers.dart';
import 'helpers/tabular.dart';

void main() {
  group('parse', () {
    group(
      'parses correctly',
      tabular((String s, int intVal, int scale, int precision) {
        final decimal = BigDecimal.parse(s);
        expect(decimal.intVal, BigInt.from(intVal), reason: 'intVal');
        expect(decimal.scale, scale, reason: 'scale');
        expect(decimal.precision, precision, reason: 'precision');
      }, [
        tabCase(['0.2', 2, 1, 1], 'only decimal places'),
        tabCase(['.2', 2, 1, 1], 'only decimal places'),
        tabCase(['-0.2', -2, 1, 1], 'negative with decimal places'),
        tabCase(['-.2', -2, 1, 1], 'negative with decimal places'),
        tabCase(['2', 2, 0, 1], 'positive integer with no decimal places'),
        tabCase(['-2', -2, 0, 1], 'negative integer with no decimal places'),
        tabCase(['2.000', 2000, 3, 4], 'positive integer with decimal places'),
        tabCase(
            ['-2.000', -2000, 3, 4], 'negative integer with decimal places'),
        tabCase(['2.01', 201, 2, 3], 'positive number with decimal places'),
        tabCase(['-2.01', -201, 2, 3], 'negative number with decimal places'),
        tabCase(
            ['-.2e1', -2, 0, 1], 'negative with decimal places and exponent'),
        tabCase(['-.2e-1', -2, 2, 1],
            'negative with decimal places and negative exponent'),
        tabCase(['10.00e2', 1000, 0, 4], 'with exponential'),
        tabCase(['10e2', 10, -2, 2], 'with exponential and negative scale'),
        tabCase(['10.e2', 10, -2, 2], 'with exponential and negative scale'),
        tabCase(['10e-2', 10, 2, 2], 'with negative exponential'),
        tabCase(['10e+2', 10, -2, 2], 'with exponential'),
      ]),
    );

    group(
      'throws while parsing',
      tabular((String s, [TypeMatcher? type]) {
        expect(() => BigDecimal.parse(s), throwsA(type ?? isA<Exception>()));
      }, [
        tabCase(['', isA<RangeError>()]),
        tabCase(['.']),
        tabCase(['e']),
        tabCase(['e2']),
        tabCase(['.e2']),
        tabCase(['1e']),
      ]),
    );
  });

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

  group(
    'unary -',
    tabular((Object a, Object result) {
      expect(
        -a.dec,
        exactly(result.dec),
      );
    }, [
      tabCase(['10.0', '-10.0']),
      tabCase(['-10.0', '10.0']),
    ]),
  );

  group('division', () {
    group(
      'divide',
      tabular((Object a, Object b, Object result,
          [RoundingMode roundingMode = RoundingMode.UNNECESSARY, int? scale]) {
        expect(
          a.dec.divide(b.dec, roundingMode: roundingMode, scale: scale),
          exactly(result.dec),
        );
      }, [
        tabCase(['20', '2', '10']),
        tabCase(['20', '-2', '-10']),
        tabCase(['20.0', '2.5', '8.0']),
        tabCase(['10', '3', '4', RoundingMode.UP]),
        tabCase(['10', '3', '4', RoundingMode.CEILING]),
        tabCase(['10', '3', '3', RoundingMode.DOWN]),
        tabCase(['10', '3', '3', RoundingMode.FLOOR]),
        tabCase(['10', '3', '3', RoundingMode.HALF_DOWN]),
        tabCase(['10', '3', '3', RoundingMode.HALF_EVEN]),
        tabCase(['10', '3', '3', RoundingMode.HALF_UP]),
        tabCase(['10', '3', '3.34', RoundingMode.CEILING, 2]),
        tabCase(['10', '8', '1.2', RoundingMode.HALF_DOWN, 1]),
        tabCase(['10', '8', '1.2', RoundingMode.HALF_EVEN, 1]),
        tabCase(['10', '8', '1.3', RoundingMode.HALF_UP, 1]),
      ]),
    );

    test('unable to divide to repeating decimals without proper RoundingMode',
        () {
      // 0.3333333...
      expect(() => '10'.dec.divide('3'.dec), throwsException);
      // 7.3828282...
      expect(() => '7309'.dec.divide('990'.dec), throwsException);
    });
  });

  group(
    'pow',
    tabular((Object a, int b, Object result) {
      expect(
        a.dec.pow(b),
        exactly(result.dec),
      );
    }, [
      tabCase(['10.0', 2, '100.00']),
      tabCase(['-10.0', 2, '100.00']),
      tabCase(['-10.0', 3, '-1000.000']),
      tabCase(['0.5', 2, '0.25']),
      tabCase(['0.50', 2, '0.2500']),
      tabCase(['-0.5', 3, '-0.125']),
    ]),
  );

  group(
    '< operator',
    tabular((Object a, Object b, bool result) {
      expect(
        a.dec < b.dec,
        result,
      );
    }, [
      tabCase(['38.2873'.dec, '98129'.dec, true]),
      tabCase(['32487239'.dec, '98129'.dec, false]),
      tabCase(['-12.1287'.dec, '10.7861'.dec, true]),
      tabCase(['-100.1287'.dec, '-1.2872'.dec, true]),
      tabCase(['10.01'.dec, '10.01'.dec, false]),
    ]),
  );

  group(
    '<= operator',
    tabular((Object a, Object b, bool result) {
      expect(
        a.dec <= b.dec,
        result,
      );
    }, [
      tabCase(['38.2873'.dec, '98129'.dec, true]),
      tabCase(['32487239'.dec, '98129'.dec, false]),
      tabCase(['-12.1287'.dec, '10.7861'.dec, true]),
      tabCase(['-100.1287'.dec, '-1.2872'.dec, true]),
      tabCase(['10.01'.dec, '10.01'.dec, true]),
    ]),
  );

  group(
    '> operator',
    tabular((Object a, Object b, bool result) {
      expect(
        a.dec > b.dec,
        result,
      );
    }, [
      tabCase(['38.2873'.dec, '98129'.dec, false]),
      tabCase(['32487239'.dec, '98129'.dec, true]),
      tabCase(['-12.1287'.dec, '10.7861'.dec, false]),
      tabCase(['-100.1287'.dec, '-1.2872'.dec, false]),
      tabCase(['10.01'.dec, '10.01'.dec, false]),
    ]),
  );

  group(
    '>= operator',
    tabular((Object a, Object b, bool result) {
      expect(
        a.dec >= b.dec,
        result,
      );
    }, [
      tabCase(['38.2873'.dec, '98129'.dec, false]),
      tabCase(['32487239'.dec, '98129'.dec, true]),
      tabCase(['-12.1287'.dec, '10.7861'.dec, false]),
      tabCase(['-100.1287'.dec, '-1.2872'.dec, false]),
      tabCase(['10.01'.dec, '10.01'.dec, true]),
    ]),
  );

  group(
    '== operator',
    tabular((Object a, Object b, bool result) {
      expect(
        a.dec == b.dec,
        result,
      );
    }, [
      tabCase(['38.2873'.dec, '98129'.dec, false]),
      tabCase(['32487239'.dec, '98129'.dec, false]),
      tabCase(['-12.1287'.dec, '10.7861'.dec, false]),
      tabCase(['-100.1287'.dec, '-1.2872'.dec, false]),
      tabCase(['10.01'.dec, '10.01'.dec, true]),
      tabCase(['10.01'.dec, '10.010'.dec, true]),
      tabCase(['010'.dec, '10.0'.dec, true]),
      tabCase(['10'.dec, '10.0'.dec, true]),
      tabCase(['10'.dec, '10.00'.dec, true]),
    ]),
  );

  group(
    'abs()',
    tabular((Object a, Object result) {
      expect(
        a.dec.abs(),
        exactly(result.dec),
      );
    }, [
      tabCase(['10.0198', '10.0198']),
      tabCase(['-10.0198', '10.0198']),
      tabCase(['0', '0']),
      tabCase(['-0', '0']),
    ]),
  );

  group('withScale()', () {
    group('successfully changing the scale', () {
      group(
        'simple cases',
        tabular((Object a, int newScale, Object result,
            [RoundingMode roundingMode = RoundingMode.UNNECESSARY]) {
          expect(
            a.dec.withScale(newScale, roundingMode: roundingMode),
            exactly(result.dec),
          );
        }, [
          tabCase(['100', 2, '100.00']),
          tabCase(['100', -2, '1e+2']),
          tabCase(['0.331276', 2, '.33', RoundingMode.DOWN]),
        ]),
      );
      group(
        'table from Java RoundingMode docs',
        tabular((
          String input,
          String up,
          String down,
          String ceiling,
          String floor,
          String half_up,
          String half_down,
          String half_even,
          Object unnecessary,
        ) {
          BigDecimal round(RoundingMode mode) =>
              input.dec.withScale(0, roundingMode: mode);
          expect(round(RoundingMode.UP), exactly(up.dec), reason: 'UP');
          expect(round(RoundingMode.DOWN), exactly(down.dec), reason: 'DOWN');
          expect(round(RoundingMode.CEILING), exactly(ceiling.dec),
              reason: 'CEILING');
          expect(round(RoundingMode.FLOOR), exactly(floor.dec),
              reason: 'FLOOR');
          expect(round(RoundingMode.HALF_UP), exactly(half_up.dec),
              reason: 'HALF_UP');
          expect(round(RoundingMode.HALF_DOWN), exactly(half_down.dec),
              reason: 'HALF_DOWN');
          expect(round(RoundingMode.HALF_EVEN), exactly(half_even.dec),
              reason: 'HALF_EVEN');
          if (unnecessary is String) {
            expect(round(RoundingMode.UNNECESSARY), exactly(unnecessary.dec),
                reason: 'UNNECESSARY');
          } else {
            expect(() => round(RoundingMode.UNNECESSARY), unnecessary,
                reason: 'UNNECESSARY');
          }
        }, [
          // Input  UP  DOWN  CEILING  FLOOR  HALF_UP  HALF_DOWN  HALF_EVEN  UNNECESSARY
          tabCase(['5.5', '6', '5', '6', '5', '6', '5', '6', throwsException]),
          tabCase(['2.5', '3', '2', '3', '2', '3', '2', '2', throwsException]),
          tabCase(['1.6', '2', '1', '2', '1', '2', '2', '2', throwsException]),
          tabCase(['1.1', '2', '1', '2', '1', '1', '1', '1', throwsException]),
          tabCase(['1.0', '1', '1', '1', '1', '1', '1', '1', '1']),
          tabCase(['-1.0', '-1', '-1', '-1', '-1', '-1', '-1', '-1', '-1']),
          tabCase([
            '-1.1',
            '-2',
            '-1',
            '-1',
            '-2',
            '-1',
            '-1',
            '-1',
            throwsException
          ]),
          tabCase([
            '-1.6',
            '-2',
            '-1',
            '-1',
            '-2',
            '-2',
            '-2',
            '-2',
            throwsException
          ]),
          tabCase([
            '-2.5',
            '-3',
            '-2',
            '-2',
            '-3',
            '-3',
            '-2',
            '-2',
            throwsException
          ]),
          tabCase([
            '-5.5',
            '-6',
            '-5',
            '-5',
            '-6',
            '-6',
            '-5',
            '-6',
            throwsException
          ]),
        ]),
      );
    });

    test('unable to change scale without proper RoundingMode', () {
      expect(() => '0.331276'.dec.withScale(2).toString(), throwsException);
    });
  });

  group(
    'toDouble',
    tabular((BigDecimal bd, double d) {
      expect(bd.toDouble(), d);
    }, [
      tabCase(['1.5'.dec, 1.5]),
      tabCase(['0'.dec, 0.0]),
      tabCase(['-0'.dec, 0.0]),
      tabCase([BigInt.from(9223372036854775807).dec, 9223372036854775807.0]),
      // the above case and the one below are actually the same, because
      // 9223372036854775807 is not perfectly representable by a double
      // it gets "rounded" to 9223372036854776000.0
      tabCase([BigInt.from(9223372036854775807).dec, 9223372036854776000.0]),
      tabCase([BigInt.from(-9223372036854775808).dec, -9223372036854775808.0]),
      tabCase([BigInt.from(-9223372036854775808).dec, -9223372036854776000.0]),
    ]),
  );

  group(
    'toBigInt',
    tabular((BigDecimal bd, BigInt bint,
        [RoundingMode roundingMode = RoundingMode.UNNECESSARY]) {
      expect(bd.toBigInt(roundingMode: roundingMode), bint);
    }, [
      tabCase(['1.5'.dec, BigInt.from(1), RoundingMode.DOWN]),
      tabCase(['1.5'.dec, BigInt.from(1), RoundingMode.FLOOR]),
      tabCase(['1.5'.dec, BigInt.from(2), RoundingMode.UP]),
      tabCase(['1.5'.dec, BigInt.from(2), RoundingMode.CEILING]),
      tabCase(['1.5'.dec, BigInt.from(2), RoundingMode.HALF_EVEN]),
      tabCase(['1.5'.dec, BigInt.from(2), RoundingMode.HALF_UP]),
      tabCase(['1.5'.dec, BigInt.from(1), RoundingMode.HALF_DOWN]),
      tabCase(['-1.5'.dec, BigInt.from(-1), RoundingMode.DOWN]),
      tabCase(['-1.5'.dec, BigInt.from(-2), RoundingMode.FLOOR]),
      tabCase(['-1.5'.dec, BigInt.from(-2), RoundingMode.UP]),
      tabCase(['-1.5'.dec, BigInt.from(-1), RoundingMode.CEILING]),
      tabCase(['-1.5'.dec, BigInt.from(-2), RoundingMode.HALF_EVEN]),
      tabCase(['-1.5'.dec, BigInt.from(-2), RoundingMode.HALF_UP]),
      tabCase(['-1.5'.dec, BigInt.from(-1), RoundingMode.HALF_DOWN]),
      tabCase([
        '92233720368547758089999'.dec,
        BigInt.parse('92233720368547758089999')
      ], 'very large integer'),
      tabCase([
        '-92233720368547758089999'.dec,
        BigInt.parse('-92233720368547758089999')
      ], 'very small integer'),
    ]),
  );

  group(
    'toInt',
    tabular((BigDecimal bd, int i,
        [RoundingMode roundingMode = RoundingMode.UNNECESSARY]) {
      expect(bd.toInt(roundingMode: roundingMode), i);
    }, [
      tabCase(['1.5'.dec, 1, RoundingMode.DOWN]),
      tabCase(['1.5'.dec, 1, RoundingMode.FLOOR]),
      tabCase(['1.5'.dec, 2, RoundingMode.UP]),
      tabCase(['1.5'.dec, 2, RoundingMode.CEILING]),
      tabCase(['1.5'.dec, 2, RoundingMode.HALF_EVEN]),
      tabCase(['1.5'.dec, 2, RoundingMode.HALF_UP]),
      tabCase(['1.5'.dec, 1, RoundingMode.HALF_DOWN]),
      tabCase(['-1.5'.dec, -1, RoundingMode.DOWN]),
      tabCase(['-1.5'.dec, -2, RoundingMode.FLOOR]),
      tabCase(['-1.5'.dec, -2, RoundingMode.UP]),
      tabCase(['-1.5'.dec, -1, RoundingMode.CEILING]),
      tabCase(['-1.5'.dec, -2, RoundingMode.HALF_EVEN]),
      tabCase(['-1.5'.dec, -2, RoundingMode.HALF_UP]),
      tabCase(['-1.5'.dec, -1, RoundingMode.HALF_DOWN]),
      tabCase(['92233720368547758089999'.dec, 9223372036854775807],
          'very large integer'),
      tabCase(['-92233720368547758089999'.dec, -9223372036854775808],
          'very small integer'),
    ]),
  );

  group(
    'toString()',
    tabular((Object a, String result) {
      expect(
        a.dec.toString(),
        result,
      );
    }, [
      // zeroes
      tabCase(['0', '0']),
      tabCase(['+0', '0']),
      tabCase(['-0', '0']),
      tabCase(['0.0', '0.0']),
      tabCase(['+0.0', '0.0']),
      tabCase(['-0.0', '0.0']),
      tabCase(['.0', '0.0']),
      tabCase(['+.0', '0.0']),
      tabCase(['-.0', '0.0']),
      // no scale
      tabCase(['1', '1']),
      tabCase(['-1', '-1']),
      // with scale/decimal
      tabCase(['1.0', '1.0']),
      tabCase(['-1.0', '-1.0']),
      tabCase(['.5', '0.5']),
      tabCase(['-.5', '-0.5']),
      // with exponent input
      tabCase(['3e-2', '0.03']),
      tabCase(['3e-1', '0.3']),
      tabCase(['-3e-1', '-0.3']),
      tabCase(['3e0', '3']),
      tabCase(['3.0e0', '3.0']),
      tabCase(['3.0e-1', '0.30']),
      tabCase(['-3.0e-1', '-0.30']),
      tabCase(['3.0e1', '30']),
      // with exponent toString()
      tabCase(['3e2', '3e+2']),
      tabCase(['123.456e-9', '1.23456e-7']),
      tabCase(['300e1', '3.00e+3']),
      tabCase(['123.456e-8', '0.00000123456']),
    ]),
  );

  group('hashcode', () {
    test('same for equal numbers', () {
      expect('1.0'.dec.hashCode, '1.0'.dec.hashCode);
      expect('-1.0'.dec.hashCode, '-1.0'.dec.hashCode);
      expect('1.0000'.dec.hashCode, '1.0000'.dec.hashCode);
      expect('0'.dec.hashCode, '0'.dec.hashCode);
    });

    test('different for different numbers', () {
      expect(false, '1.0'.dec.hashCode == '1.00'.dec.hashCode);
      expect(false, '-1.0'.dec.hashCode == '1.0'.dec.hashCode);
      expect(false, '1.0000'.dec.hashCode == '2'.dec.hashCode);
      expect(false, '0'.dec.hashCode == '0.00'.dec.hashCode);
    });
  });
}
