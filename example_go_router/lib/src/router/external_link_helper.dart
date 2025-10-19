import 'package:example_go_router/example_go_router_routes.dart';

// A tiny helper to hold parse results.
class RouteParseResult {
  final String routeName;
  final Map<String, String> queryParameters;
  RouteParseResult(this.routeName, this.queryParameters);
}

class ExternalLinkHelper {
  factory ExternalLinkHelper() => _externalLinkHelper;
  ExternalLinkHelper._();
  static final ExternalLinkHelper _externalLinkHelper = ExternalLinkHelper._();

  final List<String> _allowedExternalDomains = <String>[
    'fluttercandies.com',
    'www.fluttercandies.com',
  ];

  // White list entries support:
  // - exact names: 'pageA' or '/pageA' or 'pageA/sub'
  // - prefix pattern with '*' suffix: 'group/*' matches 'group/foo', 'group/bar/baz'
  // Matching is case-insensitive.
  final List<String> _externalLinkWhiteList = <String>[
    // Fill with route keys, e.g. 'pageA' or 'group/*'
    Routes.pageA.name,
  ];

  /// Check whether a route (like '/PageA') is allowed by the white list.
  bool isWhiteListed(String routeName) {
    return _externalLinkWhiteList.contains(routeName);
  }

  /// Parse an external URL (custom scheme or https) into an internal route
  /// name (case preserved from generated `routeNames`) and query params.
  RouteParseResult? parseExternalLocation(Uri uri) {
    try {
      // For https/http links validate allowed domains and use the uri.path.
      // For custom schemes like `fluttercandies://pageA?param=value`, the
      // `host` often contains the page name; treat that as the path when
      // `uri.path` is empty.
      // http,https,fluttercandies
      if (uri.scheme.isEmpty) {
        return null;
      }
      String path = uri.path; // e.g. '/pageA' or '/PageA'
      if (uri.scheme == 'http' || uri.scheme == 'https') {
        // ensure the host is allowed
        final host = uri.host.toLowerCase();
        final allowed = _allowedExternalDomains
            .map((e) => e.toLowerCase())
            .toList();
        if (!allowed.contains(host)) return null;
      } else {
        // custom scheme: if path is empty but host contains something like
        // 'pageA', treat it as '/pageA'.
        if (uri.host.isNotEmpty) {
          path = '/${uri.host}$path';
        }
      }

      if (path.length > 1 && path.endsWith('/')) {
        path = path.substring(0, path.length - 1);
      }

      String? matched;
      if (routeNames.contains(path)) {
        matched = path;
      } else {
        final pathLower = path.toLowerCase();
        for (final r in routeNames) {
          final rl = r.toLowerCase();
          if (rl == pathLower) {
            matched = r; // preserve original casing from routeNames
            break;
          }
        }
      }

      if (matched == null) return null;

      return RouteParseResult(matched, uri.queryParameters);
    } catch (e) {
      return null;
    }
  }
}
