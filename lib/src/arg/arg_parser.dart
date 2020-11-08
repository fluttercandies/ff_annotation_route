import 'package:args/args.dart';

final ArgParser parser = ArgParser();
ArgResults argResults;
void parseArgs(List<String> args) {
  argResults ??= parser.parse(args);
}
