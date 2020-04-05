# ff_annotation_route

[![pub package](https://img.shields.io/pub/v/ff_annotation_route.svg)](https://pub.dartlang.org/packages/ff_annotation_route) [![GitHub stars](https://img.shields.io/github/stars/fluttercandies/ff_annotation_route)](https://github.com/fluttercandies/ff_annotation_route/stargazers) [![GitHub forks](https://img.shields.io/github/forks/fluttercandies/ff_annotation_route)](https://github.com/fluttercandies/ff_annotation_route/network)  [![GitHub license](https://img.shields.io/github/license/fluttercandies/ff_annotation_route)](https://github.com/fluttercandies/ff_annotation_route/blob/master/LICENSE)  [![GitHub issues](https://img.shields.io/github/issues/fluttercandies/ff_annotation_route)](https://github.com/fluttercandies/ff_annotation_route/issues) <a target="_blank" href="https://jq.qq.com/?_wv=1027&k=5bcc0gy"><img border="0" src="https://pub.idqqimg.com/wpa/images/group.png" alt="flutter-candies" title="flutter-candies"></a>

Languages: [English](README.md) | [中文简体](README-ZH.md)

[掘金地址](https://juejin.im/post/5d5a7fe5f265da03b94ff42c)

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
    - [Push](#push)
      - [Push name](#push-name)
      - [Push name with arguments](#push-name-with-arguments)

## 使用

### 增加引用

添加引用到`dev_dependencies`，及你需要注解的project/packages到`pubspec.yaml`中
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

```dart
import 'package:ff_annotation_route/ff_annotation_route.dart';

@FFRoute(
  name: "fluttercandies://picswiper",
  routeName: "PicSwiper",
  argumentNames: ["index", "pics"],
  showStatusBar: false,
  pageRouteType: PageRouteType.transparent,
)
class PicSwiper extends StatefulWidget {
  final int index;
  final List<PicSwiperItem> pics;
  PicSwiper({this.index, this.pics});
  // ...
}
```  
#### FFRoute

| Parameter     | Description                                  | Default  |
| ------------- | -------------------------------------------- | -------- |
| name          | 路由的名字 (e.g., "/settings").                | required |
| argumentNames | 路由的参数的名字 (只能使用")                     | -        |
| showStatusBar | 是否显示状态栏                                 | true     |
| routeName     | 用于埋点收集数据的页面名字                       | ''       |
| pageRouteType | 路由的类型 (material, cupertino, transparent) | -        |
| description   | 路由的描述                                    | ''       |


### 生成文件

#### 环境

添加dart的bin的路径到你的系统 `$PATH`.

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

|  command name  | description  |
|  ----  | ----  |
| -h&#160;, --help  | 打印帮助信息. |
| -p&#160;, --path [arguments]  | 执行命令的目录，没有就是当前目录.
 |
|  -rc, --route-constants  | 是否在根项目中的 `xxx_route.dart` 生成全部路由的静态常量  |
|  -rh, --route-helper  | 生成 xxx_route_helper.dart 来帮助你处理路由  |
|  -rn, --route-names  | 是否在根项目中的 `xxx_route.dart` 生成全部路由的名字   |
|  -s&#160;, --save  | 是否保存命令到本地，如果保存了，下一次就只需要执行`ff_route`就可以了  |
|  -na, --no-arguments  | FFRouteSettings 将没有arguments这个参数,这个是主要是为了适配Flutter低版本  |
|  -g&#160;, --git package1,package2  | 是否扫描git引用的package，你需要指定package的名字  |
|  &#160;&#160;&#160;&#160;&#160;&#160; --package  | 这个是否是一个package  |
|  &#160;&#160;&#160;&#160;&#160;&#160; --no-is-initial-route   | FFRouteSettings 将没有isInitialRoute这个参数,这个是主要是为了适配Flutter高版本  |

### Main.dart

- 如果运行的命令带有参数 `--route-helper` , `FFNavigatorObserver/FFRouteSettings`
  将会生成在 `xxx_route_helper.dart` 中，用于协助追踪页面和设置状态栏。

- 如果运行的命令带有参数 `--route-helper` ，`FFTransparentPageRoute` 将会生成在
  `xxx_route_helper.dart` 中，可以使用它来 `push` 一个透明的 `PageRoute` 。

```dart
Widget build(BuildContext context) {
    return OKToast(
        child: MaterialApp(
      title: 'ff_annotation_route demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      navigatorObservers: [
        FFNavigatorObserver(routeChange:
            (RouteSettings newRouteSettings, RouteSettings oldRouteSettings) {
          //you can track page here
          print(
              "route change: ${oldRouteSettings?.name} => ${newRouteSettings?.name}");
          if (newRouteSettings is FFRouteSettings &&
              oldRouteSettings is FFRouteSettings) {
            if (newRouteSettings?.showStatusBar !=
                oldRouteSettings?.showStatusBar) {
              if (newRouteSettings?.showStatusBar == true) {
                SystemChrome.setEnabledSystemUIOverlays(
                    SystemUiOverlay.values);
                SystemChrome.setSystemUIOverlayStyle(
                    SystemUiOverlayStyle.dark);
              } else {
                SystemChrome.setEnabledSystemUIOverlays([]);
              }
            }
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
      initialRoute: Routes.FLUTTERCANDIES_MAINPAGE,// fluttercandies://mainpage
      onGenerateRoute: (RouteSettings settings) =>
          onGenerateRouteHelper(settings, notFoundFallback: NoRoute()),
    ),
  );
}
```

[更多信息](https://github.com/fluttercandies/ff_annotation_route/blob/master/example/lib/main.dart)

### Push

#### Push name

```dart
  Navigator.pushNamed(context, Routes.FLUTTERCANDIES_MAINPAGE /* fluttercandies://mainpage */);
```

#### Push name with arguments

参数必须是一个 `Map<String, dynamic>`
```dart
  Navigator.pushNamed(
    context,
    Routes.FLUTTERCANDIES_PICSWIPER, // fluttercandies://picswiper
    arguments: {
      "index": index,
      "pics": listSourceRepository
          .map<PicSwiperItem>((f) => PicSwiperItem(f.imageUrl, des: f.title))
          .toList(),
    },
  );
```