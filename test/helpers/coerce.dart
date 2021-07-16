import 'package:big_decimal/big_decimal.dart';

extension CoerceToBigDecimal on Object {
  BigDecimal get dec {
    if (this is BigDecimal) {
      return this as BigDecimal;
    }
    if (this is String) {
      return BigDecimal.parse(this as String);
    }
    if (this is BigInt) {
      return BigDecimal.fromBigInt(this as BigInt);
    }
    if (this is int) {
      return BigDecimal.fromBigInt(BigInt.from(this as int));
    }
    if (this is double) {
      return BigDecimal.parse((this as double).toString());
    }
    throw Exception('Cannot coerce $this to BigDecimal.');
  }
}
