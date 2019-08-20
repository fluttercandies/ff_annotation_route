# ff_annotation_route

[![pub package](https://img.shields.io/pub/v/ff_annotation_route.svg)](https://pub.dartlang.org/packages/ff_annotation_route)

Language: [English](README.md) | [中文简体](README-ZH.md)

## Description

Provide route generator to create route map quickly by annotations.

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
add packages to dev_dependencies in your project/packages's pubspec.yaml  
```yaml
dev_dependencies:
  ff_annotation_route: any
```

download with `flutter packages get` 

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
    pageRouteType: PageRouteType.transparent)
class PicSwiper extends StatefulWidget {
  final int index;
  final List<PicSwiperItem> pics;
  PicSwiper({this.index, this.pics});
        // ...
  }
```  
#### FFRoute

| parameter     | description                                              | default  |
| ------------- | -------------------------------------------------------- | -------- |
| name          | The name of the route (e.g., "/settings").               | required |
| argumentNames | The argument names passed to  FFRoute.                   | -        |
| showStatusBar | Whether show status bar.                                 | true     |
| routeName     | The route name to track page                             | ''       |
| pageRouteType | The type of page route(material, cupertino, transparent) | -        |



### Generate Route File

#### Environment

add dart bin into to your `$PATH`.

`cache\dart-sdk\bin` 

[`more info `](https://dart.dev/tools/pub/cmd/pub-global)


#### Activate

`pub global activate ff_annotation_route`


#### Execute command

you can cd to your project and exectue command.
`ff_annotation_route`

or you can exectue command with your project path
`ff_annotation_route path=`

#### Command Parameter

use as parameter=xxx, and use space to split them.

| parameter                | description                                                                                                                                                                          | default |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------- |
| path                     | The path of your project.                                                                                                                                                            | current |
| generateRouteNames       | Whether generate route names in xxx_route.dart at root project                                                                                                                       | false   |
| mode                     | 0 or 1, 1 will generate xxx_route_helper.dart to help you to handle showStatusBar/routeName/pageRouteType                                                                            | 0       |
| routeSettingsNoArguments | if true, FFRouteSettings(in xxx_route_helper.dart) has no arguments for low flutter sdk                                                                                              | false   |

### Main.dart

- if you exectue command with mode=1, FFNavigatorObserver/FFRouteSettings will generate in xxx_route_helper.dart
they help you to track page or change status bar state.

- if you exectue command with mode=1, FFTransparentPageRoute will generate in xxx_route_helper.dart
it helps you to push a transparent page route.

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

[more info](https://github.com/fluttercandies/ff_annotation_route/blob/master/example/lib/main.dart)

### Push

#### Push name

```dart
  Navigator.pushNamed(context, "fluttercandies://mainpage");
```

#### Push name with arguments

and arguments should be Map<String,dynamic>
```dart
   Navigator.pushNamed(context, "fluttercandies://picswiper",
                arguments: {
                  "index": index,
                  "pics": listSourceRepository
                      .map<PicSwiperItem>(
                          (f) => PicSwiperItem(f.imageUrl, des: f.title))
                      .toList(),
                });

```