# ff_annotation_route

[![pub package](https://img.shields.io/pub/v/ff_annotation_route.svg)](https://pub.dartlang.org/packages/ff_annotation_route) [![GitHub stars](https://img.shields.io/github/stars/fluttercandies/ff_annotation_route)](https://github.com/fluttercandies/ff_annotation_route/stargazers) [![GitHub forks](https://img.shields.io/github/forks/fluttercandies/ff_annotation_route)](https://github.com/fluttercandies/ff_annotation_route/network)  [![GitHub license](https://img.shields.io/github/license/fluttercandies/ff_annotation_route)](https://github.com/fluttercandies/ff_annotation_route/blob/master/LICENSE)  [![GitHub issues](https://img.shields.io/github/issues/fluttercandies/ff_annotation_route)](https://github.com/fluttercandies/ff_annotation_route/issues) <a target="_blank" href="https://jq.qq.com/?_wv=1027&k=5bcc0gy"><img border="0" src="https://pub.idqqimg.com/wpa/images/group.png" alt="flutter-candies" title="flutter-candies"></a>

Languages: [English](README.md) | [中文简体](README-ZH.md)

## Description

Provide a route generator to create route map quickly by annotations.

- [ff_annotation_route](#ffannotationroute)
  - [Description](#description)
  - [Usage](#usage)
    - [Add packages to dev_dependencies](#add-packages-to-devdependencies)
    - [Add annotation](#add-annotation)
      - [Empty Constructor](#empty-constructor)
      - [Constructor with arguments](#constructor-with-arguments)
      - [FFRoute](#ffroute)
    - [Generate Route File](#generate-route-file)
      - [Environment](#environment)
      - [Activate](#activate)
      - [Execute command](#execute-command)
      - [Command Parameter](#command-parameter)
    - [Main.dart](#maindart)
    - [Push](#push)
      - [Push name](#push-name)
      - [Push name with arguments](#push-name-with-arguments)

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

| Parameter     | Description                                                          | Default  |
| ------------- | -------------------------------------------------------------------- | -------- |
| name          | The name of the route (e.g., "/settings").                           | required |
| argumentNames | Arguments name passed to `FFRoute`. Pass with double quote (") only. | -        |
| showStatusBar | Whether to show the status bar.                                      | true     |
| routeName     | The route name to track page.                                        | ''       |
| pageRouteType | The type of page route.(material, cupertino, transparent)            | -        |
| description   | The description of the route.                                        | ''       |


### Generate Route File

#### Environment

Add dart bin into to your `$PATH`.

`cache\dart-sdk\bin` 

[`More info`](https://dart.dev/tools/pub/cmd/pub-global)


#### Activate the plugin

`pub global activate ff_annotation_route`


#### Execute command

Go to your project's root path and execute command.
`ff_annotation_route`

Or you can execute command with your project path `ff_annotation_route
path=`

#### Command Parameter

Using with `parameter=xxx`, and use the space(` `) to split.

| Parameter                | Description                                                                                                       | Default |
| ------------------------ | ----------------------------------------------------------------------------------------------------------------- | ------- |
| path                     | The path of your project.                                                                                         | current |
| mode                     | `0` or `1`, `1` will generate xxx_route_helper.dart to help you to handle showStatusBar/routeName/pageRouteType   | 0       |
| generateRouteNames       | Whether to generate route names in `xxx_route.dart` at root project.                                              | false   |
| generateRouteConstants   | Whether to generate route constants in `xxx_route.dart` at root project, with a class named `Routes`.             | false   |
| routeSettingsNoArguments | if `true`, `FFRouteSettings(in xxx_route_helper.dart)` has no arguments for lower flutter sdk.                    | false   |

### Main.dart

- If you execute command with `mode=1`, `FFNavigatorObserver/FFRouteSettings` will generate in `xxx_route_helper.dart`
which help you to track page or change status bar state.

- If you execute command with `mode=1`, `FFTransparentPageRoute` will generate in `xxx_route_helper.dart`
which helps you to push a transparent page route.

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

[More info](https://github.com/fluttercandies/ff_annotation_route/blob/master/example/lib/main.dart)

### Push

#### Push name

```dart
  Navigator.pushNamed(context, Routes.FLUTTERCANDIES_MAINPAGE /* fluttercandies://mainpage */);
```

#### Push name with arguments

`arguments` **MUST** be a `Map<String, dynamic>`
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