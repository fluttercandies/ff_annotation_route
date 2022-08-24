## 9.3.1

* [functional_widget](https://github.com/rrousselGit/functional_widget) support ugly function name. (#39)

## 9.3.0

* Support [functional_widget](https://github.com/rrousselGit/functional_widget). (#38)

## 9.2.2

* Remove old command support.

## 9.2.1

* Support generate consts when it's a package.

## 9.2.0

* Support Flutter 3.

## 9.1.1

* Fix `--arguments-case-sensitive` is not working for constructorName

## 9.1.0

* Add `--arguments-case-sensitive` to support igore arguments case sensitive

## 9.0.2

* Fix multi constructor nullsafety error 

## 9.0.1

* Add unnecessary_import for generate files header

## 9.0.0

* Breaking change: use `FFRouteSettings.builder` instead of `FFRouteSettings.widget`
* Breaking change: use `FFPage.builder` instead of `FFPage.widget`
* Breaking change: use `notFoundPageBuilder` instead of `notFoundWidget` 
* Add `FFRoute.codes` to support something can't write in annotation
* Add GetX support

## 8.0.0

* Support Flutter 2.5.0, basically with the type alias support.
  Also, drop supports below Flutter 2.5.0 .
* Revert the `required` keyword extra handling since this fix has been addressed in the `analyzer`.
* De-duplicate all imports.
* Sort imports alphabetically.
* Brought `ignore_for_file` front.
* Apply trailing comma to safe/super arguments for the `require_trailing_commas` lint rule.
* Support fix class names conflict.
  (Do not use the same class name in one package, they can't be exported correctly.)
* Use constants value from core in the template.

## 7.0.3

* Fix typo (Supper => Super)
* Add notFoundWidget for Page is not found.

## 7.0.2

* Fix required annotation detect for inner fields.
* Fix not handled nullable type annotation in no null safety mode.

## 7.0.1

* Fix null operator check on git args.

## 7.0.0

* null-safety
  
## 6.0.2

* Fix `--null-safety` `!` error
* Add unused_local_variable

## 6.0.0

* Add `--null-safety` to support null-safety

## 5.1.1

* Fix Cannot remove from a fixed-length list
  
## 5.1.0

* Add @FFArgumentImport() instead of @FFRoute.argumentImports

## 5.0.1

* Fix uncomment debug arguments

## 5.0.0

* breaking change :

  remove --route-helper, it's ff_annotation_route_library in now.
  remove --no-is-initial-route
  remove --no-arguments
  remove --route-constants
  remove --route-names

* add Navigator 2.0 support

## 4.2.3

* Hide parameters.

## 4.2.2

* Add `name` parameter.

## 4.2.1

* fix the method `firstWhere` was called on null,gitNames is null

## 4.2.0

* add `--super-arguments` which generate page arguments helper class
* add `--const-ignore` is the regular to ignore some route consts

## 4.1.0

* use args to parse arguments

## 4.0.2

* remove dart:mirrors.

## 4.0.1

* remove duplicate and sort imports.

## 4.0.0

* Breaking change: remove 'argumentNames' and 'argumentTypes', they will be generated automatically.
* Support optional/positional argument.
* Supoort multiple constructors.
* Supoort const constructor.

## 3.4.2+1

* Solve format issue and dependencies upgrade.

## 3.4.2

* Consist transparent transition with `showDialog`.

## 3.4.1

* Improve optional arguments handle.

## 3.4.0

* Add WidgetBuilder for onGenerateRouteHelper.

## 3.3.2

* Capable with Flutter For the Web.

## 3.3.1

* Fix build error from [analyzer].

## 3.3.0

* Do better for quotation marks.

## 3.2.1

* Try catch DartFormatter.

## 3.2.0

* Change style of save commands.
* Add argumentTypes for FFRoute.
* Add name for RouteResult.

## 3.1.3

* Fix Map<String,dynamic> exts for FFRoute are not generated.

## 3.1.2

* Fix duplicate generate helper
* Fix generateRouteNames is not work

## 3.1.1

* Fix camelCase error of constants

## 3.1.0

* Use DartStyle to format dart code.
* Add **routes*file*output command for xxx_routes.dart(is relative to the lib directory)
* Breaking change
  Generate route names and route constant in single file(xxx_routes.dart)
  Route constants are following camelCase rule now(suggestion from Flutter Team)

## 2.1.0

* Fix command SettingsNoIsInitialRoute.
* Add Map<String,dynamic> exts for FFRoute

## 2.0.9

* Handle case that argumentNames: <String>['test', 'test1']
* Add 'ignore_for_file: argument_type_not_assignable' for route file.

## 2.0.8

* Update format in code and generated codes to match analyzer options.

## 2.0.7

* Add output command for root.

## 2.0.6+1

* Format readme.

## 2.0.6

* Fix issue about Save command for Git and Path commands.

## 2.0.5

* Change Git command(contains name to equal name)

## 2.0.4

* Add new command Git(Whether scan git lib,you should specify package names and split multiple by ',')
* Add new command Package(Is this a package.)
* Add new command SettingsNoIsInitialRoute(Whether RouteSettings has isInitialRoute(for higher flutter sdk).)

## 2.0.3

* Breaking change
  Route instead of RouteSetting for RouteChange call back.
* Demo
  Track page only for PageRoute

## 2.0.2

* Fix error about *na, **no*arguments.

## 2.0.1

* Add more friendly prompt.

## 2.0.0

* Breaking change

Manage your Flutter app development with ff_annotation_route.

Activate:  `pub global activate ff_annotation_route `

Usage: `ff_route <command> [arguments]`

Available commands:

*h&#160;, **help&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;Print this usage information.

*p&#160;, **path [arguments]&#160;&#160;&#160;&#160;The path of folder to be executed with commands.

*rc, **route*constants&#160;&#160;&#160;&#160;&#160;&#160;&#160;Whether generate route names as constants.

*rh, **route*helper&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;Whether generate xxx_route_helper.dart

*rn, **route*names&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;Whether generate route names as a list.

*s&#160;, **save&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160; Whether save commands in local, it will read commands from local next time to execute if run "ff_route" without any commands.

*na, **no*arguments&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;Whether RouteSettings has arguments(for lower flutter sdk).

## 1.1.9

* Merge files from `1.1.8`.

## 1.1.8

* Fix NPE when `_didRouteChange` was called.
* Update `onGenerateRouteHelper`'s not found fallback.

## 1.1.7

* Fix route constants didn't generated for submodules.
* Generated routes will be sorted.
* Update parameter for `onGenerateRouteHelper`.
* Remove `showStatusBarChange` from `FFNavigatorObserver`.
* Improve code quality and remove redundant code.

## 1.1.6

* Add `onGenerateRouteHelper` to helper file instead of written in `MaterialApp`.

## 1.1.5

* Add const private constructor.

## 1.1.4

* Fix format failed.
* Fix demo error.

## 1.1.3+2

* Remove `_` while route constant was start with `/`, which will cause
  the constant unreachable.

## 1.1.3+1

* Remove the deprecated `author:` field from pubspec.yaml
* Update codes according to health suggestion.

## 1.1.3

* Add `generateRouteConstants` param to generate routes in `Routes` with
  constants.

## 1.1.2

* Format output files.

## 1.1.1

* Correct typos and formatted codes

## 1.1.0

* Fix null exception about dependencies

## 1.0.9

* Fix demo issue and update analyzer version

## 1.0.7

* Add description parameter for FFRoute

## 1.0.6

* Command "checkEnable" is obsolete now. only sacn the project/package which has dependency of "ff_annotation_route"

## 1.0.5

* Fix FFNavigatorObserver

## 1.0.4

* Public getFFRouteSettings

## 1.0.3

* Fix getRouteResult method error

## 1.0.2

* Correct analyzer version for flutter low sdk

## 1.0.1

* Correct analyzer version

## 1.0.0

* First Version
