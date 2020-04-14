import 'dart:io' as io;

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer/source/line_info.dart';

// ignore: implementation_imports
import 'package:analyzer/src/generated/source.dart';

// ignore: implementation_imports
import 'package:analyzer/src/string_source.dart';

// ignore: implementation_imports
import 'package:analyzer/src/dart/scanner/reader.dart';

// ignore: implementation_imports
import 'package:analyzer/src/dart/scanner/scanner.dart';

// ignore: implementation_imports
import 'package:analyzer/src/error.dart';

// ignore: implementation_imports
import 'package:analyzer/src/file_system/file_system.dart';

// ignore: implementation_imports
import 'package:analyzer/src/generated/parser.dart';

// ignore: implementation_imports
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
  featureSet ??= FeatureSet.fromEnableFlags(<String>[]);
  final Source source = StringSource(contents, name);
  return _parseSource(contents, source, featureSet,
      suppressErrors: suppressErrors, parseFunctionBodies: parseFunctionBodies);
}

CompilationUnit parseDartFile(
  String path, {
  bool suppressErrors = false,
  bool parseFunctionBodies = true,
  FeatureSet featureSet,
}) {
  featureSet ??= FeatureSet.fromEnableFlags(<String>[]);
  final String contents = io.File(path).readAsStringSync();
  final SourceFactory sourceFactory =
      SourceFactory(<UriResolver>[ResourceUriResolver(PhysicalResourceProvider.INSTANCE)]);

  final String absolutePath = pathos.absolute(path);
  final Source source = sourceFactory.forUri(pathos.toUri(absolutePath).toString());
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
  final CharSequenceReader reader = CharSequenceReader(contents);
  final _ErrorCollector errorCollector = _ErrorCollector();
  final Scanner scanner = Scanner(source, reader, errorCollector)..configureFeatures(featureSet);
  final Token token = scanner.tokenize();
  final Parser parser = Parser(source, errorCollector, featureSet: featureSet)
    ..parseFunctionBodies = parseFunctionBodies;
  final CompilationUnit unit = parser.parseCompilationUnit(token)
    ..lineInfo = LineInfo(scanner.lineStarts);

  if (errorCollector.hasErrors && !suppressErrors) {
    throw errorCollector.group;
  }

  return unit;
}

class _ErrorCollector extends AnalysisErrorListener {
  _ErrorCollector();

  final List<AnalysisError> _errors = <AnalysisError>[];

  /// The group of errors collected.
  AnalyzerErrorGroup get group => AnalyzerErrorGroup.fromAnalysisErrors(_errors);

  /// Whether any errors where collected.
  bool get hasErrors => _errors.isNotEmpty;

  @override
  void onError(AnalysisError error) => _errors.add(error);
}
