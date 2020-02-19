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
