import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:ff_annotation_route/src/route_info/route_info_base.dart';

class FileInfo {
  FileInfo({
    required this.packageName,
    required this.export,
  });

  final String packageName;
  final String export;
  final List<RouteInfoBase> routes = <RouteInfoBase>[];

  final Map<String, LibraryImportElement> importPrefixMap =
      <String, LibraryImportElement>{};
  static Set<String> imports = <String>{};

  final Map<DartType, String> typeImportPrefixMap = <DartType, String>{};

  String? parameterHasPrefixImport(
    ParameterElement parameter,
    ClassElement classElement,
  ) {
    if (parameter.defaultValueCode != null) {
      final String type =
          parameter.type.getDisplayString(withNullability: false);
      final String defaultValueCode = parameter.defaultValueCode!;
      for (final String prefix in importPrefixMap.keys) {
        final String prefixType = prefix + '.' + type;
        if (defaultValueCode.contains(prefixType) ||
            defaultValueCode.contains(' $prefixType')) {
          //print('dddd');
          return prefix;
        }
      }
    }

    // for (final FieldElement field in classElement.fields) {
    //   //print('dddd');
    // }

    return null;
  }

  String getTypeString(DartType type) {
    if (typeImportPrefixMap.containsKey(type)) {
      return '${typeImportPrefixMap[type]}.$type';
    }
    return '$type';
  }
}
