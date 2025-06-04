import 'dart:io' as io show Directory, File;

import 'package:io/ansi.dart';
import 'package:path/path.dart' as path;

import '/src/arg/args.dart';

class GitPackageHandler {
  factory GitPackageHandler() => _gitPackageHandler;

  GitPackageHandler._();

  static final GitPackageHandler _gitPackageHandler = GitPackageHandler._();

  String get tempPath => path.join('.dart_tool', 'ff_route');

  void _copyDirectory(io.Directory source, io.Directory destination) {
    for (final entity in source.listSync(recursive: false)) {
      if (entity is io.Directory) {
        final io.Directory newDirectory = io.Directory(
          path.join(destination.absolute.path, path.basename(entity.path)),
        );
        newDirectory.createSync();
        _copyDirectory(entity.absolute, newDirectory);
      } else if (entity is io.File) {
        entity.copySync(
          path.join(destination.path, path.basename(entity.path)),
        );
      }
    }
  }

  bool get hasGitPackage =>
      !Args().isFastMode &&
      Args().gitNames != null &&
      Args().gitNames!.isNotEmpty;

  final Map<String, String> gitPackageLibs = <String, String>{};

  io.Directory copyGitPackageToDartTool(
    io.Directory lib,
    String packageName,
  ) {
    if (hasGitPackage) {
      // copy to .dart_tool
      if (lib.path.contains(path.join('.pub-cache', 'git'))) {
        print(
          yellow.wrap('find git package $packageName at ${lib.parent.path}'),
        );

        final destination = io.Directory(
          path.join(Args().pathUri, tempPath, packageName),
        );
        print(
          yellow.wrap(
            'copy $packageName to ${path.join(tempPath, packageName)} before analyze.\n',
          ),
        );
        if (destination.existsSync()) {
          destination.deleteSync(recursive: true);
        }
        destination.createSync(recursive: true);
        _copyDirectory(lib.parent, destination);

        final destinationLib = io.Directory(path.join(destination.path, 'lib'));
        gitPackageLibs[destinationLib.path] = packageName;

        return destinationLib;
      }
    }
    return lib;
  }

  void deleteGitPackageFromDartTool() {
    if (hasGitPackage) {
      final destination = io.Directory(path.join(Args().pathUri, tempPath));
      if (destination.existsSync()) {
        destination.deleteSync(recursive: true);
      }
    }
  }

  String replaceUri(String uri) {
    if (hasGitPackage && uri.contains(tempPath)) {
      final String libPath = gitPackageLibs.keys.firstWhere(
        (String element) => uri.contains(element),
        orElse: () => '',
      );
      if (libPath.isNotEmpty) {
        final int index = uri.indexOf(libPath);
        if (index >= 0) {
          return 'package:${gitPackageLibs[libPath]}${uri.substring(index + libPath.length)}';
        }
      }
    }

    return uri;
  }
}
