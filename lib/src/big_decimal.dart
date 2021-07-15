final _pattern = RegExp(r'^([+-]?\d*)(\.\d*)?([eE][+-]?\d+)?$');

enum RoundingMode {
  UP,
  DOWN,
  CEILING,
  FLOOR,
  HALF_UP,
  HALF_DOWN,
  HALF_EVEN,
  UNNECESSARY,
}

class BigDecimal implements Comparable<BigDecimal> {
  BigDecimal._({
    required this.intVal,
    required this.scale,
  });

  factory BigDecimal.fromBigInt(BigInt value) {
    return BigDecimal._(
      intVal: value,
      scale: 0,
    );
  }

  factory BigDecimal.parse(String value) {
    // TODO: Change this into Java implementation
    final match = _pattern.firstMatch(value);
    if (match == null) {
      throw FormatException('Invalid BigDecimal forma for $value');
    }
    final intPart = match.group(1)!;
    final decimalWithSeparator = match.group(2);

    if (decimalWithSeparator != null) {
      final decimalPart = decimalWithSeparator.substring(1);
      return BigDecimal._(
        intVal: BigInt.parse(intPart + decimalPart),
        scale: decimalPart.length,
      );
    }

    return BigDecimal._(
      intVal: BigInt.parse(intPart),
      scale: 0,
    );
  }

  final BigInt intVal;
  late final int precision = _calculatePrecision();
  final int scale;

  // TODO: Fix
  @override
  bool operator ==(dynamic other) =>
      other is BigDecimal && compareTo(other) == 0;

  BigDecimal operator +(BigDecimal other) =>
      _add(intVal, other.intVal, scale, other.scale);

  BigDecimal operator *(BigDecimal other) =>
      BigDecimal._(intVal: intVal * other.intVal, scale: scale + other.scale);

  BigDecimal operator -(BigDecimal other) =>
      _add(intVal, -other.intVal, scale, other.scale);

  bool operator <(BigDecimal other) => compareTo(other) < 0;

  bool operator <=(BigDecimal other) => compareTo(other) <= 0;

  bool operator >(BigDecimal other) => compareTo(other) > 0;

  bool operator >=(BigDecimal other) => compareTo(other) >= 0;

  BigDecimal abs() => BigDecimal._(intVal: intVal.abs(), scale: scale);

  BigDecimal divide(
    BigDecimal divisor, {
    RoundingMode roundingMode = RoundingMode.UNNECESSARY,
    int? scale,
  }) =>
      _divide(intVal, this.scale, divisor.intVal, divisor.scale,
          scale ?? this.scale, roundingMode);

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
      return BigDecimal._(intVal: intValA + intValB, scale: scaleA);
    } else if (scaleDiff < 0) {
      final scaledX = intValA * BigInt.from(10).pow(-scaleDiff);
      return BigDecimal._(intVal: scaledX + intValB, scale: scaleB);
    } else {
      final scaledY = intValB * BigInt.from(10).pow(scaleDiff);
      return BigDecimal._(intVal: intValA + scaledY, scale: scaleA);
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
      return BigDecimal._(intVal: BigInt.zero, scale: scale);
    }
    if (sumScale(scale, divisorScale) > dividendScale) {
      final newScale = scale + divisorScale;
      final raise = newScale - dividendScale;
      final scaledDividend = dividend * BigInt.from(10).pow(raise);
      return _divideAndRound(
          scaledDividend, divisor, scale, roundingMode, scale);
    } else {
      final newScale = sumScale(dividendScale, -scale);
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
    final remainder = dividend.remainder(divisor);
    final quotientPositive = dividend.sign == divisor.sign;

    if (remainder != BigInt.zero) {
      if (_needIncrement(
          divisor, roundingMode, quotientPositive, quotient, remainder)) {
        final intResult =
            quotient + (quotientPositive ? BigInt.one : -BigInt.one);
        return BigDecimal._(intVal: intResult, scale: scale);
      }
      return BigDecimal._(intVal: quotient, scale: scale);
    } else {
      if (preferredScale != scale) {
        return createAndStripZerosForScale(quotient, scale, preferredScale);
      } else {
        return BigDecimal._(intVal: quotient, scale: scale);
      }
    }
  }

  static BigDecimal createAndStripZerosForScale(
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
      scaleMut = sumScale(scaleMut, -1);
    }

    return BigDecimal._(intVal: intValMut, scale: scaleMut);
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

  static int sumScale(int scaleA, int scaleB) {
    // TODO: We need to check for overflows here
    return scaleA + scaleB;
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

  // TODO: Better impl
  @override
  String toString() {
    final intStr = intVal.toString();
    return '${intStr.substring(0, intStr.length - scale)}.${intStr.substring(intStr.length)}';
  }
}

BigDecimal dec(String value) => BigDecimal.parse(value);
