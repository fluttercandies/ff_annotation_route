# ff_annotation_route

[![pub package](https://img.shields.io/pub/v/ff_annotation_route.svg)](https://pub.dartlang.org/packages/ff_annotation_route) [![GitHub stars](https://img.shields.io/github/stars/fluttercandies/ff_annotation_route)](https://github.com/fluttercandies/ff_annotation_route/stargazers) [![GitHub forks](https://img.shields.io/github/forks/fluttercandies/ff_annotation_route)](https://github.com/fluttercandies/ff_annotation_route/network) [![GitHub license](https://img.shields.io/github/license/fluttercandies/ff_annotation_route)](https://github.com/fluttercandies/ff_annotation_route/blob/master/LICENSE) [![GitHub issues](https://img.shields.io/github/issues/fluttercandies/ff_annotation_route)](https://github.com/fluttercandies/ff_annotation_route/issues) <a target="_blank" href="https://jq.qq.com/?_wv=1027&k=5bcc0gy"><img border="0" src="https://pub.idqqimg.com/wpa/images/group.png" alt="flutter-candies" title="flutter-candies"></a>

Languages: [English](README.md) | 中文简体

[掘金地址](https://juejin.im/post/5d5a7fe5f265da03b94ff42c)

## 描述

通过注解快速完成路由映射.

- [ff_annotation_route](#ff_annotation_route)
  - [描述](#描述)
  - [使用](#使用)
    - [增加引用](#增加引用)
    - [添加注解](#添加注解)
      - [空构造](#空构造)
      - [带参数构造](#带参数构造)
      - [FFRoute](#ffroute)
    - [生成文件](#生成文件)
      - [环境](#环境)
      - [激活](#激活)
      - [执行命令](#执行命令)
      - [命令参数](#命令参数)
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
      - [设置 GetPageRoute 的参数](#设置-getpageroute-的参数)
    - [Functional Widget](#functional-widget)
      - [如何与 functional_widget 一起使用？](#如何与-functional_widget-一起使用)
    - [Code Hints](#code-hints)
  - [来杯可乐](#来杯可乐)

## 使用

### 增加引用

添加引用到`dependencies`，及你需要注解的 project/packages 到`pubspec.yaml`中

``` yaml
dependencies:
  # 如果是一个package，只用添加 ff_annotation_route_core
  ff_annotation_route_core: any
  # 如果是一个主项目，只需要添加 ff_annotation_route_library
  ff_annotation_route_library: any
``` 

执行 `flutter packages get` 下载

### 添加注解

#### 空构造

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

#### 带参数构造

工具会自动处理带参数的构造，不需要做特殊处理。唯一需要注意的是，你需要使用 `argumentImports` 为class/enum的参数提供 import 地址。现在你可以使用 `@FFArgumentImport()` 来替代.

当然你现在可以选使用 `--no-fast-mode` 非快速模式进行解析，它会自动添加参数对应的引用。


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
  // 为了防止 @FFArgumentImport() 不能完全表达的情况， 依然保留 argumentImports。
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

| Parameter     | Description                                   | Default  |
| ------------- | --------------------------------------------- | -------- |
| name          | 路由的名字 (e.g., "/settings")               | required |
| showStatusBar | 是否显示状态栏                                | true     |
| routeName     | 用于埋点收集数据的页面名字                    | ''       |
| pageRouteType | 路由的类型 (material, cupertino, transparent) | -        |
| description   | 路由的描述                                    | ''       |
| exts          | 其他扩展参数.                                 | -        |
| argumentImports | 某些参数的导入.有一些参数是类或者枚举，需要指定它们的导入地址.现在你可以使用 @FFArgumentImport()来替代  | -        |
| codes | 有些代码无法直接写在注释里面, 你可以使用该参数，生成路由的时候会生成对应代码. [see](https://github.com/fluttercandies/ff_annotation_route/tree/master/example_getx) | -        |
### 生成文件

#### 环境

添加 dart 的 bin 的路径到你的系统 `$PATH`.

`cache\dart-sdk\bin`

[更多信息](https://dart.dev/tools/pub/cmd/pub-global)

不清楚的可以看[掘金](https://juejin.im/post/5d4b8959e51d4561df780555)

#### 激活

`dart pub global activate ff_annotation_route`

#### 执行命令

到你的项目根目录下面执行.

`ff_route <command> [arguments]`

#### 命令参数

可用的命令:

``` markdown
-h, --[no-]help                   帮助信息。

-p, --path                        执行命令的目录，默认当前目录。

-o, --output                      route 和 helper 文件的输出目录路径，路径相对于主项目的 lib 文件夹。

-n, --name                        路由常量类的名称，默认为 `Routes`。

-g, --git                         扫描 git 引用的 package，你需要指定 package 的名字，多个用 `,` 分开    
    --exclude-packages            排除某些 packages 被扫描
    --routes-file-output          routes 文件的输出目录路径，路径相对于主项目的lib文件夹
    --const-ignore                使用正则表达式忽略一些const(不是全部const都希望生成)
    --[no-]route-constants        是否在根项目中的 `xxx_route.dart` 生成全部路由的静态常量
    --[no-]package                这个是否是一个 package
    --[no-]super-arguments        是否生成路由参数帮助类

-s, --[no-]save                   是否保存命令到本地。如果保存了，下一次就只需要执行 `ff_route` 就可以了。
    --[no-]null-safety            是否支持空安全，默认 `true`
    --[no-]fast-mode              快速模式: 只会对单独文件进行解析, 它更快.
                                  非快速模式: 会对 packages 和 sdk 进行解析, 支持构造超级参数解析以及自动根据参数添加引用.
                                  默认是快速模式    
```

### Navigator 1.0

完整代码在 [example](https://github.com/fluttercandies/ff_annotation_route/tree/master/example) 中
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

```dart
  Navigator.pushNamed(context, Routes.fluttercandiesMainpage /* fluttercandies://mainpage */);
```

##### Push name with arguments

* 参数必须是一个 `Map<String, dynamic>`

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
* 开启 --super-arguments

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

### Navigator 2.0

完整代码在 [example1](https://github.com/fluttercandies/ff_annotation_route/tree/master/example1) 中
#### Main.dart

```dart
import 'dart:convert';
import 'package:example1/src/model/test_model.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'example1_route.dart';
import 'example1_routes.dart';

void main() {
  // 工具将处理简单的类型，但是没法处理全部的
  // 比如在浏览器中输入以下地址
  // http://localhost:64916/#flutterCandies://testPageF?list=[4,5,6]&map={"ddd":123}&testMode={"id":2,"isTest":true}
  // queryParameters 将会根据你自身的情况转换成你对应的类型
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
      // 初始化第一个页面
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

用在 Web 平台，当你在浏览器上面输入的时候路由配置转换成为[RouteSettings]，或者当反馈给浏览器的时候将[RouteSettings]转换成路由配置

举个例子:

`xxx?a=1&b=2` <=> `RouteSettings(name:'xxx',arguments:<String, dynamic>{'a':'1','b':'2'})`


#### FFRouterDelegate

用于创建和配置导航的委托，它提供 [Navigator] 中相似的方法.

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

你可以在 [test_page_c.dart](https://github.com/fluttercandies/ff_annotation_route/tree/master/example1/lib/src/pages/simple/test_page_c.dart) 页面里面找到更多的例子

#### Push

##### Push name

```dart
  FFRouterDelegate.of(context).pushNamed<void>(
    Routes.flutterCandiesTestPageA,
  );
```

##### Push name with arguments

* 参数必须是一个 `Map<String, dynamic>`

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
* 开启 --super-arguments

```dart
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
支持 Getx 的用法, 你只需要转换 `FFRouteSettings` 成为 `GetPageRoute`

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

#### 设置 GetPageRoute 的参数

比如：
'Bindings' 不是 const class, 所以它没法直接写在注解里面, 但是你可以这么做:

1. 把它定义在 `codes` 里面
2. 不要忘记添加对应的引用地址 `argumentImports`
3. 最后在 `onGenerateRoute` 中获取到它

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

#### 如何与 [functional_widget](https://github.com/rrousselGit/functional_widget) 一起使用？

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

[示例代码](example/lib/src/pages/func/func.dart) 可以在这里找到.


### Code Hints

你能这样使用路由 'Routes.flutterCandiesTestPageE', 并且在编辑器中看到代码提示。
包括页面描述，构造，参数类型，参数名字，参数是否必填。

* 默认

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

* 开启 --super-arguments

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

## 来杯可乐

![img](http://zmtzawqlp.gitee.io/my_images/images/qrcode.png)
