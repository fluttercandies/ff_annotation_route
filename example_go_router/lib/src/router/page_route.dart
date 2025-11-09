import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class TransparentPage<T> extends Page<T> {
  const TransparentPage({
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
    super.canPop = true,
    required this.child,
  });
  final Widget child;
  @override
  Route<T> createRoute(BuildContext context) {
    return FFTransparentPageRoute(
      settings: this,
      pageBuilder: (context, _, __) => child,
    );
  }
}

class FFGoRoute extends GoRoute {
  FFGoRoute({
    required super.path,
    super.name,
    super.builder,
    super.pageBuilder,
    super.parentNavigatorKey,
    super.redirect,
    super.onExit,
    super.caseSensitive = true,
    super.routes = const <RouteBase>[],
    required this.settings,
  });

  final FFGoRouterRouteSettings settings;

  String get routeName => settings.routeName!;
}
