# ff_annotation_route

[![pub package](https://img.shields.io/pub/v/ff_annotation_route.svg)](https://pub.dartlang.org/packages/ff_annotation_route) [![GitHub stars](https://img.shields.io/github/stars/fluttercandies/ff_annotation_route)](https://github.com/fluttercandies/ff_annotation_route/stargazers) [![GitHub forks](https://img.shields.io/github/forks/fluttercandies/ff_annotation_route)](https://github.com/fluttercandies/ff_annotation_route/network) [![GitHub license](https://img.shields.io/github/license/fluttercandies/ff_annotation_route)](https://github.com/fluttercandies/ff_annotation_route/blob/master/LICENSE) [![GitHub issues](https://img.shields.io/github/issues/fluttercandies/ff_annotation_route)](https://github.com/fluttercandies/ff_annotation_route/issues) <a href="https://qm.qq.com/q/ZyJbSVjfSU">![FlutterCandies QQ 群](https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Ffluttercandies%2F.github%2Frefs%2Fheads%2Fmain%2Fdata.yml&query=%24.qq_group_number&label=QQ%E7%BE%A4&logo=qq&color=1DACE8)

Languages: [English](README.md) | 中文简体

[掘金地址](https://juejin.im/post/5d5a7fe5f265da03b94ff42c)

## 描述

ff_annotation_route 是一个基于注解自动生成路由映射的 Flutter 解决方案。它不仅支持基础的 “路由名称 → Widget” 映射，还提供多导航支持（Navigator 1.0 / 2.0、GetX、GoRouter）、路由与全局拦截器、页面/弹窗生命周期、强类型参数辅助构造、深度链接与 Web Query 解析、嵌套路由、分组与排序（exts）、快速/完整两种构建模式，以及在多 package / monorepo 场景下的跨包扫描能力。

### 关键特性 (Key Features)
* 多导航模式：Navigator 1.0、Navigator 2.0、GetX、GoRouter
* 自动生成路由映射与强类型参数助手（支持 super 参数模式）
* 快速模式 vs 非快速模式：性能与智能的平衡
* 路由级与全局拦截器，扩展安全/登录/权限等场景
* 页面与弹窗生命周期：前后台、显示/隐藏、Route 显示/隐藏
* GetX Bindings 支持：通过 `codes` + 自动导入实现依赖注入
* 深度链接 / Web Query 自动解析，可自定义 `FFConvert.convert`
* 嵌套路由（Nested Router）支持多层级导航栈
* 多 package / git 扫描，支持排除与分组
* 透明 / Cupertino / Material RouteType 及灵活包装
* 提供扩展方法：`pushNamedWithInterceptor` 等

### 架构概览 (Architecture Overview)
1. 收集阶段：扫描指定路径/包中的注解元素（快速模式 = 单文件 AST；非快速模式 = 包 + SDK 解析）
2. 分析阶段：解析构造函数参数，推断必要 import（或使用 `@FFAutoImport`），生成参数 Map 构造辅助、codes 映射
3. 输出阶段：生成路由文件、常量、参数辅助类、供不同导航策略消费的 switch 映射

### 快速模式 vs 非快速模式 (Fast Mode vs Non-Fast Mode)
| 模式                         | 速度 | 导入推断                                       | Super 参数辅助 | 适用场景          |
| ---------------------------- | ---- | ---------------------------------------------- | -------------- | ----------------- |
| 快速模式(默认)               | 极快 | 需要手动 (`@FFAutoImport` / `argumentImports`) | 有限           | 频繁增量生成/CI   |
| 非快速模式(`--no-fast-mode`) | 较慢 | 自动推断 (构造参数类型)                        | 完整           | 首次接入/复杂泛型 |

### 嵌套路由示例 (Nested Router)
使用多个 `FFRouterDelegate` + `FFRouteInformationParser` 实例（如 Tab 内部再开 Router）并结合 `ChildBackButtonDispatcher` 管理系统返回事件。详见 `example1` 的 nested router demo。

### 拦截器与生命周期 (Interceptors & Lifecycle)
在 `@FFRoute(interceptors: [...])` 中声明路由级拦截器；通过 `RouteInterceptorManager().addGlobalInterceptors` 注册全局拦截器。生命周期 Mixin `RouteLifecycleState` 支持：`onPageShow/onPageHide/onForeground/onBackground/onRouteShow/onRouteHide`，同时适用于页面与对话框（依赖 `ExtendedRouteObserver`）。

### 深度链接与 Query 解析 (Deep Link & Query Parsing)
在 Web (Navigator 2.0) 下形如 `...?list=[1,2]&testMode={"id":2,"isTest":true}` 的查询字符串可通过自定义 `FFConvert.convert` 转换为强类型（如 List<int>、自定义 Model）。

### 多 Package / Monorepo 支持 (Monorepo / Multi-Package)
通过 `--git` 扫描工作区下的多个包，使用 `--exclude-packages` 排除不需要的包。生成跨包统一映射，保持边界清晰。

### 性能建议 (Performance Notes)
迭代/CI 使用快速模式；发布前或新增复杂类型与超级参数时用非快速模式校验导入与构造。

### 常见问题排查 (Troubleshooting)
* 构造参数类型导入缺失：添加 `@FFAutoImport()`、`argumentImports` 或使用非快速模式
* 拦截器不生效：确保使用扩展导航方法（如 `pushNamedWithInterceptor`）且包装未替换掉 settings
* 生命周期不触发：在 `navigatorObservers` 中添加 `ExtendedRouteObserver` 且页面继承 `RouteLifecycleState`
* Query 解析类型错误：扩展自定义 `FFConvert.convert`

更多中文深度解析请见：`技术文章-ff_annotation_route深度解析.md`

- [ff\_annotation\_route](#ff_annotation_route)
  - [描述](#描述)
    - [关键特性 (Key Features)](#关键特性-key-features)
    - [架构概览 (Architecture Overview)](#架构概览-architecture-overview)
    - [快速模式 vs 非快速模式 (Fast Mode vs Non-Fast Mode)](#快速模式-vs-非快速模式-fast-mode-vs-non-fast-mode)
    - [嵌套路由示例 (Nested Router)](#嵌套路由示例-nested-router)
    - [拦截器与生命周期 (Interceptors \& Lifecycle)](#拦截器与生命周期-interceptors--lifecycle)
    - [深度链接与 Query 解析 (Deep Link \& Query Parsing)](#深度链接与-query-解析-deep-link--query-parsing)
    - [多 Package / Monorepo 支持 (Monorepo / Multi-Package)](#多-package--monorepo-支持-monorepo--multi-package)
    - [性能建议 (Performance Notes)](#性能建议-performance-notes)
    - [常见问题排查 (Troubleshooting)](#常见问题排查-troubleshooting)
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
    - [GoRouter](#gorouter)
      - [如何使用 GoRouter](#如何使用-gorouter)
      - [GoRouter 特性](#gorouter-特性)
    - [GetX](#getx)
      - [How to use](#how-to-use)
      - [设置 GetPageRoute 的参数](#设置-getpageroute-的参数)
    - [路由扩展](#路由扩展)
      - [NavigatorWithInterceptor](#navigatorwithinterceptor)
      - [RouteLifecycleState](#routelifecyclestate)
    - [Functional Widget](#functional-widget)
      - [如何与 functional\_widget 一起使用？](#如何与-functional_widget-一起使用)
    - [Code Hints](#code-hints)
  - [我可以不用,但你必须要有](#我可以不用但你必须要有)
    - [Interceptor](#interceptor)
      - [Route Interceptor](#route-interceptor)
        - [实现 `RouteInterceptor`](#实现-routeinterceptor)
        - [添加注解 `interceptors`](#添加注解-interceptors)
        - [生成映射](#生成映射)
        - [完成配置](#完成配置)
      - [Global Interceptor](#global-interceptor)
        - [实现 RouteInterceptor](#实现-routeinterceptor-1)
        - [完成配置](#完成配置-1)
      - [跳转](#跳转)
    - [Lifecycle](#lifecycle)
      - [RouteLifecycleState](#routelifecyclestate-1)
      - [ExtendedRouteObserver](#extendedrouteobserver)
    - [GlobalNavigator](#globalnavigator)
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

工具会自动处理带参数的构造，不需要做特殊处理。唯一需要注意的是，你需要使用 `argumentImports` 为class/enum的参数提供 import 地址。现在你可以使用 `@FFAutoImport()` 来替代.

当然你现在可以选使用 `--no-fast-mode` 非快速模式进行解析，它会自动添加参数对应的引用。


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
  // 为了防止 @FFAutoImport() 不能完全表达的情况， 依然保留 argumentImports。
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

| Parameter       | Description                                                                                                                                                         | Default  |
| --------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| name            | 路由的名字 (e.g., "/settings")                                                                                                                                      | required |
| showStatusBar   | 是否显示状态栏                                                                                                                                                      | true     |
| routeName       | 用于埋点收集数据的页面名字                                                                                                                                          | ''       |
| pageRouteType   | 路由的类型 (material, cupertino, transparent)                                                                                                                       | -        |
| description     | 路由的描述                                                                                                                                                          | ''       |
| exts            | 其他扩展参数.                                                                                                                                                       | -        |
| argumentImports | 某些参数的导入.有一些参数是类或者枚举，需要指定它们的导入地址.现在你可以使用 @FFAutoImport()来替代                                                                  | -        |
| codes           | 有些代码无法直接写在注释里面, 你可以使用该参数，生成路由的时候会生成对应代码. [see](https://github.com/fluttercandies/ff_annotation_route/tree/master/example_getx) | -        |
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
  );
```

### GoRouter

完整代码在 [example_go_router](https://github.com/fluttercandies/ff_annotation_route/tree/master/example_go_router) 中

#### 如何使用 GoRouter

`ff_annotation_route` 与 [GoRouter](https://pub.dev/packages/go_router) 完美集成。工具会生成 `FFGoRouterRouteSettings` 用于 GoRouter。

```dart
import 'package:example_go_router/example_go_router_route.dart';
import 'package:example_go_router/example_go_router_routes.dart';
import 'package:go_router/go_router.dart';

GoRouter appGoRouter = GoRouter(
  initialLocation: Routes.indexHome.name,
  routes: [
    // 使用 StatefulShellRoute 实现状态保持的底部导航
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ShellContainer(navigationShell: navigationShell);
      },
      branches: goRouterRouteSettings
          .where((x) => x.name!.startsWith('/index/'))
          .map((settings) {
            return StatefulShellBranch(
              routes: [
                FFGoRoute(
                  settings: settings,
                  path: settings.name!,
                  pageBuilder: (context, state) {
                    return _pageBuilder(state, settings);
                  },
                ),
              ],
            );
          })
          .toList(),
    ),
    // 其他路由
    ...goRouterRouteSettings
        .where((r) => !r.name!.startsWith('/index/'))
        .map((settings) {
          return FFGoRoute(
            settings: settings,
            path: settings.name!,
            pageBuilder: (context, state) {
              return _pageBuilder(state, settings);
            },
          );
        }),
  ],
);
```

#### GoRouter 特性

- **StatefulShellRoute 支持**：使用 `IndexedStack` 实现状态保持的底部导航
- **路由生命周期**：`GoRouterRouteLifecycleService` 监控页面显示/隐藏和应用前台/后台
- **Deep Link 支持**：处理 Universal Links (HTTPS) 和自定义 scheme 链接，带白名单验证
- **路由拦截器**：支持路由级和全局拦截器
- **类型安全导航**：生成的路由常量带参数辅助方法

查看完整的 [example_go_router](https://github.com/fluttercandies/ff_annotation_route/tree/master/example_go_router) 了解高级用法，包括：
- 使用 `ExternalLinkBinding` 处理外部链接
- 自定义页面转场（Material、Cupertino、Transparent）
- 路由生命周期管理
- 使用 GetIt 进行依赖注入

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

### 路由扩展

完整代码在 [example_route_extension](https://github.com/fluttercandies/ff_annotation_route/tree/master/example_route_extension) 中

#### NavigatorWithInterceptor

`ff_annotation_route_library` 提供了带拦截器支持的导航扩展：

```dart
// 扩展方法
Navigator.of(context).pushNamedWithInterceptor(
  Routes.fluttercandiesPageA.name,
);

// 静态方法
NavigatorWithInterceptor.pushNamed(
  context,
  Routes.fluttercandiesPageB.name,
);
```

#### RouteLifecycleState

通过继承 `RouteLifecycleState` 轻松监测页面生命周期事件：

```dart
class _PageAState extends RouteLifecycleState<PageA> {
  @override
  void onPageShow() {
    print('PageA 现在可见了');
    // 刷新数据、恢复动画、埋点统计
  }

  @override
  void onPageHide() {
    print('PageA 现在隐藏了');
    // 暂停动画、保存状态
  }

  @override
  void onForeground() {
    print('应用回到前台');
    // 刷新实时数据
  }

  @override
  void onBackground() {
    print('应用进入后台');
    // 暂停任务、释放资源
  }
}
```

别忘了在 `MaterialApp` 中添加 `ExtendedRouteObserver`：

```dart
MaterialApp(
  navigatorObservers: <NavigatorObserver>[ExtendedRouteObserver()],
  // ...
)
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

## 我可以不用,但你必须要有

### Interceptor

#### Route Interceptor


##### 实现 `RouteInterceptor`
针对某个页面进行跳转拦截，根据你的场景实现 `RouteInterceptor`。

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

`RouteInterceptResult.complete` ，`RouteInterceptResult.next` 和 `RouteInterceptResult.abort` 对应的下面几种情况:  

``` dart
/// 表示路由拦截器在被调用后的可能动作
/// 这些动作在路由拦截过程中执行。
enum RouteInterceptAction {
  /// 停止拦截链并取消任何后续操作。
  /// 这表明当前拦截器已确定不应推送任何路由，
  /// 导航过程将被中止。
  abort,

  /// 转到链中的下一个拦截器。
  /// 这表明当前拦截器不想处理该路由，
  /// 并将决策委托给后续的拦截器。
  next,

  /// 完成拦截过程并允许推送路由。
  /// 这表明当前拦截器已处理该路由，
  /// 导航应按预期继续进行。
  complete,
}
``` 


##### 添加注解 `interceptors`

为页面增加 `interceptors` 拦截器注解

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

##### 生成映射

执行 `ff_route`, 生成拦截器映射

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

##### 完成配置

``` dart
void main() {
  RouteInterceptorManager().addAllRouteInterceptors(routeInterceptors);
  runApp(const MyApp());
}
``` 

#### Global Interceptor

如果你不想在注解里面增加拦截器，你可以选择使用全局的拦截器。

##### 实现 RouteInterceptor

你可以在这里根据你的场景进行编写逻辑

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

##### 完成配置

``` dart
void main() {
  RouteInterceptorManager().addGlobalInterceptors([
    const GlobalLoginInterceptor(),
    const GlobalPermissionInterceptor(),
  ]);
  runApp(const MyApp());
}
``` 

#### 跳转

1. 你可以利用 `NavigatorWithInterceptorExtension` 扩展，调用带有 `WithInterceptor` 的方法

``` dart
    Navigator.of(context).pushNamedWithInterceptor(
      Routes.fluttercandiesPageA.name,
    );
```

2. 调用 `NavigatorWithInterceptor` 的静态方法
   
``` dart
    NavigatorWithInterceptor.pushNamed(
      context,
      Routes.fluttercandiesPageB.name,
    );
```

### Lifecycle

#### RouteLifecycleState

通过继承 `RouteLifecycleState`，你可以方便的感知页面的各种状态。

只有当当前组件的承载是一个 `PageRoute`，才会触发 `onPageShow` 和 `onPageHide`。

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

[ExtendedRouteObserver] 是一个扩展 Flutter 内置 RouteObserver 功能的工具类。
它允许在导航栈中进行更高级的路由管理和跟踪。此类维护一个内部的活动路由列表，并提供
若干用于路由检查和操作的实用方法。

[ExtendedRouteObserver] 的主要特点：
- 跟踪导航栈中的所有活动路由。
- 通过 `topRoute` getter 提供对顶部路由的访问。
- 通过 `containsRoute()` 方法检查特定路由是否存在于栈中。
- 通过 `getRouteByName()` 方法根据名称检索路由。
- 通过 `onRouteAdded` 和 `onRouteRemoved` 通知订阅者路由的添加或删除。
- 通过 `onRouteAdd()` 和 `onRouteRemove()` 支持在路由添加或删除时执行自定义操作。

当需要全球路由跟踪或高级导航行为时，此类非常有用，例如：
- 监控当前活动的路由。
- 基于当前路由栈处理自定义导航逻辑。
- 实现导航历史记录功能或面包屑式导航。

通过利用此类，开发者可以更好地了解和控制应用的导航状态。

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


`context` 是 `Flutter` 中非常重要的一部分，涉及到很多关键的功能，比如主题、路由、依赖注入等。`Flutter` 的设计哲学是基于 `widget` 树的上下文传播，通过 `context` 来获取相关信息和功能，这样可以保持良好的组件分离和可维护性。

通过全局 `navigatorKey` 来直接访问 `Navigator` 或 `context`，虽然在某些特定情况下是可以的，但不建议在常规情况下使用，特别是当 `Flutter` 的推荐模式（如通过 `context`）能很好地处理问题时。

这种方式会带来一些潜在的问题：

1. 违背 `Flutter` 的设计理念：`Flutter` 的设计初衷是基于 `BuildContext` 的局部导航和状态管理，通过全局方式绕过 `context`，可能会导致状态管理混乱，难以维护。

2. 潜在的性能问题：全局访问 `context` 可能会绕过 `Flutter` 的优化机制，因为 `Flutter` 依赖于上下文树的结构来高效地更新 `UI`。

3. 可维护性差：依赖全局导航会使代码变得难以理解和维护，特别是在应用规模变大时，可能很难追踪导航的流向和状态。

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





## 来杯可乐

![img](http://zmtzawqlp.gitee.io/my_images/images/qrcode.png)
