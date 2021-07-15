import 'package:test/test.dart';

void main() {
  group('A test', () {
    test('Passing test', () {
      expect(1, equals(1));
    });

    test('Failing test', () {
      expect(2, equals(1));
    });
  });
}
