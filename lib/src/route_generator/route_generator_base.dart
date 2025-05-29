import 'dart:io';

// ignore: implementation_imports
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:ff_annotation_route/src/arg/args.dart';
import 'package:ff_annotation_route/src/file_info.dart';
import 'package:ff_annotation_route/src/route_info/route_info_base.dart';
import 'package:ff_annotation_route/src/routes_file_generator.dart';
import 'package:ff_annotation_route/src/template.dart';
import 'package:ff_annotation_route/src/utils/convert.dart';
import 'package:ff_annotation_route/src/utils/dart_type_auto_import.dart';
import 'package:ff_annotation_route/src/utils/format.dart';
import 'package:ff_annotation_route/src/utils/git_package_handler.dart';
import 'package:path/path.dart' as path;

abstract class RouteGeneratorBase {
  RouteGeneratorBase({
    required this.packageName,
    required String packagePath,
    required this.isRoot,
  }) {
    final Directory lib = Directory(path.join(packagePath, 'lib'));
    if (lib.existsSync()) {
      _lib = GitPackageHandler().copyGitPackageToDartTool(lib, packageName);
    }
  }

  final List<FileInfo> _fileInfoList = <FileInfo>[];

  List<FileInfo> get fileInfoList => _fileInfoList;

  Directory? _lib;
  Directory? get lib => _lib;

  final String packageName;
  final bool isRoot;

  bool get hasAnnotationRoute => _lib != null && _fileInfoList.isNotEmpty;

  String get packageImport {
    String g = '';
    if (Args().gSuffix.value == true) {
      g = '.g';
    }
    return "import 'package:$packageName/${packageName}_route$g.dart';";
  }

  // get imports in root
  String get imports {
    if (_fileInfoList.isNotEmpty) {
      final StringBuffer sb = StringBuffer();

      _fileInfoList
          .sort((FileInfo a, FileInfo b) => a.export.compareTo(b.export));
      List<String> classNames = <String>[];
      int pageCount = 0;
      for (final FileInfo info in _fileInfoList) {
        if (isRoot) {
          classNames = <String>[];
        }
        String import = isRoot
            ? "import '${info.export}'"
            : packageImport.replaceRange(packageImport.length - 1, null, '');
        for (final RouteInfoBase route in info.routes) {
          if (route.classNameConflictPrefix != null) {
            sb.write('$import as ${route.classNameConflictPrefix};\n');
            classNames.add(route.className);
          }
          pageCount++;
        }

        if (isRoot) {
          if (classNames.length != info.routes.length || classNames.isEmpty) {
            if (classNames.isNotEmpty) {
              import += ' hide ';
              import += classNames.join(',');
            }
            sb.write('$import;\n');
          }
        }
      }
      if (!isRoot) {
        String import =
            packageImport.replaceRange(packageImport.length - 1, null, '');
        if (classNames.length != pageCount || classNames.isEmpty) {
          if (classNames.isNotEmpty) {
            import += ' hide ';
            import += classNames.join(',');
          }
          sb.write('$import;\n');
        }
      }
      return sb.toString();
    }
    return '';
  }

  // for package
  String get export {
    if (_fileInfoList.isNotEmpty) {
      assert(!isRoot);
      final StringBuffer sb = StringBuffer();

      sb.write('library ${packageName}_route;\n');

      _fileInfoList
          .sort((FileInfo a, FileInfo b) => a.export.compareTo(b.export));

      for (final FileInfo info in _fileInfoList) {
        sb.write("export '${info.export}';\n");
      }
      return sb.toString();
    }
    return '';
  }

  Future<void> scanLib({String? output, AnalysisContextCollection? collection});

  String funcName2ClassName(String funcName) {
    if (funcName.isNotEmpty && funcName[0] == '_') {
      funcName = funcName.substring(1);
    }
    return funcName.replaceFirstMapped(RegExp('[a-zA-Z]'), (Match match) {
      return match.group(0)!.toUpperCase();
    });
  }

  void generateFile({
    List<RouteGeneratorBase>? nodes,
  }) {
    final File file = deleteFile();
    if (isRoot && _fileInfoList.isEmpty && (nodes?.isEmpty ?? true)) {
      return;
    }

    final StringBuffer sb = StringBuffer();

    final List<RouteInfoBase> routes = _fileInfoList
        .map((FileInfo it) => it.routes)
        .expand((List<RouteInfoBase> it) => it)
        .toList();

    if (nodes != null && nodes.isNotEmpty) {
      routes.addAll(
        nodes
            .map((RouteGeneratorBase it) => it.fileInfoList)
            .expand((List<FileInfo> it) => it)
            .map((FileInfo it) => it.routes)
            .expand((List<RouteInfoBase> it) => it),
      );
    }
    routes.sort(
      (RouteInfoBase a, RouteInfoBase b) =>
          a.ffRoute.name.compareTo(b.ffRoute.name),
    );

    final Map<String, List<RouteInfoBase>> conflictClassNames =
        routes.groupListsBy((RouteInfoBase element) => element.className);

    for (final String key in conflictClassNames.keys) {
      final List<RouteInfoBase>? routes = conflictClassNames[key];
      // ClassName is conflict
      if (routes != null && routes.length > 1) {
        for (final RouteInfoBase route in routes) {
          route.classNameConflictPrefix =
              route.className.toLowerCase() + route.ffRoute.name.md5;
        }
      }
    }

    if (isRoot) {
      final Set<String> imports = <String>{};

      final StringBuffer caseSb = StringBuffer();

      /// Create route generator

      imports.add('import \'package:flutter/widgets.dart\';');
      imports.add(
        'import \'package:ff_annotation_route_library/ff_annotation_route_library.dart\';',
      );

      /// Nodes import
      ///
      if (nodes != null && nodes.isNotEmpty) {
        for (final RouteGeneratorBase node in nodes) {
          // add root imports
          imports.addAll(node.imports.split('\n'));
        }
      }

      // add root imports
      imports.addAll(this.imports.split('\n'));

      for (final RouteInfoBase it in routes) {
        caseSb.write(it.caseString);
        if (it.ffRoute.argumentImports != null &&
            it.ffRoute.argumentImports!.isNotEmpty) {
          imports.addAll(it.ffRoute.argumentImports!);
        }
      }
      imports.addAll(DartTypeAutoImportHelper().imports);
      imports.addAll(FileInfo.imports);
      writeImports(imports, sb);

      sb.write(rootFile
          .replaceAll('{0}', caseSb.toString())
          .replaceAll('{1}', Args().enableNullSafety ? 'required' : '@required')
          .replaceAll('{2}', Args().enableNullSafety ? '?' : '')
          .replaceAll(
              '{3}',
              Args().argumentsIsCaseSensitive
                  ? '''  final Map<String, dynamic> safeArguments =
      arguments ?? const <String, dynamic>{};'''
                  : '''  Map<String, dynamic> safeArguments = arguments ?? const <String, dynamic>{};
  if (arguments != null && arguments.isNotEmpty) {
    final Map<String, dynamic> ignoreCaseMap = <String, dynamic>{};
    safeArguments.forEach((String key, dynamic value) {
      ignoreCaseMap[key.toLowerCase()] = value;
    });
    safeArguments = ignoreCaseMap;
  }'''));
    } else {
      /// Export
      sb.write(export);
    }

    // this is root project or this is package
    if (isRoot || Args().isPackage) {
      RoutesFileGenerator(
        routes: routes,
        lib: _lib!,
        packageName: packageName,
      ).generateRoutesFile();
    }

    if (sb.isNotEmpty) {
      file.createSync(recursive: true);
      file.writeAsStringSync(formatDart(fileHeader + sb.toString()));
      print('Generate : ${path.relative(file.path, from: _lib!.parent.path)}');
    }
  }

  File deleteFile() {
    String g = '';
    if (Args().gSuffix.value == true) {
      g = '.g';
    }
    final String name = '${packageName}_route$g.dart';
    String routePath;
    if (isRoot && Args().outputPath != null) {
      routePath = path.join(_lib!.path, Args().outputPath, name);
    } else {
      routePath = path.join(_lib!.path, name);
    }

    final File file = File(routePath);
    if (file.existsSync()) {
      file.deleteSync();
    }
    return file;
  }
}
