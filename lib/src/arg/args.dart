import 'const_ignore.dart';
import 'git.dart';
import 'help.dart';
import 'name.dart';
import 'output.dart';
import 'package.dart';
import 'path.dart';
import 'routes_file_output.dart';
import 'save.dart';
import 'super_arguments.dart';

class Args {
  factory Args() => args ??= Args._();
  Args._()
      : help = Help(),
        path = Path(),
        name = Name(),
        output = Output(),
        git = Git(),
        routesFileOutput = RoutesFileOutput(),
        constIgnore = ConstIgnore(),
        package = Package(),
        supperArguments = SupperArguments(),
        save = Save();
  static Args args;
  final Help help;
  final Path path;
  final Name name;
  final Output output;
  final Git git;
  final RoutesFileOutput routesFileOutput;
  final ConstIgnore constIgnore;
  final Package package;
  final SupperArguments supperArguments;
  final Save save;

  String get className => name.value;

  List<String> get gitNames => git.value;

  bool get isPackage => package.value;

  bool get enableSupperArguments => supperArguments.value;

  RegExp get constIgnoreRegExp =>
      constIgnore.value != null ? RegExp(constIgnore.value) : null;

  String get outputPath => output.value;

  String get routesFileOutputPath => routesFileOutput.value;
}
