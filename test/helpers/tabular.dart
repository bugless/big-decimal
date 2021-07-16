import 'package:test/test.dart';

class TabularCase {
  TabularCase(this.args, [this.description]);
  final List<Object> args;
  final String? description;
}

TabularCase tabCase(List<Object> args, [String? description]) => TabularCase(args, description);

void Function() tabular(Function runCase, List<TabularCase> cases) => () {
      for (final c in cases.asMap().entries) {
        test(c.value.description ?? 'Test case ${c.key}', () {
          Function.apply(runCase, c.value.args);
        });
      }
    };
