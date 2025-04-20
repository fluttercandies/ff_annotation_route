# ff_annotation_route

[![pub package](https://img.shields.io/pub/v/ff_annotation_route.svg)](https://pub.dartlang.org/packages/ff_annotation_route) [![GitHub stars](https://img.shields.io/github/stars/fluttercandies/ff_annotation_route)](https://github.com/fluttercandies/ff_annotation_route/stargazers) [![GitHub forks](https://img.shields.io/github/forks/fluttercandies/ff_annotation_route)](https://github.com/fluttercandies/ff_annotation_route/network) [![GitHub license](https://img.shields.io/github/license/fluttercandies/ff_annotation_route)](https://github.com/fluttercandies/ff_annotation_route/blob/master/LICENSE) [![GitHub issues](https://img.shields.io/github/issues/fluttercandies/ff_annotation_route)](https://github.com/fluttercandies/ff_annotation_route/issues) <a href="https://qm.qq.com/q/ZyJbSVjfSU"><img src="https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Ffluttercandies%2F.github%2Frefs%2Fheads%2Fmain%2Fdata.yml&query=%24.qq_group_number&style=for-the-badge&label=QQ%E7%BE%A4&logo=qq&color=1DACE8" /></a>

Languages: English | [中文简体](README-ZH.md)

## Description

Provide a route generator to create route map quickly by annotations.

- [ff\_annotation\_route](#ff_annotation_route)
  - [Description](#description)
  - [Usage](#usage)
    - [Add packages to dependencies](#add-packages-to-dependencies)
    - [Add annotation](#add-annotation)
      - [Empty Constructor](#empty-constructor)
      - [Constructor with arguments](#constructor-with-arguments)
      - [FFRoute](#ffroute)
    - [Generate Route File](#generate-route-file)
      - [Environment](#environment)
      - [Activate the plugin](#activate-the-plugin)
      - [Execute command](#execute-command)
      - [Command Parameter](#command-parameter)
    - [Navigator 1.0](#navigator-10)
      - [Main.dart](#maindart)
      - [Push](#push)
        - [Push name](#push-name)
        - [Push name with arguments](#push-name-with-arguments)
    - [Navigator 2.0](#navigator-20)
      - [Main.dart](#maindart-1)
      - [FFRouteInformationParser](#ffrouteinformationparser)
      - [FFRouterDelegate](#ffrouterdelegate)
      - [Push](#push-1)
        - [Push name](#push-name-1)
        - [Push name with arguments](#push-name-with-arguments-1)
    - [GetX](#getx)
      - [How to use](#how-to-use)
      - [How to set the parameter of GetPageRoute](#how-to-set-the-parameter-of-getpageroute)
    - [Functional Widget](#functional-widget)
      - [How to use with functional\_widget?](#how-to-use-with-functional_widget)
    - [Code Hints](#code-hints)
  - [I can do without it, but you must have it](#i-can-do-without-it-but-you-must-have-it)
    - [Interceptor](#interceptor)
      - [Route Interceptor](#route-interceptor)
        - [Implement `RouteInterceptor`](#implement-routeinterceptor)
        - [Add interceptors Annotation](#add-interceptors-annotation)
        - [Generate Mapping](#generate-mapping)
        - [Complete configuration](#complete-configuration)
      - [Global Interceptor](#global-interceptor)
        - [Implement RouteInterceptor](#implement-routeinterceptor-1)
        - [Complete configuration](#complete-configuration-1)
      - [push route](#push-route)
    - [Lifecycle](#lifecycle)
      - [RouteLifecycleState](#routelifecyclestate)
      - [ExtendedRouteObserver](#extendedrouteobserver)
    - [GlobalNavigator](#globalnavigator)

## Usage

### Add packages to dependencies

Add the package to `dependencies` in your project/packages's `pubspec.yaml`

*  null-safety

``` yaml
dependencies:
  # add for a package
  ff_annotation_route_core: any
  # add only for a project
  ff_annotation_route_library: any
``` 

Download with `flutter packages get`

### Add annotation

#### Empty Constructor

```dart
import 'package:ff_annotation_route/ff_annotation_route.dart';

@FFRoute(
  name: "fluttercandies://mainpage",
  routeName: "MainPage",
)
class MainPage extends StatelessWidget
{
  // ...
}

```

#### Constructor with arguments

The tool will handle it. What you should take care is that provide import url by setting `argumentImports` if it has
class/enum argument.you can use `@FFAutoImport()` instead now. 

or you can use `--no-fast-mode` for now, it will add parameters refer import automatically.

```dart
@FFAutoImport('hide TestMode2')
import 'package:example1/src/model/test_model.dart';
@FFAutoImport()
import 'package:example1/src/model/test_model1.dart' hide TestMode3;
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';

@FFRoute(
  name: 'flutterCandies://testPageE',
  routeName: 'testPageE',
  description: 'Show how to push new page with arguments(class)',
  // argumentImports are still work for some cases which you can't use @FFAutoImport()
  // argumentImports: <String>[
  //   'import \'package:example1/src/model/test_model.dart\';',
  //   'import \'package:example1/src/model/test_model1.dart\';',
  // ],
  exts: <String, dynamic>{
    'group': 'Complex',
    'order': 1,
  },
)
class TestPageE extends StatelessWidget {
  const TestPageE({
    this.testMode = const TestMode(
      id: 2,
      isTest: false,
    ),
    this.testMode1,
  });
  factory TestPageE.deafult() => TestPageE(
        testMode: TestMode.deafult(),
      );

  factory TestPageE.required({@required TestMode testMode}) => TestPageE(
        testMode: testMode,
      );

  final TestMode testMode;
  final TestMode1 testMode1;
}
```

#### FFRoute

| Parameter       | Description                                                                                                                                                                             | Default  |
| --------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| name            | The name of the route (e.g., "/settings")                                                                                                                                               | required |
| showStatusBar   | Whether to show the status bar.                                                                                                                                                         | true     |
| routeName       | The route name to track page.                                                                                                                                                           | ''       |
| pageRouteType   | The type of page route.(material, cupertino, transparent)                                                                                                                               | -        |
| description     | The description of the route.                                                                                                                                                           | ''       |
| exts            | The extend arguments.                                                                                                                                                                   | -        |
| argumentImports | The imports of arguments. For example, class/enum argument should provide import url. you can use @FFAutoImport() instead now.                                                          | -        |
| codes           | to support something can't write in annotation, it will be hadnled as a code when generate route. [see](https://github.com/fluttercandies/ff_annotation_route/tree/master/example_getx) | -        |


### Generate Route File

#### Environment

Add dart bin into to your `$PATH`.

`cache\dart-sdk\bin`

[`pub-global`](https://dart.dev/tools/pub/cmd/pub-global)

#### Activate the plugin

`dart pub global activate ff_annotation_route`

#### Execute command

Go to your project's root and execute command.

`ff_route <command> [arguments]`

#### Command Parameter

Available commands:

```markdown
-h, --[no-]help                        Help usage
-p, --path                             Flutter project root path
                                       (defaults to ".")
-n, --name                             Routes constant class name.
                                       (defaults to "Routes")
-o, --output                           The path of main project route file and helper file.It is relative to the lib directory
-g, --git                              scan git lib(you should specify package names and split multiple by ,)
    --exclude-packages                 Exclude given packages from scanning
    --routes-file-output               The path of routes file. It is relative to the lib directory
    --const-ignore                     The regular to ignore some route consts
    --[no-]package                     Is this a package
    --[no-]super-arguments             Whether generate page arguments helper class
-s, --[no-]save                        Whether save the arguments into the local
                                       It will execute the local arguments if run "ff_route" without any arguments
    --[no-]null-safety                 enable null-safety
                                       (defaults to on)
    --[no-]arguments-case-sensitive    arguments is case sensitive or not
                                       (defaults to on)
    --[no-]fast-mode                   fast-mode: only analyze base on single dart file, it's fast.
                                       no-fast mode: analyze base on whole packages and sdk, support super parameters and add parameters refer import automatically.
                                       (defaults to on)
```
### Navigator 1.0

you can see full demo in [example](https://github.com/fluttercandies/ff_annotation_route/tree/master/example)
#### Main.dart

```dart
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';
import 'example_route.dart';
import 'example_routes.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ff_annotation_route demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: Routes.fluttercandiesMainpage,
      onGenerateRoute: (RouteSettings settings) {
        return onGenerateRoute(
          settings: settings,
          getRouteSettings: getRouteSettings,
          routeSettingsWrapper: (FFRouteSettings ffRouteSettings) {
            if (ffRouteSettings.name == Routes.fluttercandiesMainpage ||
                ffRouteSettings.name ==
                    Routes.fluttercandiesDemogrouppage.name) {
              return ffRouteSettings;
            }
            return ffRouteSettings.copyWith(
                widget: CommonWidget(
              child: ffRouteSettings.widget,
              title: ffRouteSettings.routeName,
            ));
          },
        );
      },
    );
  }
}
```

#### Push

##### Push name

``` dart
  Navigator.pushNamed(context, Routes.fluttercandiesMainpage /* fluttercandies://mainpage */);
```

##### Push name with arguments

* `arguments` **MUST** be a `Map<String, dynamic>`

```dart
  Navigator.pushNamed(
    context,
    Routes.flutterCandiesTestPageE,
    arguments: <String, dynamic>{
      constructorName: 'required',
      'testMode': const TestMode(
        id: 100,
        isTest: true,
      ),
    },
  );
```
* enable --super-arguments

``` dart
  Navigator.pushNamed(
    context,
    Routes.flutterCandiesTestPageE.name,
    arguments: Routes.flutterCandiesTestPageE.requiredC(
      testMode: const TestMode(
        id: 100,
        isTest: true,
      ),
    ),
  );
```
### Navigator 2.0

you can see full demo in [example1](https://github.com/fluttercandies/ff_annotation_route/tree/master/example1)
#### Main.dart

``` dart
import 'dart:convert';
import 'package:example1/src/model/test_model.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'example1_route.dart';
import 'example1_routes.dart';

void main() {
  // tool will handle simple types(int,double,bool etc.), but not all of them.
  // for example, you can type in web browser
  // http://localhost:64916/#flutterCandies://testPageF?list=[4,5,6]&map={"ddd":123}&testMode={"id":2,"isTest":true}
  // the queryParameters will be converted base on your case.
  FFConvert.convert = <T>(dynamic value) {
    if (value == null) {
      return null;
    }
    print(T);
    final dynamic output = json.decode(value.toString());
    if (<int>[] is T && output is List<dynamic>) {
      return output.map<int>((dynamic e) => asT<int>(e)).toList() as T;
    } else if (<String, String>{} is T && output is Map<dynamic, dynamic>) {
      return output.map<String, String>((dynamic key, dynamic value) =>
          MapEntry<String, String>(key.toString(), value.toString())) as T;
    } else if (const TestMode() is T && output is Map<dynamic, dynamic>) {
      return TestMode.fromJson(output) as T;
    }

    return json.decode(value.toString()) as T;
  };
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FFRouteInformationParser _ffRouteInformationParser =
      FFRouteInformationParser();

  final FFRouterDelegate _ffRouterDelegate = FFRouterDelegate(
    getRouteSettings: getRouteSettings,
    pageWrapper: <T>(FFPage<T> ffPage) {
      return ffPage.copyWith(
        widget: ffPage.name == Routes.fluttercandiesMainpage ||
                ffPage.name == Routes.fluttercandiesDemogrouppage.name
            ? ffPage.widget
            : CommonWidget(
                child: ffPage.widget,
                routeName: ffPage.routeName,
              ),
      );
    },
  );
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ff_annotation_route demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // initialRoute
      routeInformationProvider: PlatformRouteInformationProvider(
        initialRouteInformation: const RouteInformation(
          location: Routes.fluttercandiesMainpage,
        ),
      ),
      routeInformationParser: _ffRouteInformationParser,
      routerDelegate: _ffRouterDelegate,
    );
  }
}
```

#### FFRouteInformationParser

It's working on Web when you type in browser or report to browser. A delegate that is used by the [Router] widget to parse a route information
into a configuration of type [RouteSettings].

for example:

`xxx?a=1&b=2` <=> `RouteSettings(name:'xxx',arguments:<String, dynamic>{'a':'1','b':'2'})`


#### FFRouterDelegate

A delegate that is used by the [Router] widget to build and configure anavigating widget.

It provides push/pop methods like [Navigator].

``` dart
  FFRouterDelegate.of(context).pushNamed<void>(
    Routes.flutterCandiesTestPageF.name,
    arguments: Routes.flutterCandiesTestPageF.d(
      <int>[1, 2, 3],
      map: <String, String>{'ddd': 'dddd'},
      testMode: const TestMode(id: 1, isTest: true),
    ),
  );
```

you can find more demo in [test_page_c.dart](https://github.com/fluttercandies/ff_annotation_route/tree/master/example1/lib/src/pages/simple/test_page_c.dart).

#### Push

##### Push name

``` dart
  FFRouterDelegate.of(context).pushNamed<void>(
    Routes.flutterCandiesTestPageA,
  );
```

##### Push name with arguments

* `arguments` **MUST** be a `Map<String, dynamic>`

```dart
  FFRouterDelegate.of(context).pushNamed<void>(
    Routes.flutterCandiesTestPageF.name,
    arguments: Routes.flutterCandiesTestPageF.d(
      <int>[1, 2, 3],
      map: <String, String>{'ddd': 'dddd'},
      testMode: const TestMode(id: 1, isTest: true),
    ),
  );
```
* enable --super-arguments

``` dart
  FFRouterDelegate.of(context).pushNamed<void>(
    Routes.flutterCandiesTestPageF.name,
    arguments: <String, dynamic>{
        'list': <int>[1, 2, 3],
        'map': <String, String>{'ddd': 'dddd'},
        'testMode': const TestMode(id: 1, isTest: true),
     }
  )
```

### GetX

#### How to use
Getx is supported, you just need to convert `FFRouteSettings` to `GetPageRoute`

``` dart
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ff_annotation_route demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: Routes.fluttercandiesMainpage.name,
      onGenerateRoute: (RouteSettings settings) {
        FFRouteSettings ffRouteSettings = getRouteSettings(
          name: settings.name!,
          arguments: settings.arguments as Map<String, dynamic>?,
          notFoundPageBuilder: () => Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: Text('not find page'),
            ),
          ),
        );
        Bindings? binding;
        if (ffRouteSettings.codes != null) {
          binding = ffRouteSettings.codes!['binding'] as Bindings?;
        }

        Transition? transition;
        bool opaque = true;
        if (ffRouteSettings.pageRouteType != null) {
          switch (ffRouteSettings.pageRouteType) {
            case PageRouteType.cupertino:
              transition = Transition.cupertino;
              break;
            case PageRouteType.material:
              transition = Transition.downToUp;
              break;
            case PageRouteType.transparent:
              opaque = false;
              break;
            default:
          }
        }

        return GetPageRoute(
          binding: binding,
          opaque: opaque,
          settings: ffRouteSettings,
          transition: transition,
          page: () => ffRouteSettings.builder(),
        );
      },
    );
  }
}
```

#### How to set the parameter of GetPageRoute

for example:
'Bindings' is not const class, so it can't write in annotation, but you can set it as following codes:

1. define it in `codes`
2. add import url in `argumentImports`
3. get it in `onGenerateRoute`

``` dart
@FFRoute(
  name: "/BindingsPage",
  routeName: 'BindingsPage',
  description: 'how to use Bindings with Annotation.',
  codes: <String, String>{
    'binding': 'Bindings1()',
  },
  argumentImports: <String>[
    'import \'package:example_getx/src/bindings/bindings1.dart\';'
  ],
)

```

``` dart
      onGenerateRoute: (RouteSettings settings) {
        FFRouteSettings ffRouteSettings = getRouteSettings(
          name: settings.name!,
          arguments: settings.arguments as Map<String, dynamic>?,
          notFoundPageBuilder: () => Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: Text('not find page'),
            ),
          ),
        );
        Bindings? binding;
        if (ffRouteSettings.codes != null) {
          binding = ffRouteSettings.codes!['binding'] as Bindings?;
        }

        Transition? transition;
        bool opaque = true;
        if (ffRouteSettings.pageRouteType != null) {
          switch (ffRouteSettings.pageRouteType) {
            case PageRouteType.cupertino:
              transition = Transition.cupertino;
              break;
            case PageRouteType.material:
              transition = Transition.downToUp;
              break;
            case PageRouteType.transparent:
              opaque = false;
              break;
            default:
          }
        }

        return GetPageRoute(
          binding: binding,
          opaque: opaque,
          settings: ffRouteSettings,
          transition: transition,
          page: () => ffRouteSettings.builder(),
        );
      },

```



### Functional Widget

#### How to use with [functional_widget](https://github.com/rrousselGit/functional_widget)?

```dart  
@swidget
@FFRoute(
  name: 'flutterCandies://func1',
  routeName: 'test-func-1',
)
Widget func1(
  int a,
  String? b, {
  bool? c,
  required double d,
}) {
  return Container();
}
```

[Simple code](example/lib/src/pages/func/func.dart) is here.


### Code Hints

you can use route as 'Routes.flutterCandiesTestPageE', and see Code Hints from ide.

* default

``` dart
  /// 'This is test page E.'
  ///
  /// [name] : 'flutterCandies://testPageE'
  ///
  /// [routeName] : 'testPageE'
  ///
  /// [description] : 'This is test page E.'
  ///
  /// [constructors] :
  ///
  /// TestPageE : [TestMode testMode, TestMode1 testMode1]
  ///
  /// TestPageE.deafult : []
  ///
  /// TestPageE.required : [TestMode(required) testMode]
  ///
  /// [exts] : {group: Complex, order: 1}
  static const String flutterCandiesTestPageE = 'flutterCandies://testPageE';
```

* enable --super-arguments

``` dart
  /// 'This is test page E.'
  ///
  /// [name] : 'flutterCandies://testPageE'
  ///
  /// [routeName] : 'testPageE'
  ///
  /// [description] : 'This is test page E.'
  ///
  /// [constructors] :
  ///
  /// TestPageE : [TestMode testMode, TestMode1 testMode1]
  ///
  /// TestPageE.test : []
  ///
  /// TestPageE.requiredC : [TestMode(required) testMode]
  ///
  /// [exts] : {group: Complex, order: 1}
  static const _FlutterCandiesTestPageE flutterCandiesTestPageE =
      _FlutterCandiesTestPageE();

  class _FlutterCandiesTestPageE {
    const _FlutterCandiesTestPageE();

    String get name => 'flutterCandies://testPageE';

    Map<String, dynamic> d(
            {TestMode testMode = const TestMode(id: 2, isTest: false),
            TestMode1 testMode1}) =>
        <String, dynamic>{
          'testMode': testMode,
          'testMode1': testMode1,
        };

    Map<String, dynamic> test() => const <String, dynamic>{
          'constructorName': 'test',
        };

    Map<String, dynamic> requiredC({@required TestMode testMode}) =>
        <String, dynamic>{
          'testMode': testMode,
          'constructorName': 'requiredC',
        };

    @override
    String toString() => name;
  }

```

## I can do without it, but you must have it

### Interceptor

#### Route Interceptor

##### Implement `RouteInterceptor`

Implement a `RouteInterceptor` to intercept route transitions for a specific page based on your scenario.

``` dart
class LoginInterceptor extends RouteInterceptor {
  const LoginInterceptor();

  @override
  Future<RouteInterceptResult> intercept(
    String routeName, {
    Object? arguments,
  }) async {
    if (!User().hasLogin) {
      return RouteInterceptResult.complete(
        routeName: Routes.fluttercandiesLoginPage.name,
      );
    }

    return RouteInterceptResult.next(
      routeName: routeName,
      arguments: arguments,
    );
  }
}
``` 

Here are the possible scenarios corresponding to `RouteInterceptResult.complete`, `RouteInterceptResult.next`, and `RouteInterceptResult.abort`:

``` dart
/// Represents the possible actions a route interceptor can take
/// after being invoked during the route interception process.
enum RouteInterceptAction {
  /// Stops the interception chain and cancels any further actions.
  /// This indicates that the current interceptor has determined
  /// that no route should be pushed, and the navigation process should be aborted.
  abort,

  /// Moves to the next interceptor in the chain.
  /// This indicates that the current interceptor does not want to handle
  /// the route and delegates the decision to subsequent interceptors.
  next,

  /// Completes the interception process and allows the route to be pushed.
  /// This indicates that the current interceptor has handled the route
  /// and the navigation should proceed as expected.
  complete,
}

``` 


##### Add interceptors Annotation

Add an interceptors annotation to the page for route interception.

``` dart
@FFRoute(
  name: 'fluttercandies://PageA',
  routeName: 'PageA',
  description: 'PageA',
  interceptors: <RouteInterceptor>[
    LoginInterceptor(),
  ],
)
class PageA extends StatefulWidget {
  const PageA({Key? key}) : super(key: key);

  @override
  State<PageA> createState() => _PageAState();
}
``` 

##### Generate Mapping

Execute `ff_route` to generate the interceptor mapping.
 

``` dart
/// The routeInterceptors auto generated by https://github.com/fluttercandies/ff_annotation_route
const Map<String, List<RouteInterceptor>> routeInterceptors =
    <String, List<RouteInterceptor>>{
  'fluttercandies://PageA': <RouteInterceptor>[LoginInterceptor()],
  'fluttercandies://PageB': <RouteInterceptor>[
    LoginInterceptor(),
    PermissionInterceptor()
  ],
};
``` 

##### Complete configuration

``` dart
void main() {
  RouteInterceptorManager().addAllRouteInterceptors(routeInterceptors);
  runApp(const MyApp());
}
``` 

#### Global Interceptor

If you don’t want to add interceptors in the annotation, you can choose to use global interceptors.

##### Implement RouteInterceptor

You can write your logic here based on your specific scenario.

``` dart
class GlobalLoginInterceptor extends RouteInterceptor {
  const GlobalLoginInterceptor();
  @override
  Future<RouteInterceptResult> intercept(String routeName,
      {Object? arguments}) async {
    if (routeName == Routes.fluttercandiesPageB.name ||
        routeName == Routes.fluttercandiesPageA.name) {
      if (!User().hasLogin) {
        return RouteInterceptResult.complete(
          routeName: Routes.fluttercandiesLoginPage.name,
        );
      }
    }

    return RouteInterceptResult.next(
      routeName: routeName,
      arguments: arguments,
    );
  }
}
``` 

##### Complete configuration

``` dart
void main() {
  RouteInterceptorManager().addGlobalInterceptors([
    const GlobalLoginInterceptor(),
    const GlobalPermissionInterceptor(),
  ]);
  runApp(const MyApp());
}
``` 

#### push route

1. You can use the `NavigatorWithInterceptorExtension` extension to call methods with `WithInterceptor`.
``` dart
    Navigator.of(context).pushNamedWithInterceptor(
      Routes.fluttercandiesPageA.name,
    );
```

2. Call the static methods of `NavigatorWithInterceptor`.  

``` dart
    NavigatorWithInterceptor.pushNamed(
      context,
      Routes.fluttercandiesPageB.name,
    );
```

### Lifecycle

#### RouteLifecycleState

By inheriting from `RouteLifecycleState`, you can easily detect various states of the page.

The `onPageShow` and `onPageHide` callbacks are only triggered when the current component is hosted by a `PageRoute`.

``` dart
class _PageBState extends RouteLifecycleState<PageB> {
  @override
  void onForeground() {
    print('PageB onForeground');
  }

  @override
  void onBackground() {
    print('PageB onBackground');
  }

  @override
  void onPageShow() {
    print('PageB onPageShow');
  }

  @override
  void onPageHide() {
    print('PageB onPageHide');
  }

  @override
  void onRouteShow() {
    print('onRouteShow');
  }

  @override
  void onRouteHide() {
    print('onRouteHide');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page B'),
      ),
      body: GestureDetector(
        onTap: () {},
        child: const Center(
          child: Text('This is Page B'),
        ),
      ),
    );
  }
}
``` 

#### ExtendedRouteObserver

[ExtendedRouteObserver] is a utility class that extends the functionality of
Flutter's built-in RouteObserver. It allows for more advanced route
management and tracking in the navigation stack. This class maintains
an internal list of active routes and provides several utility methods
for route inspection and manipulation.

Key features of [ExtendedRouteObserver]:
- Tracks all active routes in the navigation stack.
- Provides access to the top-most route via the `topRoute` getter.
- Allows checking if a specific route exists in the stack with `containsRoute()`.
- Enables retrieval of a route by its name using `getRouteByName()`.
- Notifies subscribers when a route is added or removed via `onRouteAdded` and `onRouteRemoved`.
- Supports custom actions when a route is added or removed via `onRouteAdd()` and `onRouteRemove()`.

This class is useful in cases where global route tracking or advanced
navigation behavior is needed, such as:
- Monitoring which routes are currently active.
- Handling custom navigation logic based on the current route stack.
- Implementing a navigation history feature or a breadcrumb-style navigator.

By leveraging this class, developers can gain better insight into and
control over their app's navigation state. 

``` dart
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: <NavigatorObserver>[ExtendedRouteObserver()],
    );
  }
``` 

### GlobalNavigator

GlobalNavigator class is a utility class for managing global navigation actions.
It provides easy access to the Navigator and BuildContext from anywhere in the app.


`context` is a crucial part of `Flutter`, involving many key functionalities such as themes, routing, and dependency injection. Flutter’s design philosophy is based on the propagation of context through the widget tree, allowing context to access relevant information and functionalities, which helps maintain good component separation and maintainability.

While it is possible to directly access the `Navigator` or `context` via a global `navigatorKey` in certain situations, it is generally not recommended to use this approach regularly, especially when Flutter’s recommended patterns (such as accessing via `context`) work well.

This approach can introduce some potential issues:

1. Violates Flutter’s Design Philosophy: Flutter’s original design is based on localized navigation and state management through `BuildContext`. Bypassing `context` with a global approach may lead to state management confusion and make the code harder to maintain.

2. Potential Performance Issues: Accessing `context` globally may bypass Flutter’s optimization mechanisms, as Flutter relies on the context tree’s structure for efficient `UI` updates.

3. Poor Maintainability: Relying on global navigation can make the code more difficult to understand and maintain, especially as the app grows larger. It may become hard to track navigation flow and state.

``` dart
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: GlobalNavigator.navigatorKey,  
      home: HomeScreen(),
    );
  }
}
``` 
``` dart
    GlobalNavigator.navigator?.push(
      MaterialPageRoute(builder: (context) => SecondScreen()),
    );
``` 

``` dart
    showDialog(
      context: GlobalNavigator.context!,
      builder: (b) {
        return AlertDialog(
          title: const Text('Permission Denied'),
          content:
              Text('You do not have permission to access this page.'),
          actions: [
            TextButton(
              onPressed: () {
                GlobalNavigator.navigator?.pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
``` 