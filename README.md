# ff_annotation_route

[![pub package](https://img.shields.io/pub/v/ff_annotation_route.svg)](https://pub.dartlang.org/packages/ff_annotation_route) [![GitHub stars](https://img.shields.io/github/stars/fluttercandies/ff_annotation_route)](https://github.com/fluttercandies/ff_annotation_route/stargazers) [![GitHub forks](https://img.shields.io/github/forks/fluttercandies/ff_annotation_route)](https://github.com/fluttercandies/ff_annotation_route/network) [![GitHub license](https://img.shields.io/github/license/fluttercandies/ff_annotation_route)](https://github.com/fluttercandies/ff_annotation_route/blob/master/LICENSE) [![GitHub issues](https://img.shields.io/github/issues/fluttercandies/ff_annotation_route)](https://github.com/fluttercandies/ff_annotation_route/issues) <a target="_blank" href="https://jq.qq.com/?_wv=1027&k=5bcc0gy"><img border="0" src="https://pub.idqqimg.com/wpa/images/group.png" alt="flutter-candies" title="flutter-candies"></a>

Languages: English | [中文简体](README-ZH.md)

## Description

Provide a route generator to create route map quickly by annotations.

- [ff_annotation_route](#ff_annotation_route)
  - [Description](#description)
  - [Usage](#usage)
    - [Add packages to dev_dependencies](#add-packages-to-dev_dependencies)
    - [Add annotation](#add-annotation)
      - [Empty Constructor](#empty-constructor)
      - [Constructor with arguments](#constructor-with-arguments)
      - [FFRoute](#ffroute)
    - [Generate Route File](#generate-route-file)
      - [Environment](#environment)
      - [Activate the plugin](#activate-the-plugin)
      - [Execute command](#execute-command)
      - [Command Parameter](#command-parameter)
    - [Main.dart](#maindart)
    - [Push](#push)
      - [Push name](#push-name)
      - [Push name with arguments](#push-name-with-arguments)
      - [Code Hints](#code-hints)

## Usage

### Add packages to dev_dependencies

Add the package to `dev_dependencies` in your project/packages's `pubspec.yaml`

```yaml
dev_dependencies:
  ff_annotation_route: latest-version
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
class/enum argument.

```dart
import 'package:ff_annotation_route/ff_annotation_route.dart';

@FFRoute(
  name: 'flutterCandies://testPageE',
  routeName: 'testPageE',
  description: 'This is test page E.',
  argumentImports: <String>[
    'import \'package:example/src/model/test_model.dart\';',
    'import \'package:example/src/model/test_model1.dart\';'
  ],
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
| argumentImports | The imports of arguments. For example, class/enum argument should provide import url. | -        |

### Generate Route File

#### Environment

Add dart bin into to your `$PATH`.

`cache\dart-sdk\bin`

[`More info`](https://dart.dev/tools/pub/cmd/pub-global)

#### Activate the plugin

`pub global activate ff_annotation_route`

#### Execute command

Go to your project's root and execute command.

`ff_route <command> [arguments]`

#### Command Parameter

Available commands:

```markdown
-h, --[no-]help                   Help usage.

-p, --path                        Flutter project root path.
                                  (defaults to ".")

-o, --output                      The path of main project route file and helper file.It is relative to the lib directory.

-n, --name                        The class name for the routes constant.
                                  (defaults to "Routes")

-g, --git                         Scan git lib (you should specify package names and split multiple by ,)
    --routes-file-output          The path of routes file. It is relative to the lib directory
    --const-ignore                The regular to ignore some route consts    
    --[no-]route-names            Whether generate route names as a list
    --[no-]route-helper           Whether generate xxx_route_helper.dart
    --[no-]route-constants        Whether generate route names as constants
    --[no-]no-arguments           Whether RouteSettings has arguments(for lower flutter sdk)
    --[no-]package                Is it a package
    --[no-]no-is-initial-route    Whether RouteSettings has isInitialRoute(for higher flutter sdk)
    --[no-]supper-arguments       Whether generate page arguments helper class

-s, --[no-]save                   Whether save the arguments into the local
                                  It will execute the local arguments if run "ff_route" without any arguments.
```
### Main.dart

- If you execute command with `--route-helper`, `FFNavigatorObserver/FFRouteSettings` will generate in `xxx_route_helper.dart`
  which help you to track page or change status bar state.

- If you execute command with `--route-helper`, `FFTransparentPageRoute` will generate in `xxx_route_helper.dart`
  which helps you to push a transparent page route.

```dart
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
        //when refresh web, route will as following
        //   /
        //   /fluttercandies:
        //   /fluttercandies:/
        //   /fluttercandies://mainpage
        if (kIsWeb && settings.name.startsWith('/')) {
          return onGenerateRouteHelper(
            settings.copyWith(name: settings.name.replaceFirst('/', '')),
            notFoundFallback:
                getRouteResult(name: Routes.fluttercandiesMainpage).widget,
          );
        }
        return onGenerateRouteHelper(settings,
            builder: (Widget child, RouteResult result) {
          if (settings.name == Routes.fluttercandiesMainpage ||
              settings.name == Routes.fluttercandiesDemogrouppage) {
            return child;
          }
          return CommonWidget(
            child: child,
            result: result,
          );
        });
      },
    );
  }
}
```

### Push

#### Push name

```dart
  Navigator.pushNamed(context, Routes.fluttercandiesMainpage /* fluttercandies://mainpage */);
```

#### Push name with arguments

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

```dart
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

#### Code Hints

you can use route as 'Routes.flutterCandiesTestPageE', and see Code Hints from ide.

* default

```dart
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

```dart
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