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

  final BigInt intVal;
  late final int precision = _calculatePrecision();
  final int scale;

  int _calculatePrecision() {
    if (intVal.sign == 0) {
      return 1;
    }
    final r = ((intVal.bitLength + 1) * 646456993) >> 31;
    return intVal.abs().compareTo(BigInt.from(10).pow(r)) < 0 ? r : r + 1;
  }

  @override
  int compareTo(BigDecimal other) {
    // TODO: implement compareTo
    throw UnimplementedError();
  }
}
