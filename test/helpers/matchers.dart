import 'package:big_decimal/big_decimal.dart';
import 'package:test/test.dart';

class ExactlyBigDecimal extends Matcher {
  ExactlyBigDecimal(this.expected);

  final BigDecimal expected;

  @override
  Description describe(Description description) =>
      description.add('Exactly ').addDescriptionOf(expected);

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! BigDecimal) {
      return false;
    }
    return item.intVal == expected.intVal && item.scale == expected.scale;
  }
}

Matcher exactly(BigDecimal expected) => ExactlyBigDecimal(expected);
