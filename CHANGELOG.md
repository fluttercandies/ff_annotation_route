## 2.0.3

- Breaking change
  Route instead of RouteSetting for RouteChange call back.
- Demo
  Track page only for PageRoute
  
## 2.0.2

- Fix error about -na, --no-arguments.
  
## 2.0.1

- Add more friendly prompt.

## 2.0.0

- Breaking change

Manage your Flutter app development with ff_annotation_route.

Activate:  `pub global activate ff_annotation_route `

Usage: `ff_route <command> [arguments]`

Available commands:

-h&#160;, --help&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;Print this usage information.

-p&#160;, --path [arguments]&#160;&#160;&#160;&#160;The path of folder to be executed with commands.

-rc, --route-constants&#160;&#160;&#160;&#160;&#160;&#160;&#160;Whether generate route names as constants.

-rh, --route-helper&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;Whether generate xxx_route_helper.dart

-rn, --route-names&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;Whether generate route names as a list.

-s&#160;, --save&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160; Whether save commands in local, it will read commands from local next time to execute if run "ff_route" without any commands.

-na, --no-arguments&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;Whether RouteSettings has arguments(for lower flutter sdk).

## 1.1.9

- Merge files from `1.1.8`.

## 1.1.8

- Fix NPE when `_didRouteChange` was called.
- Update `onGenerateRouteHelper`'s not found fallback.

## 1.1.7

- Fix route constants didn't generated for submodules.
- Generated routes will be sorted.
- Update parameter for `onGenerateRouteHelper`.
- Remove `showStatusBarChange` from `FFNavigatorObserver`.
- Improve code quality and remove redundant code.

## 1.1.6

- Add `onGenerateRouteHelper` to helper file instead of written in `MaterialApp`.

## 1.1.5

- Add const private constructor.

## 1.1.4

- Fix format failed.
- Fix demo error.

## 1.1.3+2

- Remove `_` while route constant was start with `/`, which will cause
  the constant unreachable.

## 1.1.3+1

- Remove the deprecated `author:` field from pubspec.yaml
- Update codes according to health suggestion.

## 1.1.3

- Add `generateRouteConstants` param to generate routes in `Routes` with
  constants.

## 1.1.2

- Format output files.

## 1.1.1

- Correct typos and formatted codes

## 1.1.0

- Fix null exception about dependencies

## 1.0.9

- Fix demo issue and update analyzer version

## 1.0.7

- Add description parameter for FFRoute

## 1.0.6

- Command "checkEnable" is obsolete now. only sacn the project/package which has dependency of "ff_annotation_route"

## 1.0.5

- Fix FFNavigatorObserver

## 1.0.4

- Public getFFRouteSettings

## 1.0.3

- Fix getRouteResult method error

## 1.0.2

- Correct analyzer version for flutter low sdk

## 1.0.1

- Correct analyzer version

## 1.0.0

- First Version
