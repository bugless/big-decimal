import 'big_decimal.dart';

class BigDecimalInfinity extends BigDecimal {
  final bool isNegative;

  BigDecimalInfinity({this.isNegative = false}) : super(intVal: BigInt.from(double.maxFinite), scale: 1);

  @override
  BigDecimal operator +(BigDecimal other) {
    if (other is BigDecimalInfinity) {
      if (isNegative && !other.isNegative) {
        throw Exception('Invalid operation: NaN');
      }

      if (!isNegative && other.isNegative) {
        throw Exception('Invalid operation: NaN');
      }
    }

    if (isNegative) return BigDecimal.negativeInifinity;

    return BigDecimal.infinity;
  }

  @override
  BigDecimal operator *(BigDecimal other) {
    if (other is BigDecimalInfinity) {
      if (other.isNegative) {
        return BigDecimal.negativeInifinity;
      }

      return BigDecimal.infinity;
    }

    if (other == BigDecimal.zero) {
      throw Exception('Invalid operation: NaN');
    }

    return BigDecimal.infinity;
  }

  @override
  BigDecimal operator -(BigDecimal other) {
    if (other is BigDecimalInfinity) {
      if (isNegative && other.isNegative) {
        throw Exception('Invalid operation: NaN');
      }

      if (!isNegative && !other.isNegative) {
        throw Exception('Invalid operation: NaN');
      }
    }

    if (other.intVal < BigInt.zero) {
      return BigDecimal.negativeInifinity;
    }

    return BigDecimal.infinity;
  }

  @override
  BigDecimal operator -() => isNegative ? BigDecimal.infinity : BigDecimal.negativeInifinity;

  @override
  BigDecimal abs() {
    return BigDecimal.infinity;
  }

  @override
  BigDecimal divide(
    BigDecimal divisor, {
    RoundingMode roundingMode = RoundingMode.UNNECESSARY,
    int? scale,
  }) {
    if (divisor is BigDecimalInfinity) {
      throw Exception('Invalid operation: NaN');
    }

    return BigDecimal.infinity;
  }

  @override
  BigDecimal pow(int n) {
    if (isNegative) {
      switch (n) {
        case 0:
          return BigDecimal.fromBigInt(BigInt.one);
        case -1:
          return BigDecimal.fromBigInt(BigInt.zero);
        case 1:
          return BigDecimal.negativeInifinity;
      }

      if (n < -1) {
        return BigDecimal.fromBigInt(BigInt.zero);
      }

      return BigDecimal.infinity;
    }

    switch (n) {
      case 0:
        return BigDecimal.fromBigInt(BigInt.one);
      case -1:
        return BigDecimal.fromBigInt(BigInt.zero);
      case 1:
        return BigDecimal.negativeInifinity;
    }

    if (n < -1) {
      return BigDecimal.fromBigInt(BigInt.zero);
    }

    return BigDecimal.infinity;
  }

  @override
  double toDouble() {
    return isNegative ? double.negativeInfinity : double.infinity;
  }

  @override
  BigInt toBigInt({RoundingMode roundingMode = RoundingMode.UNNECESSARY}) {
    throw UnsupportedError('Value must be finite: ${isNegative ? "-Infinity" : "Infinity"}');
  }

  @override
  int toInt({RoundingMode roundingMode = RoundingMode.UNNECESSARY}) {
    throw UnsupportedError('Value must be finite: ${isNegative ? "-Infinity" : "Infinity"}');
  }

  @override
  BigDecimal withScale(int newScale, {RoundingMode roundingMode = RoundingMode.UNNECESSARY}) {
    throw UnsupportedError('Value must be finite: ${isNegative ? "-Infinity" : "Infinity"}');
  }

  @override
  int compareTo(BigDecimal other) {
    if (other is BigDecimalInfinity) {
      return 0;
    }

    return 1;
  }

  @override
  bool exactlyEquals(other) {
    if (other is BigDecimalInfinity) {
      return true;
    }

    return false;
  }

  @override
  String toString() => isNegative ? "-Infinity" : "Infinity";

  @override
  String toPlainString() => isNegative ? "-Infinity" : "Infinity";
}
