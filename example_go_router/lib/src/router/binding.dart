import 'package:example_go_router/src/router/external_link_helper.dart';
import 'package:example_go_router/src/router/navigator.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class ExternalLinkBinding extends WidgetsFlutterBinding {
  @override
  BinaryMessenger createBinaryMessenger() {
    return ExternalLinkBinaryMessenger(super.createBinaryMessenger());
  }
}

class ExternalLinkBinaryMessenger extends BinaryMessenger {
  ExternalLinkBinaryMessenger(this.original);
  final BinaryMessenger original;
  @override
  Future<void> handlePlatformMessage(
    String channel,
    ByteData? data,
    PlatformMessageResponseCallback? callback,
  ) {
    // ignore: deprecated_member_use
    return original.handlePlatformMessage(channel, data, callback);
  }

  @override
  Future<ByteData?>? send(String channel, ByteData? message) {
    return original.send(channel, message);
  }

  @override
  void setMessageHandler(String channel, MessageHandler? handler) {
    if (channel == SystemChannels.navigation.name) {
      Future<ByteData?>? newHandler(ByteData? message) async {
        final methodCall = SystemChannels.navigation.codec.decodeMethodCall(
          message,
        );
        // android
        // App Links (HTTPS)
        // adb shell am start -a android.intent.action.VIEW -d "https://fluttercandies.com/pageA?param=value"
        // Schemed Links (custom scheme)
        // adb shell am start -a android.intent.action.VIEW -d "fluttercandies://pageA?param=value"

        // iOS
        // Universal Links (HTTPS)
        // xcrun simctl openurl booted "https://fluttercandies.com/pageA?param=value"
        // Schemed Links (custom scheme)
        // xcrun simctl openurl booted "fluttercandies://pageA?param=value"

        ByteData? forwardedMessage = message;
        if (methodCall.method == 'pushRouteInformation') {
          final args = methodCall.arguments as Map?;
          final location = args?['location'] as String?;
          final state = args?['state'] as Object?;
          if (location != null) {
            // Try to handle external location and possibly forward a new
            // pushRouteInformation message back to the framework.
            Uri? uri = Uri.tryParse(location);
            if (uri != null) {
              // Main handler: parse -> whitelist -> intercept -> build forwarded message
              final parsed = ExternalLinkHelper().parseExternalLocation(uri);
              if (parsed == null) return null;

              if (!ExternalLinkHelper().isWhiteListed(parsed.routeName)) {
                return null;
              }

              final RouteInterceptResult? result = await AppNavigator()
                  .intercept(
                    parsed.routeName,
                    arguments: parsed.queryParameters,
                  );

              if (result == null) return null;

              // If interceptor returned arguments we try to append them as query params
              // when possible.
              if (result.arguments is Map<String, dynamic>) {
                final Map<String, String> qp = <String, String>{};
                (result.arguments as Map<String, dynamic>).forEach((k, v) {
                  qp[k.toString()] = v?.toString() ?? '';
                });
                forwardedMessage = _buildForwardedMessage(
                  result.routeName,
                  query: qp,
                  state: state,
                );
              } else {
                forwardedMessage = _buildForwardedMessage(
                  result.routeName,
                  state: state,
                );
              }
            }
          }
        }
        if (handler != null) {
          return handler(forwardedMessage);
        }
        return null;
      }

      original.setMessageHandler(channel, newHandler);
      return;
    }

    original.setMessageHandler(channel, handler);
  }

  /// Build a new pushRouteInformation ByteData from a route name and optional
  /// query params. Returns the encoded ByteData ready to be returned from the
  /// message handler.
  ByteData _buildForwardedMessage(
    String routeName, {
    Map<String, String>? query,
    Object? state,
  }) {
    // Build the location string manually using an encoded query portion.
    // Using `Uri(queryParameters: ...).query` ensures percent-encoding
    // (spaces -> %20) instead of any form-encoding that might use '+'.
    final String loc = query != null && query.isEmpty
        ? routeName
        : '$routeName?${Uri(queryParameters: query).query}';
    return SystemChannels.navigation.codec.encodeMethodCall(
      MethodCall('pushRouteInformation', {'location': loc, 'state': state}),
    );
  }
}
