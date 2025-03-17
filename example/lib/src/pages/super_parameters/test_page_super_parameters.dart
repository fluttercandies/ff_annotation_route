import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:module_a/module_a_route.dart';

@FFRoute(
  name: 'flutterCandies://TestPageSuperParameters',
  routeName: 'TestPageSuperParameters ' '',
  description: 'This is super parameter test page.',
  exts: <String, dynamic>{
    'group': 'Complex',
    'order': 2,
  },
  showStatusBar: true,
  pageRouteType: PageRouteType.material,
)
class TestPageSuperParameters extends TestPageB {
  const TestPageSuperParameters({
    super.key,
    super.argument,
    super.title = 'abc',
  });
}
