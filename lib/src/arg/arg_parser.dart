import 'package:args/args.dart';

import 'args.dart';

ArgParser parser = ArgParser();
late ArgResults argResults;
void parseArgs(List<String> args) {
  Args();
  argResults = parser.parse(args);
}
