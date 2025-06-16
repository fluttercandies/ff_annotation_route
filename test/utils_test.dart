import 'package:ff_annotation_route/src/utils/convert.dart';
import 'package:test/test.dart';

void main() {
  test('writeImports', () {
    final buffer = StringBuffer();
    writeImports(
      <String>{
        "import '/test_b.dart",
        "import '../test_c.dart",
        "import '/test_a.dart",
        "import './test_e.dart",
        "import 'test_d.dart",
      },
      buffer,
    );
    expect(
      buffer.toString(),
      [
        "import '/test_a.dart",
        "import '/test_b.dart",
        "import '../test_c.dart",
        "import './test_e.dart",
        "import 'test_d.dart",
      ].join('\n'),
    );
  });
}
