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
    - [Main.dart](#maindart)
    - [Push](#push)
      - [Push name](#push-name)
      - [Push name with arguments](#push-name-with-arguments)
      - [Code Hints](#code-hints)
  - [☕️Buy me a coffee](#️buy-me-a-coffee)

## 使用

### 增加引用

添加引用到`dev_dependencies`，及你需要注解的 project/packages 到`pubspec.yaml`中

```yaml
dev_dependencies:
  ff_annotation_route: latest-version
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

工具会自动处理带参数的构造，不需要做特殊处理。唯一需要注意的是，你需要使用 `argumentImports` 为class/enum的参数提供 import 地址。

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

| Parameter     | Description                                   | Default  |
| ------------- | --------------------------------------------- | -------- |
| name          | 路由的名字 (e.g., "/settings")               | required |
| showStatusBar | 是否显示状态栏                                | true     |
| routeName     | 用于埋点收集数据的页面名字                    | ''       |
| pageRouteType | 路由的类型 (material, cupertino, transparent) | -        |
| description   | 路由的描述                                    | ''       |
| exts          | 其他扩展参数.                                 | -        |
| argumentImports | 某些参数的导入.有一些参数是类或者枚举，需要指定它们的导入地址 | -        |

### 生成文件

#### 环境

添加 dart 的 bin 的路径到你的系统 `$PATH`.

`cache\dart-sdk\bin`

[更多信息](https://dart.dev/tools/pub/cmd/pub-global)

不清楚的可以看[掘金](https://juejin.im/post/5d4b8959e51d4561df780555)

#### 激活

`pub global activate ff_annotation_route`

#### 执行命令

到你的项目根目录下面执行.

`ff_route <command> [arguments]`

#### 命令参数

可用的命令:

| command name                | description                                                                        |
| --------------------------- | ---------------------------------------------------------------------------------- |
| -h, --help                  | 打印帮助信息.                                                                      |
| -p, --path [arguments]      | 执行命令的目录，没有就是当前目录.                                                  |
| -rc, --route-constants      | 是否在根项目中的 `xxx_route.dart` 生成全部路由的静态常量                           |
| -rh, --route-helper         | 生成 xxx_route_helper.dart 来帮助你处理路由                                        |
| -rn, --route-names          | 是否在根项目中的 `xxx_route.dart` 生成全部路由的名字                               |
| -s, --save                  | 是否保存命令到本地，如果保存了，下一次就只需要执行`ff_route`就可以了               |
| -na, --no-arguments         | FFRouteSettings 将没有 arguments 这个参数,这个是主要是为了适配 Flutter 低版本      |
| -g, --git package1,package2 | 是否扫描 git 引用的 package，你需要指定 package 的名字                             |
| --package                   | 这个是否是一个 package                                                             |
| --no-is-initial-route       | FFRouteSettings 将没有 isInitialRoute 这个参数,这个是主要是为了适配 Flutter 高版本 |
| -o --output                 | route和helper文件的输出目录路径，路径相对于主项目的lib文件夹                       |
| -rfo --routes-file-output   | routes 文件的输出目录路径，路径相对于主项目的lib文件夹                             |

### Main.dart

- 如果运行的命令带有参数 `--route-helper` , `FFNavigatorObserver/FFRouteSettings`
  将会生成在 `xxx_route_helper.dart` 中，用于协助追踪页面和设置状态栏。

- 如果运行的命令带有参数 `--route-helper` ，`FFTransparentPageRoute` 将会生成在
  `xxx_route_helper.dart` 中，可以使用它来 `push` 一个透明的 `PageRoute` 。

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

参数必须是一个 `Map<String, dynamic>`

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

#### Code Hints 

你能这样使用路由 'Routes.flutterCandiesTestPageE', 并且在编辑器中看到代码提示。
包括页面描述，构造，参数类型，参数名字，参数是否必填。

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

## ☕️Buy me a coffee

![img](http://zmtzawqlp.gitee.io/my_images/images/qrcode.png)
