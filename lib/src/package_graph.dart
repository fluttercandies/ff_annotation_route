import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:package_config/package_config.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

class PackageGraph {
  PackageGraph._(this.root, Map<String, PackageNode> allPackages)
    : allPackages = Map<String, PackageNode>.unmodifiable(allPackages);

  final PackageNode root;
  final Map<String, PackageNode> allPackages;

  static Future<PackageGraph> forPath(String packagePath) async {
    final String absolutePackagePath = p.canonicalize(packagePath);
    final YamlMap rootPubspec = _pubspecForPath(absolutePackagePath);
    final String? rootPackageName = rootPubspec['name'] as String?;
    if (rootPackageName == null) {
      throw StateError(
        'The current package has no name, please add one to the pubspec.yaml.',
      );
    }

    final _PackageConfigResult packageConfigResult = await _findPackageConfig(
      absolutePackagePath,
    );
    final Map<String, DependencyType> dependencyTypes = _parseDependencyTypes(
      packageConfigResult.rootDir,
    );

    final Map<String, PackageNode> nodes = <String, PackageNode>{};
    final List<Package> packages =
        packageConfigResult.config.packages.toList()
          ..sort((Package a, Package b) => a.name.compareTo(b.name));

    for (final Package package in packages) {
      nodes[package.name] = PackageNode(
        package.name,
        package.root.toFilePath(),
        dependencyTypes[package.name] ?? DependencyType.path,
        isRoot: package.name == rootPackageName,
      );
    }

    PackageNode packageNode(String package, {String? parent}) {
      final PackageNode? node = nodes[package];
      if (node == null) {
        throw StateError(
          'Dependency $package ${parent != null ? 'of $parent ' : ''}not '
          'present, please run `dart pub get` or `flutter pub get` to fetch '
          'dependencies.',
        );
      }
      return node;
    }

    final PackageNode rootNode = packageNode(rootPackageName);
    rootNode.dependencies.addAll(
      _depsFromYaml(rootPubspec, isRoot: true).map(
        (String name) => packageNode(name, parent: rootPackageName),
      ),
    );

    for (final Package package in packages) {
      if (package.name == rootPackageName) {
        continue;
      }
      final YamlMap pubspec = _pubspecForPath(package.root.toFilePath());
      packageNode(package.name).dependencies.addAll(
        _depsFromYaml(pubspec).map(
          (String name) => packageNode(name, parent: package.name),
        ),
      );
    }

    _ensureAnalyzerContext(rootNode.path);
    return PackageGraph._(rootNode, nodes);
  }
}

class PackageNode {
  PackageNode(
    this.name,
    String path,
    this.dependencyType, {
    this.isRoot = false,
  }) : path = p.canonicalize(path);

  final String name;
  final String path;
  final DependencyType dependencyType;
  final bool isRoot;
  final List<PackageNode> dependencies = <PackageNode>[];
}

enum DependencyType { github, path, hosted }

class _PackageConfigResult {
  const _PackageConfigResult(this.rootDir, this.config);

  final String rootDir;
  final PackageConfig config;
}

Future<_PackageConfigResult> _findPackageConfig(String packagePath) async {
  String rootDir = packagePath;
  while (true) {
    final PackageConfig? packageConfig = await findPackageConfig(
      Directory(rootDir),
      recurse: false,
    );
    if (packageConfig != null) {
      return _PackageConfigResult(rootDir, packageConfig);
    }
    final String next = p.dirname(rootDir);
    if (next == rootDir) {
      throw StateError(
        'Unable to find package config for package at $packagePath.',
      );
    }
    rootDir = next;
  }
}

Map<String, DependencyType> _parseDependencyTypes(String rootPackagePath) {
  final File pubspecLock = File(p.join(rootPackagePath, 'pubspec.lock'));
  if (!pubspecLock.existsSync()) {
    throw StateError(
      'Unable to generate package graph, no `pubspec.lock` found. '
      'This program must be ran from the root directory of your package.',
    );
  }
  final YamlMap dependencies =
      loadYaml(pubspecLock.readAsStringSync()) as YamlMap;
  final YamlMap packages = dependencies['packages'] as YamlMap;
  return <String, DependencyType>{
    for (final Object? packageName in packages.keys)
      packageName as String: _dependencyTypeFromSource(
        (packages[packageName] as YamlMap)['source'] as String,
      ),
  };
}

DependencyType _dependencyTypeFromSource(String source) {
  switch (source) {
    case 'git':
      return DependencyType.github;
    case 'hosted':
      return DependencyType.hosted;
    case 'path':
    case 'sdk':
      return DependencyType.path;
  }
  throw ArgumentError('Unable to determine dependency type:\n$source');
}

List<String> _depsFromYaml(YamlMap yaml, {bool isRoot = false}) {
  final Set<String> deps = <String>{
    ..._stringKeys(yaml['dependencies'] as Map?),
    if (isRoot) ..._stringKeys(yaml['dev_dependencies'] as Map?),
  };
  return deps.toList()..sort();
}

Iterable<String> _stringKeys(Map? map) =>
    map == null ? const <String>[] : map.keys.cast<String>();

YamlMap _pubspecForPath(String absolutePath) {
  final String pubspecPath = p.join(absolutePath, 'pubspec.yaml');
  final File pubspec = File(pubspecPath);
  if (!pubspec.existsSync()) {
    throw StateError(
      'Unable to generate package graph, no `$pubspecPath` found.',
    );
  }
  return loadYaml(pubspec.readAsStringSync()) as YamlMap;
}

void _ensureAnalyzerContext(String packagePath) {
  final String libPath = p.join(packagePath, 'lib');
  AnalysisContextCollection(
    includedPaths: <String>[
      Directory(libPath).existsSync() ? libPath : packagePath,
    ],
    resourceProvider: PhysicalResourceProvider.INSTANCE,
  );
}
