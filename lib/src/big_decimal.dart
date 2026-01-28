// enum is using screaming snake case due to a direct migration from java
// ignore_for_file: constant_identifier_names
import 'dart:math' as math;

import 'big_decimal_infinity.dart';

/// rounding mode used when doing operations on a [BigDecimal]
enum RoundingMode {
  /// away from zero
  UP,

  /// towards zero
  DOWN,

  /// towards +infinity
  CEILING,

  /// towards -infinity
  FLOOR,

  /// away from zero if remainder comparison to half divisor is even
  HALF_UP,

  /// towards zero if remainder comparison to half divisor is even
  HALF_DOWN,

  /// towards zero if remainder comparison to half divisor is even and [BigDecimal] is odd
  HALF_EVEN,

  /// does not round at all.
  ///
  /// Throws [Exception] if not exact and needs rounding
  UNNECESSARY,
}

const _plusCode = 43;
const _minusCode = 45;
const _dotCode = 46;
const _smallECode = 101;
const _capitalECode = 69;
const _zeroCode = 48;
const _nineCode = 57;

/// representation of an arbitrarily large decimal number
class BigDecimal implements Comparable<BigDecimal> {
  /// Creates a [BigDecimal] with the given [intVal] and [scale]
  BigDecimal({
    required this.intVal,
    required this.scale,
  });

  /// factory constructor of a [BigDecimal] from a [BigInt]
  factory BigDecimal.fromBigInt(BigInt value) {
    return BigDecimal(
      intVal: value,
      scale: 0,
    );
  }

  /// a [BigDecimal] with a numerical value of 0
  static final zero = BigDecimal.fromBigInt(BigInt.zero);

  /// a [BigDecimal] with a numerical value of 1
  static final one = BigDecimal.fromBigInt(BigInt.one);

  /// a [BigDecimal] with a numerical value of 2
  static final two = BigDecimal.fromBigInt(BigInt.two);

  /// a [BigDecimal] representing positive infinity
  static final infinity = BigDecimalInfinity();

  /// a [BigDecimal] representing negative infinity
  static final negativeInifinity = BigDecimalInfinity(isNegative: true);

  static int _nextNonDigit(String value, [int start = 0]) {
    var index = start;
    for (; index < value.length; index++) {
      final code = value.codeUnitAt(index);
      if (code < _zeroCode || code > _nineCode) {
        break;
      }
    }
    return index;
  }

  /// try to create a [BigDecimal] from a [String]. Returns null if invalid
  static BigDecimal? tryParse(String value) {
    try {
      return BigDecimal.parse(value);
    } catch (e) {
      return null;
    }
  }

  /// try to create a [BigDecimal] from a [String].
  ///
  /// Throws [Exception] if invalid
  factory BigDecimal.parse(String value) {
    if (value == double.infinity.toString()) {
      return BigDecimal.infinity;
    }

    if (value == double.negativeInfinity.toString()) {
      return BigDecimal.negativeInifinity;
    }

    var sign = '';
    var index = 0;
    var nextIndex = 0;

    switch (value.codeUnitAt(index)) {
      case _minusCode:
        sign = '-';
        index++;
        break;
      case _plusCode:
        index++;
        break;
      default:
        break;
    }

    nextIndex = _nextNonDigit(value, index);
    final integerPart = '$sign${value.substring(index, nextIndex)}';
    index = nextIndex;

    if (index >= value.length) {
      return BigDecimal.fromBigInt(BigInt.parse(integerPart));
    }

    var decimalPart = '';
    if (value.codeUnitAt(index) == _dotCode) {
      index++;
      nextIndex = _nextNonDigit(value, index);
      decimalPart = value.substring(index, nextIndex);
      index = nextIndex;

      if (index >= value.length) {
        return BigDecimal(
          intVal: BigInt.parse('$integerPart$decimalPart'),
          scale: decimalPart.length,
        );
      }
    }

    switch (value.codeUnitAt(index)) {
      case _smallECode:
      case _capitalECode:
        index++;
        final exponent = int.parse(value.substring(index));
        return BigDecimal(
          intVal: BigInt.parse('$integerPart$decimalPart'),
          scale: decimalPart.length - exponent,
        );
    }

    throw Exception(
      'Not a valid BigDecimal string representation: $value.\n'
      'Unexpected ${value.substring(index)}.',
    );
  }

  /// the arbitrarily large numeric value without scale
  final BigInt intVal;

  /// precision of the decimal digits of this
  late final int precision = _calculatePrecision();

  /// scale of this [BigDecimal]
  final int scale;

  @override
  bool operator ==(Object other) =>
      other is BigDecimal && compareTo(other) == 0;

  /// compares this with [other] for both value and scale
  bool exactlyEquals(Object? other) =>
      other is BigDecimal && intVal == other.intVal && scale == other.scale;

  /// adds this to [other]
  BigDecimal operator +(BigDecimal other) =>
      _add(intVal, other.intVal, scale, other.scale);

  /// multiply this with [other]
  BigDecimal operator *(BigDecimal other) =>
      BigDecimal(intVal: intVal * other.intVal, scale: scale + other.scale);

  /// subtracts this to [other]
  BigDecimal operator -(BigDecimal other) =>
      _add(intVal, -other.intVal, scale, other.scale);

  /// Whether this is less than [other].
  bool operator <(BigDecimal other) => compareTo(other) < 0;

  /// Whether this is less than or equal to [other].
  bool operator <=(BigDecimal other) => compareTo(other) <= 0;

  /// Whether this is greater than [other].
  bool operator >(BigDecimal other) => compareTo(other) > 0;

  /// Whether this is greater than or equal to [other].
  bool operator >=(BigDecimal other) => compareTo(other) >= 0;

  /// Negates this big decimal
  BigDecimal operator -() => BigDecimal(intVal: -intVal, scale: scale);

  /// Returns the absolute value of this
  BigDecimal abs() => BigDecimal(intVal: intVal.abs(), scale: scale);

  /// divides this number by [divisor]. Defaults to not rounding the number.
  ///
  /// Throws [Exception] if rounding is [RoundingMode.UNNECESSARY] but rounding
  /// is actually necessary.
  BigDecimal divide(
    BigDecimal divisor, {
    RoundingMode roundingMode = RoundingMode.UNNECESSARY,
    int? scale,
  }) =>
      _divide(intVal, this.scale, divisor.intVal, divisor.scale,
          scale ?? this.scale, roundingMode);

  /// this to the power of [n]
  BigDecimal pow(int n) {
    if (n >= 0 && n <= 999999999) {
      // TODO: Check scale of this multiplication
      final newScale = scale * n;
      return BigDecimal(intVal: intVal.pow(n), scale: newScale);
    }
    throw Exception(
        'Invalid operation: Exponent should be between 0 and 999999999');
  }

  /// returns this as a [double]
  double toDouble() => intVal.toDouble() / math.pow(10.0, scale);

  /// returns this as a [BigInt] with the desired [roundingMode]
  ///
  /// Throws [Exception] if rounding is [RoundingMode.UNNECESSARY] but rounding
  /// is actually necessary.
  BigInt toBigInt({RoundingMode roundingMode = RoundingMode.UNNECESSARY}) =>
      withScale(0, roundingMode: roundingMode).intVal;

  /// returns this as a [int] with the desired [roundingMode]
  ///
  /// Throws [Exception] if rounding is [RoundingMode.UNNECESSARY] but rounding
  /// is actually necessary.
  int toInt({RoundingMode roundingMode = RoundingMode.UNNECESSARY}) =>
      toBigInt(roundingMode: roundingMode).toInt();

  /// returns a new [BigDecimal] with the desired [newScale]. May round by
  /// [roundingMode].
  ///
  /// Throws [Exception] if rounding is [RoundingMode.UNNECESSARY] but rounding
  /// is actually necessary.
  BigDecimal withScale(
    int newScale, {
    RoundingMode roundingMode = RoundingMode.UNNECESSARY,
  }) {
    if (scale == newScale) {
      return this;
    } else if (intVal.sign == 0) {
      return BigDecimal(intVal: BigInt.zero, scale: newScale);
    } else {
      if (newScale > scale) {
        final drop = _sumScale(newScale, -scale);
        final intResult = intVal * BigInt.from(10).pow(drop);
        return BigDecimal(intVal: intResult, scale: newScale);
      } else {
        final drop = _sumScale(scale, -newScale);
        return _divideAndRound(intVal, BigInt.from(10).pow(drop), newScale,
            roundingMode, newScale);
      }
    }
  }

  int _calculatePrecision() {
    if (intVal.sign == 0) {
      return 1;
    }
    final r = ((intVal.bitLength + 1) * 646456993) >> 31;
    return intVal.abs().compareTo(BigInt.from(10).pow(r)) < 0 ? r : r + 1;
  }

  static BigDecimal _add(
      BigInt intValA, BigInt intValB, int scaleA, int scaleB) {
    final scaleDiff = scaleA - scaleB;
    if (scaleDiff == 0) {
      return BigDecimal(intVal: intValA + intValB, scale: scaleA);
    } else if (scaleDiff < 0) {
      final scaledX = intValA * BigInt.from(10).pow(-scaleDiff);
      return BigDecimal(intVal: scaledX + intValB, scale: scaleB);
    } else {
      final scaledY = intValB * BigInt.from(10).pow(scaleDiff);
      return BigDecimal(intVal: intValA + scaledY, scale: scaleA);
    }
  }

  static BigDecimal _divide(
    BigInt dividend,
    int dividendScale,
    BigInt divisor,
    int divisorScale,
    int scale,
    RoundingMode roundingMode,
  ) {
    if (dividend == BigInt.zero) {
      return BigDecimal(intVal: BigInt.zero, scale: scale);
    }
    if (_sumScale(scale, divisorScale) > dividendScale) {
      final newScale = scale + divisorScale;
      final raise = newScale - dividendScale;
      final scaledDividend = dividend * BigInt.from(10).pow(raise);
      return _divideAndRound(
          scaledDividend, divisor, scale, roundingMode, scale);
    } else {
      final newScale = _sumScale(dividendScale, -scale);
      final raise = newScale - divisorScale;
      final scaledDivisor = divisor * BigInt.from(10).pow(raise);
      return _divideAndRound(
          dividend, scaledDivisor, scale, roundingMode, scale);
    }
  }

  static BigDecimal _divideAndRound(
    BigInt dividend,
    BigInt divisor,
    int scale,
    RoundingMode roundingMode,
    int preferredScale,
  ) {
    final quotient = dividend ~/ divisor;
    final remainder = dividend.remainder(divisor).abs();
    final quotientPositive = dividend.sign == divisor.sign;
    if (remainder != BigInt.zero) {
      if (_needIncrement(
          divisor, roundingMode, quotientPositive, quotient, remainder)) {
        final intResult =
            quotient + (quotientPositive ? BigInt.one : -BigInt.one);
        return BigDecimal(intVal: intResult, scale: scale);
      }
      return BigDecimal(intVal: quotient, scale: scale);
    } else {
      if (preferredScale != scale) {
        return _createAndStripZerosForScale(quotient, scale, preferredScale);
      } else {
        return BigDecimal(intVal: quotient, scale: scale);
      }
    }
  }

  static BigDecimal _createAndStripZerosForScale(
    BigInt intVal,
    int scale,
    int preferredScale,
  ) {
    final ten = BigInt.from(10);
    var intValMut = intVal;
    var scaleMut = scale;

    while (intValMut.compareTo(ten) >= 0 && scaleMut > preferredScale) {
      if (intValMut.isOdd) {
        break;
      }
      final remainder = intValMut.remainder(ten);

      if (remainder.sign != 0) {
        break;
      }
      intValMut = intValMut ~/ ten;
      scaleMut = _sumScale(scaleMut, -1);
    }

    return BigDecimal(intVal: intValMut, scale: scaleMut);
  }

  static bool _needIncrement(
    BigInt divisor,
    RoundingMode roundingMode,
    bool quotientPositive,
    BigInt quotient,
    BigInt remainder,
  ) {
    final remainderComparisonToHalfDivisor =
        (remainder * BigInt.from(2)).compareTo(divisor);
    switch (roundingMode) {
      case RoundingMode.UNNECESSARY:
        throw Exception('Rounding necessary');
      case RoundingMode.UP: // Away from zero
        return true;
      case RoundingMode.DOWN: // Towards zero
        return false;
      case RoundingMode.CEILING: // Towards +infinity
        return quotientPositive;
      case RoundingMode.FLOOR: // Towards -infinity
        return !quotientPositive;
      case RoundingMode.HALF_DOWN:
      case RoundingMode.HALF_EVEN:
      case RoundingMode.HALF_UP:
        if (remainderComparisonToHalfDivisor < 0) {
          return false;
        } else if (remainderComparisonToHalfDivisor > 0) {
          return true;
        } else {
          // Half
          switch (roundingMode) {
            case RoundingMode.HALF_DOWN:
              return false;

            case RoundingMode.HALF_UP:
              return true;

            // At this point it must be HALF_EVEN
            default:
              return quotient.isOdd;
          }
        }
    }
  }

  @override
  int compareTo(BigDecimal other) {
    if (scale == other.scale) {
      return intVal != other.intVal ? (intVal > other.intVal ? 1 : -1) : 0;
    }

    final thisSign = intVal.sign;
    final otherSign = other.intVal.sign;
    if (thisSign != otherSign) {
      return (thisSign > otherSign) ? 1 : -1;
    }

    if (thisSign == 0) {
      return 0;
    }
    //TODO: Optimize this
    return _add(intVal, -other.intVal, scale, other.scale).intVal.sign;
  }

  @override
  int get hashCode => 31 * intVal.hashCode + scale;

  @override
  String toString() {
    if (scale == 0) {
      return intVal.toString();
    }

    final intStr = intVal.abs().toString();
    final adjusted = (intStr.length - 1) - scale;

    // Java's heuristic to avoid too many decimal places
    if (scale >= 0 && adjusted >= -6) {
      return toPlainString();
    }

    // Exponential notation
    final b = StringBuffer(intVal.isNegative ? '-' : '');
    b.write(intStr[0]);
    if (intStr.length > 1) {
      b
        ..write('.')
        ..write(intStr.substring(1));
    }
    if (adjusted != 0) {
      b.write('e');
      if (adjusted > 0) {
        b.write('+');
      }
      b.write(adjusted);
    }

    return b.toString();
  }

  /// returns its [String] represantation without using exponential notation
  String toPlainString() {
    if (scale == 0) {
      return intVal.toString();
    }

    final intStr = intVal.abs().toString();
    final b = StringBuffer(intVal.isNegative ? '-' : '');

    if (scale > 0) {
      if (intStr.length > scale) {
        final integerPart = intStr.substring(0, intStr.length - scale);
        b.write(integerPart);

        final decimalPart = intStr.substring(intStr.length - scale);
        if (decimalPart.isNotEmpty) {
          b.write('.$decimalPart');
        }
      } else {
        b
          ..write('0.')
          ..write(intStr.padLeft(scale, '0'));
      }
    } else {
      b.write(intStr.padRight(scale.abs() + intStr.length, '0'));
    }

    return b.toString();
  }
}

int _sumScale(int scaleA, int scaleB) {
  // TODO: We need to check for overflows here
  return scaleA + scaleB;
}
