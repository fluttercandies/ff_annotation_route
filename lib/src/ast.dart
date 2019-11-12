import 'dart:io' as io;

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:analyzer/src/generated/source.dart';
import 'package:analyzer/src/string_source.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/src/dart/scanner/reader.dart';
import 'package:analyzer/src/dart/scanner/scanner.dart';
import 'package:analyzer/src/error.dart';
import 'package:analyzer/src/file_system/file_system.dart';
import 'package:analyzer/src/generated/parser.dart';
import 'package:analyzer/src/generated/source_io.dart';
import 'package:path/path.dart' as pathos;

/// Parses a string of Dart code into an AST.
///
/// If [name] is passed, it's used in error messages as the name of the code
/// being parsed.
///
/// Throws an [AnalyzerErrorGroup] if any errors occurred, unless
/// [suppressErrors] is `true`, in which case any errors are discarded.
///
/// If [parseFunctionBodies] is [false] then only function signatures will be
/// parsed.
CompilationUnit parseCompilationUnit(
  String contents, {
  String name,
  bool suppressErrors = false,
  bool parseFunctionBodies = true,
  FeatureSet featureSet,
}) {
  featureSet ??= FeatureSet.fromEnableFlags([]);
  Source source = StringSource(contents, name);
  return _parseSource(contents, source, featureSet,
      suppressErrors: suppressErrors, parseFunctionBodies: parseFunctionBodies);
}

CompilationUnit parseDartFile(
  String path, {
  bool suppressErrors = false,
  bool parseFunctionBodies = true,
  FeatureSet featureSet,
}) {
  featureSet ??= FeatureSet.fromEnableFlags([]);
  final contents = io.File(path).readAsStringSync();
  final sourceFactory =
      SourceFactory([ResourceUriResolver(PhysicalResourceProvider.INSTANCE)]);

  final absolutePath = pathos.absolute(path);
  final source = sourceFactory.forUri(pathos.toUri(absolutePath).toString());
  if (source == null) {
    throw ArgumentError("Can't get source for path $path");
  }
  if (!source.exists()) {
    throw ArgumentError("Source $source doesn't exist");
  }

  return _parseSource(
    contents,
    source,
    featureSet,
    suppressErrors: suppressErrors,
    parseFunctionBodies: parseFunctionBodies,
  );
}

/// Parses a Dart file into an AST.
///
/// Throws an [AnalyzerErrorGroup] if any errors occurred, unless
/// [suppressErrors] is `true`, in which case any errors are discarded.
///
/// If [parseFunctionBodies] is [false] then only function signatures will be
/// parsed.
CompilationUnit _parseSource(
  String contents,
  Source source,
  FeatureSet featureSet, {
  bool suppressErrors = false,
  bool parseFunctionBodies = true,
}) {
  final reader = CharSequenceReader(contents);
  final errorCollector = _ErrorCollector();
  final scanner = Scanner(source, reader, errorCollector)
    ..configureFeatures(featureSet);
  final token = scanner.tokenize();
  final parser = Parser(source, errorCollector, featureSet: featureSet)
    ..parseFunctionBodies = parseFunctionBodies;
  final unit = parser.parseCompilationUnit(token)
    ..lineInfo = LineInfo(scanner.lineStarts);

  if (errorCollector.hasErrors && !suppressErrors) {
    throw errorCollector.group;
  }

  return unit;
}

class _ErrorCollector extends AnalysisErrorListener {
  final _errors = <AnalysisError>[];

  _ErrorCollector();

  /// The group of errors collected.
  AnalyzerErrorGroup get group =>
      AnalyzerErrorGroup.fromAnalysisErrors(_errors);

  /// Whether any errors where collected.
  bool get hasErrors => _errors.isNotEmpty;

  @override
  void onError(AnalysisError error) => _errors.add(error);
}
