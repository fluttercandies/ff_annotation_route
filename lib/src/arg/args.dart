import 'package:ff_annotation_route/src/arg/arguments_case_sensitive.dart';
import 'package:ff_annotation_route/src/arg/null_safety.dart';

import 'const_ignore.dart';
import 'exclude_packages.dart';
import 'fast_mode.dart';
import 'git.dart';
import 'help.dart';
import 'name.dart';
import 'output.dart';
import 'package.dart';
import 'path.dart';
import 'routes_file_output.dart';
import 'save.dart';
import 'super_arguments.dart';
import 'package:path/path.dart' as path;

class Args {
  factory Args() => _args ??= Args._();

  Args._()
      : help = Help(),
        _path = Path(),
        name = Name(),
        output = Output(),
        git = Git(),
        excludePackages = ExcludePackages(),
        routesFileOutput = RoutesFileOutput(),
        constIgnore = ConstIgnore(),
        package = Package(),
        superArguments = SuperArguments(),
        save = Save(),
        nullSafety = NullSafety(),
        argumentsCaseSensitive = ArgumentsCaseSensitive(),
        fastMode = FastMode();
  static Args? _args;
  final Help help;
  final Path _path;
  final Name name;
  final Output output;
  final Git git;
  final ExcludePackages excludePackages;
  final RoutesFileOutput routesFileOutput;
  final ConstIgnore constIgnore;
  final Package package;
  final SuperArguments superArguments;
  final Save save;
  final NullSafety nullSafety;
  final ArgumentsCaseSensitive argumentsCaseSensitive;
  final FastMode fastMode;

  String get className => name.value!;

  List<String>? get gitNames => git.value;

  bool get isPackage => package.value!;

  bool get enableSuperArguments => superArguments.value!;

  RegExp? get constIgnoreRegExp =>
      constIgnore.value != null ? RegExp(constIgnore.value!) : null;

  String? get outputPath => output.value;

  List<String> get excludedPackagesName => excludePackages.value ?? <String>[];

  String? get routesFileOutputPath => routesFileOutput.value;

  bool get enableNullSafety => nullSafety.value!;

  bool get argumentsIsCaseSensitive => argumentsCaseSensitive.value!;

  bool get isFastMode => fastMode.value ?? false;

  String get pathUri =>
      _path.value == '.' ? path.current : _path.value ?? path.current;
}
