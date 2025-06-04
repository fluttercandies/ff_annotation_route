import 'dart:io' as io show File;

import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart' show loadYaml;

/// The formatter will only use the tall-style if the SDK constraint is ^3.7.
DartFormatter _buildDartFormatter({
  required VersionConstraint? sdk,
  required int? pageWidth,
}) {
  final useShort = switch (sdk) {
    final c? => c.allowsAny(VersionConstraint.parse('<3.7.0')),
    _ => true,
  };
  return DartFormatter(
    languageVersion: useShort
        ? DartFormatter.latestShortStyleLanguageVersion
        : DartFormatter.latestLanguageVersion,
    pageWidth: pageWidth,
    lineEnding: '\n',
  );
}

String formatDart({
  required String content,
  required String directory,
}) {
  final (sdk, pageWidth) = _readConfig(directory);
  final formatter = _buildDartFormatter(sdk: sdk, pageWidth: pageWidth);
  return formatter.format(content);
}

(VersionConstraint? sdk, int? pageWidth) _readConfig(String directory) {
  final pubspecFile = io.File(p.join(directory, 'pubspec.yaml'));
  final pubspecSource = pubspecFile.existsSync()
      ? loadYaml(pubspecFile.readAsStringSync()) as Map?
      : null;
  final VersionConstraint? sdk;
  final rawSdk = pubspecSource?['environment']?['sdk'] as String?;
  if (rawSdk != null) {
    sdk = VersionConstraint.parse(rawSdk);
  } else {
    sdk = null;
  }

  final analysisFile = io.File(p.join(directory, 'analysis_options.yaml'));
  final analysisSource = analysisFile.existsSync()
      ? loadYaml(analysisFile.readAsStringSync()) as Map?
      : null;
  final pageWidth = analysisSource?['formatter']?['page_width'] as int?;
  return (sdk, pageWidth);
}
