import 'package:ff_annotation_route/src/arg/args.dart';
import 'package:pub_cache/pub_cache.dart';

Type typeOf<T>() => T;
late PubCache _cache = PubCache();
String? _version;
String? get version {
  try {
    return _version ??=
        _cache.getLatestVersion('ff_annotation_route')?.version.toString();
  } catch (e) {
    return null;
  }
}

String get fileHeader {
  return '''// GENERATED CODE - DO NOT MODIFY MANUALLY
// **************************************************************************
// Auto generated by https://github.com/fluttercandies/ff_annotation_route 
// **************************************************************************
// fast mode: ${Args().isFastMode}${version != null ? '\n// version: $version' : ''}
// **************************************************************************
// ignore_for_file: prefer_const_literals_to_create_immutables,unused_local_variable,unused_import,unnecessary_import,unused_shown_name,implementation_imports,duplicate_import,library_private_types_in_public_api
''';
}

/// ignore_for_file: argument_type_not_assignable

const String rootFile = '''
/// Get route settings base on route name, auto generated by https://github.com/fluttercandies/ff_annotation_route 
FFRouteSettings getRouteSettings({
  {1} String name,
  Map<String, dynamic>{2} arguments,
  PageBuilder{2} notFoundPageBuilder,
}) {
  {3}    
  switch (name) {
{0}   default:
    return FFRouteSettings(
      name: FFRoute.notFoundName,
      routeName: FFRoute.notFoundRouteName,
      builder: notFoundPageBuilder??()=>Container(),
    );
  }
}
''';
