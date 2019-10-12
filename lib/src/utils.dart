Type typeOf<T>() => T;

const String fileHeader = """// GENERATED CODE - DO NOT MODIFY BY HAND
// **************************************************************************
// auto generated by https://github.com/fluttercandies/ff_annotation_route
// ************************************************************************** \n""";

const String rootFile = """

RouteResult getRouteResult({String name, Map<String, dynamic> arguments}) {
  //arguments??={};
  switch (name) {
{0}   default:
      return RouteResult();
  }
}

class RouteResult {
  /// The Widget return base on route
  final Widget widget;

  /// Whether show this route with status bar.
  final bool showStatusBar;

  /// The route name to track page
  final String routeName;

  /// The type of page route
  final PageRouteType pageRouteType;

  /// The description of route
  final String description;

  const RouteResult(
      {this.widget,
      this.showStatusBar = true,
      this.routeName = '',
      this.pageRouteType,
      this.description = ''});
}

 enum PageRouteType { material, cupertino, transparent }
""";

const String routeHelper = """
import 'package:flutter/widgets.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class FFNoRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("can't find route"),
        ),
        body: Center(
          child: Container(
            child: Text("can't find route"),
          ),
        ));
  }
}

class FFNavigatorObserver extends NavigatorObserver {
  final ShowStatusBarChange showStatusBarChange;
  final RouteChange routeChange;

  // 当前路由栈
  static List<Route> _mRoutes;
  List<Route> get routes => _mRoutes;
  // 当前路由
  Route get currentRoute => _mRoutes[_mRoutes.length - 1];
  // stream相关
  static StreamController _streamController;
  StreamController get streamController=> _streamController;

  /* 单例给出NavigatorManager */
  static FFNavigatorObserver navigatorManager;
  static FFNavigatorObserver getInstance() {
    if (navigatorManager == null) {
      navigatorManager = new FFNavigatorObserver();
      _streamController = StreamController.broadcast();
    }
    return navigatorManager;
  }

  FFNavigatorObserver({this.showStatusBarChange, this.routeChange});

  @override
  void didPop(Route route, Route previousRoute) {
    super.didPop(route, previousRoute);
    if (route is CupertinoPageRoute || route is MaterialPageRoute) {
      _mRoutes.remove(route);
      _showStatusBarChange(previousRoute, route);
      _routeChange(previousRoute);
      _routeObserver();
    }
  }

  @override
  void didPush(Route route, Route previousRoute) {
    super.didPush(route, previousRoute);
    if (_mRoutes == null) {
      _mRoutes = new List<Route>();
    }
    // 这里过滤调push的是dialog的情况
    if (route is CupertinoPageRoute || route is MaterialPageRoute) {
      _mRoutes.add(route);
      _showStatusBarChange(route, previousRoute);
      _routeChange(route);
      _routeObserver();
    }
  }

  @override
  void didRemove(Route route, Route previousRoute) {
    super.didRemove(route, previousRoute);
    if (route is CupertinoPageRoute || route is MaterialPageRoute) {
      _mRoutes.remove(route);
      _showStatusBarChange(previousRoute, route);
      _routeChange(previousRoute);
      _routeObserver();
    }
  }

  @override
  void didReplace({Route newRoute, Route oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute is CupertinoPageRoute || newRoute is MaterialPageRoute) {
      _mRoutes.remove(oldRoute);
      _mRoutes.add(newRoute);
      _showStatusBarChange(newRoute, oldRoute);
      _routeChange(newRoute);
      _routeObserver();
    }
  }

  @override
  void didStartUserGesture(Route route, Route previousRoute) {
    super.didStartUserGesture(route, previousRoute);
  }

  @override
  void didStopUserGesture() {
    super.didStopUserGesture();
  }

  // replace 页面
  pushReplacementNamed(String routeName, [WidgetBuilder builder]) {
    var routeResult = getRouteResult(
      name: routeName,
    );

    var page = routeResult.widget ?? FFNoRoute();
    var targetRoute = Platform.isIOS
        ? CupertinoPageRoute(
            builder: builder ?? (context) => page,
            settings: RouteSettings(name: routeName),
          )
        : MaterialPageRoute(
            builder: builder ?? (context) => page,
            settings: RouteSettings(name: routeName),
          );
    return navigator.pushReplacement(
      targetRoute,
    );
  }

  // push 页面
  pushNamed(String routeName, [WidgetBuilder builder]) {
    var routeResult = getRouteResult(
      name: routeName,
    );

    var page = routeResult.widget ?? FFNoRoute();
    var targetRoute = Platform.isIOS
        ? CupertinoPageRoute(
            builder: builder ?? (context) => page,
            settings: RouteSettings(name: routeName),
          )
        : MaterialPageRoute(
            builder: builder ?? (context) => page,
            settings: RouteSettings(name: routeName),
          );
    return navigator.push(
      targetRoute,
    );
  }

  // pop 页面
  pop<T extends Object>([T result]) {
    navigator.pop(result);
  }

  // push一个页面， 移除该页面下面所有页面
  pushNamedAndRemoveUntil(String newRouteName) {
    return navigator.pushNamedAndRemoveUntil(
        newRouteName, (Route<dynamic> route) => false);
  }

  void _showStatusBarChange(Route newRoute, Route oldRoute) {
    if (showStatusBarChange != null) {
      var newSettting = getFFRouteSettings(newRoute);
      var oldSetting = getFFRouteSettings(oldRoute);
      if (newSettting?.showStatusBar != null &&
          newSettting.showStatusBar != oldSetting?.showStatusBar) {
        showStatusBarChange(newSettting.showStatusBar);
      }
    }
  }

  void _routeChange(Route newRoute) {
    if (routeChange != null) {
      var newSettting = getFFRouteSettings(newRoute);
      if (newSettting?.routeName != null) {
        routeChange(newSettting.routeName);
      }
    }
  }
  
  void _routeObserver() {
    print('&&路由栈&&');
    print('\$_mRoutes');
    print('&&当前路由&&');
    print('\${_mRoutes[_mRoutes.length - 1]}');
    // 当前页面的navigator，用来路由跳转
    // navigator = _mRoutes[_mRoutes.length - 1].navigator;
    _streamController.sink.add(_mRoutes);
  }

  FFRouteSettings getFFRouteSettings(Route route) {
    if (route != null &&
        route.settings != null &&
        route.settings is FFRouteSettings) {
      return route.settings;
    }
    return null;
  }
}

typedef ShowStatusBarChange = void Function(bool showStatusBar);

typedef RouteChange = void Function(String routeName);

class FFTransparentPageRoute<T> extends PageRouteBuilder<T> {
  FFTransparentPageRoute({
    RouteSettings settings,
    @required RoutePageBuilder pageBuilder,
    RouteTransitionsBuilder transitionsBuilder = _defaultTransitionsBuilder,
    Duration transitionDuration = const Duration(milliseconds: 300),
    bool barrierDismissible = false,
    Color barrierColor,
    String barrierLabel,
    bool maintainState = true,
  })  : assert(pageBuilder != null),
        assert(transitionsBuilder != null),
        assert(barrierDismissible != null),
        assert(maintainState != null),
        super(
            settings: settings,
            opaque: false,
            pageBuilder: pageBuilder,
            transitionsBuilder: transitionsBuilder,
            transitionDuration: transitionDuration,
            barrierDismissible: barrierDismissible,
            barrierColor: barrierColor,
            barrierLabel: barrierLabel,
            maintainState: maintainState);
}

Widget _defaultTransitionsBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child) {
  return child;
}

""";

const String ffRouteSettings = """
class FFRouteSettings extends RouteSettings {
  final String routeName;
  final bool showStatusBar;
  const FFRouteSettings({
    this.routeName,
    this.showStatusBar,
    String name,
    bool isInitialRoute = false,
    Object arguments,
  }) : super(name: name, isInitialRoute: isInitialRoute, arguments: arguments);
}
""";

const String ffRouteSettingsNoArguments = """
class FFRouteSettings extends RouteSettings {
  final String routeName;
  final bool showStatusBar;
  const FFRouteSettings({
    this.routeName,
    this.showStatusBar,
    String name,
    bool isInitialRoute = false,
  }) : super(name: name, isInitialRoute: isInitialRoute);
}
""";
