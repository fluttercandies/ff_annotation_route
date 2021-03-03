# ff_annotation_route

[![pub package](https://img.shields.io/pub/v/ff_annotation_route.svg)](https://pub.dartlang.org/packages/ff_annotation_route) [![GitHub stars](https://img.shields.io/github/stars/fluttercandies/ff_annotation_route)](https://github.com/fluttercandies/ff_annotation_route/stargazers) [![GitHub forks](https://img.shields.io/github/forks/fluttercandies/ff_annotation_route)](https://github.com/fluttercandies/ff_annotation_route/network) [![GitHub license](https://img.shields.io/github/license/fluttercandies/ff_annotation_route)](https://github.com/fluttercandies/ff_annotation_route/blob/master/LICENSE) [![GitHub issues](https://img.shields.io/github/issues/fluttercandies/ff_annotation_route)](https://github.com/fluttercandies/ff_annotation_route/issues) <a target="_blank" href="https://jq.qq.com/?_wv=1027&k=5bcc0gy"><img border="0" src="https://pub.idqqimg.com/wpa/images/group.png" alt="flutter-candies" title="flutter-candies"></a>

Languages: English | [中文简体](README-ZH.md)

## Description

Provide a route generator to create route map quickly by annotations.

- [ff_annotation_route](#ff_annotation_route)
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
    - [Code Hints](#code-hints)

## Usage

### Add packages to dependencies

Add the package to `dependencies` in your project/packages's `pubspec.yaml`

*  null-safety

``` yaml
environment:
  sdk: '>=2.12.0 <3.0.0'
dependencies:
  ff_annotation_route_core: ^2.0.0
  ff_annotation_route_library: ^2.0.0
``` 

*  non-null-safety
  
``` yaml
environment:
  sdk: '>=2.6.0 <2.12.0'
dependencies:
  ff_annotation_route_core: ^2.0.1-non-null-safety
  ff_annotation_route_library: ^2.0.1-non-null-safety
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
class/enum argument.you can use `@FFArgumentImport()` instead now. 

```dart
@FFArgumentImport('hide TestMode2')
import 'package:example1/src/model/test_model.dart';
@FFArgumentImport()
import 'package:example1/src/model/test_model1.dart' hide TestMode3;
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';

@FFRoute(
  name: 'flutterCandies://testPageE',
  routeName: 'testPageE',
  description: 'Show how to push new page with arguments(class)',
  // argumentImports are still work for some cases which you can't use @FFArgumentImport()
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

| Parameter       | Description                                                                           | Default  |
| --------------- | ------------------------------------------------------------------------------------- | -------- |
| name            | The name of the route (e.g., "/settings")                                             | required |
| showStatusBar   | Whether to show the status bar.                                                       | true     |
| routeName       | The route name to track page.                                                         | ''       |
| pageRouteType   | The type of page route.(material, cupertino, transparent)                             | -        |
| description     | The description of the route.                                                         | ''       |
| exts            | The extend arguments.                                                                 | -        |
| argumentImports | The imports of arguments. For example, class/enum argument should provide import url. you can use @FFArgumentImport() instead now. | -        |

### Generate Route File

#### Environment

Add dart bin into to your `$PATH`.

`cache\dart-sdk\bin`

[`pub-global`](https://dart.dev/tools/pub/cmd/pub-global)

#### Activate the plugin

*  null-safety

`pub global activate ff_annotation_route`

*  non-null-safety
  
`pub global activate ff_annotation_route 6.x.x-non-null-safety`

#### Execute command

Go to your project's root and execute command.

`ff_route <command> [arguments]`

#### Command Parameter

Available commands:

```markdown
-h, --[no-]help                Help usage
-p, --path                     Flutter project root path
                               (defaults to ".")
-n, --name                     Routes constant class name.
                               (defaults to "Routes")
-o, --output                   The path of main project route file and helper file.It is relative to the lib directory
-g, --git                      scan git lib(you should specify package names and split multiple by ,)
    --routes-file-output       The path of routes file. It is relative to the lib directory
    --const-ignore             The regular to ignore some route consts
    --[no-]package             Is it a package
    --[no-]supper-arguments    Whether generate page arguments helper class
-s, --[no-]save                Whether save the arguments into the local
                               It will execute the local arguments if run "ff_route" without any arguments
    --[no-]null-safety         enable null-safety
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
* enable --supper-arguments

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
* enable --supper-arguments

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

* enable --supper-arguments

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