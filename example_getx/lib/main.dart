import 'package:example_getx/example_getx_route.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';
import 'example_getx_routes.dart';
import 'package:get/get.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ff_annotation_route demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: Routes.fluttercandiesMainpage.name,
      onGenerateRoute: (RouteSettings settings) {
        FFRouteSettings ffRouteSettings = getRouteSettings(
          name: settings.name!,
          arguments: settings.arguments as Map<String, dynamic>?,
          notFoundPageBuilder: () => Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: Text('not find page'),
            ),
          ),
        );
        Bindings? binding;
        if (ffRouteSettings.codes != null) {
          binding = ffRouteSettings.codes!['binding'] as Bindings?;
        }

        Transition? transition;
        bool opaque = true;
        if (ffRouteSettings.pageRouteType != null) {
          switch (ffRouteSettings.pageRouteType) {
            case PageRouteType.cupertino:
              transition = Transition.cupertino;
              break;
            case PageRouteType.material:
              transition = Transition.downToUp;
              break;
            case PageRouteType.transparent:
              opaque = false;
              break;
            default:
          }
        }

        return GetPageRoute(
          binding: binding,
          opaque: opaque,
          settings: ffRouteSettings,
          transition: transition,
          page: () => ffRouteSettings.builder(),
        );
      },
    );
  }
}
