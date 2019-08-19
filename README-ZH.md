# ff_annotation_route

[![pub package](https://img.shields.io/pub/v/ff_annotation_route.svg)](https://pub.dartlang.org/packages/ff_annotation_route)

Language: [English](README.md) | [中文简体](README-ZH.md)


## 描述

通过注解快速完成路由映射.

- [ff_annotation_route](#ffannotationroute)
  - [描述](#%e6%8f%8f%e8%bf%b0)
  - [使用](#%e4%bd%bf%e7%94%a8)
    - [增加引用](#%e5%a2%9e%e5%8a%a0%e5%bc%95%e7%94%a8)
    - [添加注解](#%e6%b7%bb%e5%8a%a0%e6%b3%a8%e8%a7%a3)
      - [空构造](#%e7%a9%ba%e6%9e%84%e9%80%a0)
      - [带参数构造](#%e5%b8%a6%e5%8f%82%e6%95%b0%e6%9e%84%e9%80%a0)
      - [FFRoute](#ffroute)
    - [生成文件](#%e7%94%9f%e6%88%90%e6%96%87%e4%bb%b6)
      - [环境](#%e7%8e%af%e5%a2%83)
      - [激活](#%e6%bf%80%e6%b4%bb)
      - [执行命令](#%e6%89%a7%e8%a1%8c%e5%91%bd%e4%bb%a4)
      - [命令参数](#%e5%91%bd%e4%bb%a4%e5%8f%82%e6%95%b0)
    - [Main.dart](#maindart)

## 使用

### 增加引用

添加引用到dev_dependencies，你需要注解的project/packages的pubspec.yaml中
```yaml
dev_dependencies:
  ff_annotation_route: any
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

```dart
import 'package:ff_annotation_route/ff_annotation_route.dart';
@FFRoute(
    name: "fluttercandies://picswiper",
    routeName: "PicSwiper",
    argumentNames: ["index", "pics"],
    showStatusBar: false,
    pageRouteType: PageRouteType.transparent)
class PicSwiper extends StatefulWidget {
  final int index;
  final List<PicSwiperItem> pics;
  PicSwiper({this.index, this.pics});
        // ...
  }
```  
#### FFRoute

| parameter     | description                                  | default  |
| ------------- | -------------------------------------------- | -------- |
| name          | 路由的名字(e.g., "/settings").               | required |
| argumentNames | 路由的参数的名字                             | -        |
| showStatusBar | 是否显示状态栏                               | true     |
| routeName     | 用于埋点收集数据的页面名字                   | ''       |
| pageRouteType | 路由的类型(material, cupertino, transparent) | -        |



### 生成文件

#### 环境

添加dart的bin的路径到你的系统 `$PATH`.

`cache\dart-sdk\bin` 

[更多信息](https://dart.dev/tools/pub/cmd/pub-global)

不清楚的可以看[掘金](https://juejin.im/post/5d4b8959e51d4561df780555)

#### 激活

`pub global activate ff_annotation_route`


#### 执行命令

你可以到你的项目路径下面执行
`ff_annotation_route`

你也可以直接执行，并且带上你的项目路径
`ff_annotation_route path=`

#### 命令参数

使用 parameter=xxx, 使用空格隔开多个参数

| 参数                     | 描述                                                                                                                                                                                                       | 默认     |
| ------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| path                     | 你的项目路径                                                                                                                                                                                               | 当前路径 |
| checkEnable              | 是否检查 pubspec.yaml 中的'annotation_route_enable' . 如果你只想一部分模块扫描生成注解，你可以把这个参数设置为true，并且在对应的project/packages中的pubspec.yaml 加上 'annotation_route_enable: true' 节点 | false    |
| generateRouteNames       | 是否在根项目中的 xxx_route.dart 生成全部路由的名字                                                                                                                                                         | false    |
| mode                     | 0或者1, 模式1会生成 xxx_route_helper.dart 来帮助你处理 showStatusBar/routeName/pageRouteType                                                                                                               | 0        |
| routeSettingsNoArguments | 如果为true， FFRouteSettings 将没有arguments这个参数,这个是主要是为了适配Flutter低版本                                                                                                                     | false    |

### Main.dart

- 如果你设置命令带有参数 mode=1, FFNavigatorObserver/FFRouteSettings 将会生成 在 xxx_route_helper.dart
他们帮助追踪页面和设置状态栏.

-  如果你设置命令带有参数 mode=1,FFTransparentPageRoute 将会生成 在 xxx_route_helper.dart
它帮助push一个透明的PageRoute.

```dart
Widget build(BuildContext context) {
    return OKToast(
        child: MaterialApp(
      title: 'ff_annotation_route demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      navigatorObservers: [
        FFNavigatorObserver(routeChange: (name) {
          //you can track page here
          print(name);
        }, showStatusBarChange: (bool showStatusBar) {
          if (showStatusBar) {
            SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
            SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
          } else {
            SystemChrome.setEnabledSystemUIOverlays([]);
          }
        })
      ],
      builder: (c, w) {
        ScreenUtil.instance =
            ScreenUtil(width: 750, height: 1334, allowFontScaling: true)
              ..init(c);
        var data = MediaQuery.of(c);
        return MediaQuery(
          data: data.copyWith(textScaleFactor: 1.0),
          child: w,
        );
      },
      initialRoute: "fluttercandies://mainpage",
      onGenerateRoute: (RouteSettings settings) {
        var routeResult =
            getRouteResult(name: settings.name, arguments: settings.arguments);

        if (routeResult.showStatusBar != null ||
            routeResult.routeName != null) {
          settings = FFRouteSettings(
              arguments: settings.arguments,
              name: settings.name,
              isInitialRoute: settings.isInitialRoute,
              routeName: routeResult.routeName,
              showStatusBar: routeResult.showStatusBar);
        }

        var page = routeResult.widget ?? NoRoute();

        switch (routeResult.pageRouteType) {
          case PageRouteType.material:
            return MaterialPageRoute(settings: settings, builder: (c) => page);
          case PageRouteType.cupertino:
            return CupertinoPageRoute(settings: settings, builder: (c) => page);
          case PageRouteType.transparent:
            return FFTransparentPageRoute(
                settings: settings,
                pageBuilder: (BuildContext context, Animation<double> animation,
                        Animation<double> secondaryAnimation) =>
                    page);
          default:
            return Platform.isIOS
                ? CupertinoPageRoute(settings: settings, builder: (c) => page)
                : MaterialPageRoute(settings: settings, builder: (c) => page);
        }
      },
    ));
  }
```

[更多信息](https://github.com/fluttercandies/ff_annotation_route/blob/master/example/lib/main.dart)

